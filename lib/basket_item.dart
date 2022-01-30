import 'dart:developer';

import 'dart:convert';
import 'package:flutter_yemek/menu_item.dart';
import 'package:http/http.dart' as http;

class BasketItem{
  int sepet_yemek_id = -1;
  String yemek_adi = "";
  String yemek_resim_adi = "";
  String yemek_fiyat = "";
  String yemek_siparis_adet = "";
  String kullanici_adi = "";

  BasketItem.fromEmpty();

  BasketItem({
    required this.sepet_yemek_id,
    required this.yemek_adi,
    required this.yemek_resim_adi,
    required this.yemek_fiyat,
    required this.yemek_siparis_adet,
    required this.kullanici_adi,
  });

  factory BasketItem.fromJson(dynamic json){
    try {
      return BasketItem(sepet_yemek_id: int.parse(json["sepet_yemek_id"]), yemek_adi: json["yemek_adi"], yemek_resim_adi: json["yemek_resim_adi"], yemek_fiyat: json["yemek_fiyat"], yemek_siparis_adet: json["yemek_siparis_adet"], kullanici_adi: json["kullanici_adi"]);
    } catch (e) {
      return BasketItem.fromEmpty();
    }
  }

  static Future<List<BasketItem>> GetBasketItems() async{
    final response = await http.post(Uri.parse("http://kasimadalan.pe.hu/yemekler/sepettekiYemekleriGetir.php"), body: {"kullanici_adi": "bengisu_eda"});

    if(response.statusCode == 200){
      try {
        dynamic j = json.decode(response.body);
        List<dynamic> list = j["sepet_yemekler"];
        List<BasketItem> foodList = [];
        for (int i = 0; i < list.length; i++) {
          foodList.add(BasketItem.fromJson(list[i]));
        }
        return foodList;
      }catch(e){
        return [];
      }
    }else{
      throw Exception("Couldn't get game");
    }
  }

  static Future<bool> DeleteFromBasket(BasketItem item) async{
    final Map<String, String> map = {
      "sepet_yemek_id": item.sepet_yemek_id.toString(),
      "kullanici_adi": "bengisu_eda"
    };
    final response = await http.post(Uri.parse("http://kasimadalan.pe.hu/yemekler/sepettenYemekSil.php"), body: map);

    if(response.statusCode == 200) {
      if(response.body.contains("success\":1"))
        return Future<bool>.value(true);
      else
        return Future<bool>.value(false);
    }else{
      return Future<bool>.value(false);
    }
  }

  static Future<bool> UpdateFromBasket(BasketItem item, int count) async{
    bool isDeleted = await DeleteFromBasket(item);

    if(isDeleted){
      bool isAdded = true;
      if(count > 0) {
        MenuItem menuItem = MenuItem(yemek_id: -1,
            yemek_adi: item.yemek_adi,
            yemek_resim_adi: item.yemek_resim_adi,
            yemek_fiyat: item.yemek_fiyat);
        isAdded = await MenuItem.AddToBasket(menuItem, count);
      }

      if(isAdded) {
        return Future<bool>.value(true);
      }else{
        return Future<bool>.value(false);
      }
    }else{
      return Future<bool>.value(false);
    }

  }

}