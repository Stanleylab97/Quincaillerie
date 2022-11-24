import 'package:flutter/material.dart';
import 'package:shop_app/controllers/cart_controller.dart';
import 'package:shop_app/models/cart_item.dart';

class CartProductCard extends StatelessWidget {
  late CartItem product;
  final CartController controller;
  final int index;
  CartProductCard(
      {required this.product, required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.article.libelle,
                    style: Theme.of(context).textTheme.headline6),
                Text(
                  "${product.article.prixUnitaire} F",
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    controller.removeProduct(product.article);
                  },
                  icon: Icon(Icons.remove_circle)),
              Text("${product.qte}"),
              IconButton(onPressed: () {
                controller.addProduct(product.article,0);
              }, icon: Icon(Icons.add_circle)),
            ],
          )
        ],
      ),
    );
  }
}
