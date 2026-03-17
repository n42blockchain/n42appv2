# Main Wallet File Inventory

## Scope Notes

- 本清单服务于主钱包 code review 计划，覆盖主要可审计代码与测试文件。
- 默认纳入：`lib/`、`test/`、`plugins/flutter_mining/` 的源码、配置、平台壳层。
- 默认排除：`assets/`、`.dart_tool/`、`build/`、Flutter ephemeral 文件。

## Counts

- `lib/`: 926 Dart 文件
- `test/`: 138 Dart 文件
- `plugins/flutter_mining/`: 8 Dart 文件，122 个文件总计

## Source Inventory

### application.dart (1)

- `application.dart`

### core/api_hub (14)

- `core/api_hub/aggregators/market_data_aggregator.dart`
- `core/api_hub/aggregators/news_aggregator.dart`
- `core/api_hub/aggregators/url_security_aggregator.dart`
- `core/api_hub/api_hub.dart`
- `core/api_hub/datasources/coincap_datasource.dart`
- `core/api_hub/datasources/coinlore_datasource.dart`
- `core/api_hub/datasources/coinpaprika_datasource.dart`
- `core/api_hub/datasources/cryptocompare_price_datasource.dart`
- `core/api_hub/datasources/defillama_datasource.dart`
- `core/api_hub/datasources/messari_datasource.dart`
- `core/api_hub/datasources/urlhaus_datasource.dart`
- `core/api_hub/models/coin_price.dart`
- `core/api_hub/models/defi_protocol.dart`
- `core/api_hub/models/url_threat.dart`

### core/app (1)

- `core/app/app_globals.dart`

### core/config (4)

- `core/config/api_keys_config.dart`
- `core/config/app_config.dart`
- `core/config/proxy_config.dart`
- `core/config/rpc_config.dart`

### core/constants (2)

- `core/constants/app_colors.dart`
- `core/constants/language_constants.dart`

### core/di (2)

- `core/di/injection.dart`
- `core/di/service_locator_setup.dart`

### core/error (2)

- `core/error/exceptions.dart`
- `core/error/failures.dart`

### core/market (2)

- `core/market/crypto_news_service.dart`
- `core/market/fear_greed_service.dart`

### core/network (12)

- `core/network/activity_api.dart`
- `core/network/api_client.dart`
- `core/network/base_api.dart`
- `core/network/base_http.dart`
- `core/network/circuit_breaker_interceptor.dart`
- `core/network/external_http.dart`
- `core/network/ipfs_api.dart`
- `core/network/request_url.dart`
- `core/network/request_url_mainnet.dart`
- `core/network/request_url_testnet.dart`
- `core/network/retry_config.dart`
- `core/network/retry_interceptor.dart`

### core/performance (1)

- `core/performance/performance_config.dart`

### core/platform (3)

- `core/platform/chat_social_auth_config.dart`
- `core/platform/deep_link_service.dart`
- `core/platform/social_auth_native_config.dart`

### core/providers (5)

- `core/providers/core_providers.dart`
- `core/providers/core_providers_profile.dart`
- `core/providers/core_providers_security.dart`
- `core/providers/core_providers_ui.dart`
- `core/providers/legacy_wallet_adapter.dart`

### core/routing (1)

- `core/routing/deep_link_handler.dart`

### core/security (17)

- `core/security/address_label_service.dart`
- `core/security/dapp_security_service.dart`
- `core/security/device_security.dart`
- `core/security/goplus_security_result.dart`
- `core/security/goplus_security_service.dart`
- `core/security/phishing_detector.dart`
- `core/security/phishing_warning_dialog.dart`
- `core/security/secure_memory.dart`
- `core/security/secure_storage.dart`
- `core/security/security_config.dart`
- `core/security/tx_risk_analyzer.dart`
- `core/security/tx_risk_decoders.dart`
- `core/security/tx_risk_formatters.dart`
- `core/security/tx_risk_models.dart`
- `core/security/tx_simulation_result.dart`
- `core/security/tx_simulation_service.dart`
- `core/security/wallet_data_migration.dart`

### core/state (1)

- `core/state/async_state.dart`

### core/storage (3)

- `core/storage/app_database.dart`
- `core/storage/secure_preferences.dart`
- `core/storage/sp_util.dart`

### core/token_discovery (2)

- `core/token_discovery/discovered_token.dart`
- `core/token_discovery/token_discovery_service.dart`

### core/usecase (1)

- `core/usecase/usecase.dart`

### core/utils (7)

- `core/utils/event_bus.dart`
- `core/utils/js_escape_utils.dart`
- `core/utils/message_model_bridge.dart`
- `core/utils/responsive_utils.dart`
- `core/utils/result.dart`
- `core/utils/theme_mode_utils.dart`
- `core/utils/toast_utils.dart`

### core/wallet_sdk (9)

- `core/wallet_sdk/models/key_pair.dart`
- `core/wallet_sdk/models/keystore_info.dart`
- `core/wallet_sdk/models/signing_result.dart`
- `core/wallet_sdk/models/wallet_account.dart`
- `core/wallet_sdk/models/wallet_sdk_models.dart`
- `core/wallet_sdk/wallet_address.dart`
- `core/wallet_sdk/wallet_key_manager.dart`
- `core/wallet_sdk/wallet_sdk.dart`
- `core/wallet_sdk/wallet_signer.dart`

### data/models (2)

- `data/models/device_login_info.dart`
- `data/models/user_info.dart`

### domain/entities (2)

- `domain/entities/user.dart`
- `domain/entities/wallet.dart`

### domain/repositories (2)

- `domain/repositories/auth_repository.dart`
- `domain/repositories/wallet_repository.dart`

### features/airdrop (10)

- `features/airdrop/api/airdrop_api.dart`
- `features/airdrop/models/airdrop_model.dart`
- `features/airdrop/pages/airdrop_detail_page.dart`
- `features/airdrop/pages/airdrop_detail_page_actions.dart`
- `features/airdrop/pages/airdrop_detail_page_logic.dart`
- `features/airdrop/pages/airdrop_detail_page_widgets.dart`
- `features/airdrop/pages/airdrop_home_page.dart`
- `features/airdrop/pages/airdrop_home_page_logic.dart`
- `features/airdrop/pages/airdrop_home_page_widgets.dart`
- `features/airdrop/provider/airdrop_provider.dart`

### features/auth (4)

- `features/auth/auth.dart`
- `features/auth/data/services/auth_service_impl.dart`
- `features/auth/domain/entities/auth_entity.dart`
- `features/auth/domain/repositories/auth_repository.dart`

### features/bridge (11)

- `features/bridge/api/lifi_api.dart`
- `features/bridge/models/bridge_models.dart`
- `features/bridge/pages/bridge_history_page.dart`
- `features/bridge/pages/bridge_home_page.dart`
- `features/bridge/pages/bridge_home_page_logic.dart`
- `features/bridge/pages/bridge_home_page_sections.dart`
- `features/bridge/pages/bridge_home_page_widgets.dart`
- `features/bridge/pages/bridge_select_chain_page.dart`
- `features/bridge/provider/_bridge_execution.dart`
- `features/bridge/provider/_bridge_persistence.dart`
- `features/bridge/provider/bridge_provider.dart`

### features/browser (23)

- `features/browser/api/browser_api.dart`
- `features/browser/browser.dart`
- `features/browser/data/recommended_dapps.dart`
- `features/browser/data/repositories/browser_repository_impl.dart`
- `features/browser/domain/entities/browser_entity.dart`
- `features/browser/domain/repositories/browser_repository.dart`
- `features/browser/handler/dapp_request_handler.dart`
- `features/browser/js/ethereum_provider.dart`
- `features/browser/models/browser_collection_model.dart`
- `features/browser/models/browser_history_model.dart`
- `features/browser/models/browser_search_history_model.dart`
- `features/browser/pages/browser_collection.dart`
- `features/browser/pages/browser_collection_info.dart`
- `features/browser/pages/browser_collection_list.dart`
- `features/browser/pages/browser_history_page.dart`
- `features/browser/pages/browser_page.dart`
- `features/browser/pages/browser_page_tabs.dart`
- `features/browser/pages/browser_page_widgets.dart`
- `features/browser/pages/browser_setting.dart`
- `features/browser/pages/dapp_directory_page.dart`
- `features/browser/presentation/providers/browser_providers.dart`
- `features/browser/provider/browser_provider.dart`
- `features/browser/widgets/dapp_signing_sheet.dart`

