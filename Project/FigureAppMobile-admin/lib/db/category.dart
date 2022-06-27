import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CategoryServices{
  Firestore _fireStore = Firestore.instance;
  String ref = "Categories";

  void createCategory(String name, String image){
    var id = new Uuid();
    String categoryId = id.v1();
    _fireStore.collection(ref).document(categoryId).setData({
      "categoryID" : categoryId,
      "categoryName" : name,
      "categoryImage" : image
    });
  }
  Future<List<DocumentSnapshot>> getCategories() =>
      _fireStore.collection(ref).getDocuments().then((snaps) {
        return snaps.documents;
      });
  void updateCategory(String selectId, String name, String image ){
    try{
      _fireStore.collection(ref).document(selectId).updateData({
        "categoryID" : selectId,
        "categoryName" : name,
        "categoryImage" : image,
      });
    }catch(e){
      print(e.toString());
    }
  }

  void deleteCategory(String selectId){
    try{
      _fireStore.collection(ref).document(selectId).delete();
    }catch(e){
      print(e.toString());
    }
  }
}