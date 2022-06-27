import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admin/db/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin/db/brand.dart';
import 'package:admin/db/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProduct extends StatefulWidget {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final bool onSale;
  final bool featured;
  final List colors;
  final List sizes;
  final List images;
  final double price;
  final double oldPrice;
  UpdateProduct({Key key,
    @required this.id, this.images, this.sizes, this.colors,
    this.featured, this.onSale, this.price, this.name,
    this.category, this.brand, this.description, this.oldPrice}) : super(key: key);
  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {

  BrandServices _brandServices = BrandServices();
  CategoryServices _categoryServices = CategoryServices();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <
      DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ProductServices _productServices = ProductServices();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _productDescribeController = TextEditingController();
  TextEditingController _oldPriceController = TextEditingController();
  TextEditingController _colorController1 = TextEditingController();
  TextEditingController _colorController2 = TextEditingController();
  TextEditingController _colorController3 = TextEditingController();
  TextEditingController _sizeController1 = TextEditingController();
  TextEditingController _sizeController2 = TextEditingController();
  TextEditingController _sizeController3 = TextEditingController();
  TextEditingController _sizeController4 = TextEditingController();
  TextEditingController _sizeController5 = TextEditingController();
  TextEditingController _sizeController6 = TextEditingController();
  List<String> imagesList = <String>[];
  List<String> sizesList = <String>[];
  List<String> colorsList = <String>[];
  bool isDisplaying1 = false;
  bool isDisplaying2 = false;
  bool isDisplaying3 = false;
  bool sale = false;
  bool featured = false;
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;
  bool isHaveSize = true;
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
        title: Text("Update Product"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Image: ", style: TextStyle(color: Colors.red,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),)
                ),
              ),
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
                              color: Colors.grey.withOpacity(0.8), width: 1.0),
                          child: isDisplaying1 ? _displayImage1() : Image
                              .network(widget.images[0])),
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
                              color: Colors.grey.withOpacity(0.8), width: 1.0),
                          child: isDisplaying2 ? _displayImage2() : Image
                              .network(widget.images[1])),
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
                              color: Colors.grey.withOpacity(0.8), width: 1.0),
                          child: isDisplaying3 ? _displayImage3() : Image
                              .network(widget.images[2])),
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
                  decoration: InputDecoration(hintText:  widget.name,
                      labelText: "Product name",
                      labelStyle: TextStyle(
                          color: Colors.blue, fontSize: 18.0)),
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
                  decoration: InputDecoration(hintText: widget.description,
                      labelText: "Product description",
                      labelStyle: TextStyle(
                          color: Colors.blue, fontSize: 18.0)),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please fill up product description";
                    }return null;
                  },
                ),
              ),
              Divider(),

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
                  decoration: InputDecoration(hintText: widget.price.toString(),
                      labelText: "Price",
                      labelStyle: TextStyle(
                          color: Colors.blue, fontSize: 18.0)),
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
                      Text('Sale:',
                        style: TextStyle(color: Colors.red, fontSize: 18.0),),
                      SizedBox(width: 10,),
                      Switch(value: widget.onSale, onChanged: (value) {
                        setState(() {
                          sale = value;
                        });
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Featured:',
                        style: TextStyle(color: Colors.red, fontSize: 18.0),),
                      SizedBox(width: 10,),
                      Switch(value: widget.featured, onChanged: (value) {
                        setState(() {
                          featured = value;
                        });
                      }),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,200,10),
                child: Container(
                  width: 120,
                  child: TextFormField(
                    controller: _oldPriceController,
                    decoration: InputDecoration(hintText: widget.oldPrice.toString(),
                        labelText: "Old price",
                        labelStyle: TextStyle(
                            color: Colors.blue, fontSize: 18.0)),
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text("Choose Your Colors",
                  style: TextStyle(color: Colors.red,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              //Colors
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: _displayTextFieldColor(widget.colors[0], _colorController1)
                  ),
                  Expanded(
                      child: _displayTextFieldColor(widget.colors[1], _colorController2)
                  ),
                  Expanded(
                      child: _displayTextFieldColor(widget.colors[2], _colorController3)
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  "Available Sizes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.red),
                ),
              ),

              //Sizes with number
              _displaySizes(),
              Divider(),

              //Button Add product
              Padding(
                padding:
                const EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
                child: FlatButton(
                  onPressed: () {
                    updateProduct();
                  },
                  child: Text(
                    "Update product",
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

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() {
          _image1 = tempImg;
          isDisplaying1 = true;
        });
        break;
      case 2:
        setState(() {
          _image2 = tempImg;
          isDisplaying2 = true;
        });
        break;
      case 3:
        setState(() {
          _image3 = tempImg;
          isDisplaying3 = true;
        });
        break;
    }
  }

  Widget _displayTextFieldColor(String color, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: "Color",
            labelText: color,
            labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),),
        ),
      ),
    );
  }


  Widget _displayTextFieldSize(String size, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Size",
            labelText: size,
            labelStyle: TextStyle(color: Colors.blue, fontSize: 18.0),),
        ),
      ),
    );
  }

  Widget _displaySizes(){
    if(widget.sizes.length > 0){
      setState(() {
        isHaveSize = true;
      });
      return Row(
        children: <Widget>[
          Expanded(
              child: _displayTextFieldSize(widget.sizes[0], _sizeController1)
          ),
          Expanded(
              child: _displayTextFieldSize(widget.sizes[1], _sizeController2)
          ),
          Expanded(
              child: _displayTextFieldSize(widget.sizes[2], _sizeController3)
          ),
          Expanded(
              child: _displayTextFieldSize(widget.sizes[3], _sizeController4)
          ),
          Expanded(
              child: _displayTextFieldSize(widget.sizes[4], _sizeController5)
          ),
          Expanded(
              child: _displayTextFieldSize(widget.sizes[5], _sizeController6)
          ),
        ],
      );
    }else{
      setState(() {
        isHaveSize = false;
      });
      return Text("No have sizes with this product", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w700),);
    }
  }

  Widget _displayImage1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 70.0, 15.0, 70.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image1);
    }
  }

  Widget _displayImage2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 70.0, 15.0, 70.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image2);
    }
  }

  Widget _displayImage3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 70.0, 15.0, 70.0),
        child: Icon(Icons.add),
      );
    } else {
      return Image.file(_image3);
    }
  }

  void _getBrands() async {
    List<DocumentSnapshot> data1 = await _brandServices.getBrands();
    setState(() {
      brands = data1;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = widget.brand;
    });
  }

  void _getCategories() async {
    List<DocumentSnapshot> data = await _categoryServices.getCategories();
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = widget.category;
    });
  }
  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }
  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }



  void updateProduct() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      if(isDisplaying1 == true){
        String imageUrl1;
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 =
            "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task1 =
        storage.ref().child(picture1).putFile(_image1);
        StorageTaskSnapshot snapshot1 =
        await task1.onComplete.then((snapshot) => snapshot);
        imageUrl1 = await snapshot1.ref.getDownloadURL();
        imagesList.add(imageUrl1);
      }else{
        imagesList.add(widget.images[0]);
      }
      if(isDisplaying2 == true){
        String imageUrl2;
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture2 =
            "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task2 =
        storage.ref().child(picture2).putFile(_image2);
        StorageTaskSnapshot snapshot2 =
        await task2.onComplete.then((snapshot) => snapshot);
        imageUrl2 = await snapshot2.ref.getDownloadURL();
        imagesList.add(imageUrl2);
      }else{
        imagesList.add(widget.images[1]);
      }
      if(isDisplaying3 == true){
        String imageUrl3;
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture3 =
            "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task3 =
        storage.ref().child(picture3).putFile(_image3);
        StorageTaskSnapshot snapshot3 =
        await task3.onComplete.then((snapshot) => snapshot);
        imageUrl3 = await snapshot3.ref.getDownloadURL();
        imagesList.add(imageUrl3);
      }else{
        imagesList.add(widget.images[2]);
      }
      if(_colorController1.text != "" && _colorController1.text != "" && _colorController3.text != ""){
        colorsList = [_colorController1.text,_colorController2.text,_colorController3.text];
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
      if(isHaveSize){
        if(_sizeController1.text != "" && _sizeController1.text != "" && _sizeController1.text != "" &&
            _sizeController1.text != "" && _sizeController1.text != "" && _sizeController1.text != ""){
          sizesList = [_sizeController1.text,_sizeController2.text,_sizeController3.text,_sizeController4.text,
            _sizeController5.text,_sizeController6.text];
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
        sizesList = [];
      }
      if(sale){
        if(_oldPriceController.text != ""){
          _productServices.updateProduct(
              widget.id,
              _productNameController.text,
              _currentBrand,
              _currentCategory,
              sizesList,
              imagesList,
              double.parse(_priceController.text),
              sale,
              featured,
              colorsList,
              _productDescribeController.text,
              sale ? double.parse(_oldPriceController.text) : 0
          );
          _formKey.currentState.reset();
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Product updated succesfully!",
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
              msg: "Please fill up old price!",
              fontSize: 18.0,
              textColor: Colors.white,
              backgroundColor: Colors.black,
              timeInSecForIosWeb: 2);
        }
      }else{
        _oldPriceController.text = "";
        _productServices.updateProduct(
            widget.id,
            _productNameController.text,
            _currentBrand,
            _currentCategory,
            sizesList,
            imagesList,
            double.parse(_priceController.text),
            sale,
            featured,
            colorsList,
            _productDescribeController.text,
            sale ? double.parse(_oldPriceController.text) : 0
        );
        _formKey.currentState.reset();
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Product updated succesfully!",
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
          msg: "Please complete fill up the form!",
          fontSize: 18.0,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          timeInSecForIosWeb: 2);
    }
  }
}