### features/component (5)

- `features/component/enums/coin_type.dart`
- `features/component/enums/load.dart`
- `features/component/pages/image_crop_page.dart`
- `features/component/pages/scan_page.dart`
- `features/component/pages/show_image.dart`

### features/earn (6)

- `features/earn/pages/earn_page.dart`
- `features/earn/pages/earn_page_logic.dart`
- `features/earn/pages/earn_page_products.dart`
- `features/earn/pages/earn_page_sections.dart`
- `features/earn/pages/earn_page_widgets.dart`
- `features/earn/provider/earn_provider.dart`

### features/feature_initializer.dart (1)

- `features/feature_initializer.dart`

### features/features.dart (1)

- `features/features.dart`

### features/hardware_wallet (19)

- `features/hardware_wallet/crypto/ur_codec.dart`
- `features/hardware_wallet/models/hardware_wallet_models.dart`
- `features/hardware_wallet/pages/device_scan_page.dart`
- `features/hardware_wallet/pages/hardware_wallet_accounts_page.dart`
- `features/hardware_wallet/pages/hardware_wallet_accounts_widgets.dart`
- `features/hardware_wallet/pages/hardware_wallet_page.dart`
- `features/hardware_wallet/pages/hardware_wallet_page_logic.dart`
- `features/hardware_wallet/pages/hardware_wallet_page_widgets.dart`
- `features/hardware_wallet/pages/keystone_pair_page.dart`
- `features/hardware_wallet/pages/keystone_scan_overlay.dart`
- `features/hardware_wallet/pages/keystone_sign_page.dart`
- `features/hardware_wallet/pages/trezor_connect_page.dart`
- `features/hardware_wallet/provider/hardware_wallet_provider.dart`
- `features/hardware_wallet/provider/hardware_wallet_provider_connection.dart`
- `features/hardware_wallet/provider/hardware_wallet_provider_signing.dart`
- `features/hardware_wallet/service/keystone_service.dart`
- `features/hardware_wallet/service/ledger_apdu_utils.dart`
- `features/hardware_wallet/service/ledger_service.dart`
- `features/hardware_wallet/service/trezor_service.dart`

### features/home (43)

- `features/home/api/version_api.dart`
- `features/home/home_draw_page.dart`
- `features/home/home_draw_page_widgets.dart`
- `features/home/home_page.dart`
- `features/home/home_page_navigation.dart`
- `features/home/models/appendix_model.dart`
- `features/home/models/exchange_account_model.dart`
- `features/home/models/version_info_model.dart`
- `features/home/setting/about_app.dart`
- `features/home/setting/account_logout_page.dart`
- `features/home/setting/browser_setting.dart`
- `features/home/setting/change_email_page.dart`
- `features/home/setting/change_email_page_logic.dart`
- `features/home/setting/change_email_page_widgets.dart`
- `features/home/setting/change_email_ui_helpers.dart`
- `features/home/setting/feedback.dart`
- `features/home/setting/personal_setting.dart`
- `features/home/setting/personal_setting_fields.dart`
- `features/home/setting/security/gesture_password_setting.dart`
- `features/home/setting/security/lock_screen_resetpassword.dart`
- `features/home/setting/security/security_edit.dart`
- `features/home/setting/security/security_google_backup_key.dart`
- `features/home/setting/security/security_google_download.dart`
- `features/home/setting/security/security_google_instructions.dart`
- `features/home/setting/security/security_google_vedification.dart`
- `features/home/setting/security/security_google_vedification_logic.dart`
- `features/home/setting/security/security_google_vedification_widgets.dart`
- `features/home/setting/security/security_setting.dart`
- `features/home/setting/security/security_setting_widgets.dart`
- `features/home/setting/setting_home_page.dart`
- `features/home/setting/setting_share.dart`
- `features/home/setting/setting_sys_language.dart`
- `features/home/setting/setting_theme.dart`
- `features/home/unlock.dart`
- `features/home/unlock_ui.dart`
- `features/home/widgets/check_version_alert.dart`
- `features/home/widgets/face_recognition_public.dart`
- `features/home/widgets/feature_entry_card.dart`
- `features/home/widgets/gesture_password/gesture_password.dart`
- `features/home/widgets/gesture_password/gesture_pattern_strength.dart`
- `features/home/widgets/nav_select_image.dart`
- `features/home/widgets/nav_setting_item.dart`
- `features/home/widgets/share_list.dart`

### features/login (18)

- `features/login/api/handtype.dart`
- `features/login/api/user_info_api.dart`
- `features/login/api/user_info_api_security.dart`
- `features/login/api/user_info_api_social.dart`
- `features/login/pages/account_create_and_reset.dart`
- `features/login/pages/account_create_and_reset_logic.dart`
- `features/login/pages/account_create_and_reset_widgets.dart`
- `features/login/pages/change_password_page.dart`
- `features/login/pages/login_page.dart`
- `features/login/pages/reset_password_page.dart`
- `features/login/pages/reset_password_widgets.dart`
- `features/login/services/social_auth_service.dart`
- `features/login/widgets/captcha_button.dart`
- `features/login/widgets/input_field.dart`
- `features/login/widgets/login_title.dart`
- `features/login/widgets/social_login_buttons.dart`
- `features/login/widgets/user_protocol.dart`
- `features/login/widgets/view_pwd_icon.dart`

### features/loyalty (14)

- `features/loyalty/api/_loyalty_api_extras.dart`
- `features/loyalty/api/_loyalty_api_mock.dart`
- `features/loyalty/api/loyalty_api.dart`
- `features/loyalty/models/loyalty_model.dart`
- `features/loyalty/pages/_tasks_logic.dart`
- `features/loyalty/pages/_tasks_widgets.dart`
- `features/loyalty/pages/history_page.dart`
- `features/loyalty/pages/loyalty_home_page.dart`
- `features/loyalty/pages/loyalty_home_page_logic.dart`
- `features/loyalty/pages/loyalty_home_page_sections.dart`
- `features/loyalty/pages/loyalty_home_page_widgets.dart`
- `features/loyalty/pages/rewards_page.dart`
- `features/loyalty/pages/tasks_page.dart`
- `features/loyalty/provider/loyalty_provider.dart`

### features/mining (8)

- `features/mining/data/repositories/mining_repository_impl.dart`
- `features/mining/data/services/mining_service_impl.dart`
- `features/mining/domain/entities/mining_entity.dart`
- `features/mining/domain/repositories/mining_repository.dart`
- `features/mining/domain/usecases/start_mining.dart`
- `features/mining/mining.dart`
- `features/mining/presentation/providers/mining_providers.dart`
- `features/mining/services/mining_channel.dart`

### features/mining_v1 (37)

- `features/mining_v1/api/mining_api.dart`
- `features/mining_v1/api/mining_config.dart`
- `features/mining_v1/api/mining_token.dart`
- `features/mining_v1/models/mining_type.dart`
- `features/mining_v1/pages/full_node_page.dart`
- `features/mining_v1/pages/full_node_page_logic.dart`
- `features/mining_v1/pages/full_node_page_widgets.dart`
- `features/mining_v1/pages/mining_background.dart`
- `features/mining_v1/pages/mining_home_page.dart`
- `features/mining_v1/pages/mining_index.dart`
- `features/mining_v1/pages/mining_plans.dart`
- `features/mining_v1/pages/mining_settings.dart`
- `features/mining_v1/pages/mining_task_list.dart`
- `features/mining_v1/pages/select_mining_plans.dart`
- `features/mining_v1/pages/share_mining.dart`
- `features/mining_v1/pages/summary_page.dart`
- `features/mining_v1/pages/summary_page_logic.dart`
- `features/mining_v1/pages/summary_page_widgets.dart`
- `features/mining_v1/pages/task_detail_page.dart`
- `features/mining_v1/pages/today_mining_page.dart`
- `features/mining_v1/pages/today_mining_page_logic.dart`
- `features/mining_v1/pages/today_mining_page_sections.dart`
- `features/mining_v1/pages/today_mining_page_widgets.dart`
- `features/mining_v1/provider/mining_provider.dart`
- `features/mining_v1/provider/mining_v1_providers.dart`
- `features/mining_v1/utils/mining_cache_utils.dart`
- `features/mining_v1/utils/mining_plugin_utils.dart`
- `features/mining_v1/utils/mining_utils.dart`
- `features/mining_v1/widgets/ast_level.dart`
- `features/mining_v1/widgets/ast_mining_board.dart`
- `features/mining_v1/widgets/group_confrim.dart`
- `features/mining_v1/widgets/item_mining_node.dart`
- `features/mining_v1/widgets/nav_show_data_item.dart`
- `features/mining_v1/widgets/select_plan.dart`
- `features/mining_v1/widgets/show_skip_confirm_dialog.dart`
- `features/mining_v1/widgets/task_item.dart`
- `features/mining_v1/widgets/task_value_bar.dart`

