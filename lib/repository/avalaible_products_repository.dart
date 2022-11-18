import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:logger/logger.dart';
import 'package:shop_app/helper/networkHandler.dart';
import 'package:shop_app/models/ArticleVente.dart';
import 'package:shop_app/models/cart_item.dart';

class AvailableDataProvider {
  NetworkHandler networkHandler = NetworkHandler();
  Logger log = Logger();

   isConnected() async {
    return await DataConnectionChecker().connectionStatus;
    // actively listen for status update
  }

  Future<AvalaibleProducts> getAvailableproducts() async{
     DataConnectionStatus status = await isConnected();
    List<ArticleVente> list = [];
    if (status == DataConnectionStatus.connected) {
      var response = await networkHandler.get("/allArticleVentes");

      if (response.statusCode == 200) {
        Map<String, dynamic> output = json.decode(response.body);
        var y = output['object']
            .map((article) => ArticleVente.fromJson(article))
            .toList();
        // log.v(y);
        for (ArticleVente i in y) {
          list.add(i);
        }
        log.v(output);
       return AvalaibleProducts(products: list) ;
      } else {
       
          if (response.statusCode == 401) {
           log.i('Token invalide. Veuillez vous reconnecter');
          }

          if (response.statusCode == 500) {        
            log.e('Erreur : ${response.body}: ');
          }
          return AvalaibleProducts(products: []) ;
      }
    } else {
      log.i('Veuillez vérifier votre connexion internet');
      return AvalaibleProducts(products: []) ;
    }
  }


 Future<List<CartItem>> getCartItems() async{
    // DataConnectionStatus status = await isConnected();
     List<CartItem> list = [];
    return list;
  } 
  
  
}