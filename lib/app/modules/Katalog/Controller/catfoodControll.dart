import 'package:cloud_firestore/cloud_firestore.dart';

class CatFoodController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch cat food data
  Stream<QuerySnapshot> getCatFoodByCategory(String category) {
    return _firestore
        .collection('cat_foods')
        .where('category', isEqualTo: category)
        .snapshots();
  }
}
