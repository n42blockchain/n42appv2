import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/contact/contact_bloc.dart';
import '../contact/contact_detail_page.dart';

/// Keep the contact state when opening a profile from a nested Moments route.
Future<void> openMomentAuthor(
  BuildContext context, {
  required String userId,
  required String displayName,
  String? avatarUrl,
}) async {
  if (!userId.startsWith('@') || !userId.contains(':')) return;
  final contacts = context.read<ContactBloc?>();
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) {
        final page = ContactDetailPage(
          userId: userId,
          displayName: displayName,
          avatarUrl: avatarUrl,
        );
        return contacts == null
            ? page
            : BlocProvider<ContactBloc>.value(value: contacts, child: page);
      },
    ),
  );
}
