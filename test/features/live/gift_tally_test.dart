import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/presentation/widgets/gift_economy.dart';
import 'package:n42_wallet/features/live/services/live_chat_service.dart';

void main() {
  final t = DateTime.fromMillisecondsSinceEpoch(0);

  LiveEvent gift(String sender, String giftId) => LiveEvent(
    id: '$sender-$giftId-${giftId.hashCode}',
    senderId: sender,
    senderName: sender,
    isMe: false,
    timestamp: t,
    data: {'t': 'gift', 'g': giftId},
  );

  test('收益=全部礼物金币总额、按目录权威计价', () {
    final tally = GiftTally.of([
      gift('@a:s', 'rose'), // 1
      gift('@a:s', 'rocket'), // 10
      gift('@b:s', 'crown'), // 99
    ]);
    expect(tally.earnings, 1 + 10 + 99);
  });

  test('各用户花费独立累计', () {
    final tally = GiftTally.of([
      gift('@a:s', 'rose'), // a:1
      gift('@a:s', 'diamond'), // a:50
      gift('@b:s', 'beer'), // b:2
    ]);
    expect(tally.spent['@a:s'], 51);
    expect(tally.spent['@b:s'], 2);
  });

  test('非礼物事件被忽略', () {
    final pred = LiveEvent(
      id: 'p1',
      senderId: '@a:s',
      senderName: 'a',
      isMe: false,
      timestamp: t,
      data: {'t': 'pred', 'a': 'create'},
    );
    final tally = GiftTally.of([pred, gift('@a:s', 'rose')]);
    expect(tally.earnings, 1);
    expect(tally.spent.containsKey('@a:s'), isTrue);
    expect(tally.spent['@a:s'], 1);
  });

  test('未知礼物 id 计价回退为 1（不当 0，防伪造低价）', () {
    final tally = GiftTally.of([gift('@a:s', 'unknown_xyz')]);
    expect(tally.earnings, 1);
  });

  test('空事件 → 收益 0、无花费', () {
    final tally = GiftTally.of([]);
    expect(tally.earnings, 0);
    expect(tally.spent, isEmpty);
  });
}
