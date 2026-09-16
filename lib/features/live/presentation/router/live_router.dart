import 'package:go_router/go_router.dart';

import '../pages/go_live_page.dart';
import '../pages/live_home_page.dart';
import '../pages/live_room_page.dart';

/// 直播客户端路由表。
/// - `/live`              直播广场（列表）
/// - `/live/room/:roomId` 观看端直播间（roomId = Matrix room id）
/// - `/live/go`           开播端
final GoRouter liveRouter = GoRouter(
  initialLocation: '/live',
  routes: [
    GoRoute(
      path: '/live',
      builder: (context, state) => const LiveHomePage(),
      routes: [
        GoRoute(
          path: 'room/:roomId',
          builder: (context, state) =>
              LiveRoomPage(roomId: state.pathParameters['roomId']!),
        ),
        GoRoute(path: 'go', builder: (context, state) => const GoLivePage()),
      ],
    ),
  ],
);
