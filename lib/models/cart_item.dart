import 'package:shop_app/models/ArticleVente.dart';

class CartItem {
 late ArticleVente article;
 late int qte;

 CartItem({required this.article, required this.qte});
}


class AvalaibleProducts{
 late List<ArticleVente> products;

 AvalaibleProducts({required this.products});

}