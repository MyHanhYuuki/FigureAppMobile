import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/db/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin/Pages/brand/add_brand.dart';
import 'package:admin/Pages/brand/update_brand.dart';

class GetBrands extends StatefulWidget {
  @override
  _GetBrandsState createState() => _GetBrandsState();
}

class _GetBrandsState extends State<GetBrands> {
  BrandServices _brandServices = BrandServices();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("BrandsList"),
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddBrand()));
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('brands').snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Text("No brands exist");
            }else{
              return ListView(
                children: getBrands(snapshot),
              );
            }
          }
        ),
      );
  }

  //Delete brand
  Future<bool> deleteBrand(selectedDoc) async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are you sure delete this brand?"),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                    _brandServices.deleteBrand(selectedDoc);
                    Fluttertoast.showToast(
                        msg: "Brand deleted succesfully!",
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

  //Get brands in FireStore
  getBrands(AsyncSnapshot<QuerySnapshot> snapshot){
    return snapshot.data.documents.map((document)=>
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Card(
            elevation: 0.0,
            child: new ListTile(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)
                =>UpdateBrand(id: document["brandID"], name: document["brandName"], image: document["brandImage"],
                  address: document["brandAddress"], phoneNumber: document["brandPhoneNumber"],
                )));
              },
              leading: Image.network(document["brandImage"], width: 80, height: 80,),
              title: Padding(
                padding: const EdgeInsets.fromLTRB(5, 15, 0, 10),
                child: new Text(
                  document['brandName'],
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 23.0),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Address: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      ),
                      TextSpan(
                        text: "${document["brandAddress"]}\n",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0),
                      ),
                      TextSpan(
                        text: "Phone: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      ),
                      TextSpan(
                        text: document["brandPhoneNumber"],
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 20.0),
                      ),
                    ],
                  ),
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          deleteBrand(document["brandID"]);
                        },
                      ),
                    ),
                  ],
                ),
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
        stream: Firestore.instance.collection('brands').snapshots(),
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
            final results = snapshot.data.documents.where((DocumentSnapshot a) => a.data['brandName'].toString().contains(query));
            return ListView(
                children: results.map<Widget>((a) => Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)
                      =>UpdateBrand(id: a.data["brandID"], name: a.data["brandName"], image: a.data["brandImage"],
                        address: a.data["brandAddress"], phoneNumber: a.data["brandPhoneNumber"],
                      )));
                    },
                    child: ListTile(
                      leading: Image.network(a.data["brandImage"], width: 80, height: 80,),
                      title: Text(a.data['brandName'], style: TextStyle(color: Colors.black, fontSize: 20.0),),
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
        stream: Firestore.instance.collection('brands').snapshots(),
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
            final results = snapshot.data.documents.where((DocumentSnapshot a) => a.data['brandName'].toString().contains(query));
            return ListView(
                children: results.map<Widget>((a) => Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)
                      =>UpdateBrand(id: a.data["brandID"], name: a.data["brandName"], image: a.data["brandImage"],
                        address: a.data["brandAddress"], phoneNumber: a.data["brandPhoneNumber"],
                      )));
                    },
                    child: ListTile(
                      leading: Image.network(a.data["brandImage"]),
                      subtitle: Text(a.data['brandName'], style: TextStyle(color: Colors.black, fontSize: 20.0),),
                    ),
                  ),
                )).toList()
            );
          }
        }
    );
  }
}

