import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/Pages/product/add_product.dart';
import 'package:admin/Pages/category/add_category.dart';
import 'package:admin/Pages/brand/add_brand.dart';
import 'package:admin/Pages/brand/BrandList.dart';
import 'package:admin/Pages/category/CategoryList.dart';
import 'package:admin/Pages/product/ProductList.dart';
import 'package:admin/Pages/Orders/ListOrders.dart';
import 'package:admin/Pages/Orders/ListSolds.dart';
import 'package:admin/Pages/Revenue.dart';
import 'package:admin/Pages/Users/ListUser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin/Pages/Sliders/list_sliders.dart';
import 'package:admin/Pages/Sliders/add_slider.dart';
import 'LogInPage.dart';

enum Page { dashboard, manage }

class AdminPage extends StatefulWidget {
  final FirebaseUser user;
  AdminPage({Key key, this.user}) : super(key: key);
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  Color grey = Colors.grey;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool isAdmin = true;

  Future<Null> signOut() async {
    // Sign out with firebase

    final FirebaseUser currentUser = await firebaseAuth.currentUser();
    Firestore.instance
        .collection("users")
        .document(currentUser.uid)
        .updateData({"isLoggedIn": false});
    Fluttertoast.showToast(
        msg: "Signed out successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    await firebaseAuth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .document(widget.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Has error: ${snapshot.error}");
          } else {
            return checkRole(snapshot.data);
          }
        },
      ),
    );
  }

  Widget _showBodyWithWidthLessThan350() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(27.0, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: () {
                      setState(() => _selectedPage = Page.dashboard);
                    },
                    icon: Icon(
                      Icons.dashboard,
                      color:
                          _selectedPage == Page.dashboard ? active : notActive,
                      size: 20.0,
                    ),
                    label: Text(
                      "Dashboard",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Expanded(
                    child: FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.settings,
                        color:
                            _selectedPage == Page.manage ? active : notActive,
                        size: 20.0,
                      ),
                      label: Text(
                        "Manage",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListTile(
                subtitle: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenueDashBoard()));
                    },
                    icon: Icon(
                      Icons.monetization_on,
                      size: 25.0,
                    ),
                    label: Text(
                      "Click to know details",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    )),
                title: Text(
                  "Revenue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23.0, color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ListUsers(username: widget.user,)));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton(
                              onPressed: null,
                              child: Text(
                                "Users",
                                style: TextStyle(
                                    color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("users")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text("0", textAlign: TextAlign.center, style: TextStyle(color: active, fontSize: 50.0),);
                            } else {
                              return Text(
                                getUsers(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetSliders()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton(
                                onPressed: null,
                                child: Text(
                                  "Sliders",
                                  style: TextStyle(color: Colors.black),
                                )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("sliders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getSliders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetCategories()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton(
                              onPressed: null,
                              child: Text(
                                "Categories",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("Categories")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getCategories(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductList()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Products",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("products")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getProducts(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetBrands()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Brands",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("brands")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getBrands(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrdersList()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Orders",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getOrders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SoldList()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Sold",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getSold(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
        break;
      case Page.manage:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(27.0, 30, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                        size: 20.0,
                      ),
                      label: Text(
                        "Dashboard",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Expanded(
                      child: FlatButton.icon(
                        onPressed: () {
                          setState(() => _selectedPage = Page.manage);
                        },
                        icon: Icon(
                          Icons.settings,
                          color:
                              _selectedPage == Page.manage ? active : notActive,
                          size: 20.0,
                        ),
                        label: Text(
                          "Manage",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              //Add Product
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add product",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddProduct()));
                },
              ),
              Divider(),
              //Product List
              ListTile(
                leading: Icon(
                  Icons.change_history,
                  color: Colors.black,
                ),
                title: Text(
                  "Products list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductList()));
                },
              ),
              Divider(),
              //Add category
              ListTile(
                leading: Icon(
                  Icons.add_circle,
                  color: Colors.black,
                ),
                title: Text(
                  "Add category",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCategory()));
                },
              ),
              Divider(),
              //Category list
              ListTile(
                leading: Icon(
                  Icons.category,
                  color: Colors.black,
                ),
                title: Text(
                  "Category list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetCategories()));
                },
              ),
              Divider(),
              //Add brand
              ListTile(
                leading: Icon(
                  Icons.add_circle_outline,
                  color: Colors.black,
                ),
                title: Text(
                  "Add brand",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddBrand()));
                },
              ),
              Divider(),
              //Brand list
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: Colors.black,
                ),
                title: Text(
                  "Brand list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetBrands()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.event,
                  color: Colors.black,
                ),
                title: Text(
                  "Sliders list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetSliders()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.library_add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add slider",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSlider()));
                },
              ),
            ],
          ),
        );
        break;
      default:
        return Container();
    }
  }

  Widget _showBodyWithWidthBetween351and410() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(27.0, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: () {
                      setState(() => _selectedPage = Page.dashboard);
                    },
                    icon: Icon(
                      Icons.dashboard,
                      color:
                      _selectedPage == Page.dashboard ? active : notActive,
                      size: 20.0,
                    ),
                    label: Text(
                      "Dashboard",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Expanded(
                    child: FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.settings,
                        color:
                        _selectedPage == Page.manage ? active : notActive,
                        size: 20.0,
                      ),
                      label: Text(
                        "Manage",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListTile(
                subtitle: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenueDashBoard()));
                    },
                    icon: Icon(
                      Icons.monetization_on,
                      size: 25.0,
                    ),
                    label: Text(
                      "Click to know details",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    )),
                title: Text(
                  "Revenue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23.0, color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ListUsers(username: widget.user,)));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton(
                              onPressed: null,
                              child: Text(
                                "Users",
                                style: TextStyle(
                                    color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("users")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text("0", textAlign: TextAlign.center, style: TextStyle(color: active, fontSize: 50.0),);
                            } else {
                              return Text(
                                getUsers(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetSliders()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton(
                              onPressed: null,
                              child: Text(
                                "Sliders",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("sliders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getSliders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetCategories()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton(
                              onPressed: null,
                              child: Text(
                                "Categories",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("Categories")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getCategories(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductList()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Products",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("products")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getProducts(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetBrands()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Brands",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("brands")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getBrands(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrdersList()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Orders",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getOrders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SoldList()));
                        },
                        title: FlatButton(
                            onPressed: null,
                            child: Text("Sold",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            } else {
                              return Text(
                                getSold(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 50.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
        break;
      case Page.manage:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(27.0, 30, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                        size: 20.0,
                      ),
                      label: Text(
                        "Dashboard",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Expanded(
                      child: FlatButton.icon(
                        onPressed: () {
                          setState(() => _selectedPage = Page.manage);
                        },
                        icon: Icon(
                          Icons.settings,
                          color:
                          _selectedPage == Page.manage ? active : notActive,
                          size: 20.0,
                        ),
                        label: Text(
                          "Manage",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              //Add Product
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add product",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddProduct()));
                },
              ),
              Divider(),
              //Product List
              ListTile(
                leading: Icon(
                  Icons.change_history,
                  color: Colors.black,
                ),
                title: Text(
                  "Products list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductList()));
                },
              ),
              Divider(),
              //Add category
              ListTile(
                leading: Icon(
                  Icons.add_circle,
                  color: Colors.black,
                ),
                title: Text(
                  "Add category",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCategory()));
                },
              ),
              Divider(),
              //Category list
              ListTile(
                leading: Icon(
                  Icons.category,
                  color: Colors.black,
                ),
                title: Text(
                  "Category list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetCategories()));
                },
              ),
              Divider(),
              //Add brand
              ListTile(
                leading: Icon(
                  Icons.add_circle_outline,
                  color: Colors.black,
                ),
                title: Text(
                  "Add brand",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddBrand()));
                },
              ),
              Divider(),
              //Brand list
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: Colors.black,
                ),
                title: Text(
                  "Brand list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetBrands()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.event,
                  color: Colors.black,
                ),
                title: Text(
                  "Sliders list",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetSliders()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.library_add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add slider",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSlider()));
                },
              ),
            ],
          ),
        );
        break;
      default:
        return Container();
    }
  }

  Widget _showBodyWithWidthBetween411and500() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: () {
                      setState(() => _selectedPage = Page.dashboard);
                    },
                    icon: Icon(
                      Icons.dashboard,
                      color:
                      _selectedPage == Page.dashboard ? active : notActive,
                      size: 30.0,
                    ),
                    label: Text(
                      "Dashboard",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Expanded(
                    child: FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.settings,
                        color:
                        _selectedPage == Page.manage ? active : notActive,
                        size: 30.0,
                      ),
                      label: Text(
                        "Manage",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListTile(
                subtitle: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenueDashBoard()));
                    },
                    icon: Icon(
                      Icons.monetization_on,
                      size: 30.0,
                    ),
                    label: Text(
                      "Click to know details",
                      style: TextStyle(
                          fontSize: 23.0, fontWeight: FontWeight.bold),
                    )),
                title: Text(
                  "Revenue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25.0, color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListUsers(
                                    username: widget.user,
                                  )));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.people_outline,
                              color: Colors.black,
                              size: 27,
                            ),
                            label: Text(
                              "Users",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18.0),
                            )),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("users")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getUsers(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetSliders()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.slideshow,
                                color: Colors.black,
                              ),
                              label: Text(
                                "Sliders",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("sliders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getSliders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetCategories()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.category,
                                color: Colors.black,
                              ),
                              label: Text(
                                "Categories",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("Categories")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getCategories(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductList()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.public,
                              color: Colors.black,
                            ),
                            label: Text("Products",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("products")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getProducts(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetBrands()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.label,
                              color: Colors.black,
                            ),
                            label: Text("Brands",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("brands")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getBrands(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrdersList()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.shopping_cart,
                              color: Colors.black,
                            ),
                            label: Text("Orders",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getOrders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SoldList()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.check,
                              color: Colors.black,
                            ),
                            label: Text("Sold",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getSold(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
        break;
      case Page.manage:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 30, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                        size: 30.0,
                      ),
                      label: Text(
                        "Dashboard",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Expanded(
                      child: FlatButton.icon(
                        onPressed: () {
                          setState(() => _selectedPage = Page.manage);
                        },
                        icon: Icon(
                          Icons.settings,
                          color:
                          _selectedPage == Page.manage ? active : notActive,
                          size: 30.0,
                        ),
                        label: Text(
                          "Manage",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              //Add Product
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add product",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddProduct()));
                },
              ),
              Divider(),
              //Product List
              ListTile(
                leading: Icon(
                  Icons.change_history,
                  color: Colors.black,
                ),
                title: Text(
                  "Products list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductList()));
                },
              ),
              Divider(),
              //Add category
              ListTile(
                leading: Icon(
                  Icons.add_circle,
                  color: Colors.black,
                ),
                title: Text(
                  "Add category",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCategory()));
                },
              ),
              Divider(),
              //Category list
              ListTile(
                leading: Icon(
                  Icons.category,
                  color: Colors.black,
                ),
                title: Text(
                  "Category list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetCategories()));
                },
              ),
              Divider(),
              //Add brand
              ListTile(
                leading: Icon(
                  Icons.add_circle_outline,
                  color: Colors.black,
                ),
                title: Text(
                  "Add brand",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddBrand()));
                },
              ),
              Divider(),
              //Brand list
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: Colors.black,
                ),
                title: Text(
                  "Brand list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetBrands()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.event,
                  color: Colors.black,
                ),
                title: Text(
                  "Sliders list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetSliders()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.library_add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add slider",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSlider()));
                },
              ),
            ],
          ),
        );
        break;
      default:
        return Container();
    }
  }

  Widget _showBodyWithWidthMoreThan501() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: () {
                      setState(() => _selectedPage = Page.dashboard);
                    },
                    icon: Icon(
                      Icons.dashboard,
                      color:
                      _selectedPage == Page.dashboard ? active : notActive,
                      size: 30.0,
                    ),
                    label: Text(
                      "Dashboard",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Expanded(
                    child: FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.settings,
                        color:
                        _selectedPage == Page.manage ? active : notActive,
                        size: 30.0,
                      ),
                      label: Text(
                        "Manage",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListTile(
                subtitle: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenueDashBoard()));
                    },
                    icon: Icon(
                      Icons.monetization_on,
                      size: 30.0,
                    ),
                    label: Text(
                      "Click to know details",
                      style: TextStyle(
                          fontSize: 23.0, fontWeight: FontWeight.bold),
                    )),
                title: Text(
                  "Revenue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25.0, color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListUsers(
                                    username: widget.user,
                                  )));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.people_outline,
                              color: Colors.black,
                              size: 27,
                            ),
                            label: Text(
                              "Users",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18.0),
                            )),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("users")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getUsers(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetSliders()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.slideshow,
                                color: Colors.black,
                              ),
                              label: Text(
                                "Sliders",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("sliders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getSliders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetCategories()));
                        },
                        title: Container(
                          width: 100,
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.category,
                                color: Colors.black,
                              ),
                              label: Text(
                                "Categories",
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("Categories")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getCategories(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductList()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.public,
                              color: Colors.black,
                            ),
                            label: Text("Products",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("products")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getProducts(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GetBrands()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.label,
                              color: Colors.black,
                            ),
                            label: Text("Brands",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("brands")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getBrands(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrdersList()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.shopping_cart,
                              color: Colors.black,
                            ),
                            label: Text("Orders",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getOrders(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SoldList()));
                        },
                        title: FlatButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.check,
                              color: Colors.black,
                            ),
                            label: Text("Sold",
                                style: TextStyle(color: Colors.black))),
                        subtitle: StreamBuilder(
                          stream: Firestore.instance
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            } else {
                              return Text(
                                getSold(snapshot).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
        break;
      case Page.manage:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 30, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                        size: 30.0,
                      ),
                      label: Text(
                        "Dashboard",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Expanded(
                      child: FlatButton.icon(
                        onPressed: () {
                          setState(() => _selectedPage = Page.manage);
                        },
                        icon: Icon(
                          Icons.settings,
                          color:
                          _selectedPage == Page.manage ? active : notActive,
                          size: 30.0,
                        ),
                        label: Text(
                          "Manage",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              //Add Product
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add product",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddProduct()));
                },
              ),
              Divider(),
              //Product List
              ListTile(
                leading: Icon(
                  Icons.change_history,
                  color: Colors.black,
                ),
                title: Text(
                  "Products list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductList()));
                },
              ),
              Divider(),
              //Add category
              ListTile(
                leading: Icon(
                  Icons.add_circle,
                  color: Colors.black,
                ),
                title: Text(
                  "Add category",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCategory()));
                },
              ),
              Divider(),
              //Category list
              ListTile(
                leading: Icon(
                  Icons.category,
                  color: Colors.black,
                ),
                title: Text(
                  "Category list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetCategories()));
                },
              ),
              Divider(),
              //Add brand
              ListTile(
                leading: Icon(
                  Icons.add_circle_outline,
                  color: Colors.black,
                ),
                title: Text(
                  "Add brand",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddBrand()));
                },
              ),
              Divider(),
              //Brand list
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: Colors.black,
                ),
                title: Text(
                  "Brand list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetBrands()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.event,
                  color: Colors.black,
                ),
                title: Text(
                  "Sliders list",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GetSliders()));
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.library_add,
                  color: Colors.black,
                ),
                title: Text(
                  "Add slider",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSlider()));
                },
              ),
            ],
          ),
        );
        break;
      default:
        return Container();
    }
  }

  Widget _responsive(){
    return LayoutBuilder(
      builder: (context,constraints){
        if(constraints.maxWidth < 350){
          return _showBodyWithWidthLessThan350();
        }else if(constraints.maxWidth > 351 && constraints.maxWidth < 412){
          return _showBodyWithWidthBetween351and410();
        }else if(constraints.maxWidth > 412 && constraints.maxWidth < 500){
          return _showBodyWithWidthBetween411and500();
        }else if(constraints.maxWidth > 501){
          return _showBodyWithWidthMoreThan501();
        }else return null;
      },
    );
  }

  getCategories(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.length;
  }

  getBrands(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.length;
  }

  getProducts(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.length;
  }

  getUsers(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.length;
  }

  getOrders(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> data = new List();
    snapshot.data.documents.map((document) {
      if (!document["status"]) {
        data.add(document);
      }
    }).toList();
    return data.length;
  }

  getSold(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> data = new List();
    snapshot.data.documents.map((document) {
      if (document["status"]) {
        data.add(document);
      }
    }).toList();
    return data.length;
  }

  getSliders(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.length;
  }

  Widget checkRole(DocumentSnapshot data) {
    if (data.data['role'] == 'admin') {
      return Scaffold(
        body: _responsive(),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  signOut();
                }),
            Text(
              "Hello: ${data.data["username"]}",
              style: TextStyle(fontSize: 16, color: Colors.black),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          signOut();
                        }),
                    Text(
                      "Oops: Something went wrong",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    )
                  ],
                ),
                Text("Maybe you don't have a permission to visit page")
              ],
            ),
          ),
        ),
      );
    }
  }
}
