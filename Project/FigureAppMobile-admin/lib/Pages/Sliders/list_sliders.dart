import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/db/slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin/Pages/Sliders/add_slider.dart';
import 'package:admin/Pages/Sliders/update_slider.dart';

class GetSliders extends StatefulWidget {
  @override
  _GetSlidersState createState() => _GetSlidersState();
}

class _GetSlidersState extends State<GetSliders> {

  SliderServices _sliderServices = SliderServices();
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  bool isDisplay = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Sliders List"),
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddSlider()));
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream:  Firestore.instance.collection('sliders').snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Text("No sliders exist");
            }else{
              return ListView(
                children: getSliders(snapshot),
              );
            }
          }
      ),
    );
  }


  Future<bool> deleteSlider(selectorDoc) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are you sure delete this slider?"),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  _sliderServices.deleteSlider(selectorDoc);
                  Fluttertoast.showToast(
                      msg: "Slider deleted successfully!",
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

  getSliders(AsyncSnapshot<QuerySnapshot> snapshot){
    return snapshot.data.documents.map((document)=>
        Card(
          elevation: 0.0,
          child: new ListTile(
            leading: Image.network(document["sliderImage"],width: 100,),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  UpdateSlider(id: document["sliderID"], image: document["sliderImage"], name: document["sliderName"],isActive: document['isActive'],)
              ));
            },
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    document['sliderName'],
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                  Row(
                    children: <Widget>[
                      Text("Active: "),
                      Text(document['isActive'].toString()),
                    ],
                  )
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        deleteSlider(document["sliderID"]);
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
        stream: Firestore.instance.collection('sliders').snapshots(),
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
            final results = snapshot.data.documents.where((DocumentSnapshot a) => a.data['sliderName'].toString().contains(query));
            return ListView(
                children: results.map<Widget>((a) => Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          UpdateSlider(id: a.data["sliderID"], image: a.data["sliderImage"], name: a.data["sliderName"],isActive: a.data['isActive'],)
                      ));
                    },
                    child: ListTile(
                      leading: Image.network(a.data["sliderImage"]),
                      subtitle: Text(a.data['sliderName'], style: TextStyle(color: Colors.black, fontSize: 20.0),),
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
        stream: Firestore.instance.collection('sliders').snapshots(),
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
            final results = snapshot.data.documents.where((DocumentSnapshot a) => a.data['sliderName'].toString().contains(query));
            return ListView(
                children: results.map<Widget>((a) => Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          UpdateSlider(id: a.data["sliderID"], image: a.data["sliderImage"], name: a.data["sliderName"],isActive: a.data['isActive'],)
                      ));
                    },
                    child: ListTile(
                      leading: Image.network(a.data["sliderImage"]),
                      subtitle: Text(a.data['sliderName'], style: TextStyle(color: Colors.black, fontSize: 20.0),),
                    ),
                  ),
                )).toList()
            );
          }
        }
    );
  }
}