### features/mining_v2 (36)

- `features/mining_v2/api/mining_api.dart`
- `features/mining_v2/api/mining_web3.dart`
- `features/mining_v2/models/mining_withdrawals_daily.dart`
- `features/mining_v2/pages/key_management/data_encryption.dart`
- `features/mining_v2/pages/key_management/file_import.dart`
- `features/mining_v2/pages/key_management/mining_import.dart`
- `features/mining_v2/pages/key_management/mining_key_list.dart`
- `features/mining_v2/pages/key_management/mining_output_pk.dart`
- `features/mining_v2/pages/key_management/mining_output_tip.dart`
- `features/mining_v2/pages/mining_background.dart`
- `features/mining_v2/pages/mining_full_node_v2.dart`
- `features/mining_v2/pages/mining_full_node_v2_logic.dart`
- `features/mining_v2/pages/mining_full_node_v2_widgets.dart`
- `features/mining_v2/pages/mining_node_detail_page.dart`
- `features/mining_v2/pages/mining_node_detail_widgets.dart`
- `features/mining_v2/pages/mining_plans_v2.dart`
- `features/mining_v2/pages/mining_setting.dart`
- `features/mining_v2/pages/mining_today_v2.dart`
- `features/mining_v2/pages/mining_today_v2_logic.dart`
- `features/mining_v2/pages/mining_today_v2_widgets.dart`
- `features/mining_v2/pages/share_mining.dart`
- `features/mining_v2/provider/mining_v2_provider.dart`
- `features/mining_v2/provider/mining_v2_provider_actions.dart`
- `features/mining_v2/provider/mining_v2_provider_beacon.dart`
- `features/mining_v2/provider/mining_v2_provider_state.dart`
- `features/mining_v2/provider/mining_v2_provider_websocket.dart`
- `features/mining_v2/provider/mining_web_socket_bridge.dart`
- `features/mining_v2/utils/mining_utils.dart`
- `features/mining_v2/widgets/background_mining_widget.dart`
- `features/mining_v2/widgets/group_confrim.dart`
- `features/mining_v2/widgets/mining_board_widget.dart`
- `features/mining_v2/widgets/mining_data_broad.dart`
- `features/mining_v2/widgets/mining_risk_card.dart`
- `features/mining_v2/widgets/mining_status_widget.dart`
- `features/mining_v2/widgets/n_level_widget.dart`
- `features/mining_v2/widgets/plans_widget.dart`

### features/models (1)

- `features/models/message_model.dart`

### features/news (2)

- `features/news/api/news_api.dart`
- `features/news/news_page.dart`

### features/notification (2)

- `features/notification/pages/message_info.dart`
- `features/notification/pages/message_list.dart`

### features/pay (2)

- `features/pay/moonpay/create_url.dart`
- `features/pay/moonpay/moonpay.dart`

### features/profile (2)

- `features/profile/pages/profile_home_page.dart`
- `features/profile/pages/profile_home_page_widgets.dart`

### features/proto (36)

- `features/proto/business.ext.pb.dart`
- `features/proto/business.ext.pbenum.dart`
- `features/proto/business.ext.pbjson.dart`
- `features/proto/business.ext.pbserver.dart`
- `features/proto/business.int.pb.dart`
- `features/proto/business.int.pbenum.dart`
- `features/proto/business.int.pbjson.dart`
- `features/proto/business.int.pbserver.dart`
- `features/proto/connect.ext.pb.dart`
- `features/proto/connect.ext.pbenum.dart`
- `features/proto/connect.ext.pbjson.dart`
- `features/proto/connect.ext.pbserver.dart`
- `features/proto/connect.int.pb.dart`
- `features/proto/connect.int.pbenum.dart`
- `features/proto/connect.int.pbjson.dart`
- `features/proto/connect.int.pbserver.dart`
- `features/proto/google/protobuf/empty.pb.dart`
- `features/proto/google/protobuf/empty.pbenum.dart`
- `features/proto/google/protobuf/empty.pbjson.dart`
- `features/proto/google/protobuf/empty.pbserver.dart`
- `features/proto/logic.ext.pb.dart`
- `features/proto/logic.ext.pbenum.dart`
- `features/proto/logic.ext.pbjson.dart`
- `features/proto/logic.ext.pbserver.dart`
- `features/proto/logic.int.pb.dart`
- `features/proto/logic.int.pbenum.dart`
- `features/proto/logic.int.pbjson.dart`
- `features/proto/logic.int.pbserver.dart`
- `features/proto/message.ext.pb.dart`
- `features/proto/message.ext.pbenum.dart`
- `features/proto/message.ext.pbjson.dart`
- `features/proto/message.ext.pbserver.dart`
- `features/proto/push.ext.pb.dart`
- `features/proto/push.ext.pbenum.dart`
- `features/proto/push.ext.pbjson.dart`
- `features/proto/push.ext.pbserver.dart`

### features/settings (3)

- `features/settings/presentation/pages/setting_language_page.dart`
- `features/settings/presentation/pages/setting_theme_page.dart`
- `features/settings/settings.dart`

### features/splash (2)

- `features/splash/splash_page.dart`
- `features/splash/splash_variants.dart`

### features/sqlite (1)

- `features/sqlite/app_database.dart`

### features/staking (15)

- `features/staking/api/atom_staking_api.dart`
- `features/staking/api/eth_staking_api.dart`
- `features/staking/api/sol_staking_api.dart`
- `features/staking/models/staking_models.dart`
- `features/staking/pages/stake_page.dart`
- `features/staking/pages/stake_page_forms.dart`
- `features/staking/pages/stake_page_logic.dart`
- `features/staking/pages/stake_page_sections.dart`
- `features/staking/pages/stake_page_widgets.dart`
- `features/staking/pages/staking_home_page.dart`
- `features/staking/pages/staking_home_page_logic.dart`
- `features/staking/pages/staking_home_page_widgets.dart`
- `features/staking/pages/staking_ui_helpers.dart`
- `features/staking/pages/validator_list_page.dart`
- `features/staking/provider/staking_provider.dart`

### features/utils (10)

- `features/utils/app_push_navigation.dart`
- `features/utils/app_push_utils.dart`
- `features/utils/chat_logout_compat.dart`
- `features/utils/data_utils.dart`
- `features/utils/device_info_util.dart`
- `features/utils/md5_util.dart`
- `features/utils/notfication_utils.dart`
- `features/utils/regular.dart`
- `features/utils/theme_adapter.dart`
- `features/utils/toast_utils.dart`

### features/wallet (445)

