import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:admin/db/product.dart';
import 'package:admin/db/brand.dart';
import 'package:admin/db/category.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  BrandServices _brandServices = BrandServices();
  CategoryServices _categoryServices = CategoryServices();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ProductServices _productServices = ProductServices();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _productDescribeController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _colorController1 = TextEditingController();
  TextEditingController _colorController2 = TextEditingController();
  TextEditingController _colorController3 = TextEditingController();
  TextEditingController _sizeController1 = TextEditingController();
  TextEditingController _sizeController2 = TextEditingController();
  TextEditingController _sizeController3 = TextEditingController();
  TextEditingController _sizeController4 = TextEditingController();
  TextEditingController _sizeController5 = TextEditingController();
  TextEditingController _sizeController6 = TextEditingController();
  TextEditingController _oldPriceController = TextEditingController();
  List<String> selectSizes = <String>[];
  List<String> colors = <String>[];
  bool featured = false;
  bool sale = false;
  bool isLoading = false;
  bool isNeedSizes = false;
  bool favourite = false;
  File _image1;
  File _image2;
  File _image3;


  @override
  void initState() {
    super.initState();
    _getBrands();
    _getCategories();
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items1 = [];
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items1.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data['brandName']),
                value: brands[i].data['brandName']));
      });
    }
    return items1;
  }
  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(categories[i].data['categoryName']),
                value: categories[i].data['categoryName']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: white,
        elevation: 0.0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            color: black,
          ),
        ),
        title: Text(
          "Add product",
          style: TextStyle(color: black),
        ),
      ),
      body: isLoading ? Container(alignment: Alignment.center,child: Center(child: CircularProgressIndicator()))
          : LayoutBuilder(
        builder: (context,constraints){
          if(constraints.maxWidth < 350){
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[


                        //Choose image of product
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      1);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage1()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage2()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      3);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage3()),
                          ),
                        ),


                      ],
                    ),
                    Divider(),
                    Text(
                      "Enter a product name (30 letters maximum)",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),



                    //Add product name
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(hintText: "Product name"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product name";
                          } else if (value.length > 30) {
                            return "Product name can't have more than 10 letters";
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _productDescribeController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Product description",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product description";
                          }return null;
                        },
                      ),
                    ),
                    Divider(),

                    //Category & brand
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        children: <Widget>[
                          Text('Category: ',
                            style: TextStyle(color: Colors.red, fontSize: 16.0),
                          ),
                          DropdownButton(
                            items: categoriesDropDown,
                            onChanged: changeSelectedCategory,
                            value: _currentCategory,
                          ),
                          SizedBox(width: 10,),
                          Text(
                            'Brand: ',
                            style: TextStyle(color: Colors.red, fontSize: 16.0),
                          ),
                          DropdownButton(
                            items: brandsDropDown,
                            onChanged: changeSelectedBrand,
                            value: _currentBrand,
                          ),
                        ],
                      ),
                    ),



                    //Price
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(hintText: "Price"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up price";
                          }
                          return null;
                        },
                      ),
                    ),



                    //Sale and featured
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Sale:', style: TextStyle(color: Colors.red, fontSize: 16.0),),
                            SizedBox(width: 10,),
                            Switch(value: sale, onChanged: (value){
                              setState(() {
                                sale = value;
                              });
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Featured:', style: TextStyle(color: Colors.red, fontSize: 16.0),),
                            SizedBox(width: 10,),
                            Switch(value: featured,onChanged: (value){
                              setState(() {
                                featured = value;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                    sale ? Padding(
                      padding: const EdgeInsets.fromLTRB(10,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          controller: _oldPriceController,
                          decoration: InputDecoration(hintText: "New Price"),
                          validator: (value){
                            if(value.isEmpty){
                              return "Please fill up new price";
                            }return null;
                          },
                        ),
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.fromLTRB(10,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          enabled: false,
                          controller: _oldPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "Price"),
                        ),
                      ),
                    ),

                    //Colors
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text("Choose Your Colors",
                        style: TextStyle(color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            child: TextFormField(
                              controller: _colorController1,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            child: TextFormField(
                              controller: _colorController2,
                              decoration: InputDecoration(hintText: "Color",),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            child: TextFormField(
                              controller: _colorController3,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Choose Your Sizes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.red),
                      ),
                    ),
                    Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Need Sizes?', style: TextStyle(color: Colors.red, fontSize: 16.0),),
                        SizedBox(width: 10,),
                        Switch(value: isNeedSizes, onChanged: (value){
                          setState(() {
                            isNeedSizes = value;
                          });
                        }),
                      ],
                    ),

                    //Sizes
                    isNeedSizes ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ),
                    Divider(),

                    //Button Add product
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(90.0, 0.0, 90.0, 0.0),
                      child: FlatButton(
                        onPressed: () {
                          validationAndUpload();
                        },
                        child: Text(
                          "Add product",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }else if(constraints.maxWidth > 351 && constraints.maxWidth < 410){
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[


                        //Choose image of product
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      1);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage1()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage2()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      3);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage3()),
                          ),
                        ),


                      ],
                    ),
                    Divider(),
                    Text(
                      "Enter a product name (30 letters maximum)",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),



                    //Add product name
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(hintText: "Product name"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product name";
                          } else if (value.length > 30) {
                            return "Product name can't have more than 10 letters";
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _productDescribeController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Product description",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product description";
                          }return null;
                        },
                      ),
                    ),
                    Divider(),

                    //Category & brand
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        children: <Widget>[
                          Text('Category: ',
                            style: TextStyle(color: Colors.red, fontSize: 16.0),
                          ),
                          DropdownButton(
                            items: categoriesDropDown,
                            onChanged: changeSelectedCategory,
                            value: _currentCategory,
                          ),
                          SizedBox(width: 10,),
                          Text(
                            'Brand: ',
                            style: TextStyle(color: Colors.red, fontSize: 16.0),
                          ),
                          DropdownButton(
                            items: brandsDropDown,
                            onChanged: changeSelectedBrand,
                            value: _currentBrand,
                          ),
                        ],
                      ),
                    ),



                    //Price
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(hintText: "Price"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up price";
                          }
                          return null;
                        },
                      ),
                    ),



                    //Sale and featured
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Sale:', style: TextStyle(color: Colors.red, fontSize: 16.0),),
                            SizedBox(width: 10,),
                            Switch(value: sale, onChanged: (value){
                              setState(() {
                                sale = value;
                              });
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Featured:', style: TextStyle(color: Colors.red, fontSize: 16.0),),
                            SizedBox(width: 10,),
                            Switch(value: featured,onChanged: (value){
                              setState(() {
                                featured = value;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                    sale ? Padding(
                      padding: const EdgeInsets.fromLTRB(10,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          controller: _oldPriceController,
                          decoration: InputDecoration(hintText: "Old Price"),
                          validator: (value){
                            if(value.isEmpty){
                              return "Please fill up old price";
                            }return null;
                          },
                        ),
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.fromLTRB(10,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          enabled: false,
                          controller: _oldPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "New Price"),
                        ),
                      ),
                    ),

                    //Colors
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text("Choose Your Colors",
                        style: TextStyle(color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            child: TextFormField(
                              controller: _colorController1,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            child: TextFormField(
                              controller: _colorController2,
                              decoration: InputDecoration(hintText: "Color",),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            child: TextFormField(
                              controller: _colorController3,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Choose Your Sizes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.red),
                      ),
                    ),
                    Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Need Sizes?', style: TextStyle(color: Colors.red, fontSize: 16.0),),
                        SizedBox(width: 10,),
                        Switch(value: isNeedSizes, onChanged: (value){
                          setState(() {
                            isNeedSizes = value;
                          });
                        }),
                      ],
                    ),

                    //Sizes
                    isNeedSizes ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 30,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ),
                    Divider(),

                    //Button Add product
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(90.0, 0.0, 90.0, 0.0),
                      child: FlatButton(
                        onPressed: () {
                          validationAndUpload();
                        },
                        child: Text(
                          "Add product",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }else if(constraints.maxWidth > 411 && constraints.maxWidth < 500){
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[


                        //Choose image of product
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      1);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage1()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage2()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      3);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage3()),
                          ),
                        ),


                      ],
                    ),
                    Divider(),
                    Text(
                      "Enter a product name (30 letters maximum)",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),



                    //Add product name
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(hintText: "Product name"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product name";
                          } else if (value.length > 30) {
                            return "Product name can't have more than 10 letters";
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _productDescribeController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Product description",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product description";
                          }return null;
                        },
                      ),
                    ),
                    Divider(),




                    //Category & brand
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Row(
                        children: <Widget>[
                          Text('Category: ',
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                          DropdownButton(
                            items: categoriesDropDown,
                            onChanged: changeSelectedCategory,
                            value: _currentCategory,
                          ),
                          SizedBox(width: 50,),
                          Text(
                            'Brand: ',
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                          DropdownButton(
                            items: brandsDropDown,
                            onChanged: changeSelectedBrand,
                            value: _currentBrand,
                          ),
                        ],
                      ),
                    ),



                    //Price
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(hintText: "Price"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up price";
                          }
                          return null;
                        },
                      ),
                    ),



                    //Sale and featured
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Sale:', style: TextStyle(color: Colors.red, fontSize: 18.0),),
                            SizedBox(width: 10,),
                            Switch(value: sale, onChanged: (value){
                              setState(() {
                                sale = value;
                              });
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Featured:', style: TextStyle(color: Colors.red, fontSize: 18.0),),
                            SizedBox(width: 10,),
                            Switch(value: featured,onChanged: (value){
                              setState(() {
                                featured = value;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                    sale ? Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          controller: _oldPriceController,
                          decoration: InputDecoration(hintText: "Old Price"),
                          validator: (value){
                            if(value.isEmpty){
                              return "Please fill up old price";
                            }return null;
                          },
                        ),
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          enabled: false,
                          controller: _oldPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "New Price"),
                        ),
                      ),
                    ),

                    //Colors
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text("Choose Your Colors",
                        style: TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: TextFormField(
                              controller: _colorController1,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: TextFormField(
                              controller: _colorController2,
                              decoration: InputDecoration(hintText: "Color",),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: TextFormField(
                              controller: _colorController3,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Choose Your Sizes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.red),
                      ),
                    ),
                    Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Need Sizes?', style: TextStyle(color: Colors.red, fontSize: 18.0),),
                        SizedBox(width: 10,),
                        Switch(value: isNeedSizes, onChanged: (value){
                          setState(() {
                            isNeedSizes = value;
                          });
                        }),
                      ],
                    ),

                    //Sizes
                    isNeedSizes ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ),
                    Divider(),

                    //Button Add product
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
                      child: FlatButton(
                        onPressed: () {
                          validationAndUpload();
                        },
                        child: Text(
                          "Add product",
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
            );
          }else if(constraints.maxWidth > 501){
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[


                        //Choose image of product
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      1);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage1()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage2()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      3);
                                },
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.8), width: 1.0),
                                child: _displayImage3()),
                          ),
                        ),


                      ],
                    ),
                    Divider(),
                    Text(
                      "Enter a product name (30 letters maximum)",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),



                    //Add product name
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(hintText: "Product name"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product name";
                          } else if (value.length > 30) {
                            return "Product name can't have more than 10 letters";
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _productDescribeController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Product description",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up product description";
                          }return null;
                        },
                      ),
                    ),
                    Divider(),




                    //Category & brand
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Row(
                        children: <Widget>[
                          Text('Category: ',
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                          DropdownButton(
                            items: categoriesDropDown,
                            onChanged: changeSelectedCategory,
                            value: _currentCategory,
                          ),
                          SizedBox(width: 50,),
                          Text(
                            'Brand: ',
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                          DropdownButton(
                            items: brandsDropDown,
                            onChanged: changeSelectedBrand,
                            value: _currentBrand,
                          ),
                        ],
                      ),
                    ),



                    //Price
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(hintText: "Price"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please fill up price";
                          }
                          return null;
                        },
                      ),
                    ),



                    //Sale and featured
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Sale:', style: TextStyle(color: Colors.red, fontSize: 18.0),),
                            SizedBox(width: 10,),
                            Switch(value: sale, onChanged: (value){
                              setState(() {
                                sale = value;
                              });
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Featured:', style: TextStyle(color: Colors.red, fontSize: 18.0),),
                            SizedBox(width: 10,),
                            Switch(value: featured,onChanged: (value){
                              setState(() {
                                featured = value;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                    sale ? Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          controller: _oldPriceController,
                          decoration: InputDecoration(hintText: "Old Price"),
                          validator: (value){
                            if(value.isEmpty){
                              return "Please fill up old price";
                            }return null;
                          },
                        ),
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,200,10),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          enabled: false,
                          controller: _oldPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "New Price"),
                        ),
                      ),
                    ),

                    //Colors
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text("Choose Your Colors",
                        style: TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: TextFormField(
                              controller: _colorController1,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: TextFormField(
                              controller: _colorController2,
                              decoration: InputDecoration(hintText: "Color",),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: TextFormField(
                              controller: _colorController3,
                              decoration: InputDecoration(hintText: "Color"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Choose Your Sizes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.red),
                      ),
                    ),
                    Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Need Sizes?', style: TextStyle(color: Colors.red, fontSize: 18.0),),
                        SizedBox(width: 10,),
                        Switch(value: isNeedSizes, onChanged: (value){
                          setState(() {
                            isNeedSizes = value;
                          });
                        }),
                      ],
                    ),

                    //Sizes
                    isNeedSizes ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController1,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController2,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController3,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController4,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController5,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            child: TextFormField(
                              enabled: false,
                              controller: _sizeController6,
                              decoration: InputDecoration(hintText: "Size"),
                            ),
                          ),
                        ),

                      ],
                    ),
                    Divider(),

                    //Button Add product
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
                      child: FlatButton(
                        onPressed: () {
                          validationAndUpload();
                        },
                        child: Text(
                          "Add product",
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
            );
          }else return null;
        },
      )
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryServices.getCategories();
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['categoryName'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data1 = await _brandServices.getBrands();
    setState(() {
      brands = data1;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data['brandName'];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() {
          _image1 = tempImg;
        });
        break;
      case 2:
        setState(() {
          _image2 = tempImg;
        });
        break;
      case 3:
        setState(() {
          _image3 = tempImg;
        });
        break;
    }
  }

  //Show Image
  Widget _displayImage1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 50.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image1);
    }
  }

  Widget _displayImage2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 50.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image2);
    }
  }

  Widget _displayImage3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 50.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image3);
    }
  }

  //Validation and add product's info to database
  void validationAndUpload() async {
    if(_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      if(_image1 != null && _image2 != null && _image3 != null){
        if(_colorController1.text != "" && _colorController2.text != "" && _colorController3.text != ""){
          if(isNeedSizes){
            if(_sizeController1.text != "" && _sizeController2.text != "" && _sizeController3.text != "" &&
            _sizeController4.text != "" && _sizeController5.text != "" && _sizeController6.text != ""){
              selectSizes = [_sizeController1.text,_sizeController2.text,_sizeController3.text,
                _sizeController4.text,_sizeController5.text,_sizeController6.text];
              String imageUrl1;
              String imageUrl2;
              String imageUrl3;

              final FirebaseStorage storage = FirebaseStorage.instance;

              final String picture1 =
                  "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
              StorageUploadTask task1 =
              storage.ref().child(picture1).putFile(_image1);

              final String picture2 =
                  "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
              StorageUploadTask task2 =
              storage.ref().child(picture2).putFile(_image2);

              final String picture3 =
                  "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
              StorageUploadTask task3 =
              storage.ref().child(picture3).putFile(_image3);

              StorageTaskSnapshot snapshot1 =
              await task1.onComplete.then((snapshot) => snapshot);
              StorageTaskSnapshot snapshot2 =
              await task2.onComplete.then((snapshot) => snapshot);
              StorageTaskSnapshot snapshot3 =
              await task3.onComplete.then((snapshot) => snapshot);

              imageUrl1 = await snapshot1.ref.getDownloadURL();
              imageUrl2 = await snapshot2.ref.getDownloadURL();
              imageUrl3 = await snapshot3.ref.getDownloadURL();

              List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];
              colors = [_colorController1.text, _colorController2.text, _colorController3.text];

              _productServices.uploadProduct(
                  productName: _productNameController.text,
                  price: double.parse(_priceController.text),
                  oldPrice: sale ? double.parse(_oldPriceController.text) : 0,
                  description: _productDescribeController.text,
                  images: imageList,
                  brand: _currentBrand,
                  category: _currentCategory,
                  sizes: selectSizes,
                  colors: colors,
                  sale: sale,
                  featured: featured,
              );
              //_formKey.currentState.reset();
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: "Product added succesfully!",
                  fontSize: 18.0,
                  textColor: Colors.white,
                  backgroundColor: Colors.red,
                  timeInSecForIosWeb: 2);
              Navigator.pop(context);
            }else{
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: "Please fill up these sizes!",
                  fontSize: 18.0,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                  timeInSecForIosWeb: 2);
            }
          }else{
            selectSizes = [];
            String imageUrl1;
            String imageUrl2;
            String imageUrl3;

            final FirebaseStorage storage = FirebaseStorage.instance;

            final String picture1 =
                "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
            StorageUploadTask task1 =
            storage.ref().child(picture1).putFile(_image1);

            final String picture2 =
                "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
            StorageUploadTask task2 =
            storage.ref().child(picture2).putFile(_image2);

            final String picture3 =
                "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
            StorageUploadTask task3 =
            storage.ref().child(picture3).putFile(_image3);

            StorageTaskSnapshot snapshot1 =
            await task1.onComplete.then((snapshot) => snapshot);
            StorageTaskSnapshot snapshot2 =
            await task2.onComplete.then((snapshot) => snapshot);
            StorageTaskSnapshot snapshot3 =
            await task3.onComplete.then((snapshot) => snapshot);

            imageUrl1 = await snapshot1.ref.getDownloadURL();
            imageUrl2 = await snapshot2.ref.getDownloadURL();
            imageUrl3 = await snapshot3.ref.getDownloadURL();

            List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];
            colors = [_colorController1.text, _colorController2.text, _colorController3.text];

            _productServices.uploadProduct(
                productName: _productNameController.text,
                price: double.parse(_priceController.text),
                oldPrice:sale ? double.parse(_oldPriceController.text) : 0,
                description: _productDescribeController.text,
                images: imageList,
                brand: _currentBrand,
                category: _currentCategory,
                sizes: selectSizes,
                colors: colors,
                sale: sale,
                featured: featured,
            );
            //_formKey.currentState.reset();
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: "Product added succesfully!",
                fontSize: 18.0,
                textColor: Colors.white,
                backgroundColor: Colors.red,
                timeInSecForIosWeb: 2);
            Navigator.pop(context);
          }
        }else{
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Please fill up these colors!",
              fontSize: 18.0,
              textColor: Colors.white,
              backgroundColor: Colors.black,
              timeInSecForIosWeb: 2);
        }
      }else{
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "All images need to be provided!",
            fontSize: 18.0,
            textColor: Colors.white,
            backgroundColor: Colors.black,
            timeInSecForIosWeb: 2);
      }
    }else{
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Please fill up the form!",
          fontSize: 18.0,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          timeInSecForIosWeb: 2);
    }
  }
}














