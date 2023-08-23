import 'package:chat_app/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class firebasehelper {
  static Future<usermodel?> getusermodelbyid(String uid) async {
    usermodel? userModel;
    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docsnap.data() != null) {
      userModel = usermodel.fromMap(docsnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
