import 'package:get/get.dart';
import 'package:shop_app/models/ArticleVente.dart';
import 'package:shop_app/models/cart_item.dart';

class CartController extends GetxController {
  var _products = {}.obs;

  void addProduct(ArticleVente article, int qte) {
    
    if (_products.keys.contains(article)) {
      if (article.qteStock > _products[article]) {
        if (qte > 0) {
          print("$qte");
          _products[article] += qte;
        } else {
          print("Incrément de 1");

          _products[article] += 1;
        }
      } else {
        Get.snackbar(
            "Attention", "Vous ne pouvez pas dépasser le stock disponible",
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2));
      }
    } else {
      print("Nouveau produit $qte");
      _products[article] = qte;
    }

    /* Get.snackbar(
        "Article ajouté", "Vous avez ajouté ${article.libelle} au panier",
        snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2)); */
  }

  get products => _products;

  void removeProduct(ArticleVente articleVente) {
    if (_products.containsKey(articleVente) && _products[articleVente] == 1) {
      _products.removeWhere((key, value) => key == articleVente);
    } else {
      _products[articleVente] -= 1;
    }
  }

  void clearCart(){
    _products.clear();
  }

  get productSubtotal => _products.entries
      .map((article) => article.key.prixUnitaire * article.value)
      .toList();

  get total => _products.length == 0
      ? 0
      : _products.entries
          .map((article) => article.key.prixUnitaire * article.value)
          .toList()
          .reduce((value, element) => value + element);
}
