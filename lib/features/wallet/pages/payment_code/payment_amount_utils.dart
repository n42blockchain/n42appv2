double calculatePaymentTokenAmount({
  required double fiatAmount,
  required double tokenPriceUsd,
}) {
  if (!fiatAmount.isFinite || fiatAmount <= 0) return 0;
  if (!tokenPriceUsd.isFinite || tokenPriceUsd <= 0) return fiatAmount;
  return fiatAmount / tokenPriceUsd;
}
