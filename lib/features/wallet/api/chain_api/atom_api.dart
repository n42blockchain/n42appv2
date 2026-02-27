import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/models/message_model.dart';

class AtomApi {
  static const Map<String, String> _jsonHeader = {'Content-Type': 'application/json'};

  String _uri() => RequestUrl().getUrl2(CoinType.ATOM.name, 'api', isTest: false);

  Future<MessageModel> getBalance(String address, String token) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_uri()}cosmos/bank/v1beta1/balances/$address',
        params: {},
        defaultReturn: false,
        header: _jsonHeader,
      );
      final List<dynamic> balances = data['balances'];
      final denom = token == '' ? 'uatom' : token;
      BigInt balance = BigInt.zero;
      for (final b in balances) {
        if ((b as Map<String, dynamic>)['denom'] == denom) {
          balance = BigInt.parse(b['amount'].toString());
          break;
        }
      }
      return MessageModel()..data = balance;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  //cosmos/auth/v1beta1/accounts/
  Future<MessageModel> getAccounts(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_uri()}cosmos/auth/v1beta1/accounts/$address',
        params: {},
        defaultReturn: false,
        header: _jsonHeader,
      );
      return MessageModel()..data = data['account'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  //cosmos/bank/v1beta1/denoms_metadata/
  Future<MessageModel> getMetadata(String denom) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_uri()}cosmos/bank/v1beta1/denoms_metadata/$denom',
        params: {},
        defaultReturn: false,
        header: _jsonHeader,
      );
      return MessageModel()..data = data['metadata'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  //cosmos/tx/v1beta1/txs/
  Future<MessageModel> getTxs(String txHash) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_uri()}cosmos/tx/v1beta1/txs/$txHash',
        params: {},
        defaultReturn: false,
        header: _jsonHeader,
      );
      return MessageModel()..data = data['metadata'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  //cosmos/tx/v1beta1/txs
  Future<MessageModel> sendTxs(dynamic rawTx) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_uri()}cosmos/tx/v1beta1/txs',
        params: {},
        data: {'tx_bytes': rawTx, 'mode': 'BROADCAST_MODE_SYNC'},
        defaultReturn: false,
        header: _jsonHeader,
      );
      final mm = MessageModel();
      mm.data = data['tx_response'] == null ? data['message'] : data['tx_response']['txhash'];
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  //cosmos/tx/v1beta1/simulate
  Future<MessageModel> sendTxsSimulate(dynamic rawTx) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_uri()}cosmos/tx/v1beta1/simulate',
        params: {},
        data: {'tx_bytes': rawTx, 'mode': 'BROADCAST_MODE_SYNC'},
        defaultReturn: false,
        header: _jsonHeader,
      );
      final mm = MessageModel();
      mm.data = data['tx_response'] == null ? data['message'] : data['tx_response']['txhash'];
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  /*
  * {
            "state": "STATE_OPEN",
            "ordering": "ORDER_ORDERED",
            "counterparty": {
                "port_id": "icahost",
                "channel_id": "channel-4672"
            },
            "connection_hops": [
                "connection-809"
            ],
            "version": "{\"version\":\"ics27-1\",\"controller_connection_id\":\"connection-809\",\"host_connection_id\":\"connection-0\",\"address\":\"neutron1u5gaalvlg2nr5spaxuvxuhx69yx05xfs0lnxjeuezq53px9au9esfrhj7t\",\"encoding\":\"proto3\",\"tx_type\":\"sdk_multi_msg\"}",
            "port_id": "icacontroller-cosmos10d07y265gmmuvt4z0w9aw880jnsr700j6zn9kn",
            "channel_id": "channel-914",
            "upgrade_sequence": "0"
        },
        * state: 通道的状态，通常是 STATE_OPEN（开放状态）或 STATE_CLOSED（关闭状态）。
ordering: 表示通道的消息传递顺序，ORDER_UNORDERED 表示不要求顺序，ORDER_ORDERED 表示要求顺序。
counterparty: 目标链的信息，包括：
port_id: 目标链上的端口名称（例如 cosmos.osmosis）。
channel_id: 目标链上对应的通道 ID（例如 channel-1）。
connection_hops: 连接跳跃，表示通道之间的连接路径。
version: IBC 协议的版本，通常会标明使用的版本号（如 ics20-1）。
        * */
  ///ibc/core/channel/v1/channels
  Future<MessageModel> getChannels() async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_uri()}ibc/core/channel/v1/channels',
        params: {},
        defaultReturn: false,
        header: _jsonHeader,
      );
      return MessageModel()..data = data['channels'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }
}
