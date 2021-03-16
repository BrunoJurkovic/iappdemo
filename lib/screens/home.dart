import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int gems = 0;

  StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> products = [];

  List<PurchaseDetails> _purchases = [];

  void _consumeGems() {
    setState(() {
      gems -= 2;
    });
  }

  Future<void> _fetchProducts() async {
    Set<String> productIds = {'android.test.purchased'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(productIds);
    setState(() {
      products = response.productDetails;
      processTransaction();
    });
  }

  void processTransaction() async {
    PurchaseDetails purchase = getPurchaseById('android.test.purchased');

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      setState(() {
        gems += 20;
      });
    }

    await InAppPurchaseConnection.instance.completePurchase(purchase);
  }

  void _makePurchase(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchaseConnection.instance
        .buyConsumable(purchaseParam: purchaseParam);
  }

  PurchaseDetails getPurchaseById(String id) {
    return _purchases.firstWhere((element) => element.productID == id,
        orElse: () => null);
  }

  Future<void> initialization() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    if (!available) {
      debugPrint('ERROR: UNAVAILABLE');
      return;
    }
    _fetchProducts();

    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      processTransaction();
      setState(() {
        _purchases.addAll(purchases);
      });
    });
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IAPP Demo'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 250,
              width: 250,
              child: Image.asset('assets/gem.png'),
            ),
          ),
          Center(
            child: Text(
              gems.toString(),
              style: TextStyle(fontSize: 48),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 100),
            child: ElevatedButton(
              onPressed: () {
                _consumeGems();
              },
              child: Text(
                'Consume 2',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 100),
            child: ElevatedButton(
              onPressed: () {
                _makePurchase(products[0]);
              },
              child: Text(
                'Buy more gems!',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
