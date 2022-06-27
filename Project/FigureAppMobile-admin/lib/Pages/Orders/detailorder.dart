import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Product{
  List products;
  Product.fromMap(Map<String,dynamic> data){
    products = data['products'];
  }
}

class ProductR{
  List products = new List();
  ProductR.fromSnapshot(DocumentSnapshot snapshot)
      : products = List.from(snapshot["products"]);
}

class DetailOrder extends StatefulWidget {
  final String id;
  DetailOrder({Key key, @required this.id}) : super(key:key);
  @override
  _DetailOrderState createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  double totalCost = 0;
  double temp = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Order"),
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("orders").snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Text("No information");
          }else{
            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: _showDetailOrder(snapshot),
            );
          }
        },
      ),
    );
  }

  _showDetailOrder(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> data = new List();
    snapshot.data.documents.map((DocumentSnapshot document){
      if(document["orderId"] == widget.id){
        data.add(document);
      }
    }).toList();
    return data.map((DocumentSnapshot document){
      return Column(
        children: <Widget>[
          Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Products",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                  SizedBox(height: 10,),
                  Column(
                    children: ProductR.fromSnapshot(document).products.map((product)=>
                        ListTile(
                          leading: Image.network(product["image"]),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text("Name: ",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                  Text(product["name"],style: TextStyle(fontSize: 18.0)),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text("Released by: ",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                  Text(product["brand"],style: TextStyle(fontSize: 18.0)),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Text(product["price"].toString(),style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5,),
                              Text("X",style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5,),
                              Text(product["quantity"].toString(),style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                            ],
                          ),
                        )
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text("Total cost: ",style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Container(
                    height: 20,
                    width: 70,
                    child: ListView(
                      children: <Widget>[
                        _totalCost(document)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 50,),
          !document["status"] ? FlatButton(
            onPressed: (){
              Firestore.instance.collection("orders").document(document.documentID).updateData({
                "status" : true
              });
              Navigator.pop(context);
            },
            child: Text("Deliveried Succesfully!", style: TextStyle(fontSize: 18),),
            color: Colors.black,
            textColor: Colors.white,
          ) : Text("This order has deliveried succesfully", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
        ],
      );
    }).toList();
  }

  _totalCost(DocumentSnapshot document) {
    ProductR.fromSnapshot(document).products.map((product){
      temp = product["cost"];
      totalCost = totalCost + temp;
    }).toList();
    return Text(totalCost.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),);
  }
}