- `features/wallet/aa/aa.dart`
- `features/wallet/aa/account/account_deployer.dart`
- `features/wallet/aa/account/account_types/biconomy_account.dart`
- `features/wallet/aa/account/account_types/safe_account.dart`
- `features/wallet/aa/account/account_types/simple7702_account.dart`
- `features/wallet/aa/account/account_types/simple_account.dart`
- `features/wallet/aa/account/smart_account_factory.dart`
- `features/wallet/aa/builder/calldata_builder.dart`
- `features/wallet/aa/builder/signature_builder.dart`
- `features/wallet/aa/builder/user_op_builder.dart`
- `features/wallet/aa/bundler/bundler_client.dart`
- `features/wallet/aa/bundler/bundler_config.dart`
- `features/wallet/aa/core/aa_config.dart`
- `features/wallet/aa/core/aa_constants.dart`
- `features/wallet/aa/core/aa_errors.dart`
- `features/wallet/aa/models/paymaster_data.dart`
- `features/wallet/aa/models/smart_account.dart`
- `features/wallet/aa/models/user_operation.dart`
- `features/wallet/aa/models/user_operation_receipt.dart`
- `features/wallet/aa/paymaster/paymaster_service.dart`
- `features/wallet/aa/provider/aa_provider.dart`
- `features/wallet/aa/provider/batch_template_provider.dart`
- `features/wallet/aa/repository/session_key_repository.dart`
- `features/wallet/aa/utils/eip7702_handler.dart`
- `features/wallet/aa/utils/gas_estimator.dart`
- `features/wallet/aa/utils/user_op_hash.dart`
- `features/wallet/api/address_book_api.dart`
- `features/wallet/api/batch_transfer_api.dart`
- `features/wallet/api/batch_transfer_encoding.dart`
- `features/wallet/api/chain_api/algo_api.dart`
- `features/wallet/api/chain_api/apt_api.dart`
- `features/wallet/api/chain_api/atom_api.dart`
- `features/wallet/api/chain_api/btc_api.dart`
- `features/wallet/api/chain_api/dot_api.dart`
- `features/wallet/api/chain_api/eth_api.dart`
- `features/wallet/api/chain_api/fil_api.dart`
- `features/wallet/api/chain_api/near_api.dart`
- `features/wallet/api/chain_api/sol_api.dart`
- `features/wallet/api/chain_api/sui_api.dart`
- `features/wallet/api/chain_api/ton_api.dart`
- `features/wallet/api/chain_api/trx_api.dart`
- `features/wallet/api/chain_api/xrp_api.dart`
- `features/wallet/api/chain_api/xtz_api.dart`
- `features/wallet/api/chain_api/zil_api.dart`
- `features/wallet/api/dex_swap_api.dart`
- `features/wallet/api/exchange_api.dart`
- `features/wallet/api/face_api.dart`
- `features/wallet/api/gas_tracker_api.dart`
- `features/wallet/api/market_api.dart`
- `features/wallet/api/redeem_token.dart`
- `features/wallet/api/simplehash_nft_api.dart`
- `features/wallet/api/swap_ast_api.dart`
- `features/wallet/api/token/btc_token_api.dart`
- `features/wallet/api/token/eth_token_api.dart`
- `features/wallet/api/token/sol_token_api.dart`
- `features/wallet/api/token/token_api.dart`
- `features/wallet/api/token/token_api_base.dart`
- `features/wallet/api/token/trx_token_api.dart`
- `features/wallet/api/token_view_api.dart`
- `features/wallet/api/token_view_api_btc.dart`
- `features/wallet/api/token_view_api_eth.dart`
- `features/wallet/api/token_view_api_ns.dart`
- `features/wallet/api/token_view_api_sol.dart`
- `features/wallet/api/token_view_api_trx.dart`
- `features/wallet/api/tokenview_enhanced_api.dart`
- `features/wallet/api/transaction_api.dart`
- `features/wallet/api/transaction_api_btc_sol_trx.dart`
- `features/wallet/api/transaction_api_eth_dot_apt_ton.dart`
- `features/wallet/api/transfer/handlers/aa_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/algo_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/apt_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/atom_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/base_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/btc_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/dot_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/evm_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/fil_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/sol_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/ton_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/trx_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/xrp_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/xtz_transfer_handler.dart`
- `features/wallet/api/transfer/handlers/zil_transfer_handler.dart`
- `features/wallet/api/transfer/transfer_base.dart`
- `features/wallet/api/transfer/transfer_btc.dart`
- `features/wallet/api/transfer/transfer_cosmos_family.dart`
- `features/wallet/api/transfer/transfer_evm.dart`
- `features/wallet/api/transfer/transfer_handler.dart`
- `features/wallet/api/transfer/transfer_handler_factory.dart`
- `features/wallet/api/transfer/transfer_others.dart`
- `features/wallet/api/transfer/transfer_sol.dart`
- `features/wallet/api/transfer/transfer_trx.dart`
- `features/wallet/api/transfer_api.dart`
- `features/wallet/data/datasources/wallet_local_datasource.dart`
- `features/wallet/data/datasources/wallet_remote_datasource.dart`
- `features/wallet/data/repositories/wallet_repository_impl.dart`
- `features/wallet/data/services/wallet_service_impl.dart`
- `features/wallet/domain/entities/wallet_entity.dart`
- `features/wallet/domain/repositories/wallet_repository.dart`
- `features/wallet/domain/usecases/create_wallet.dart`
- `features/wallet/domain/usecases/get_balance.dart`
- `features/wallet/domain/usecases/send_transaction.dart`
- `features/wallet/models/address_book_model.dart`
- `features/wallet/models/aggregated_coin_model.dart`
- `features/wallet/models/aggregated_token.dart`
- `features/wallet/models/ast_swap/swap_ast_model.dart`
- `features/wallet/models/ast_swap/swap_ast_order_model.dart`
- `features/wallet/models/batch_transfer_model.dart`
- `features/wallet/models/btc_transaction_recode_model.dart`
- `features/wallet/models/coin_model.dart`
- `features/wallet/models/coin_model_wallet_access.dart`
- `features/wallet/models/dex/dex_history_model.dart`
- `features/wallet/models/dex/dex_quote_model.dart`
- `features/wallet/models/dex/dex_token_model.dart`
- `features/wallet/models/gas_estimate_model.dart`
- `features/wallet/models/image_upload_model.dart`
- `features/wallet/models/mess_mnemonic_words_item.dart`
- `features/wallet/models/nft_model.dart`
- `features/wallet/models/non_evm_fee_model.dart`
- `features/wallet/models/ohlc_point.dart`
- `features/wallet/models/portfolio_trade.dart`
- `features/wallet/models/transaction/btc_response.dart`
- `features/wallet/models/transaction/btc_sync_utils.dart`
- `features/wallet/models/transaction/btc_tran_detail.dart`
- `features/wallet/models/transaction/common_response_item_model.dart`
- `features/wallet/models/transaction/explorer_response_utils.dart`
- `features/wallet/models/transaction/sol_transaction_item.dart`
- `features/wallet/models/transation_record_model.dart`
- `features/wallet/models/wallet_info.dart`
- `features/wallet/n42_api_hub_bridge.dart`
- `features/wallet/n42_wallet_bridge.dart`
- `features/wallet/pages/aa/aa_account_create_form.dart`
- `features/wallet/pages/aa/aa_account_create_helpers.dart`
- `features/wallet/pages/aa/aa_account_create_page.dart`
- `features/wallet/pages/aa/aa_account_detail_page.dart`
- `features/wallet/pages/aa/aa_account_detail_page_widgets.dart`
- `features/wallet/pages/aa/aa_account_list_page.dart`
- `features/wallet/pages/aa/aa_batch_add_operation_sheet.dart`
- `features/wallet/pages/aa/aa_batch_paymaster_sheet.dart`
- `features/wallet/pages/aa/aa_batch_templates_sheet.dart`
- `features/wallet/pages/aa/aa_batch_transaction_body.dart`
- `features/wallet/pages/aa/aa_batch_transaction_page.dart`
- `features/wallet/pages/aa/aa_home_page.dart`
- `features/wallet/pages/aa/aa_home_page_widgets.dart`
- `features/wallet/pages/aa/aa_send_page.dart`
- `features/wallet/pages/aa/aa_send_page_logic.dart`
- `features/wallet/pages/aa/aa_send_page_widgets.dart`
- `features/wallet/pages/aa/create_session_key_sheet.dart`
- `features/wallet/pages/aa/key_details_sheet.dart`
- `features/wallet/pages/aa/paymaster_select_page.dart`
- `features/wallet/pages/aa/session_key_card.dart`
- `features/wallet/pages/aa/session_key_form_widgets.dart`
- `features/wallet/pages/aa/session_key_manage_page.dart`
- `features/wallet/pages/aa/session_key_models.dart`
- `features/wallet/pages/aa/session_key_preset_cards.dart`
- `features/wallet/pages/aa/session_key_sheets.dart`
- `features/wallet/pages/add_token/wallet_chain_add.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all_data.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all_import_form_ui.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all_import_ui.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all_logic.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all_network_dialog.dart`
- `features/wallet/pages/add_token/wallet_coin_add_all_search_ui.dart`
- `features/wallet/pages/add_token/wallet_coin_token_add2.dart`
- `features/wallet/pages/address_book/add_address_page.dart`
- `features/wallet/pages/address_book/address_book_list.dart`
- `features/wallet/pages/address_book/address_book_list_item.dart`
- `features/wallet/pages/address_book/choose_coins_page.dart`
- `features/wallet/pages/address_book/edit_address_page.dart`
- `features/wallet/pages/ast_swap/swap_ast_form_widgets.dart`
- `features/wallet/pages/ast_swap/swap_ast_get_widget.dart`
- `features/wallet/pages/ast_swap/swap_ast_home.dart`
- `features/wallet/pages/ast_swap/swap_ast_home_build.dart`
- `features/wallet/pages/ast_swap/swap_ast_home_tx.dart`
- `features/wallet/pages/ast_swap/swap_ast_miner_fee_widget.dart`
- `features/wallet/pages/ast_swap/swap_ast_pay_widget.dart`
- `features/wallet/pages/ast_swap/swap_ast_select_chain.dart`
- `features/wallet/pages/ast_swap/swap_ast_summary.dart`
- `features/wallet/pages/ast_swap/swap_ast_transaction_detail.dart`
- `features/wallet/pages/ast_swap/swap_ast_transactions.dart`
- `features/wallet/pages/batch_transfer/batch_transfer_bottom_bar.dart`
- `features/wallet/pages/batch_transfer/batch_transfer_dialogs.dart`
- `features/wallet/pages/batch_transfer/batch_transfer_list_widgets.dart`
- `features/wallet/pages/batch_transfer/batch_transfer_page.dart`
- `features/wallet/pages/batch_transfer/batch_transfer_select_page.dart`
- `features/wallet/pages/batch_transfer/batch_transfer_widgets.dart`
- `features/wallet/pages/batch_transfer/csv_format_section.dart`
- `features/wallet/pages/batch_transfer/csv_import_page.dart`
- `features/wallet/pages/batch_transfer/csv_validation.dart`
- `features/wallet/pages/create_wallet/create/create_one.dart`
- `features/wallet/pages/create_wallet/create/create_three.dart`
- `features/wallet/pages/create_wallet/create/create_two.dart`
- `features/wallet/pages/create_wallet/create/create_two_widgets.dart`
- `features/wallet/pages/create_wallet/create_finish.dart`
- `features/wallet/pages/create_wallet/create_finish_content.dart`
- `features/wallet/pages/create_wallet/create_password.dart`
- `features/wallet/pages/create_wallet/import/import_cloud_backup.dart`
- `features/wallet/pages/create_wallet/import/import_one.dart`
- `features/wallet/pages/dex_swap/dex_swap_action_buttons.dart`
- `features/wallet/pages/dex_swap/dex_swap_confirm.dart`
- `features/wallet/pages/dex_swap/dex_swap_constants.dart`
- `features/wallet/pages/dex_swap/dex_swap_form_widgets.dart`
- `features/wallet/pages/dex_swap/dex_swap_history.dart`
- `features/wallet/pages/dex_swap/dex_swap_home.dart`
- `features/wallet/pages/dex_swap/dex_swap_quote_card.dart`
- `features/wallet/pages/dex_swap/dex_swap_token_card.dart`
- `features/wallet/pages/dex_swap/dex_token_select.dart`
- `features/wallet/pages/ens/ens_advanced_section.dart`
- `features/wallet/pages/ens/ens_chain_config.dart`
- `features/wallet/pages/ens/ens_domain_card.dart`
- `features/wallet/pages/ens/ens_home_page.dart`
- `features/wallet/pages/ens/ens_home_page_logic.dart`
- `features/wallet/pages/ens/ens_home_page_widgets.dart`
- `features/wallet/pages/ens/ens_management_page.dart`
- `features/wallet/pages/ens/ens_management_widgets.dart`
- `features/wallet/pages/ens/ens_purchase_page.dart`
- `features/wallet/pages/ens/ens_quick_actions.dart`
- `features/wallet/pages/ens/ens_record_sections.dart`
- `features/wallet/pages/ens/ens_renew_page.dart`
- `features/wallet/pages/ens/ens_search_page.dart`
- `features/wallet/pages/ens/ens_subdomain_section.dart`
- `features/wallet/pages/ens/ens_subdomain_sheet.dart`
- `features/wallet/pages/face_matching/face_binding.dart`
- `features/wallet/pages/face_matching/face_match.dart`
- `features/wallet/pages/face_matching/face_user_notice.dart`
- `features/wallet/pages/face_matching/select_wallet.dart`
- `features/wallet/pages/gas/gas_settings_page.dart`
- `features/wallet/pages/gas/gas_tracker_card.dart`
- `features/wallet/pages/gas/gas_tracker_models.dart`
- `features/wallet/pages/gas/gas_tracker_page.dart`
- `features/wallet/pages/gas/gas_tracker_widgets.dart`
- `features/wallet/pages/gas/non_evm_gas_settings_page.dart`
- `features/wallet/pages/manage_chains_page.dart`
- `features/wallet/pages/market/market_coin_info.dart`
- `features/wallet/pages/market/market_coin_info_chart.dart`
- `features/wallet/pages/market/market_coin_info_helpers.dart`
- `features/wallet/pages/market/market_coin_info_links.dart`
- `features/wallet/pages/market/market_coin_info_sections.dart`
- `features/wallet/pages/market/market_coin_info_widgets.dart`
- `features/wallet/pages/market/market_coin_tabs.dart`
- `features/wallet/pages/market/market_news_tab.dart`
- `features/wallet/pages/market/market_page.dart`
- `features/wallet/pages/market/market_shared_widgets.dart`
- `features/wallet/pages/market/price_alert_sheet.dart`
- `features/wallet/pages/market/trade_entry_sheet.dart`
- `features/wallet/pages/nft/nft_detail_page.dart`
- `features/wallet/pages/nft/nft_list_page.dart`
- `features/wallet/pages/nft/nft_list_page_widgets.dart`
- `features/wallet/pages/nft/nft_send_page.dart`
- `features/wallet/pages/payment_code/payment_code.dart`
- `features/wallet/pages/payment_code/payment_history.dart`
- `features/wallet/pages/payment_code/payment_page.dart`
- `features/wallet/pages/payment_code/payment_page_widgets.dart`
- `features/wallet/pages/payment_code/set_amount.dart`
- `features/wallet/pages/portfolio/portfolio_holdings.dart`
- `features/wallet/pages/portfolio/portfolio_models.dart`
- `features/wallet/pages/portfolio/portfolio_movers.dart`
- `features/wallet/pages/portfolio/portfolio_page.dart`
- `features/wallet/pages/portfolio/portfolio_widgets.dart`
- `features/wallet/pages/send/send_profile.dart`
- `features/wallet/pages/send/send_utils.dart`
- `features/wallet/pages/send/unified_send_page.dart`
- `features/wallet/pages/send/wallet_base_send.dart`
- `features/wallet/pages/send/wallet_chain_send.dart`
- `features/wallet/pages/send/wallet_chain_send_algo.dart`
- `features/wallet/pages/send/wallet_chain_send_algo_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_algo_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_apt.dart`
- `features/wallet/pages/send/wallet_chain_send_apt_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_apt_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_btc.dart`
- `features/wallet/pages/send/wallet_chain_send_btc_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_btc_tx.dart`
- `features/wallet/pages/send/wallet_chain_send_btc_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_dot.dart`
- `features/wallet/pages/send/wallet_chain_send_dot_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_dot_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_ens.dart`
- `features/wallet/pages/send/wallet_chain_send_fil.dart`
- `features/wallet/pages/send/wallet_chain_send_fil_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_fil_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_form.dart`
- `features/wallet/pages/send/wallet_chain_send_gas.dart`
- `features/wallet/pages/send/wallet_chain_send_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_memo.dart`
- `features/wallet/pages/send/wallet_chain_send_memo_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_memo_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_sol.dart`
- `features/wallet/pages/send/wallet_chain_send_sol_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_sol_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_sui.dart`
- `features/wallet/pages/send/wallet_chain_send_sui_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_sui_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_ton.dart`
- `features/wallet/pages/send/wallet_chain_send_ton_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_ton_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_trx.dart`
- `features/wallet/pages/send/wallet_chain_send_trx_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_trx_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_xrp.dart`
- `features/wallet/pages/send/wallet_chain_send_xrp_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_xrp_widgets.dart`
- `features/wallet/pages/send/wallet_chain_send_zil.dart`
- `features/wallet/pages/send/wallet_chain_send_zil_logic.dart`
- `features/wallet/pages/send/wallet_chain_send_zil_widgets.dart`
- `features/wallet/pages/send/wallet_security_verification.dart`
- `features/wallet/pages/send/wallet_security_verification_sections.dart`
- `features/wallet/pages/send/wallet_security_verification_widgets.dart`
- `features/wallet/pages/staking_btc/redeem.dart`
- `features/wallet/pages/staking_btc/self_custody.dart`
- `features/wallet/pages/staking_btc/self_custody1.dart`
- `features/wallet/pages/staking_btc/self_custody1_logic.dart`
- `features/wallet/pages/token_discovery/token_discovery_page.dart`
- `features/wallet/pages/transactions/transaction_detail_eth.dart`
- `features/wallet/pages/transactions/transaction_detail_eth_sections.dart`
- `features/wallet/pages/transactions/transaction_detail_page.dart`
- `features/wallet/pages/transactions/transaction_detail_trx.dart`
- `features/wallet/pages/transactions/transaction_history_list.dart`
- `features/wallet/pages/transactions/transaction_history_list_logic.dart`
- `features/wallet/pages/transactions/transaction_history_list_widgets.dart`
- `features/wallet/pages/transactions/transaction_retry.dart`
- `features/wallet/pages/transactions/transaction_retry_logic.dart`
- `features/wallet/pages/transactions/transaction_retry_widgets.dart`
- `features/wallet/pages/wallet_backup/backup_one.dart`
- `features/wallet/pages/wallet_backup/backup_three.dart`
- `features/wallet/pages/wallet_backup/backup_two.dart`
- `features/wallet/pages/wallet_backup/export_cloud_backup.dart`
- `features/wallet/pages/wallet_chain_info.dart`
- `features/wallet/pages/wallet_chain_info_actions.dart`
- `features/wallet/pages/wallet_chain_info_sync.dart`
- `features/wallet/pages/wallet_chain_info_xrp.dart`
- `features/wallet/pages/wallet_chain_info_xrp_actions.dart`
- `features/wallet/pages/wallet_coin_item.dart`
- `features/wallet/pages/wallet_coin_list_header.dart`
- `features/wallet/pages/wallet_coin_list_section.dart`
- `features/wallet/pages/wallet_manage/add_watch_wallet_page.dart`
- `features/wallet/pages/wallet_manage/edit_wallet.dart`
- `features/wallet/pages/wallet_manage/edit_wallet_password.dart`
- `features/wallet/pages/wallet_manage/keystore/export_keystore_desc.dart`
- `features/wallet/pages/wallet_manage/keystore/export_keystore_page.dart`
- `features/wallet/pages/wallet_manage/keystore/import_keystore.dart`
- `features/wallet/pages/wallet_manage/keystore/import_privatekey.dart`
- `features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage.dart`
- `features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage_widgets.dart`
- `features/wallet/pages/wallet_manage/wallet_list.dart`
- `features/wallet/pages/wallet_manage/wallet_list_actions.dart`
- `features/wallet/pages/wallet_manage/wallet_list_face_section.dart`
- `features/wallet/pages/wallet_manage/wallet_list_tiles.dart`
- `features/wallet/pages/wallet_manage/wallet_manage.dart`
- `features/wallet/pages/wallet_network_sheet.dart`
- `features/wallet/pages/wallet_page.dart`
- `features/wallet/pages/wallet_page_helpers.dart`
- `features/wallet/pages/wallet_page_top_bar.dart`
- `features/wallet/pages/wallet_receive_qr.dart`
- `features/wallet/pages/wallet_receive_qr_content.dart`
- `features/wallet/pages/wallet_sheets.dart`
- `features/wallet/presentation/pages/wallet_page_riverpod.dart`
- `features/wallet/presentation/providers/transaction_providers.dart`
- `features/wallet/presentation/providers/wallet_providers.dart`
- `features/wallet/provider/batch_transfer_provider.dart`
- `features/wallet/provider/transaction_record_iterms_provider.dart`
- `features/wallet/provider/transaction_state_resolver.dart`
- `features/wallet/provider/trustdart.dart`
- `features/wallet/provider/wallet_action_provider.dart`
- `features/wallet/provider/wallet_action_provider_market.dart`
- `features/wallet/provider/wallet_action_provider_sort.dart`
- `features/wallet/provider/wallet_action_provider_token.dart`
- `features/wallet/provider/wallet_action_provider_wallet.dart`
- `features/wallet/services/coin_price_alert_service.dart`
- `features/wallet/services/ens_expiry_reminder_service.dart`
- `features/wallet/services/ens_management_service.dart`
- `features/wallet/services/ens_models.dart`
- `features/wallet/services/ens_registration_service.dart`
- `features/wallet/services/ens_resolution_models.dart`
- `features/wallet/services/ens_service.dart`
- `features/wallet/services/gas_alert_service.dart`
- `features/wallet/services/portfolio_trade_service.dart`
- `features/wallet/services/recent_address_service.dart`
- `features/wallet/utils/bip340.dart`
- `features/wallet/utils/browser/browser_address.dart`
- `features/wallet/utils/browser/browser_token_address.dart`
- `features/wallet/utils/browser/browser_txhash.dart`
- `features/wallet/utils/btc_base_api.dart`
- `features/wallet/utils/chain/chain_eip1559.dart`
- `features/wallet/utils/chain/chain_url_registry.dart`
- `features/wallet/utils/chain/configs/chain_url_configs_part1.dart`
- `features/wallet/utils/chain/configs/chain_url_configs_part2.dart`
- `features/wallet/utils/chain/configs/chain_url_configs_part3.dart`
- `features/wallet/utils/chain/configs/chain_url_configs_part4.dart`
- `features/wallet/utils/chain/configs/chain_url_configs_part5.dart`
- `features/wallet/utils/chain/configs/wallet_chain_configs_part1.dart`
- `features/wallet/utils/chain/configs/wallet_chain_configs_part2.dart`
- `features/wallet/utils/chain/eth_layer2_chains.dart`
- `features/wallet/utils/chain/wallet_chain_registry.dart`
- `features/wallet/utils/transaction/btc_tx_builder.dart`
- `features/wallet/utils/transaction/btc_tx_crypto.dart`
- `features/wallet/utils/transaction/btc_tx_script.dart`
- `features/wallet/utils/transaction/coin_gas.dart`
- `features/wallet/utils/transaction/create_btc_tx.dart`
- `features/wallet/utils/transaction/create_btc_tx_1.dart`
- `features/wallet/utils/transaction/create_btc_tx_2.dart`
- `features/wallet/utils/transaction/create_p2wsh.dart`
- `features/wallet/utils/validation/address_validator.dart`
- `features/wallet/utils/validation/signature_validator.dart`
- `features/wallet/utils/wallet_backup_crypto.dart`
- `features/wallet/wallet.dart`
- `features/wallet/widgets/aa/aa_transaction_preview.dart`
- `features/wallet/widgets/aa/batch_operation_item.dart`
- `features/wallet/widgets/aa/deployment_status_indicator.dart`
- `features/wallet/widgets/aa/gas_sponsorship_badge.dart`
- `features/wallet/widgets/aa/paymaster_option_card.dart`
- `features/wallet/widgets/aa/smart_account_card.dart`
- `features/wallet/widgets/about_show_dialog.dart`
- `features/wallet/widgets/address_edit.dart`
- `features/wallet/widgets/arlert_widget.dart`
- `features/wallet/widgets/board_item.dart`
- `features/wallet/widgets/choose_import_coin.dart`
- `features/wallet/widgets/create_wallet_button.dart`
- `features/wallet/widgets/ens/ens_owned_list_item.dart`
- `features/wallet/widgets/ens/ens_price_card.dart`
- `features/wallet/widgets/ens/ens_purchase_step_content.dart`
- `features/wallet/widgets/ens/ens_registration_steps.dart`
- `features/wallet/widgets/ens/ens_renew_success_card.dart`
- `features/wallet/widgets/ens/ens_search_bar.dart`
- `features/wallet/widgets/ens/ens_search_result_view.dart`
- `features/wallet/widgets/ens_address_display.dart`
- `features/wallet/widgets/ens_address_field.dart`
- `features/wallet/widgets/ens_address_text.dart`
- `features/wallet/widgets/ens_confirm_dialog.dart`
- `features/wallet/widgets/feature_entry_cards.dart`
- `features/wallet/widgets/feature_entry_cards_items.dart`
- `features/wallet/widgets/gas_selector_widget.dart`
- `features/wallet/widgets/item_wallet.dart`
- `features/wallet/widgets/nav_import_wallet.dart`
- `features/wallet/widgets/nft_info_board.dart`
- `features/wallet/widgets/non_evm_fee_selector.dart`
- `features/wallet/widgets/wallet_board.dart`
- `features/wallet/widgets/wallet_chain_info_board.dart`
- `features/wallet/widgets/wallet_chain_info_title.dart`
- `features/wallet/widgets/wallet_chain_info_transactions_item.dart`
- `features/wallet/widgets/wallet_coin_market_preview.dart`
- `features/wallet/widgets/wallet_gen_success.dart`
- `features/wallet/widgets/wallet_search_coin.dart`
- `features/wallet/widgets/wallet_search_coin_item.dart`

