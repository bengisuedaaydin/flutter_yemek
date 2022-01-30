import 'dart:developer';

import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuItem{
  int yemek_id = -1;
  String yemek_adi = "";
  String yemek_resim_adi = "";
  String yemek_fiyat = "";

  MenuItem.fromEmpty();

  MenuItem({
    required this.yemek_id,
    required this.yemek_adi,
    required this.yemek_resim_adi,
    required this.yemek_fiyat,
  });

  factory MenuItem.fromJson(dynamic json){
    try {
      return MenuItem(yemek_id: int.parse(json["yemek_id"]), yemek_adi: json["yemek_adi"], yemek_resim_adi: json["yemek_resim_adi"], yemek_fiyat: json["yemek_fiyat"]);
    } catch (e) {
      return MenuItem.fromEmpty();
    }
  }

  static Future<List<MenuItem>> GetMenuItems() async{
    final response = await http.get(Uri.parse("http://kasimadalan.pe.hu/yemekler/tumYemekleriGetir.php"));

    if(response.statusCode == 200){
      dynamic j = json.decode(response.body);
      List<dynamic> list = j["yemekler"];
      List<MenuItem> foodList = [];
      for(int i = 0; i < list.length; i++){
        foodList.add(MenuItem.fromJson(list[i]));
      }
      return foodList;
    }else{
      throw Exception("Couldn't get game");
    }
  }

  static Future<bool> AddToBasket(MenuItem item, int count) async{
    final Map<String, String> map = {
      "yemek_adi": item.yemek_adi,
      "yemek_resim_adi": item.yemek_resim_adi,
      "yemek_fiyat": item.yemek_fiyat,
      "yemek_siparis_adet": count.toString(),
      "kullanici_adi": "bengisu_eda"
    };
    final response = await http.post(Uri.parse("http://kasimadalan.pe.hu/yemekler/sepeteYemekEkle.php"), body: map);

    if(response.statusCode == 200) {
      if(response.body.contains("success\":1"))
        return Future<bool>.value(true);
      else
        return Future<bool>.value(false);
    }else{
      return Future<bool>.value(false);
    }
  }

}