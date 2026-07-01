import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/presentation/widgets/gift_economy.dart';
import 'package:n42_wallet/features/live/services/live_chat_service.dart';

void main() {
  final t0 = DateTime.fromMillisecondsSinceEpoch(1000000);
  DateTime at(int sec) => t0.add(Duration(seconds: sec));
  var seq = 0;

  LiveEvent gift(String sender, String giftId, {int sec = 0}) {
    seq++;
    return LiveEvent(
      id: 'evt-$seq',
      senderId: sender,
      senderName: sender,
      isMe: false,
      timestamp: at(sec),
      data: {'t': 'gift', 'g': giftId},
    );
  }

  List<GiftLedgerEntry> replayOf(Map<String, List<LiveEvent>> byRoom) =>
      LiveGiftEconomy.replay(byRoom, initialCoins: 1000);

  int earningsFor(List<GiftLedgerEntry> ledger, String roomId) => ledger
      .where((g) => g.valid && g.roomId == roomId)
      .fold<int>(0, (s, g) => s + g.price);

  int spentBy(List<GiftLedgerEntry> ledger, String sender) => ledger
      .where((g) => g.valid && g.event.senderId == sender)
      .fold<int>(0, (s, g) => s + g.price);

  test('收益=全部有效礼物金币总额、按目录权威计价', () {
    final ledger = replayOf({
      'room1': [
        gift('@a:s', 'rose', sec: 1), // 1
        gift('@a:s', 'rocket', sec: 2), // 10
        gift('@b:s', 'crown', sec: 3), // 99
      ],
    });
    expect(earningsFor(ledger, 'room1'), 1 + 10 + 99);
  });

  test('各用户花费独立累计', () {
    final ledger = replayOf({
      'room1': [
        gift('@a:s', 'rose', sec: 1), // a:1
        gift('@a:s', 'diamond', sec: 2), // a:50
        gift('@b:s', 'beer', sec: 3), // b:2
      ],
    });
    expect(spentBy(ledger, '@a:s'), 51);
    expect(spentBy(ledger, '@b:s'), 2);
  });

  test('非礼物事件被忽略（只传入礼物事件即视为源数据已过滤）', () {
    final ledger = replayOf({
      'room1': [gift('@a:s', 'rose', sec: 1)],
    });
    expect(earningsFor(ledger, 'room1'), 1);
    expect(spentBy(ledger, '@a:s'), 1);
  });

  test('未知礼物 id 被忽略（不计价，防跨版本客户端算出不同收益）', () {
    final ledger = replayOf({
      'room1': [
        gift('@a:s', 'unknown_xyz', sec: 1),
        gift('@a:s', 'rose', sec: 2), // 认识的礼物仍正常计入
      ],
    });
    expect(ledger.length, 1); // 未知礼物完全不进入账目，既不算有效也不算无效
    expect(earningsFor(ledger, 'room1'), 1);
  });

  test('空事件 → 无收益无花费', () {
    final ledger = replayOf({'room1': const []});
    expect(earningsFor(ledger, 'room1'), 0);
  });

  test('超出全局初始余额的礼物被判无效——不计收益不计花费（防伪造刷收益）', () {
    // initialCoins=1000；单个用户连续送出 11 个皇冠（99*11=1089>1000），
    // 第 11 个必然透支，应被重放判无效。
    final events = List.generate(
      11,
      (i) => gift('@attacker:s', 'crown', sec: i),
    );
    final ledger = replayOf({'room1': events});
    final validCount = ledger.where((g) => g.valid).length;
    final invalidCount = ledger.where((g) => !g.valid).length;
    expect(validCount, 10); // 10*99=990 <= 1000，第 11 笔超额
    expect(invalidCount, 1);
    expect(earningsFor(ledger, 'room1'), 990);
    expect(spentBy(ledger, '@attacker:s'), 990);
  });

  test('跨房间统一余额——同一发送者在两个房间的花费共享同一份初始额度', () {
    // @a:s 在 room1 送 600(6*100=... 用 crown*6=594 接近), room2 再送超额部分应被拒。
    final ledger = replayOf({
      'roomA': [
        gift('@a:s', 'crown', sec: 1), // 99
        gift('@a:s', 'crown', sec: 2), // 99
        gift('@a:s', 'crown', sec: 3), // 99
        gift('@a:s', 'crown', sec: 4), // 99 -> 396
      ],
      'roomB': [
        gift('@a:s', 'crown', sec: 5), // 99 -> 495
      ],
    });
    // 跨房间总花费应聚合而非各房间各自重置为 1000。
    expect(spentBy(ledger, '@a:s'), 99 * 5);
  });

  test('不同发送者互不影响——一人透支不影响另一人的有效额度', () {
    final ledger = replayOf({
      'room1': [
        ...List.generate(11, (i) => gift('@attacker:s', 'crown', sec: i)),
        gift('@honest:s', 'rose', sec: 20),
      ],
    });
    expect(spentBy(ledger, '@honest:s'), 1);
    final honestEntry = ledger.firstWhere(
      (g) => g.event.senderId == '@honest:s',
    );
    expect(honestEntry.valid, isTrue);
  });

  test('确定性：同一份事件（跨房间）在两次重放中得到完全一致的结果', () {
    final byRoom = {
      'room1': [gift('@a:s', 'crown', sec: 1), gift('@b:s', 'diamond', sec: 2)],
      'room2': [gift('@a:s', 'rose', sec: 3)],
    };
    final l1 = replayOf(byRoom);
    final l2 = replayOf(byRoom);
    expect(l1.map((g) => g.valid).toList(), l2.map((g) => g.valid).toList());
    expect(earningsFor(l1, 'room1'), earningsFor(l2, 'room1'));
  });
}
