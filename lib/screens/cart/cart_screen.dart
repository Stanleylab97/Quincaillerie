import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/models/Cart.dart';

import 'components/body.dart';
import 'components/check_out_card.dart';

class CartScreen extends StatelessWidget {
  static String routeName = "/cart";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
      bottomNavigationBar: CheckoutCard(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Panier du client",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          Container(
            child: Row(
              children: [
                Text(
                  "${demoCarts.length} commandes",
                  style: Theme.of(context).textTheme.caption,
                ),
                FaIcon(FontAwesomeIcons.cartPlus, color: Colors.orange.shade900,size: 30,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
