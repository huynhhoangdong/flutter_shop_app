import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_providers.dart';
import '../widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool isFavs;

  ProductGrid(this.isFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProviders>(context, listen: false);
    final products = isFavs ? productsData.favoriteItems : productsData.items;
    // print(products.length);
    // products.forEach((element) {
    //   print(element.isFavorite);
    // });
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProducItem(),
            ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10));
  }
}
