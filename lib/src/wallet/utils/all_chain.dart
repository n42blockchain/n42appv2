import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'chain_data_part1.dart';
import 'chain_data_part2.dart';
import 'chain_data_part3.dart';
import 'chain_data_part4.dart';
import 'chain_data_part5.dart';

Map<String, dynamic> allChainUrlMap = <String, dynamic>{
  ...chainDataPart1,
  ...chainDataPart2,
  ...chainDataPart3,
  ...chainDataPart4,
  ...chainDataPart5,
};
