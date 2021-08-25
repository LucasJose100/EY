import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String id, String token, String userId) async {
    var _params = {'auth': token};
    final oldState = isFavorite;
    isFavorite = !isFavorite;

    final url = Uri.https('shop-app-9aaa4-default-rtdb.firebaseio.com',
        '/userFavorites/$userId/$id.json', _params);

    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );

      if (response.statusCode >= 400) {
        isFavorite = oldState;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldState;
    }

    notifyListeners();
  }
}
