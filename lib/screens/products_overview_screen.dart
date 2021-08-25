import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions { Favorites, All }

class ProductsOverview extends StatefulWidget {
  const ProductsOverview({Key? key}) : super(key: key);

  @override
  _ProductsOverviewState createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  var _showOnlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    _isLoading = true;
    Provider.of<Products>(context, listen: false).fetchProducts().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(title: Text('ShopApp'), actions: [
        PopupMenuButton(
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              if (selectedValue == FilterOptions.Favorites) {
                _showOnlyFavorites = true;
              } else {
                _showOnlyFavorites = false;
              }
            });
          },
          icon: Icon(
            Icons.more_vert,
          ),
          itemBuilder: (_) => [
            PopupMenuItem(
                child: Text('Only Favorites'), value: FilterOptions.Favorites),
            PopupMenuItem(
              child: Text('Show All'),
              value: FilterOptions.All,
            ),
          ],
        ),
        Consumer<Cart>(
            builder: (_, cartData, ch) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      },
                      icon: Icon(Icons.shopping_cart),
                    ),
                    Text(
                      cartData.itemCount.toString(),
                      style: TextStyle(backgroundColor: Colors.red),
                    ),
                  ],
                ))
      ]),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(showOnlyFavorites: _showOnlyFavorites),
    );
  }
}
