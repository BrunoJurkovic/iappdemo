import 'package:flutter/material.dart';
import 'package:iappdemo/screens/home.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  // We have to initialize the plugin because on Android
  // you can't make purchases unless you run this function.
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In App Purchases',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
