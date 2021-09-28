import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_providers.dart';
import 'package:shop_app/widgets/drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-product-item";
  Future<void> _refeshIndicator(BuildContext context) async {
    await Provider.of<ProductProviders>(context, listen: false)
        .getProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<ProductProviders>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refeshIndicator(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refeshIndicator(context),
                    child: Consumer<ProductProviders>(
                      builder: (context, products, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: products.items.length,
                          itemBuilder: (context, i) => Column(
                            children: [
                              UserProductItem(
                                  products.items[i].id,
                                  products.items[i].title,
                                  products.items[i].imageUrl),
                              Divider()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
