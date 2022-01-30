import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yemek/basket.dart';
import 'package:flutter_yemek/menu_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Menu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MenuItem> allMenuItems = [];
  List<TextEditingController> _controllers = [];

  Future<void> getMenuItems() async {
    allMenuItems.clear();
    Future<List<MenuItem>> items = MenuItem.GetMenuItems();
    items.then((value) {
      allMenuItems.addAll(value);
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getMenuItems();
  }

  Widget getMenuItemWidget(int pos) {

    return Container(
      height: 50,
      color: const Color(0xfff3f6fb),
      child: Row(
        children: [
          Expanded(
            child: Image.network("http://kasimadalan.pe.hu/yemekler/resimler/" +
                allMenuItems[pos].yemek_resim_adi),
            flex: 2,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allMenuItems[pos].yemek_adi,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  allMenuItems[pos].yemek_fiyat + ",00 ₺",
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
                        if(count > 0)
                          count--;
                        _controllers[pos].text = count.toString();
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
                      },
                      child: Text(
                        "+",
                        textAlign: TextAlign.center,
                      )),
                  height: 30,
                  width: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(left:5),
                  child: ElevatedButton(
                      onPressed: () {
                        Future<bool> res = MenuItem.AddToBasket(allMenuItems[pos], int.parse(_controllers[pos].text));
                        res.then((value) {
                          if(value) {
                            _controllers[pos].text = "0";
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Ürünler Başarıyla Sepetinize Eklendi"),
                            ));
                          }else
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Ürünler Sepete Eklenirken Hata Oluştu! Tekrar Deneyiniz."),
                            ));
                        });
                      },
                      child: Center(
                        child: Icon(
                          Icons.shopping_basket,
                          size: 16,
                        ),
                      )
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BasketPage(title: "Sepet")),
                );
              },
              child: Icon(
                  Icons.shopping_basket
              ),
            ),
          )
        ],
      ),
      body: Container(
          child: ListView.separated(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              separatorBuilder: (context, index) => Divider(
                    color: Colors.black,
                  ),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: allMenuItems.length,
              itemBuilder: (BuildContext context, int position) {
                var newController = new TextEditingController();
                newController.text = "0";
                _controllers.add(newController);
                return getMenuItemWidget(position);
              })),
    );
  }
}
