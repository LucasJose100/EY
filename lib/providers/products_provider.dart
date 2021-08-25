import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';

import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _products = [];
  late final String? authToken;
  late final String? userId;

  Products(this.authToken, this.userId, this._products);

  List<Product> get items {
    return [..._products];
  }

  List<Product> get favoriteItems {
    return _products.where((element) => element.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    var _params = {
      'auth': authToken,
    };

    if (filterByUser) {
      _params = {
        'auth': authToken,
        'orderBy': '"userId"',
        'equalTo': '"$userId"',
      };
    }

    var url = Uri.https('shop-app-9aaa4-default-rtdb.firebaseio.com',
        '/products.json', _params);

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData.isEmpty) {
        return;
      }
      url = Uri.https('shop-app-9aaa4-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', _params);

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];

      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          price: productData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });
      _products = loadedProducts.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    var _params = {'auth': authToken};
    final url = Uri.https('shop-app-9aaa4-default-rtdb.firebaseio.com',
        '/products.json', _params);

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'userId': userId
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );

      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    var _params = {'auth': authToken};
    final url = Uri.https('shop-app-9aaa4-default-rtdb.firebaseio.com',
        '/products/$id.json', _params);
    http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }));
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    _products[prodIndex] = newProduct;

    notifyListeners();
  }

  // This guarantee that the product is readded to the list if the removal failed
  void deleteProduct(String productId) {
    var _params = {'auth': authToken};
    final url = Uri.https('shop-app-9aaa4-default-rtdb.firebaseio.com',
        '/products/$productId.json', _params);

    final existingProductIndex =
        _products.indexWhere((product) => product.id == productId);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);

    _products.removeWhere((prod) => prod.id == productId);

    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw ('Could not delete the product...');
      }
      existingProduct.dispose();
    }).catchError((_) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
    notifyListeners();
  }
}
