import 'dart:async';
import 'package:n42_wallet/features/mining/services/mining_channel.dart';

class MiningBackground{
  final MiningChannel _channel = MiningChannel();

  void backgroundStart() {
    unawaited(_channel.liveActivityStart());
  }
  void backgroundEnd() {
    unawaited(_channel.liveActivityEnd(0));
  }
}