### features/wallet_connect (14)

- `features/wallet_connect/models/wc_eth_sign_message.dart`
- `features/wallet_connect/models/wc_eth_sign_transcation.dart`
- `features/wallet_connect/pages/wallet_connect_page.dart`
- `features/wallet_connect/pages/wallet_connect_widgets_mixin.dart`
- `features/wallet_connect/pages/wc_session_list_page.dart`
- `features/wallet_connect/presentation/providers/wallet_connect_providers.dart`
- `features/wallet_connect/provider/wallet_connect_connection.dart`
- `features/wallet_connect/provider/wallet_connect_provider.dart`
- `features/wallet_connect/provider/wallet_connect_session.dart`
- `features/wallet_connect/provider/wallet_connect_signing.dart`
- `features/wallet_connect/provider/wallet_connect_state.dart`
- `features/wallet_connect/wallet_connect.dart`
- `features/wallet_connect/widgets/tx_risk_banner_widget.dart`
- `features/wallet_connect/widgets/wallet_connect_alert_widget.dart`

### features/widgets (34)

- `features/widgets/app_bar_widget.dart`
- `features/widgets/app_home_top_bar.dart`
- `features/widgets/base_list.dart`
- `features/widgets/button_widget.dart`
- `features/widgets/candlestick_chart.dart`
- `features/widgets/chart_histogram.dart`
- `features/widgets/comm_input.dart`
- `features/widgets/container_widget.dart`
- `features/widgets/contract_security_card.dart`
- `features/widgets/custom_popup_menu_wrap.dart`
- `features/widgets/dapp_security_badge.dart`
- `features/widgets/detail_refresh_widget.dart`
- `features/widgets/dialog_widget/device_login_dialog.dart`
- `features/widgets/dialog_widget/tips_dialog_1.dart`
- `features/widgets/dialog_widget/tips_dialog_2.dart`
- `features/widgets/dialog_widget/tips_dialog_3.dart`
- `features/widgets/dialog_widget/tips_dialog_4.dart`
- `features/widgets/dialog_widget/tips_dialog_6.dart`
- `features/widgets/dialog_widget/tips_dialog_7.dart`
- `features/widgets/empty.dart`
- `features/widgets/eso_image_cachemanager.dart`
- `features/widgets/image_network.dart`
- `features/widgets/keep_state_widget.dart`
- `features/widgets/line_chart.dart`
- `features/widgets/loading.dart`
- `features/widgets/loading_page.dart`
- `features/widgets/prompt_widget.dart`
- `features/widgets/reply_empty_widget.dart`
- `features/widgets/round_refresh_icon.dart`
- `features/widgets/sheet_bottom.dart`
- `features/widgets/terms_of_service_widget.dart`
- `features/widgets/text_field_widget.dart`
- `features/widgets/tx_simulation_card.dart`
- `features/widgets/video_play_safe.dart`

