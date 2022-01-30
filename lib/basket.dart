import 'package:flutter/material.dart';
import 'package:flutter_yemek/basket_item.dart';
import 'package:flutter_yemek/menu_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sepet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BasketPage(title: 'Sepet'),
    );
  }
}

class BasketPage extends StatefulWidget {
  BasketPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<BasketItem> allBasketItems = [];
  List<TextEditingController> _controllers = [];
  List<String> allCounts = [];
  int totalPrice = 0;

  Future<void> getBasketItems() async {
    allBasketItems.clear();
    _controllers.clear();
    allCounts.clear();
    totalPrice = 0;

    Future<List<BasketItem>> items = BasketItem.GetBasketItems();
    items.then((value) {
      allBasketItems.addAll(value);
      for (int i = 0; i < allBasketItems.length; i++) {
        allCounts.add(allBasketItems[i].yemek_siparis_adet);
        totalPrice += (int.parse(allBasketItems[i].yemek_fiyat) * int.parse(allBasketItems[i].yemek_siparis_adet));
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getBasketItems();
  }

  Widget getBasketItemWidget(int pos) {
    _controllers[pos].text = allCounts[pos];
    return Container(
      height: 50,
      color: const Color(0xfff3f6fb),
      child: Row(
        children: [
          Expanded(
            child: Image.network("http://kasimadalan.pe.hu/yemekler/resimler/" +
                allBasketItems[pos].yemek_resim_adi),
            flex: 2,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allBasketItems[pos].yemek_adi,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  (int.parse(allBasketItems[pos].yemek_fiyat) *
                              int.parse(allBasketItems[pos].yemek_siparis_adet))
                          .toString() +
                      ",00 ₺",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            flex: 3,
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  child: ElevatedButton(
                      onPressed: () {
                        int count = int.parse(_controllers[pos].text);
                        if (count > 0) count--;
                        _controllers[pos].text = count.toString();
                        allCounts[pos] = count.toString();
                        setState(() {});
                      },
                      child: Text(
                        "-",
                        textAlign: TextAlign.center,
                      )),
                  height: 30,
                  width: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: TextField(
                    enabled: false,
                    textAlign: TextAlign.center,
                    controller: _controllers[pos],
                  ),
                  height: 30,
                  width: 30,
                ),
                Container(
                  child: ElevatedButton(
                      onPressed: () {
                        int count = int.parse(_controllers[pos].text);
                        count++;
                        _controllers[pos].text = count.toString();
                        allCounts[pos] = count.toString();
                        setState(() {});
                      },
                      child: Text(
                        "+",
                        textAlign: TextAlign.center,
                      )),
                  height: 30,
                  width: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  child: getButton(
                      _controllers[pos].text,
                      allBasketItems[pos].yemek_siparis_adet,
                      allBasketItems[pos],
                      pos),
                  height: 30,
                  width: 50,
                ),
              ],
            ),
            flex: 3,
          )
        ],
      ),
    );
  }

  Widget getButton(
      String currentCount, String startCount, BasketItem item, int pos) {
    if (currentCount == startCount) {
      return ElevatedButton(
          onPressed: () {
            Future<bool> res = BasketItem.DeleteFromBasket(item);
            res.then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Ürünler Başarıyla Sepetinizden Kaldırıldı."),
                ));
              } else
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Ürünler Sepetten Kaldırılırken Hata Oluştu! Tekrar Deneyiniz."),
                ));
              getBasketItems();
            });
          },
          child: Center(
            child: Icon(
              Icons.delete,
              size: 16,
            ),
          ));
    } else {
      return ElevatedButton(
          onPressed: () {
            Future<bool> res =
                BasketItem.UpdateFromBasket(item, int.parse(currentCount));
            res.then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Ürünler Başarıyla Güncellendi."),
                ));
                allCounts[pos] = currentCount;
              } else
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Ürünler Güncellenirken Hata Oluştu."),
                ));
              getBasketItems();
            });
          },
          child: Center(
            child: Icon(
              Icons.update,
              size: 16,
            ),
          ));
    }
  }

  void makeOrder() async{
    for (int i = 0; i < allBasketItems.length; i++) {
      await BasketItem.DeleteFromBasket(allBasketItems[i]);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Siparişiniz başarıyla alındı!"),
        ));
    getBasketItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Container(
                child: ListView.separated(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    separatorBuilder: (context, index) => Divider(
                          color: Colors.black,
                        ),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: allBasketItems.length,
                    itemBuilder: (BuildContext context, int position) {
                      var newController = new TextEditingController();
                      newController.text = "0";
                      _controllers.add(newController);
                      return getBasketItemWidget(position);
                    })),
            Container(
              height: 50,
              color: Colors.white,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 30),
                        child: Text("Toplam Tutar: " + totalPrice.toString() + ",00 ₺",style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              if(allBasketItems.length > 0) {
                                makeOrder();
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Sepetiniz boş!"),
                                    ));
                              }
                            },
                            child: Text(
                              "Sepeti Onayla",
                              textAlign: TextAlign.center,),)
                        ),
                      flex: 1,
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
