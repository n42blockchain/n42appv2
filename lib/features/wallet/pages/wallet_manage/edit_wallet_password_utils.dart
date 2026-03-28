import 'package:n42_wallet/core/enums/load.dart';

bool canDismissEditWalletPassword(Load load) => load != Load.loading;
