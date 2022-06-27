import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/Pages/Users/CreateUser.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ListUsers extends StatefulWidget {
  final FirebaseUser username;
  ListUsers({Key key, this.username}) : super(key:key);
  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String newEmail;
  String newPassword;

  TextEditingController _newEmailController = TextEditingController();
  TextEditingController _newPassController = TextEditingController();
  TextEditingController _currentPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of Users Admin"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RegisterUser()));
            }
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Users Admin:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            StreamBuilder(
              stream: Firestore.instance.collection("users").document(widget.username.uid).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Text("Has error: ${snapshot.error}");
                }else{
                  return getInfoCurrentUser(snapshot.data);
                }
              },
            ),
            SizedBox(height: 30,),
            Row(
              children: <Widget>[
                Text("Num of users client: ", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),),
                StreamBuilder(
                  stream: Firestore.instance.collection("users").snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return Text("Has error: ${snapshot.error}");
                    }else{
                      return Text(getUsersClient(snapshot).toString(), style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),);
                    }
                  },
                ),
              ],
            )

          ],
        ),
      ),
    );
  }

  Widget getInfoCurrentUser(DocumentSnapshot data) {
    if(true){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Username: ${data.data["username"]}", style: TextStyle(fontSize: 18, color: Colors.black),),
          SizedBox(width: 20,),
          Text("Email: ${data.data["email"]}", style: TextStyle(fontSize: 18, color: Colors.black),),
          FlatButton(
            onPressed: (){
              _showDialogtoUpdateEmail();
            },
            child: Text("Change email"),
            color: Colors.grey.withOpacity(0.7),
          ),
          FlatButton(
            onPressed: ()async{
              _showDialogtoUpdatePassword();
            },
            child: Text("Change password"),
            color: Colors.grey.withOpacity(0.7),
          ),
        ],
      );
    }
  }

  void _showDialogtoUpdateEmail() {
    var alert = new AlertDialog(
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _newEmailController,
          decoration: InputDecoration(
              hintText: "New Email"
          ),
          validator: (value) {
            if (value.isEmpty) {
              bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value);
              if (!emailValid)
                return "Please make sure your email address is correct!";
              else
                return null;
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            if(_formKey.currentState.validate()){
              widget.username.updateEmail(_newEmailController.text).then((_) {
                Fluttertoast.showToast(msg: "Succesfull changed email");
              }).catchError((error) {
                Fluttertoast.showToast(msg: "email can't be changed" + error.toString());
              });
              Firestore.instance.collection('users').document(widget.username.uid).updateData({
                'email' : _newEmailController.text
              });
              Navigator.pop(context);
            }
            return null;
          },
          child: Text('OK')),
        FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  void _showDialogtoUpdatePassword() {
    var alert = new AlertDialog(
      content: Form(
        key: _formKey1,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _currentPassController,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Current Password"
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Please make sure your password is correct!";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _newPassController,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "New Password"
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Please make sure your password not null!";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: ()async{
              FirebaseUser user = await firebaseAuth.currentUser();
              final AuthCredential credential = EmailAuthProvider.getCredential(email: user.email, password: _currentPassController.text);
              user.updatePassword(_newPassController.text).then((_){
                Fluttertoast.showToast(msg: "Successfully changed password");
              }).catchError((error){
                Fluttertoast.showToast(msg: "Password can't be changed" + error.toString());
                //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
              });
              Navigator.pop(context);
              _formKey1.currentState.reset();
            },
            child: Text('OK')
        ),
        FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  getUsersClient(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> dataUsers = new List();
    for(DocumentSnapshot data in snapshot.data.documents){
      if(data['role'] == 'client'){
        dataUsers.add(data);
      }
    }
    return dataUsers.length;
  }
}