### generated/intl (14)

- `generated/intl/messages_all.dart`
- `generated/intl/messages_de.dart`
- `generated/intl/messages_en.dart`
- `generated/intl/messages_es_ES.dart`
- `generated/intl/messages_fr.dart`
- `generated/intl/messages_id.dart`
- `generated/intl/messages_it.dart`
- `generated/intl/messages_ja.dart`
- `generated/intl/messages_ko.dart`
- `generated/intl/messages_pl.dart`
- `generated/intl/messages_pt.dart`
- `generated/intl/messages_ru.dart`
- `generated/intl/messages_tr.dart`
- `generated/intl/messages_vi.dart`

### generated/l10n.dart (1)

- `generated/l10n.dart`

### main.dart (1)

- `main.dart`

### presentation/themes (1)

- `presentation/themes/theme_adapter.dart`

### shared/contracts (1)

- `shared/contracts/feature_contracts.dart`

### shared/di (1)

- `shared/di/service_locator.dart`

### shared/domain (4)

- `shared/domain/entities/wallet_info.dart`
- `shared/domain/services/auth_service_interface.dart`
- `shared/domain/services/mining_service_interface.dart`
- `shared/domain/services/wallet_service_interface.dart`

### shared/events (2)

- `shared/events/cross_feature_events.dart`
- `shared/events/event_manager.dart`

