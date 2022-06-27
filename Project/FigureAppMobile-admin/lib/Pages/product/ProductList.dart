import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/db/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin/Pages/product/update_product.dart';
import 'package:admin/Pages/product/add_product.dart';

class Product{
  List images;
  List colors;
  List sizes;

  Product.fromMap(Map<String,dynamic> data){
    sizes = data['sizes'];
    images = data['images'];
    colors = data['colors'];
  }
}
class ProductR{
  List<String> images = new List<String>();
  List<String> colors = new List<String>();
  List<String> sizes = new List<String>();

  ProductR.fromSnapshot(DocumentSnapshot snapshot)
  : images = List.from(snapshot["images"]),
    colors = List.from(snapshot["colors"]),
    sizes = List.from(snapshot["sizes"]);

}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  ProductServices _productServices = ProductServices();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text("Products List"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){
                showSearch(context: context, delegate: DataSearch());
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddProduct()));
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('products').snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Text("No products exist");
            }else{
              return ListView(
                children: getProducts(snapshot),
              );
            }
          }
        ),
      );
  }

  Future<bool> deleteProduct(selectedDoc) async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are you sure delete this product?"),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  _productServices.deleteProduct(selectedDoc);
                  Fluttertoast.showToast(
                      msg: "Product deleted succesfully!",
                      fontSize: 18.0,
                      textColor: Colors.white,
                      backgroundColor: Colors.red,
                      timeInSecForIosWeb: 2);
                  Navigator.pop(context);
                },
                child: Text("DELETE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ],
          );
        }
    );
  }

  getProducts(AsyncSnapshot<QuerySnapshot> snapshot){
    return snapshot.data.documents.map((document)=>
        Card(
          elevation: 0.0,
          color: Colors.grey.withOpacity(0.2),
          child: new ListTile(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)
                => UpdateProduct(id: document["id"], name: document["name"], brand: document["brand"],
                  category: document["category"], featured: document["featured"], colors: document["colors"],
                  price: document["price"], images: document["images"], onSale: document["onSale"],
                  sizes: document["sizes"], description: document["description"], oldPrice: document["oldPrice"],
                )));
              },
            title: Padding(
              padding: const EdgeInsets.fromLTRB(5, 27, 0, 10),
              child: new Text(
                document['name'],
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 23.0),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Brand: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "${document["brand"]}\n",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "Category: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "${document["category"]}\n",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "Price: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "\$${document["price"]}\n",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "Description: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "${document["description"]}\n",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "Sale: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "${document["onSale"]}\t\t",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "Featured: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0),
                        ),
                        TextSpan(
                          text: "${document["featured"]} ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: <Widget>[
                      Text("Colors: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      ),

                    Expanded(
                      child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: ProductR.fromSnapshot(document).colors.map((color)=>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Chip(label: Text(color, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),))
                                ],
                              ),
                          ).toList()
                      ),
                  ),
                ],
              ),
                  Row(
                    children: <Widget>[
                      Text("Sizes: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      ),

                      Expanded(
                        child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          crossAxisCount: 3,
                          children: ProductR.fromSnapshot(document).sizes
                              .map((size)=>
                              Chip(
                                label: Text(size,style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500 ),
                                ),
                              ),
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text("Images: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      ),

                      Expanded(
                        child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          crossAxisCount: 3,
                          children: ProductR.fromSnapshot(document).images
                              .map((image)=>
                              Image.network(image)
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        deleteProduct(document["id"]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ).toList();
  }
}

class DataSearch extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(icon: Icon(Icons.search), onPressed: () {
        query = '';
      }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation
        ),
        onPressed: () {
          close(context, null);
        }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text("Search term must be longer than two letters.",
              style: TextStyle(color: Colors.red, fontSize: 20.0),),
          )
        ],
      );
    }
    return StreamBuilder(
        stream: Firestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
              ],
            );
          } else {
            final results = snapshot.data.documents.where((
                DocumentSnapshot a) => a.data['name'].toString().contains(query)
            );
            return ListView(
                children: results.map<Widget>((a) =>
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (
                              context) =>
                              UpdateProduct(id: a.data["id"],
                                name: a.data["name"],
                                sizes: a.data["sizes"],
                                onSale: a.data["onSale"],
                                images: a.data["images"],
                                price: a.data["price"],
                                category: a.data["category"],
                                brand: a.data["brand"],
                                colors: a.data["colors"],
                                featured: a.data["featured"],
                              )));
                        },
                        child: ListTile(
                          leading: Image.network(a.data["images"][0]),
                          subtitle: Text(
                            a.data['name'], style: TextStyle(color: Colors
                              .black, fontSize: 20.0),),
                        ),
                      ),
                    )).toList()
            );
          }
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
              ],
            );
          }else{
            final results = snapshot.data.documents.where((
                DocumentSnapshot a) => a.data['name'].toString().contains(query)
            );
            return ListView(
                children: results.map<Widget>((a) =>
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (
                              context) =>
                              UpdateProduct(id: a.data["id"],
                                name: a.data["name"],
                                sizes: a.data["sizes"],
                                onSale: a.data["onSale"],
                                images: a.data["images"],
                                price: a.data["price"],
                                category: a.data["category"],
                                brand: a.data["brand"],
                                colors: a.data["colors"],
                                featured: a.data["featured"],
                              )));
                        },
                        child: ListTile(
                          leading: Image.network(a.data["images"][0]),
                          subtitle: Text(
                            a.data['name'], style: TextStyle(color: Colors
                              .black, fontSize: 20.0),),
                        ),
                      ),
                    )).toList()
            );
          }
        }
    );
  }
}

