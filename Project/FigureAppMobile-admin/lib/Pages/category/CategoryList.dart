import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/db/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin/Pages/category/add_category.dart';
import 'package:admin/Pages/category/update_category.dart';

class GetCategories extends StatefulWidget {
  @override
  _GetCategoriesState createState() => _GetCategoriesState();
}

class _GetCategoriesState extends State<GetCategories> {

  CategoryServices _categoryServices = CategoryServices();
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  bool isDisplay = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("CategoriesList"),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){
                showSearch(context: context, delegate: DataSearch());
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddCategory()));
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream:  Firestore.instance.collection('Categories').snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Text("No categories exist");
            }else{
              return ListView(
                children: getCategories(snapshot),
              );
            }
          }
        ),
      );
  }


  Future<bool> deleteCategory(selectorDoc) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are you sure delete this category?"),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  _categoryServices.deleteCategory(selectorDoc);
                  Fluttertoast.showToast(
                      msg: "Category deleted succesfully!",
                      fontSize: 18.0,
                      textColor: Colors.white,
                      backgroundColor: Colors.red,
                      timeInSecForIosWeb: 2);
                  Navigator.pop(context);
                },
                child: Text("DELETE"),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("CANCEL"),
              ),
            ],
          );
        }
    );
  }

  getCategories(AsyncSnapshot<QuerySnapshot> snapshot){
    return snapshot.data.documents.map((document)=>
       Card(
        elevation: 0.0,
        child: new ListTile(
          leading: Image.network(document["categoryImage"]),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>
              UpdateCategory(id: document["categoryID"], image: document["categoryImage"], name: document["categoryName"],)
            ));
          },
          title: Padding(
            padding: const EdgeInsets.fromLTRB(5, 25, 0, 10),
            child: new Text(
              document['categoryName'],
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 23.0),
              ),
            ),
          trailing: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      deleteCategory(document["categoryID"]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    ).toList();
  }
}
class DataSearch extends SearchDelegate<String>{

  @override
  List<Widget> buildActions(BuildContext context) {

    // TODO: implement buildActions
    return [
      IconButton(icon: Icon(Icons.search), onPressed: (){
        query = '';
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation
        ),
        onPressed: (){
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
            child: Text("Search term must be longer than two letters.", style: TextStyle(color: Colors.red, fontSize: 20.0),),
          )
        ],
      );
    }
    return StreamBuilder(
        stream: Firestore.instance.collection('Categories').snapshots(),
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
            final results = snapshot.data.documents.where((DocumentSnapshot a) => a.data['categoryName'].toString().contains(query));
            return ListView(
                children: results.map<Widget>((a) => Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          UpdateCategory(id: a.data["categoryID"], image: a.data["categoryImage"], name: a.data["categoryName"],)
                      ));
                    },
                    child: ListTile(
                      leading: Image.network(a.data["categoryImage"]),
                      subtitle: Text(a.data['categoryName'], style: TextStyle(color: Colors.black, fontSize: 20.0),),
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
        stream: Firestore.instance.collection('Categories').snapshots(),
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
            final results = snapshot.data.documents.where((DocumentSnapshot a) => a.data['categoryName'].toString().contains(query));
            return ListView(
                children: results.map<Widget>((a) => Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          UpdateCategory(id: a.data["categoryID"], image: a.data["categoryImage"], name: a.data["categoryName"],)
                      ));
                    },
                    child: ListTile(
                      leading: Image.network(a.data["categoryImage"]),
                      subtitle: Text(a.data['categoryName'], style: TextStyle(color: Colors.black, fontSize: 20.0),),
                    ),
                  ),
                )).toList()
            );
          }
        }
    );
  }
}