## Test Inventory

### all_tests.dart (1)

- `all_tests.dart`

### benchmark

- `benchmark/core_business_benchmark_test.dart`
- `benchmark/navigation_benchmark_test.dart`
- `benchmark/startup_benchmark_test.dart`

### core/browser (1)

- `core/browser/browser_models_test.dart`

### core/config (3)

- `core/config/app_config_test.dart`
- `core/config/proxy_config_test.dart`
- `core/config/rpc_config_test.dart`

### core/enums (1)

- `core/enums/coin_type_test.dart`

### core/error (1)

- `core/error/failures_test.dart`

### core/network (5)

- `core/network/api_client_test.dart`
- `core/network/api_client_test.mocks.dart`
- `core/network/circuit_breaker_interceptor_test.dart`
- `core/network/retry_config_test.dart`
- `core/network/retry_interceptor_test.dart`

### core/performance (1)

- `core/performance/performance_config_test.dart`

### core/platform (3)

- `core/platform/chat_social_auth_config_test.dart`
- `core/platform/deep_link_service_test.dart`
- `core/platform/social_auth_native_config_test.dart`

### core/providers (5)

- `core/providers/core_providers_test.dart`
- `core/providers/locale_provider_test.dart`
- `core/providers/screen_lock_provider_test.dart`
- `core/providers/theme_provider_test.dart`
- `core/providers/use_new_chat_provider_test.dart`

### core/routing (1)

- `core/routing/deep_link_handler_test.dart`

### core/security (6)

- `core/security/device_security_test.dart`
- `core/security/goplus_security_result_test.dart`
- `core/security/phishing_detector_test.dart`
- `core/security/secure_storage_test.dart`
- `core/security/security_config_test.dart`
- `core/security/tx_risk_analyzer_test.dart`

### core/state (1)

- `core/state/async_state_test.dart`

### core/utils (8)

- `core/utils/chain_util_test.dart`
- `core/utils/data_utils_test.dart`
- `core/utils/js_escape_utils_test.dart`
- `core/utils/md5_util_test.dart`
- `core/utils/message_model_bridge_test.dart`
- `core/utils/regular_test.dart`
- `core/utils/responsive_utils_test.dart`
- `core/utils/result_test.dart`

### core/wallet (10)

