const int kStakingRedeemUtxoPageSize = 10;
const int kStakingRedeemUtxoPageNum = 1;

int? parseStakingLockupSeconds(String? lockupDays) {
  final days = double.tryParse(lockupDays?.trim() ?? '');
  if (days == null || !days.isFinite || days <= 0) return null;
  return (days * 86400).round();
}
