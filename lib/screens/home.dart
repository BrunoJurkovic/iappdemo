import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This is our mock currency.
  int gems = 0;

  // The [in_app_purchase] package gives out our payment status
  // in the form of a Stream. We will listen to it later to update
  // our UI accordingly.
  StreamSubscription<List<PurchaseDetails>> _subscription;

  // We have to load our products from the relevant store front.
  List<ProductDetails> products = [];

  List<PurchaseDetails> _purchases = [];

  // This function takes the existing gems and
  // gives reduces it by 5.
  // It's purpose is to simmulate a user buying something
  // with the in-app currency.
  void _consumeGems() {
    setState(() {
      // We call setState() so that when we consume the product, the UI updates.
      gems -= 2;
    });
  }

  // To have any success with making purchases, we have to fetch all of the product
  // details from the relevant store front first.
  Future<void> _fetchProducts() async {
    Set<String> productIds = {
      'android.test.purchased' // This is the mock id for purchases
    };
    final ProductDetailsResponse response = await InAppPurchaseConnection
        .instance
        .queryProductDetails(productIds); // Returns a list of [ProductDetails]
    setState(() {
      products = response.productDetails;
    });
  }

  void processTransaction() {
    PurchaseDetails purchase = getPurchaseById('android.test.purchased');

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      setState(() {
        gems += 20;
      });
    }
    InAppPurchaseConnection.instance.completePurchase(purchase);
  }

  void _makePurchase(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchaseConnection.instance
        .buyConsumable(purchaseParam: purchaseParam);
  }

  PurchaseDetails getPurchaseById(String id) {
    return _purchases.firstWhere((element) => element.productID == id);
  }

  Future<void> initialization() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    if (!available) {
      debugPrint('ERROR: UNAVAILABLE');
      return;
    }
    _fetchProducts();
    processTransaction();

    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      setState(() {
        _purchases.addAll(purchases);
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _handlePurchaseUpdates(purchases) {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription =
        purchaseUpdated.listen((purchaseDetailsList) {}, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IAPP Demo'),
        actions: [],
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
              gems.toString(), // Here we display the current amount of our currency.
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
        ],
      ),
    );
  }
}
