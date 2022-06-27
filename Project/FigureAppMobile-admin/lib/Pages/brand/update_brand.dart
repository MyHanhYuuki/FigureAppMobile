import 'dart:io';
import 'package:flutter/material.dart';
import 'package:admin/db/brand.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateBrand extends StatefulWidget {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String image;

  UpdateBrand({Key key,
    @required this.id, this.name, this.image, this.address, this.phoneNumber}) : super(key: key);
  @override
  _UpdateBrandState createState() => _UpdateBrandState();
}

class _UpdateBrandState extends State<UpdateBrand> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController brandNameController = TextEditingController();
  TextEditingController brandAddressController = TextEditingController();
  TextEditingController brandPhoneNumberController = TextEditingController();
  BrandServices _brandServices = BrandServices();
  File _image;
  Color grey = Colors.grey;
  bool isLoading = false;
  bool isDisplaying = false;
  String imageNew;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Update Brand"),
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
                  controller: brandNameController,
                  decoration: InputDecoration(
                      hintText: "Brand Name",
                      labelText: widget.name,
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                      hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return "Please enter brand name!";
                    }else{
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: brandAddressController,
                  decoration: InputDecoration(
                      labelText: widget.address,
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                      hintText: "Brand Address",
                      hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return "Please enter brand address!";
                    }else{
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: brandPhoneNumberController,
                  decoration: InputDecoration(
                      labelText: widget.phoneNumber,
                      labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
                      hintText: "Brand Phone Number",
                      hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return "Please enter brand phone number!";
                    }else if(value.length < 10 && value.length > 10){
                      return "Phone number cannot be less than 10 characters or more than 10 characters";
                    }
                    return null;
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
                    "Update brand",
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
    if (_image == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 70.0, 15.0, 70.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image, width: 250, height: 300,);
    }
  }

  void validationAndUpload() async{
    if(_formKey.currentState.validate()){
      if(isDisplaying == true){
        String imageUrl;
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture =
            "${brandNameController.text}${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task =
        storage.ref().child(picture).putFile(_image);
        StorageTaskSnapshot snapshot1 =
        await task.onComplete.then((snapshot) => snapshot);
        imageUrl = await snapshot1.ref.getDownloadURL();
        imageNew = imageUrl;
      }else{
        imageNew = widget.image;
      }
      _brandServices.updateBrand(widget.id, brandNameController.text,
          brandAddressController.text, brandPhoneNumberController.text, imageNew);
      _formKey.currentState.reset();
      Fluttertoast.showToast(
          msg: "Updated brand succesfully!",
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
