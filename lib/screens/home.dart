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

  // This is a list of all the purchases that will be made later on
  // inside the app.
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

  // We use this function to make sure that all of the code
  void processTransaction() {
    PurchaseDetails purchase = getPurchaseById('android.test.purchased');

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      setState(() {
        gems += 20;
      });
    }
    // We have to call this function or the purchase will be refunded in 30 days.
    InAppPurchaseConnection.instance.completePurchase(purchase);
  }

  // Simple function for actually displaying the purchase sheet.
  void _makePurchase(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchaseConnection.instance
        .buyConsumable(purchaseParam: purchaseParam);
  }

  // We have to make sure that the purchase exists before we give it to the user.
  PurchaseDetails getPurchaseById(String id) {
    return _purchases.firstWhere((element) => element.productID == id);
  }

  // A collection of all the function in the app.
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
          Container(
            padding: const EdgeInsets.only(top: 100),
            child: ElevatedButton(
              onPressed: () {
                _makePurchase(products[
                    0]); // As there is only one product, we know where it is in the map.
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
