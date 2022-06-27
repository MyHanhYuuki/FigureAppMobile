import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/Pages/Orders/detailorder.dart';

class OrdersList extends StatefulWidget {
  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("List of Orders"),
        elevation: 0.0,
      ),
      body: StreamBuilder(
          stream:  Firestore.instance.collection('orders').snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Text("No orders exist");
            }else{
              return ListView(
                children: getOrders(snapshot),
              );
            }
          }
      ),
    );
  }

  getOrders(AsyncSnapshot<QuerySnapshot> snapshot){
    List<DocumentSnapshot> data = new List();
    snapshot.data.documents.map((document){
      if(!document["status"]){
        data.add(document);
      }
    }).toList();
    return data.map((DocumentSnapshot document){
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 5.0,
          child: ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailOrder(id: document["orderId"])));
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("OrderID:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                Text(document["orderId"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),),
                SizedBox(height: 10,),
                Text("Time to order: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                Text(document["time"].toDate().toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),),
                SizedBox(height: 10,),
                Row(
                  children: <Widget>[
                    Text("Name of Customer: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                    Text(document["informationPersonal"]["name"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("Phone of Customer: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                    Text(document["informationPersonal"]["phone"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),),
                  ],
                ),
                Text("Address of Customer: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(document["informationPersonal"]["address"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),),
                ),
                SizedBox(height: 10,),
                Row(
                  children: <Widget>[
                    Text("Status: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                    document["status"] ? Text("deliveried", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),)
                        : Text("Not delivery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),)
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
    }
  }





