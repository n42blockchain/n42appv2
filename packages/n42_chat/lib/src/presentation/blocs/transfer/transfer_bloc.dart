import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/transfer_entity.dart';
import '../../../domain/repositories/transfer_repository.dart';
import '../../../integration/wallet_bridge.dart';
import '../bloc_message_keys.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';
import '../../../core/utils/debug_log.dart';

/// 转账BLoC
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final ITransferRepository _transferRepository;
  final IWalletBridge _walletBridge;

  TransferBloc(this._transferRepository, this._walletBridge)
      : super(const TransferState.initial()) {
    on<LoadWalletInfo>(_onLoadWalletInfo);
    on<LoadTokens>(_onLoadTokens);
    on<LoadTokenBalance>(_onLoadTokenBalance);
    on<InitiateTransfer>(_onInitiateTransfer);
    on<CreatePaymentRequest>(_onCreatePaymentRequest);
    on<FulfillPaymentRequest>(_onFulfillPaymentRequest);
    on<ValidateAddress>(_onValidateAddress);
    on<ClearTransferState>(_onClearTransferState);
  }

  Future<void> _onLoadWalletInfo(
    LoadWalletInfo event,
    Emitter<TransferState> emit,
  ) async {
    try {
      final isConnected = _walletBridge.isWalletConnected;
      final walletAddress = _walletBridge.walletAddress;
      final tokens = await _walletBridge.getSupportedTokens();

      // 加载所有代币余额
      final balances = <String, String>{};
      for (final token in tokens) {
        try {
          balances[token.symbol] = await _walletBridge.getBalance(token.symbol);
        } catch (e) {
          balances[token.symbol] = '0';
        }
      }

      emit(state.copyWith(
        status: TransferBlocStatus.walletLoaded,
        isWalletConnected: isConnected,
        walletAddress: walletAddress,
        tokens: tokens,
        balances: balances,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransferBlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTokens(
    LoadTokens event,
    Emitter<TransferState> emit,
  ) async {
    if (state.status == TransferBlocStatus.initial) {
      add(const LoadWalletInfo());
      return;
    }

    try {
      final tokens = await _transferRepository.getSupportedTokens();
      emit(state.copyWith(tokens: tokens));
    } catch (e) {
      emit(state.copyWith(
        status: TransferBlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTokenBalance(
    LoadTokenBalance event,
    Emitter<TransferState> emit,
  ) async {
    try {
      final balance = await _transferRepository.getTokenBalance(event.token);
      final newBalances = Map<String, String>.from(state.balances);
      newBalances[event.token] = balance;
      emit(state.copyWith(balances: newBalances));
    } catch (e) {
      // 忽略余额加载错误
      debugLog('Error: $e');
    }
  }

  Future<void> _onInitiateTransfer(
    InitiateTransfer event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(
      status: TransferBlocStatus.processing,
      processingMessage: BlocMessageKeys.transferProcessing,
    ));

    try {
      final transfer = await _transferRepository.initiateTransfer(
        roomId: event.roomId,
        receiverAddress: event.receiverAddress,
        amount: event.amount,
        token: event.token,
        memo: event.memo,
      );

      if (transfer.isSuccess) {
        emit(state.copyWith(
          status: TransferBlocStatus.success,
          lastTransfer: transfer,
        ));
      } else if (transfer.status == TransferStatus.cancelled) {
        emit(state.copyWith(
          status: TransferBlocStatus.failure,
          errorMessage: BlocMessageKeys.transferCancelled,
        ));
      } else {
        emit(state.copyWith(
          status: TransferBlocStatus.failure,
          errorMessage: transfer.failureReason ?? BlocMessageKeys.transferFailed,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransferBlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreatePaymentRequest(
    CreatePaymentRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(
      status: TransferBlocStatus.processing,
      processingMessage: BlocMessageKeys.paymentProcessing,
    ));

    try {
      final request = await _transferRepository.createPaymentRequest(
        amount: event.amount,
        token: event.token,
        memo: event.memo,
      );

      // 发送收款请求消息
      await _transferRepository.sendPaymentRequestMessage(
        roomId: event.roomId,
        request: request,
      );

      emit(state.copyWith(
        status: TransferBlocStatus.paymentCreated,
        paymentRequest: request,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransferBlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFulfillPaymentRequest(
    FulfillPaymentRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(
      status: TransferBlocStatus.processing,
      processingMessage: BlocMessageKeys.paymentProcessing,
    ));

    try {
      final transfer = await _transferRepository.fulfillPaymentRequest(
        roomId: event.roomId,
        requestId: event.requestId,
        receiverAddress: event.receiverAddress,
        amount: event.amount,
        token: event.token,
      );

      if (transfer.isSuccess) {
        emit(state.copyWith(
          status: TransferBlocStatus.success,
          lastTransfer: transfer,
        ));
      } else {
        emit(state.copyWith(
          status: TransferBlocStatus.failure,
          errorMessage: transfer.failureReason ?? BlocMessageKeys.paymentFailed,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransferBlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onValidateAddress(
    ValidateAddress event,
    Emitter<TransferState> emit,
  ) async {
    final isValid = _transferRepository.isValidAddress(event.address);

    WalletUserInfo? userInfo;
    if (isValid) {
      userInfo = await _walletBridge.getUserInfoByAddress(event.address);
    }

    emit(state.copyWith(
      status: TransferBlocStatus.addressValidated,
      validatedAddress: event.address,
      isAddressValid: isValid,
      userInfo: userInfo,
    ));
  }

  void _onClearTransferState(
    ClearTransferState event,
    Emitter<TransferState> emit,
  ) {
    add(const LoadWalletInfo());
  }
}
