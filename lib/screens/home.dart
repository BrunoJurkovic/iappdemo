import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int gems = 2;
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
              gems.toString(),
              style: TextStyle(fontSize: 48),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 100),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                'Consume 5',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