- `core/wallet/aa_constants_test.dart`
- `core/wallet/aa_errors_test.dart`
- `core/wallet/address_validation_result_test.dart`
- `core/wallet/browser_collection_model_test.dart`
- `core/wallet/bundler_config_test.dart`
- `core/wallet/chain_balance_test.dart`
- `core/wallet/coin_gas_test.dart`
- `core/wallet/transfer_handler_test.dart`
- `core/wallet/user_operation_receipt_test.dart`
- `core/wallet/wc_eth_sign_transaction_test.dart`

### features/aa (8)

- `features/aa/aa_config_test.dart`
- `features/aa/account_deployer_test.dart`
- `features/aa/eip7702_handler_test.dart`
- `features/aa/gas_estimator_test.dart`
- `features/aa/session_key_test.dart`
- `features/aa/signature_builder_test.dart`
- `features/aa/smart_account_test.dart`
- `features/aa/user_operation_test.dart`

### features/airdrop (3)

- `features/airdrop/airdrop_eligibility_test.dart`
- `features/airdrop/airdrop_filter_sheet_test.dart`
- `features/airdrop/airdrop_model_test.dart`

### features/auth (3)

- `features/auth/auth_entity_test.dart`
- `features/auth/password_feature_test.dart`
- `features/auth/social_auth_test.dart`

### features/batch_transfer (1)

- `features/batch_transfer/batch_transfer_model_test.dart`

### features/bridge (3)

- `features/bridge/bridge_model_test.dart`
- `features/bridge/bridge_provider_polling_test.dart`
- `features/bridge/bridge_provider_test.dart`

### features/browser (2)

- `features/browser/browser_entity_test.dart`
- `features/browser/browser_models_test.dart`

### features/dex (1)

- `features/dex/dex_models_test.dart`

### features/earn (1)

- `features/earn/earn_provider_test.dart`

### features/ens (1)

- `features/ens/ens_service_test.dart`

### features/gas (1)

- `features/gas/gas_estimate_model_test.dart`

### features/hardware_wallet (2)

- `features/hardware_wallet/hardware_wallet_model_test.dart`
- `features/hardware_wallet/ledger_utils_test.dart`

### features/home (2)

- `features/home/exchange_account_model_test.dart`
- `features/home/version_info_model_test.dart`

### features/login (2)

- `features/login/user_info_api_test.dart`
- `features/login/user_info_model_test.dart`

### features/loyalty (2)

- `features/loyalty/loyalty_api_test.dart`
- `features/loyalty/loyalty_model_test.dart`

### features/mining (4)

- `features/mining/mining_api_test.dart`
- `features/mining/mining_entity_test.dart`
- `features/mining/mining_reward_calculation_test.dart`
- `features/mining/mining_withdrawals_model_test.dart`

### features/nft (1)

- `features/nft/nft_model_test.dart`

### features/sqlite (1)

- `features/sqlite/app_database_test.dart`

### features/staking (2)

- `features/staking/dot_feature_flag_test.dart`
- `features/staking/staking_model_test.dart`

### features/ui (1)

- `features/ui/ui_fixes_test.dart`

### features/wallet (28)

- `features/wallet/address_book_model_test.dart`
- `features/wallet/address_validation_test.dart`
- `features/wallet/aggregated_token_test.dart`
- `features/wallet/btc_input_output_model_test.dart`
- `features/wallet/btc_response_test.dart`
- `features/wallet/btc_sync_utils_test.dart`
- `features/wallet/btc_tran_detail_test.dart`
- `features/wallet/chain_config_test.dart`
- `features/wallet/coin_pin_test.dart`
- `features/wallet/common_response_item_model_test.dart`
- `features/wallet/domain/usecases/create_wallet_test.dart`
- `features/wallet/domain/usecases/get_balance_test.dart`
- `features/wallet/domain/usecases/send_transaction_test.dart`
- `features/wallet/explorer_paging_test.dart`
- `features/wallet/explorer_response_utils_test.dart`
- `features/wallet/mess_mnemonic_words_item_test.dart`
- `features/wallet/payment_code/payment_code_flow_test.dart`
- `features/wallet/providers/wallet_balance_provider_test.dart`
- `features/wallet/providers/wallet_providers_test.dart`
- `features/wallet/send/recent_address_service_test.dart`
- `features/wallet/sol_transaction_item_test.dart`
- `features/wallet/stablecoin_price_test.dart`
- `features/wallet/swap_ast_model_test.dart`
- `features/wallet/swap_ast_order_model_test.dart`
- `features/wallet/transaction_retry_test.dart`
- `features/wallet/wallet_action_provider_test.dart`
- `features/wallet/wallet_entity_test.dart`
- `features/wallet/wallet_service_balance_test.dart`

### features/wallet_connect (6)

- `features/wallet_connect/eth_tx_mapping_test.dart`
- `features/wallet_connect/personal_sign_bounds_test.dart`
- `features/wallet_connect/tron_tx_mapping_test.dart`
- `features/wallet_connect/wc_models_test.dart`
- `features/wallet_connect/wc_provider_test.dart`
- `features/wallet_connect/wc_signing_test.dart`

### helpers

- `helpers/mock_providers.dart`
- `helpers/test_helpers.dart`
- `helpers/widget_test_helpers.dart`

### integration

- `integration/app_initialization_test.dart`

### l10n

- `l10n/localization_test.dart`
- `l10n/market_i18n_test.dart`

### other test entry points

- `send/send_profile_test.dart`
- `src/models/message_model_test.dart`
- `widget/chain_ui_test.dart`
- `widget/platform_test.dart`
- `widget/theme_test.dart`
- `widget_test.dart`
- `widgets/feature_entry_cards_test.dart`

## Plugin Inventory: flutter_mining

### Dart / plugin API

- `plugins/flutter_mining/lib/flutter_mining.dart`
- `plugins/flutter_mining/lib/flutter_mining_method_channel.dart`
- `plugins/flutter_mining/lib/flutter_mining_platform_interface.dart`
- `plugins/flutter_mining/test/flutter_mining_method_channel_test.dart`
- `plugins/flutter_mining/test/flutter_mining_test.dart`
- `plugins/flutter_mining/pubspec.yaml`
- `plugins/flutter_mining/pubspec.lock`
- `plugins/flutter_mining/analysis_options.yaml`

### Android

- `plugins/flutter_mining/android/build.gradle`
- `plugins/flutter_mining/android/settings.gradle`
- `plugins/flutter_mining/android/mobile-sdk-module/build.gradle`
- `plugins/flutter_mining/android/evm-module/build.gradle`
- `plugins/flutter_mining/android/src/main/AndroidManifest.xml`
- `plugins/flutter_mining/android/src/main/kotlin/mining/ai/n42/www/flutter_mining/FlutterMiningPlugin.kt`
- `plugins/flutter_mining/android/src/test/kotlin/mining/ai/n42/www/flutter_mining/FlutterMiningPluginTest.kt`
- `plugins/flutter_mining/android/libs/evm.aar`
- `plugins/flutter_mining/android/libs/evm-sources.jar`
- `plugins/flutter_mining/android/libs/mobile-sdk-release.aar`

### iOS

- `plugins/flutter_mining/ios/Classes/FlutterMiningPlugin.swift`
- `plugins/flutter_mining/ios/flutter_mining.podspec`
- `plugins/flutter_mining/ios/Resources/PrivacyInfo.xcprivacy`

### Example

- `plugins/flutter_mining/example/lib/main.dart`
- `plugins/flutter_mining/example/test/widget_test.dart`
- `plugins/flutter_mining/example/integration_test/plugin_integration_test.dart`
- `plugins/flutter_mining/example/pubspec.yaml`
- `plugins/flutter_mining/example/pubspec.lock`

## Existing Audit / Context Files

- `audit_results/audit_consensus.md`
- `audit_results/audit_n42-mobile-ffi.md`
- `audit_results/audit_n42_chat.md`
- `audit_results/n42_chat_architecture_and_dataflow_2026-03-13.md`
- `audit_results/n42_chat_module_review_2026-03-14.md`
- `docs/production-readiness-audit-2026-03-02.md`
- `docs/CODE_AUDIT_REPORT.md`
- `docs/SECURITY_AUDIT_REPORT.md`
