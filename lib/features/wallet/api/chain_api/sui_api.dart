import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Sui chain access through the official GraphQL API.
///
/// Public fullnodes answer every JSON-RPC method with -32601 ("JSON-RPC on
/// public fullnodes has been deprecated"), so reads, simulation and execution
/// go through the Sui GraphQL service. Transaction bytes and signatures are
/// produced exactly as before; only the transport changed.
class SuiApi {
  /// GraphQL endpoint, configured like the other chain URLs ('graphql').
  String url = "";

  /// Optional transport (tests); defaults to the shared HTTP client.
  final Future<dynamic> Function(String url, Map<String, dynamic> body)? post;
  SuiApi({bool isTest = false, this.post}) {
    url = RequestUrl().getUrl2(CoinType.SUI.name, "graphql", isTest: isTest);
  }

  static const balanceQuery = r'''
query SuiBalance($owner: SuiAddress!) {
  address(address: $owner) {
    balance(coinType: "0x2::sui::SUI") {
      totalBalance
    }
  }
}''';

  static const gasPriceQuery = r'''
query SuiReferenceGasPrice {
  epoch {
    referenceGasPrice
  }
}''';

  /// 50 is the service's maximum page size for Address.objects.
  static const coinsQuery = r'''
query SuiCoins($owner: SuiAddress!, $after: String) {
  address(address: $owner) {
    objects(
      first: 50
      after: $after
      filter: {type: "0x2::coin::Coin<0x2::sui::SUI>"}
    ) {
      pageInfo {
        hasNextPage
        endCursor
      }
      nodes {
        address
        version
        digest
        contents {
          json
        }
      }
    }
  }
}''';

  static const simulateQuery = r'''
query SuiSimulate($transaction: JSON!) {
  simulateTransaction(transaction: $transaction) {
    effects {
      status
      executionError {
        message
      }
      gasEffects {
        gasSummary {
          computationCost
          storageCost
          storageRebate
        }
      }
    }
  }
}''';

  static const executeMutation = r'''
mutation SuiExecute($transactionDataBcs: Base64!, $signatures: [Base64!]!) {
  executeTransaction(
    transactionDataBcs: $transactionDataBcs
    signatures: $signatures
  ) {
    effects {
      digest
      status
      executionError {
        message
      }
      checkpoint {
        sequenceNumber
      }
    }
  }
}''';

  static const transactionQuery = r'''
query SuiTransaction($digest: String!) {
  transaction(digest: $digest) {
    digest
    sender {
      address
    }
    effects {
      digest
      status
      executionError {
        message
      }
      checkpoint {
        sequenceNumber
      }
    }
  }
}''';

  static final _decimal = RegExp(r'^[0-9]+$');

  /// A non-negative integer from a GraphQL BigInt (decimal string) or UInt53
  /// (JSON number); anything else is rejected.
  static BigInt? amount(Object? value) {
    if (value is String && _decimal.hasMatch(value)) return BigInt.parse(value);
    if (value is int && value >= 0) return BigInt.from(value);
    return null;
  }

  static Object? field(Object? value, List<String> path) {
    for (final key in path) {
      if (value is! Map) return null;
      value = value[key];
    }
    return value;
  }

  static bool isDigest(Object? value) {
    if (value is! String) return false;
    try {
      final bytes = Base58Decode(value);
      return bytes.length == 32 && Base58Encode(bytes) == value;
    } catch (_) {
      return false;
    }
  }

  Future<MessageModel> getBalanceSui(String address) async {
    final rmm = resultToMessageModel(
      await graphQL(balanceQuery, {'owner': address}),
    );
    if (rmm.error) return rmm;
    // An unused address reports "0"; a missing balance is not proof of an
    // empty account.
    final total = amount(
      field(rmm.data, ['address', 'balance', 'totalBalance']),
    );
    if (total == null) {
      return MessageModel.error()..data = 'Invalid Sui balance response';
    }
    return MessageModel()..data = total;
  }

  Future<MessageModel> getGasPriceSui() async {
    final rmm = resultToMessageModel(await graphQL(gasPriceQuery, const {}));
    if (rmm.error) return rmm;
    final price = amount(field(rmm.data, ['epoch', 'referenceGasPrice']));
    if (price == null) {
      return MessageModel.error()..data = 'Invalid Sui gas price response';
    }
    return MessageModel()..data = price;
  }

  /// Every SUI coin object owned by [address], in the shape the send code and
  /// the native signers consume: `{'data': {'objectId', 'version' (decimal
  /// string), 'digest', 'content': {'fields': {'balance'}}}}`. A malformed or
  /// incomplete page yields an empty list, never a partial selection.
  Future<List<dynamic>> getOwnedObjects(String address) async {
    final objects = <dynamic>[];
    final cursors = <String>{};
    String? cursor;
    while (true) {
      final response = resultToMessageModel(
        await graphQL(coinsQuery, {'owner': address, 'after': cursor}),
      );
      final page = field(response.data, ['address', 'objects']);
      final nodes = field(page, ['nodes']);
      final hasNext = field(page, ['pageInfo', 'hasNextPage']);
      if (response.error || nodes is! List || hasNext is! bool) return [];
      for (final node in nodes) {
        final id = field(node, ['address']);
        final version = amount(field(node, ['version']));
        final digest = field(node, ['digest']);
        final balance = amount(field(node, ['contents', 'json', 'balance']));
        if (id is! String ||
            id.isEmpty ||
            version == null ||
            digest is! String ||
            digest.isEmpty ||
            balance == null) {
          return [];
        }
        objects.add({
          'data': {
            'objectId': id,
            'version': version.toString(),
            'digest': digest,
            'content': {
              'fields': {'balance': balance.toString()},
            },
          },
        });
      }
      if (!hasNext) return objects;
      final next = field(page, ['pageInfo', 'endCursor']);
      if (next is! String || next.isEmpty || !cursors.add(next)) return [];
      cursor = next;
    }
  }

