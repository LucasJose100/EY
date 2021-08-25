import 'package:flutter/material.dart';

class ShopAppScreen extends StatefulWidget {
  ShopAppScreen({Key? key}) : super(key: key);

  @override
  _ShopAppScreenState createState() => _ShopAppScreenState();
}

class _ShopAppScreenState extends State<ShopAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShopApp'),
      ),
      backgroundColor: Colors.black,
    );
  }
}
