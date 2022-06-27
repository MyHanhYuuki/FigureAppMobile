import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BrandServices {
  Firestore _fireStore = Firestore.instance;
  String ref = "brands";
  //Create Brand
  void createBrand(String name, String address, String phoneNumber, String image) {
    var id = new Uuid();
    String brandId = id.v1();
    _fireStore.collection(ref).document(brandId).setData({
      "brandID" : brandId,
      'brandName': name,
      "brandAddress" : address,
      "brandPhoneNumber" : phoneNumber,
      "brandImage" : image
    });
  }
  Future<List<DocumentSnapshot>> getBrands() =>
        _fireStore.collection(ref).getDocuments().then((snaps){
          return snaps.documents;
        });
  void updateBrand(String selectId, String name, String address, String phoneNumber, String image){
    try{
      _fireStore.collection(ref).document(selectId).updateData({
        "brandID": selectId,
        "brandName" : name,
        "brandAddress" : address,
        "brandPhoneNumber" : phoneNumber,
        "brandImage" : image
      });
    }catch(e){
      print(e.toString());
    }
  }

  void deleteBrand(String selectId){
    try{
      _fireStore.collection(ref).document(selectId).delete();
    }catch(e){
      print(e.toString());
    }
  }
}