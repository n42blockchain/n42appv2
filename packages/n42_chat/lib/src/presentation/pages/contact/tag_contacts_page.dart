import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../widgets/common/common_widgets.dart';
import 'contact_detail_page.dart';
import 'contact_tile.dart';

/// Shows current assignments, not the catalog's potentially stale ID snapshot.
class TagContactsPage extends StatefulWidget {
  final String tag;
  const TagContactsPage({super.key, required this.tag});
  @override
  State<TagContactsPage> createState() => _TagContactsPageState();
}

class _TagContactsPageState extends State<TagContactsPage> {
  List<ContactEntity> _contacts = const [];
  bool _loading = true;
  bool _failed = false;
  (String?, String?)? _identity;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<(String?, String?)> _currentIdentity() async {
    final session = await SecureStorageDataSource().getSession();
    return (session?['homeserver'], session?['userId']);
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final identity = await _currentIdentity();
      if (identity.$1 == null || identity.$2 == null)
        throw StateError('No account');
      _identity ??= identity;
      if (_identity != identity) throw StateError('Account changed');
      final all = await getIt<IContactRepository>().getContacts();
      if (await _currentIdentity() != identity)
        throw StateError('Account changed');
      final contacts = all.where((c) => c.tags.contains(widget.tag)).toList()
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      if (mounted && request == _request) setState(() => _contacts = contacts);
    } catch (_) {
      if (mounted && request == _request)
        setState(() {
          _contacts = [];
          _failed = true;
        });
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(title: widget.tag, showBackButton: true),
      body: _loading
          ? const N42Loading()
          : _failed
          ? N42EmptyState.error(
              title: l10n.commonLoadFailed,
              buttonText: l10n.commonRetry,
              onButtonPressed: _load,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_contacts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: N42EmptyState.noData(title: l10n.commonNoContacts),
                    )
                  else
                    SliverList.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) => ContactTile(
                        contact: _contacts[index],
                        onTap: () async {
                          final identity = await _currentIdentity();
                          if (!context.mounted || identity != _identity) return;
                          final contact = _contacts[index];
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => ContactDetailPage(
                                userId: contact.userId,
                                displayName: contact.effectiveDisplayName,
                                avatarUrl: contact.avatarUrl,
                              ),
                            ),
                          );
                          if (mounted) await _load();
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
