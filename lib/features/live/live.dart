/// N42 Live —— 直播客户端 feature 模块导出。
///
/// 初期作为同仓独立入口（`lib/main_live.dart`）开发，成熟后合入主 App。
library;

export 'presentation/pages/go_live_page.dart';
export 'presentation/pages/live_app.dart';
export 'presentation/pages/live_home_page.dart';
export 'presentation/pages/live_room_page.dart';
export 'presentation/router/live_router.dart';
export 'prediction/domain/prediction_market.dart';
export 'prediction/domain/prediction_repository.dart';
export 'prediction/providers/prediction_providers.dart';
export 'services/live_bootstrap.dart';
export 'services/live_chat_service.dart';
export 'services/live_video_service.dart';
