import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';


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

class RevenueDashBoard extends StatefulWidget {
  @override
  _RevenueDashBoardState createState() => _RevenueDashBoardState();
}

class _RevenueDashBoardState extends State<RevenueDashBoard> {
  DateTime timeValue;
  TextEditingController _fromTimeControl = TextEditingController();
  TextEditingController _toTimeControl = TextEditingController();
  String title = "Choose time here";
  String title1 = "Choose time here";
  DateTime t1,t2;
  Timestamp t3,t4;
  double temp = 0;
  List<DocumentSnapshot>  orders = new List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Revenue"),
        elevation: 0.0,
      ),
      body: LayoutBuilder(
        builder: (context,constraints){
          if(constraints.maxWidth < 350){
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,10,20,15),
                    child: Text("Find all orders by date range", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32,20,0,20),
                            child: Text("From: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                          Card(
                            elevation: 5.0,
                            child: SizedBox(
                              width: 115,
                              child: ListTile(
                                title: Text(title),
                                onTap: (){
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1964, 12, 31),
                                      maxTime: DateTime(2099, 12, 31),
                                      onChanged: (date) {
                                        setState(() {
                                          timeValue = date;
                                        });
                                      },
                                      onConfirm: (date) {
                                        _fromTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                        setState(() {
                                          title = _fromTimeControl.text;
                                          t1 = date.toUtc();
                                        });
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.vi);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32,20,10,20),
                            child: Text("To: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                          Card(
                            elevation: 5.0,
                            child: SizedBox(
                              width: 120,
                              child: ListTile(
                                title: Text(title1),
                                onTap: (){
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1964, 12, 31),
                                      maxTime: DateTime(2099, 12, 31),
                                      onChanged: (date) {
                                        setState(() {
                                          timeValue = date;
                                        });
                                      },
                                      onConfirm: (date) {
                                        _toTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                        var compare = _toTimeControl.text.compareTo(title);
                                        if(compare == -1){
                                          setState(() {
                                            _toTimeControl.text = "Error";
                                            title1 =  _toTimeControl.text;
                                          });
                                        }else{
                                          setState(() {
                                            title1 = _toTimeControl.text;
                                            t2 = date.toUtc();
                                          });
                                        }
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.vi);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              t3 = Timestamp.fromDate(t1);
                              t4 = Timestamp.fromDate(t2);
                              List<DocumentSnapshot> dataNew = [];
                              Firestore.instance.collection("orders").where("time",isGreaterThanOrEqualTo: t3).where("time",isLessThanOrEqualTo: t4)
                                  .getDocuments().then((snapshot) => {
                                snapshot.documents.forEach((docs){
                                  dataNew.add(docs);
                                  setState(() {
                                    orders = dataNew;
                                  });
                                })
                              });
                              setState(() {
                                dataNew = [];
                                orders = [];
                              });
                            },
                            child: Text("Execute", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              setState(() {
                                orders = [];
                                title = "Choose time here";
                                title1 = "Choose time here";
                              });
                            },
                            child: Text("Reset", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                    ],
                  ),

                  orders.isEmpty ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _showRecordDateRange(orders)
                    ],
                  ) : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Num of Orders with date range: ${orders.length.toString()}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Total cost of orders: ${_totalCost(orders)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                      ),
                      Container(
                        height: 190,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: _showRecordDateRange(orders)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }else if(constraints.maxWidth > 351 && constraints.maxWidth < 410){
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,10,20,15),
                    child: Text("Find all orders by date range", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32,20,0,20),
                            child: Text("From: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                          Card(
                            elevation: 5.0,
                            child: SizedBox(
                              width: 115,
                              child: ListTile(
                                title: Text(title),
                                onTap: (){
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1964, 12, 31),
                                      maxTime: DateTime(2099, 12, 31),
                                      onChanged: (date) {
                                        setState(() {
                                          timeValue = date;
                                        });
                                      },
                                      onConfirm: (date) {
                                        _fromTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                        setState(() {
                                          title = _fromTimeControl.text;
                                          t1 = date.toUtc();
                                        });
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.vi);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32,20,10,20),
                            child: Text("To: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                          Card(
                            elevation: 5.0,
                            child: SizedBox(
                              width: 120,
                              child: ListTile(
                                title: Text(title1),
                                onTap: (){
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1964, 12, 31),
                                      maxTime: DateTime(2099, 12, 31),
                                      onChanged: (date) {
                                        setState(() {
                                          timeValue = date;
                                        });
                                      },
                                      onConfirm: (date) {
                                        _toTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                        var compare = _toTimeControl.text.compareTo(title);
                                        if(compare == -1){
                                          setState(() {
                                            _toTimeControl.text = "Error";
                                            title1 =  _toTimeControl.text;
                                          });
                                        }else{
                                          setState(() {
                                            title1 = _toTimeControl.text;
                                            t2 = date.toUtc();
                                          });
                                        }
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.vi);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              t3 = Timestamp.fromDate(t1);
                              t4 = Timestamp.fromDate(t2);
                              List<DocumentSnapshot> dataNew = [];
                              Firestore.instance.collection("orders").where("time",isGreaterThanOrEqualTo: t3).where("time",isLessThanOrEqualTo: t4)
                                  .getDocuments().then((snapshot) => {
                                snapshot.documents.forEach((docs){
                                  dataNew.add(docs);
                                  setState(() {
                                    orders = dataNew;
                                  });
                                })
                              });
                              setState(() {
                                dataNew = [];
                                orders = [];
                              });
                            },
                            child: Text("Execute", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              setState(() {
                                orders = [];
                                title = "Choose time here";
                                title1 = "Choose time here";
                              });
                            },
                            child: Text("Reset", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                    ],
                  ),

                  orders.isEmpty ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _showRecordDateRange(orders)
                    ],
                  ) : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Num of Orders with date range: ${orders.length.toString()}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Total cost of orders: ${_totalCost(orders)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                      ),
                      Container(
                        height: 190,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: _showRecordDateRange(orders)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }else if(constraints.maxWidth > 411 && constraints.maxWidth < 500){
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,40,20,15),
                    child: Text("Find all orders by date range", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red),),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15,40,10,40),
                        child: Text("From: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                      Card(
                        elevation: 5.0,
                        child: SizedBox(
                          width: 120,
                          child: ListTile(
                            title: Text(title),
                            onTap: (){
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1964, 12, 31),
                                  maxTime: DateTime(2099, 12, 31),
                                  onChanged: (date) {
                                    setState(() {
                                      timeValue = date;
                                    });
                                  },
                                  onConfirm: (date) {
                                    _fromTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                    setState(() {
                                      title = _fromTimeControl.text;
                                      t1 = date.toUtc();
                                    });
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.vi);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,40,10,40),
                        child: Text("To: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                      Card(
                        elevation: 5.0,
                        child: SizedBox(
                          width: 120,
                          child: ListTile(
                            title: Text(title1),
                            onTap: (){
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1964, 12, 31),
                                  maxTime: DateTime(2099, 12, 31),
                                  onChanged: (date) {
                                    setState(() {
                                      timeValue = date;
                                    });
                                  },
                                  onConfirm: (date) {
                                    _toTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                    var compare = _toTimeControl.text.compareTo(title);
                                    if(compare == -1){
                                      setState(() {
                                        _toTimeControl.text = "Error";
                                        title1 =  _toTimeControl.text;
                                      });
                                    }else{
                                      setState(() {
                                        title1 = _toTimeControl.text;
                                        t2 = date.toUtc();
                                      });
                                    }
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.vi);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              t3 = Timestamp.fromDate(t1);
                              t4 = Timestamp.fromDate(t2);
                              List<DocumentSnapshot> dataNew = [];
                              Firestore.instance.collection("orders").where("time",isGreaterThanOrEqualTo: t3).where("time",isLessThanOrEqualTo: t4)
                                  .getDocuments().then((snapshot) => {
                                snapshot.documents.forEach((docs){
                                  dataNew.add(docs);
                                  setState(() {
                                    orders = dataNew;
                                  });
                                })
                              });
                              setState(() {
                                dataNew = [];
                                orders = [];
                              });
                            },
                            child: Text("Execute", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              setState(() {
                                orders = [];
                                title = "Choose time here";
                                title1 = "Choose time here";
                              });
                            },
                            child: Text("Reset", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                    ],
                  ),

                  orders.isEmpty ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _showRecordDateRange(orders)
                    ],
                  ) : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Num of Orders with date range: ${orders.length.toString()}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Total cost of orders: ${_totalCost(orders)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
                      ),
                      Container(
                        height: 250,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: _showRecordDateRange(orders)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }else if(constraints.maxWidth > 501){
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,40,20,15),
                    child: Text("Find all orders by date range", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red),),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15,40,10,40),
                        child: Text("From: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                      Card(
                        elevation: 5.0,
                        child: SizedBox(
                          width: 120,
                          child: ListTile(
                            title: Text(title),
                            onTap: (){
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1964, 12, 31),
                                  maxTime: DateTime(2099, 12, 31),
                                  onChanged: (date) {
                                    setState(() {
                                      timeValue = date;
                                    });
                                  },
                                  onConfirm: (date) {
                                    _fromTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                    setState(() {
                                      title = _fromTimeControl.text;
                                      t1 = date.toUtc();
                                    });
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.vi);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,40,10,40),
                        child: Text("To: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                      Card(
                        elevation: 5.0,
                        child: SizedBox(
                          width: 120,
                          child: ListTile(
                            title: Text(title1),
                            onTap: (){
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1964, 12, 31),
                                  maxTime: DateTime(2099, 12, 31),
                                  onChanged: (date) {
                                    setState(() {
                                      timeValue = date;
                                    });
                                  },
                                  onConfirm: (date) {
                                    _toTimeControl.text = DateFormat("yyyy-MM-dd").format(date);
                                    var compare = _toTimeControl.text.compareTo(title);
                                    if(compare == -1){
                                      setState(() {
                                        _toTimeControl.text = "Error";
                                        title1 =  _toTimeControl.text;
                                      });
                                    }else{
                                      setState(() {
                                        title1 = _toTimeControl.text;
                                        t2 = date.toUtc();
                                      });
                                    }
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.vi);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              t3 = Timestamp.fromDate(t1);
                              t4 = Timestamp.fromDate(t2);
                              List<DocumentSnapshot> dataNew = [];
                              Firestore.instance.collection("orders").where("time",isGreaterThanOrEqualTo: t3).where("time",isLessThanOrEqualTo: t4)
                                  .getDocuments().then((snapshot) => {
                                snapshot.documents.forEach((docs){
                                  dataNew.add(docs);
                                  setState(() {
                                    orders = dataNew;
                                  });
                                })
                              });
                              setState(() {
                                dataNew = [];
                                orders = [];
                              });
                            },
                            child: Text("Execute", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            color: Colors.cyan,
                            onPressed: (){
                              setState(() {
                                orders = [];
                                title = "Choose time here";
                                title1 = "Choose time here";
                              });
                            },
                            child: Text("Reset", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ),
                    ],
                  ),

                  orders.isEmpty ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _showRecordDateRange(orders)
                    ],
                  ) : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Num of Orders with date range: ${orders.length.toString()}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Total cost of orders: ${_totalCost(orders)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
                      ),
                      Container(
                        height: 250,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: _showRecordDateRange(orders)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }else return null;
        },
      ),
    );
  }

  _showRecordDateRange(List<DocumentSnapshot> orders) {
    if(orders.isEmpty){
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          alignment: Alignment.center,
          child: Text("Not found any orders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),)
        ),
      );
    }else{
      return orders.map((DocumentSnapshot document){
        return Column(
          children: <Widget>[
            Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 5.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("OrderID:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                        Text(document["orderId"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),),
                        SizedBox(height: 10,),
                        Text("Time to order: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                        Text(document["time"].toDate().toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),),
                        SizedBox(height: 10,),
                        Row(
                          children: <Widget>[
                            Text("Name of Customer: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                            Text(document["informationPersonal"]["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: <Widget>[
                            Text("Status: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                            document["status"] ? Text("deliveried", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),)
                                : Text("Not delivery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),)
                          ],
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                ),
          ],
        );
      }).toList();
    }
  }

  _totalCost(List<DocumentSnapshot> listTotal) {
    double totalCost = 0;
    listTotal.map((DocumentSnapshot document){
      ProductR.fromSnapshot(document).products.map((product)
        => totalCost += product["cost"]
      ).toList();
    }).toList();
    return totalCost.toString();
  }
}

