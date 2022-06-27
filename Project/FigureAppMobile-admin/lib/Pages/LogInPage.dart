import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin/Pages/HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();

  bool togglePass = true;
  bool isLoggedIn = false;
  bool haveError = false;

  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.blueGrey.withOpacity(0.5),
          ),
          Padding(
            padding: const EdgeInsets.only(top:30.0),
            child: Container(
              alignment: Alignment.topCenter,
              child: Image.asset("images/logo.png", width: 300, height: 300,),
              ),
            ),
          LayoutBuilder(
            builder:(context,constraints){
              if(constraints.maxWidth < 350){
                return Padding(
                  padding: const EdgeInsets.only(top: 280.0),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          //Email
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: TextFormField(
                                  controller: _emailEditingController,
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      icon: Icon(Icons.email),
                                      border: InputBorder.none
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
                            ),
                          ),
                          //Password
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ListTile(
                                    title: TextFormField(
                                      obscureText: togglePass,
                                      controller: _passwordEditingController,
                                      decoration: InputDecoration(
                                          hintText: "Password",
                                          icon: Icon(Icons.lock),
                                          border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "The password field cannot be empty";
                                        } else if (value.length < 6) {
                                          return "The password has to be at least 6 characters long";
                                        }
                                        return null;
                                      },
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        setState(() {
                                          togglePass = !togglePass;
                                        });
                                      },)
                                ),
                              ),
                            ),
                          ),
                          //Login
                          Padding(
                            padding: const EdgeInsets.fromLTRB(100,10,100,0),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.deepOrange.withOpacity(0.8),
                              elevation: 0.0,
                              child: MaterialButton(
                                onPressed: () async {
                                  loginToHomePage();
                                },
                                minWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Text("Login", textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }else if(constraints.maxWidth > 351 && constraints.maxWidth < 410){
                return Padding(
                  padding: const EdgeInsets.only(top: 340.0),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          //Email
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: TextFormField(
                                  controller: _emailEditingController,
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      icon: Icon(Icons.email),
                                      border: InputBorder.none
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
                            ),
                          ),
                          //Password
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ListTile(
                                    title: TextFormField(
                                      obscureText: togglePass,
                                      controller: _passwordEditingController,
                                      decoration: InputDecoration(
                                          hintText: "Password",
                                          icon: Icon(Icons.lock),
                                          border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "The password field cannot be empty";
                                        } else if (value.length < 6) {
                                          return "The password has to be at least 6 characters long";
                                        }
                                        return null;
                                      },
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        setState(() {
                                          togglePass = !togglePass;
                                        });
                                      },)
                                ),
                              ),
                            ),
                          ),
                          //Login
                          Padding(
                            padding: const EdgeInsets.fromLTRB(100,10,100,0),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.deepOrange.withOpacity(0.8),
                              elevation: 0.0,
                              child: MaterialButton(
                                onPressed: () async {
                                  loginToHomePage();
                                },
                                minWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Text("Login", textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }else if(constraints.maxWidth > 411 && constraints.maxWidth < 500){
                return Padding(
                  padding: const EdgeInsets.only(top: 370.0),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          //Email
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: TextFormField(
                                  controller: _emailEditingController,
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      icon: Icon(Icons.email),
                                      border: InputBorder.none
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
                            ),
                          ),
                          //Password
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,10,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ListTile(
                                    title: TextFormField(
                                      obscureText: togglePass,
                                      controller: _passwordEditingController,
                                      decoration: InputDecoration(
                                          hintText: "Password",
                                          icon: Icon(Icons.lock),
                                          border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "The password field cannot be empty";
                                        } else if (value.length < 6) {
                                          return "The password has to be at least 6 characters long";
                                        }
                                        return null;
                                      },
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        setState(() {
                                          togglePass = !togglePass;
                                        });
                                      },)
                                ),
                              ),
                            ),
                          ),
                          //Login
                          Padding(
                            padding: const EdgeInsets.fromLTRB(100,10,100,0),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.deepOrange.withOpacity(0.8),
                              elevation: 0.0,
                              child: MaterialButton(
                                onPressed: () async {
                                  loginToHomePage();
                                },
                                minWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Text("Login", textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }else if(constraints.maxWidth > 501){
                return Padding(
                  padding: const EdgeInsets.only(top: 370.0),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          //Email
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: TextFormField(
                                  controller: _emailEditingController,
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      icon: Icon(Icons.email),
                                      border: InputBorder.none
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
                            ),
                          ),
                          //Password
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,10,30,10),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withOpacity(0.6),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ListTile(
                                    title: TextFormField(
                                      obscureText: togglePass,
                                      controller: _passwordEditingController,
                                      decoration: InputDecoration(
                                          hintText: "Password",
                                          icon: Icon(Icons.lock),
                                          border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "The password field cannot be empty";
                                        } else if (value.length < 6) {
                                          return "The password has to be at least 6 characters long";
                                        }
                                        return null;
                                      },
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        setState(() {
                                          togglePass = !togglePass;
                                        });
                                      },)
                                ),
                              ),
                            ),
                          ),
                          //Login
                          Padding(
                            padding: const EdgeInsets.fromLTRB(100,10,100,0),
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.deepOrange.withOpacity(0.8),
                              elevation: 0.0,
                              child: MaterialButton(
                                onPressed: () async {
                                  loginToHomePage();
                                },
                                minWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Text("Login", textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }else return null;
            }
          ),
          haveError ? _showError(errorMessage) : Text(""),
          isLoggedIn ? Container(alignment: Alignment.center,child: Center(child: CircularProgressIndicator(),),) : Text("")
        ],
      ),
    );
  }

  Future loginToHomePage() async {
    FormState formState = _formKey.currentState;
    if (formState.validate()) {

      try{

        if (this.mounted){
          setState((){
            isLoggedIn = true;
          });
        }

        AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
            email: _emailEditingController.text,
            password: _passwordEditingController.text
        );
        FirebaseUser user = result.user;

        final FirebaseUser currentUser = await firebaseAuth.currentUser();

        DocumentReference docRef = Firestore.instance.collection("users").document(user.uid);

        print(docRef);

        // ignore: missing_return
        docRef.get().then((documentSnapshot) async {
          if(documentSnapshot["isLoggedIn"] == true){
            setState(() {
              isLoggedIn = false;
            });
            Fluttertoast.showToast(
                msg: "This account is already logged in in other device!!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 15.0
            );
          }else if(documentSnapshot["isLoggedIn"] == false){
            Firestore.instance.collection("users").document(user.uid).updateData({
              "isLoggedIn" : true
            });

            assert(user != null);
            assert(await user.getIdToken() != null);

            assert(user.uid == currentUser.uid);

            Fluttertoast.showToast(
                msg: "Logged in successfully!!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 15.0
            );

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminPage(user: user,)));
          }else{
            Fluttertoast.showToast(
                msg: "Maybe have some errors",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        });


        formState.reset();

        return user;

      }on PlatformException catch(e){
        setState(() {
          isLoggedIn = false;
          errorMessage = e.message;
          haveError = true;
        });
        _showError(errorMessage);
      }
    }
  }
  _showError(String errorMessage){
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Dialog(child: Text(errorMessage,style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),textAlign: TextAlign.center,), insetAnimationDuration: Duration(milliseconds: 1000),),
    );
  }
}