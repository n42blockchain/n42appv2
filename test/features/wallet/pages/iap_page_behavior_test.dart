import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:n42_wallet/features/wallet/pages/iap/iap_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _FakeInAppPurchasePlatform extends InAppPurchasePlatform {
  final StreamController<List<PurchaseDetails>> updates =
      StreamController<List<PurchaseDetails>>.broadcast(sync: true);
  bool available = true;
  bool purchaseStarted = true;
  bool throwWhenPurchasing = false;
  int availabilityRequests = 0;
  int restoreRequests = 0;
  Set<String>? queriedIds;
  List<ProductDetails> products = [];
  final purchaseRequests = <PurchaseParam>[];
  final completedPurchases = <PurchaseDetails>[];

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<bool> isAvailable() async {
    availabilityRequests++;
    return available;
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    queriedIds = identifiers;
    return ProductDetailsResponse(productDetails: products, notFoundIDs: []);
  }

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    purchaseRequests.add(purchaseParam);
    if (throwWhenPurchasing) throw StateError('synthetic store failure');
    return purchaseStarted;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completedPurchases.add(purchase);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreRequests++;
  }
}

ProductDetails _product({
  required String id,
  required String title,
  required double rawPrice,
}) => ProductDetails(
  id: id,
  title: title,
  description: '$title description',
  price: '\$${rawPrice.toStringAsFixed(2)}',
  rawPrice: rawPrice,
  currencyCode: 'USD',
);

PurchaseDetails _purchase(String productId, PurchaseStatus status) =>
    PurchaseDetails(
      productID: productId,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'synthetic-local-receipt',
        serverVerificationData: 'synthetic-server-receipt',
        source: 'test',
      ),
      transactionDate: '0',
      status: status,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late _FakeInAppPurchasePlatform store;
  late List<String> toastMessages;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    InAppPurchase.instance;
    debugDefaultTargetPlatformOverride = null;
    store = _FakeInAppPurchasePlatform();
    toastMessages = [];
    InAppPurchasePlatform.instance = store;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          if (call.method == 'showToast') {
            toastMessages.add((call.arguments as Map)['msg'].toString());
          }
          return true;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
    await store.updates.close();
  });

  Future<void> openPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() => tester.pump(const Duration(seconds: 8)));
    await tester.pumpWidget(wrapForTest(const IapPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  testWidgets('unavailable store can be retried and then shows products', (
    tester,
  ) async {
    store.available = false;
    store.products = [
      _product(id: 'ai.n42.www.n.4', title: 'Four credits', rawPrice: 4),
    ];

    await openPage(tester);

    expect(find.text(S.current.g_iap_retry), findsOneWidget);
    expect(store.queriedIds, isNull);

    store.available = true;
    await tester.tap(find.text(S.current.g_iap_retry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('Four credits'), findsOneWidget);
    expect(store.queriedIds, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('available products are ordered by their numeric prices', (
    tester,
  ) async {
    store.products = [
      _product(id: 'ai.n42.www.n.10', title: 'Ten credits', rawPrice: 10),
      _product(id: 'ai.n42.www.n.4', title: 'Four credits', rawPrice: 4),
    ];

    await openPage(tester);

    expect(find.text('Four credits'), findsOneWidget);
    expect(find.text('Ten credits'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Four credits')).dy,
      lessThan(tester.getTopLeft(find.text('Ten credits')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending purchase stays busy until completion arrives', (
    tester,
  ) async {
    const productId = 'ai.n42.www.n.4';
    store.products = [
      _product(id: productId, title: 'Four credits', rawPrice: 4),
    ];
    await openPage(tester);

    await tester.tap(find.text(r'$4.00'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(store.purchaseRequests, hasLength(1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final pending = _purchase(productId, PurchaseStatus.pending);
    store.updates.add([pending]);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final purchased = _purchase(productId, PurchaseStatus.purchased);
    store.updates.add([purchased]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(store.completedPurchases, [same(purchased)]);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('failed purchase start clears its busy state', (tester) async {
    store.purchaseStarted = false;
    store.products = [
      _product(id: 'ai.n42.www.n.4', title: 'Four credits', rawPrice: 4),
    ];
    await openPage(tester);

    await tester.tap(find.text(r'$4.00'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(store.purchaseRequests, hasLength(1));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('purchase launch exception clears its busy state', (
    tester,
  ) async {
    store.throwWhenPurchasing = true;
    store.products = [
      _product(id: 'ai.n42.www.n.4', title: 'Four credits', rawPrice: 4),
    ];
    await openPage(tester);

    await tester.tap(find.text(r'$4.00'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(store.purchaseRequests, hasLength(1));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(toastMessages, [contains('synthetic store failure')]);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });
}
