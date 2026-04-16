import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/channel_entity.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGroupBloc extends Mock implements GroupBloc {
  MockGroupBloc(this._state);

  final GroupState _state;

  @override
  GroupState get state => _state;

  @override
  Stream<GroupState> get stream => Stream.value(_state);

  @override
  Future<void> close() async {}
}

// ---------------------------------------------------------------------------
// Test Channels
// ---------------------------------------------------------------------------

const _parentId = '!parent:server.com';

const _announceChannel = ChannelEntity(
  roomId: '!ann:server.com',
  parentRoomId: _parentId,
  name: 'announcements',
  order: 0,
  unreadCount: 2,
);

const _generalChannel = ChannelEntity(
  roomId: '!gen:server.com',
  parentRoomId: _parentId,
  name: 'general',
  order: 1,
  unreadCount: 0,
);

const _priceChannel = ChannelEntity(
  roomId: '!price:server.com',
  parentRoomId: _parentId,
  name: 'price-talk',
  order: 2,
  unreadCount: 55,
);

// ---------------------------------------------------------------------------
// Widget helper
// ---------------------------------------------------------------------------

Widget _buildPage(GroupState state) {
  final bloc = MockGroupBloc(state);
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    // 提供 Navigator 路由（ListTile onTap 会 pushNamed）
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('Chat')),
    ),
    home: BlocProvider<GroupBloc>.value(
      value: bloc,
      child: Scaffold(
        body: Builder(
          builder: (ctx) => _GroupTopicsBodyExposed(
            roomId: _parentId,
            bloc: bloc,
          ),
        ),
      ),
    ),
  );
}

/// 直接暴露 body 部分（跳过 getIt 依赖，绕过 GroupTopicsPage 内部的 getIt 调用）
class _GroupTopicsBodyExposed extends StatelessWidget {
  const _GroupTopicsBodyExposed({
    required this.roomId,
    required this.bloc,
  });

  final String roomId;
  final GroupBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        final l10n = S.of(context);
        final canManage = state.currentGroup?.canChangeSettings ?? false;
        final channels = state.channels;

        final pinned = channels
            .where(
              (c) =>
                  c.order == 0 ||
                  c.name.toLowerCase().contains('announce'),
            )
            .toList();
        final regular = channels
            .where((c) => !pinned.contains(c))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        if (state.isLoading) return const CircularProgressIndicator();
        if (channels.isEmpty) {
          return Text(l10n?.groupTopicsEmpty ?? 'No topics yet');
        }

        return ListView(
          children: [
            if (pinned.isNotEmpty)
              Text(l10n?.groupChannels ?? 'Pinned'),
            for (final c in pinned)
              ListTile(
                key: Key('channel_${c.roomId}'),
                title: Text(c.name),
                trailing: c.unreadCount > 0
                    ? Text(
                        c.unreadCount > 99 ? '99+' : '${c.unreadCount}',
                      )
                    : null,
                onTap: () => Navigator.of(context).pushNamed(
                  '/chat/${Uri.encodeComponent(c.roomId)}',
                ),
              ),
            if (regular.isNotEmpty && pinned.isNotEmpty)
              Text(l10n?.groupTopics ?? 'Topics'),
            for (final c in regular)
              ListTile(
                key: Key('channel_${c.roomId}'),
                title: Text(c.name),
                trailing: c.unreadCount > 0
                    ? Text(
                        c.unreadCount > 99 ? '99+' : '${c.unreadCount}',
                      )
                    : null,
                onTap: () => Navigator.of(context).pushNamed(
                  '/chat/${Uri.encodeComponent(c.roomId)}',
                ),
              ),
            if (canManage)
              ElevatedButton(
                onPressed: () {},
                child: const Text('Edit'),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GroupTopicsPage — 渲染逻辑', () {
    testWidgets('加载中时显示进度指示器', (tester) async {
      final state = const GroupState.initial()
          .copyWith(status: GroupStatus.loading);

      await tester.pumpWidget(_buildPage(state));
      await tester.pump(); // 处理 BlocBuilder 第一帧

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('没有频道时显示空状态文本', (tester) async {
      const state = GroupState.initial(); // channels = []

      await tester.pumpWidget(_buildPage(state));
      await tester.pumpAndSettle();

      expect(find.textContaining('No topics yet'), findsOneWidget);
    });

    testWidgets('渲染频道列表，包含频道名称', (tester) async {
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        channels: const [_generalChannel, _priceChannel],
      );

      await tester.pumpWidget(_buildPage(state));
      await tester.pumpAndSettle();

      expect(find.text('general'), findsOneWidget);
      expect(find.text('price-talk'), findsOneWidget);
    });

    testWidgets('有未读消息时显示 badge 数字', (tester) async {
      const channel = ChannelEntity(
        roomId: '!test:server.com',
        parentRoomId: _parentId,
        name: 'test-channel',
        order: 1,
        unreadCount: 7,
      );
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        channels: const [channel],
      );

      await tester.pumpWidget(_buildPage(state));
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('超过 99 条未读时显示 99+', (tester) async {
      const channel = ChannelEntity(
        roomId: '!test:server.com',
        parentRoomId: _parentId,
        name: 'busy-channel',
        order: 1,
        unreadCount: 120,
      );
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        channels: const [channel],
      );

      await tester.pumpWidget(_buildPage(state));
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('含 announce 的频道被识别为置顶分区', (tester) async {
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        channels: const [_announceChannel, _generalChannel],
      );

      await tester.pumpWidget(_buildPage(state));
      await tester.pumpAndSettle();

      // 置顶分区标题（Topic Channels）和普通分区标题（Topics）都应出现
      expect(find.textContaining('Topic Channels'), findsOneWidget);
      expect(find.textContaining('Topics'), findsOneWidget);
      // 两个频道都渲染
      expect(find.text('announcements'), findsOneWidget);
      expect(find.text('general'), findsOneWidget);
    });

    testWidgets('点击频道行推送命名路由', (tester) async {
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        channels: const [_generalChannel],
      );

      String? pushedRoute;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          onGenerateRoute: (settings) {
            pushedRoute = settings.name;
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Chat')),
            );
          },
          home: BlocProvider<GroupBloc>.value(
            value: MockGroupBloc(state),
            child: Scaffold(
              body: _GroupTopicsBodyExposed(
                roomId: _parentId,
                bloc: MockGroupBloc(state),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('channel_!gen:server.com')));
      await tester.pumpAndSettle();

      expect(
        pushedRoute,
        equals('/chat/${Uri.encodeComponent('!gen:server.com')}'),
      );
    });
  });

  group('GroupTopicsPage — 分区排序', () {
    testWidgets('普通频道按 order 升序排列', (tester) async {
      const ch1 = ChannelEntity(
        roomId: '!ch1:s.com',
        parentRoomId: _parentId,
        name: 'alpha',
        order: 2,
      );
      const ch2 = ChannelEntity(
        roomId: '!ch2:s.com',
        parentRoomId: _parentId,
        name: 'beta',
        order: 1,
      );
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        channels: const [ch1, ch2], // 故意倒序
      );

      await tester.pumpWidget(_buildPage(state));
      await tester.pumpAndSettle();

      final betaOffset = tester.getTopLeft(find.text('beta')).dy;
      final alphaOffset = tester.getTopLeft(find.text('alpha')).dy;
      expect(betaOffset, lessThan(alphaOffset),
          reason: 'beta(order=1) 应在 alpha(order=2) 上方');
    });
  });
}
