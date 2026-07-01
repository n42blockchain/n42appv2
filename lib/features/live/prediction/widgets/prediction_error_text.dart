import 'package:flutter/widgets.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../domain/prediction_repository.dart';

/// 把预测市场业务异常 [PredictionException] 映射到本地化文案；
/// 非业务异常回退原始字符串。
String predictionErrorText(BuildContext context, Object e) {
  if (e is! PredictionException) return '$e';
  final s = S.of(context);
  return switch (e.error) {
    PredictionError.tooFewOutcomes => s.g_pred_err_outcomes,
    PredictionError.invalidOutcome => s.g_pred_err_invalid_outcome,
    PredictionError.marketClosed => s.g_pred_err_market_closed,
    PredictionError.amountTooLow => s.g_pred_err_amount_low,
    PredictionError.insufficientBalance => s.g_pred_err_insufficient_balance,
    PredictionError.slippage => s.g_pred_err_slippage,
    PredictionError.insufficientShares => s.g_pred_err_insufficient_shares,
    PredictionError.notResolved => s.g_pred_err_not_resolved,
    PredictionError.marketNotFound => s.g_pred_err_market_not_found,
    PredictionError.invalidState => s.g_pred_err_invalid_state,
    PredictionError.notResolver => s.g_pred_err_not_resolver,
  };
}
