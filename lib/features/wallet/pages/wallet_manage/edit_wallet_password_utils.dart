import 'package:n42_wallet/features/component/enums/load.dart';

bool canDismissEditWalletPassword(Load load) => load != Load.loading;
