import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;

  ProductsGrid({
    required this.showOnlyFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showOnlyFavorites ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
        // GridView.builder than GridView has better perfomance
        itemCount: products.length,
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return ChangeNotifierProvider.value(
            value: products[index],
            child: ProductItem(),
          );
        });
  }
}
