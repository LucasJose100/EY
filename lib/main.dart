import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/order_screens.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import 'screens/products_overview_screen.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(null, null, []),
            update: (context, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders(null, '', []),
            update: (context, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: auth.isAuth
                ? ProductsOverview()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? Center(
                                child: Text('Loading...'),
                              )
                            : AuthScreen(),
                  ),
            theme: ThemeData(
              primarySwatch: Colors.yellow,
              accentColor: Colors.yellow.shade900,
              buttonColor: Colors.red.shade500,
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
              }),
            ),
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrderScreen.routeName: (context) => OrderScreen(),
              UserProductScreen.routeName: (context) => UserProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ),
      ),
    );
