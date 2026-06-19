import 'dart:math';

int miningCalculateReward(
  int totalEffectiveBalance, {
  int effectiveBalance = 32000000000,
  double baseRewardsPerEpoch = 1,
  double baseRewardFactor = 1,
}) {
  // sqrt(total_effective_balance)
  final double sqrtTotal = sqrt(totalEffectiveBalance);

  // reward = (effective_balance * base_reward_factor) /
  //          (sqrt(total_effective_balance) * base_rewards_per_epoch)
  final double reward =
      (effectiveBalance * baseRewardFactor) / (sqrtTotal * baseRewardsPerEpoch);
  return reward.toInt();
}
