import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:shop_app/models/ArticleVente.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/repository/avalaible_products_repository.dart';

part 'vente_event.dart';
part 'vente_state.dart';

class VenteBloc extends Bloc<VenteEvent, VenteState> {
AvailableDataProvider ventedataProvider= AvailableDataProvider();

  VenteBloc() : super(VenteInitial()) {
    
    //add(VentePageInitializedEvent());

   
   on<VentePageInitializedEvent>((event, emit) async {
    AvalaibleProducts avalaibleProducts= await ventedataProvider.getAvailableproducts();
        List<CartItem> cartData= await ventedataProvider.getCartItems();
        
    emit(VentePageLoadedState(avalaibleProducts: avalaibleProducts, cartData: cartData));
   });

    on<ItemAddingCartEvent>((event, emit) async {
      emit(ItemAddingCartState(cartItems: event.cartItems));
    });


    on<ItemAddedCartEvent>((event, emit) async {
      emit(ItemAddedCartState(cartItems: event.cartItems));
    });

   on<ItemDeletedCartEvent>((event, emit) async {
      emit(ItemDeletingCartState(cartItems: event.cartItems));
    });


  }
}