  /// Simulate base64 BCS TransactionData (no signature needed) and return
  /// its net gas cost. Only a SUCCESS simulation yields an estimate.
  Future<MessageModel> dryRunTransactionBlock(String transactionBcs) async {
    final rmm = resultToMessageModel(
      await graphQL(simulateQuery, {
        'transaction': {
          'bcs': {'value': transactionBcs},
        },
      }),
    );
    if (rmm.error) return rmm;
    final effects = field(rmm.data, ['simulateTransaction', 'effects']);
    final gas = field(effects, ['gasEffects', 'gasSummary']);
    if (field(effects, ['status']) != 'SUCCESS' || gas is! Map) {
      return MessageModel.error()
        ..data = _withReason('Sui simulation was not successful', effects);
    }
    final computation = amount(gas['computationCost']);
    final storage = amount(gas['storageCost']);
    final rebate = amount(gas['storageRebate']);
    if (computation == null || storage == null || rebate == null) {
      return MessageModel.error()..data = 'Invalid Sui simulation gas usage';
    }
    final net = computation + storage - rebate;
    return MessageModel()..data = net.isNegative ? BigInt.zero : net;
  }

  /// Execute signed transaction bytes; retries are explicitly disabled to
  /// avoid a double submission. Success requires effects that name a
  /// well-formed digest and report SUCCESS. Anything else (GraphQL errors,
  /// FAILURE, missing or malformed effects) is an error the caller treats as
  /// an unknown outcome. On success `data` is `{'digest', 'effects'}`.
  Future<MessageModel> submit(String transactionBlock, String signStr) async {
    final response = resultToMessageModel(
      await graphQL(executeMutation, {
        'transactionDataBcs': transactionBlock,
        'signatures': [signStr],
      }, enableRetry: false),
    );
    if (response.error) return response;
    final effects = field(response.data, ['executeTransaction', 'effects']);
    final digest = field(effects, ['digest']);
    if (!isDigest(digest) || field(effects, ['status']) != 'SUCCESS') {
      return MessageModel.error()
        ..data = _withReason(
          'Sui transaction execution was not confirmed',
          effects,
        );
    }
    return MessageModel()..data = {'digest': digest, 'effects': effects};
  }

  /// Read one transaction with its sender and effects. `data` is the
  /// `transaction` object, or null when the service does not know the
  /// digest (never executed, not yet indexed, or pruned).
  Future<MessageModel> getTransactionBlock(String txHash) async {
    final rmm = resultToMessageModel(
      await graphQL(transactionQuery, {'digest': txHash}),
    );
    if (rmm.error) return rmm;
    final data = rmm.data;
    if (data is! Map || !data.containsKey('transaction')) {
      return MessageModel.error()..data = 'Invalid Sui transaction response';
    }
    return MessageModel()..data = data['transaction'];
  }

  static String _withReason(String message, Object? effects) {
    final reason = field(effects, ['executionError', 'message']);
    return reason is String && reason.isNotEmpty
        ? '$message: $reason'
        : message;
  }

  /// One GraphQL request. A reply carrying `errors` is a failure even when
  /// partial data came back; a reply without a `data` object is a failure.
  Future<Result<dynamic, AppError>> graphQL(
    String document,
    Map<String, dynamic> variables, {
    bool enableRetry = true,
  }) async {
    try {
      final body = <String, dynamic>{'query': document, 'variables': variables};
      final reply = post != null
          ? await post!(url, body)
          : await BaseApi.requestEmptyH.post(
              url,
              params: {},
              data: body,
              enableRetry: enableRetry,
            );
      final errors = reply is Map ? reply['errors'] : null;
      if (errors is List && errors.isNotEmpty) {
        final message = field(errors.first, ['message']);
        return Result.failure(
          AppError.blockchain(
            message is String && message.isNotEmpty
                ? message
                : 'Sui GraphQL error',
            code: 'SUI_GRAPHQL_ERROR',
            originalError: errors,
          ),
        );
      }
      final data = reply is Map ? reply['data'] : null;
      if (data is! Map) {
        return Result.failure(
          AppError.blockchain(
            'Invalid Sui GraphQL response',
            code: 'SUI_GRAPHQL_ERROR',
            originalError: reply,
          ),
        );
      }
      return Result.success(data);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(
        AppError.network(e.toString(), originalError: e, stackTrace: st),
      );
    }
  }
}
