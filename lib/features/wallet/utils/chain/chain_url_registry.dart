import 'configs/chain_url_configs_part1.dart';
import 'configs/chain_url_configs_part2.dart';
import 'configs/chain_url_configs_part3.dart';
import 'configs/chain_url_configs_part4.dart';
import 'configs/chain_url_configs_part5.dart';

Map<String, dynamic> allChainUrlMap = <String, dynamic>{
  ...chainUrlConfigsPart1,
  ...chainUrlConfigsPart2,
  ...chainUrlConfigsPart3,
  ...chainUrlConfigsPart4,
  ...chainUrlConfigsPart5,
};
