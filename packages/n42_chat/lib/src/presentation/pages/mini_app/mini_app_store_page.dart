import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/mini_app_store_service.dart';
import '../../../domain/entities/mini_app_entity.dart';

/// Mini App 应用商店页面。
///
/// - 顶部分类 Tab
/// - 已安装列表
/// - 可发现/推荐列表（远端 API 接入后填充）
class MiniAppStorePage extends StatefulWidget {
  const MiniAppStorePage({super.key});

  @override
  State<MiniAppStorePage> createState() => _MiniAppStorePageState();
}

class _MiniAppStorePageState extends State<MiniAppStorePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MiniAppStoreService _store;

  final _categories = MiniAppCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length + 1, vsync: this);
    _store = getIt.isRegistered<MiniAppStoreService>()
        ? getIt<MiniAppStoreService>()
        : MiniAppStoreService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini App 商店'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: '全部'),
            ..._categories.map((c) => Tab(text: c.label)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppList(null),
          ..._categories.map((c) => _buildAppList(c)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomApp,
        icon: const Icon(Icons.add),
        label: const Text('添加自定义'),
      ),
    );
  }

  Widget _buildAppList(MiniAppCategory? category) {
    return StreamBuilder<List<MiniAppEntity>>(
      stream: _store.installedStream,
      initialData: _store.installedApps,
      builder: (context, snapshot) {
        var apps = snapshot.data ?? [];
        if (category != null) {
          apps = apps.where((a) => a.category == category).toList();
        }

        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apps_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  category != null ? '该分类暂无应用' : '暂无已安装应用',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: apps.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final app = apps[index];
            return Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: app.iconUrl.startsWith('http')
                      ? Image.network(app.iconUrl,
                          width: 44, height: 44, fit: BoxFit.cover)
                      : Container(
                          width: 44,
                          height: 44,
                          color: Colors.blue[100],
                          child: const Icon(Icons.extension),
                        ),
                ),
                title: Text(app.name),
                subtitle: Text(
                  app.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: app.isBuiltIn
                    ? const Chip(label: Text('内置', style: TextStyle(fontSize: 10)))
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _confirmUninstall(app),
                      ),
                onTap: () => _openApp(app),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addCustomApp() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('添加自定义 Mini App'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://app.example.com',
            labelText: 'App URL',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;

    final app = MiniAppEntity(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: Uri.tryParse(url)?.host ?? 'Custom App',
      description: url,
      url: url,
      iconUrl: '',
      category: MiniAppCategory.tools,
      permissions: const [MiniAppPermission.chatRead],
    );
    await _store.install(app);
  }

  Future<void> _confirmUninstall(MiniAppEntity app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('卸载应用'),
        content: Text('确定卸载 "${app.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('卸载', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _store.uninstall(app.id);
    }
  }

  void _openApp(MiniAppEntity app) {
    // 导航到 MiniApp WebView 页面（已有 mini_app 基础设施）
    Navigator.pop(context, app);
  }
}
