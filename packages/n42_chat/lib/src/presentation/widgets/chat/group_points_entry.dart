import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../blocs/points/points_bloc.dart';
import '../../pages/points/points_dashboard_page.dart';

/// Group-scoped entry; the host must enable and configure the points service.
class GroupPointsEntry extends StatelessWidget {
  final String roomId;
  final String? userId;
  final bool isAdmin;

  const GroupPointsEntry({
    super.key,
    required this.roomId,
    required this.userId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final id = userId;
    if (id == null || id.isEmpty || !getIt.isRegistered<PointsBloc>()) {
      return const SizedBox.shrink();
    }
    return ListTile(
      key: const ValueKey('group-points-entry'),
      leading: const Icon(Icons.stars_outlined),
      title: Text(S.of(context)?.groupPoints ?? 'Points'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => getIt<PointsBloc>(),
            child: PointsDashboardPage(
              userId: id,
              roomId: roomId,
              isAdmin: isAdmin,
            ),
          ),
        ),
      ),
    );
  }
}
