import 'dart:io';
import 'package:flutter/material.dart';
import 'package:admin/db/category.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateCategory extends StatefulWidget {
  final String id;
  final String name;
  final String image;
  UpdateCategory({Key key, @required this.id, this.image, this.name}) : super(key : key);
  @override
  _UpdateCategoryState createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController categoryNameController = TextEditingController();

  CategoryServices _categoryServices = CategoryServices();
  File _image;
  Color grey = Colors.grey;
  bool isLoading = false;
  bool isDisplaying = false;
  String imageNew;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Update Category"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: isLoading ? Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: Container(alignment: Alignment.center,child: Center(child: CircularProgressIndicator())),
          ) :
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: OutlineButton(
                      onPressed: () {
                        _selectImage(
                            ImagePicker.pickImage(
                                source: ImageSource.gallery),
                            1);
                      },
                      borderSide: BorderSide(
                          color: grey.withOpacity(0.8), width: 1.0),
                      child: isDisplaying ? _displayImage() : Image.network(widget.image, height: 300, width: 250,)),
                ),
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                      hintText: "Cateogry Name",
                      labelText: widget.name,
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                      hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return "Please enter category name!";
                    }else{
                      return null;
                    }
                  },
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.fromLTRB(100.0, 50.0, 100.0, 0.0),
                child: FlatButton(
                  onPressed: () {
                    validationAndUpload();
                  },
                  child: Text(
                    "Update category",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImage(Future<File> pickImage, int i) async{
    File tempImg = await pickImage;
    setState(() {
      _image = tempImg;
      isDisplaying = true;
    });
  }

  Widget _displayImage(){
    if(_image == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 70.0, 10.0, 70.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image, width: 250, height: 300,);
    }
  }

  void validationAndUpload() async{
    if(_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      if(isDisplaying == true){
        String imageUrl;
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture =
            "${categoryNameController.text}${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task =
        storage.ref().child(picture).putFile(_image);
        StorageTaskSnapshot snapshot1 =
        await task.onComplete.then((snapshot) => snapshot);
        imageUrl = await snapshot1.ref.getDownloadURL();
        imageNew = imageUrl;
      }else{
        imageNew = widget.image;
      }
      _categoryServices.updateCategory(widget.id, categoryNameController.text, imageNew);
      _formKey.currentState.reset();
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Updated category succesfully!",
          fontSize: 18.0,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          timeInSecForIosWeb: 2);
      Navigator.pop(context);
    }else{
      Fluttertoast.showToast(
          msg: "Please complete fill up in form!",
          fontSize: 18.0,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          timeInSecForIosWeb: 2);
    }
  }
}

