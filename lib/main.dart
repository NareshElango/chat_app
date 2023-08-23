import 'package:chat_app/models/firebasehelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/loginpage.dart';
import 'package:chat_app/pages/signuppage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentuser = FirebaseAuth.instance.currentUser;
  if (currentuser != null) {
    usermodel? thisusermodel =
        await firebasehelper.getusermodelbyid(currentuser.uid);
    if (thisusermodel != null) {
      runApp(
          MyApploggedin(userModel: thisusermodel, firebaseUser: currentuser));
    } else {
      runApp(MyApp());
    }
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginpage(),
    );
  }
}

class MyApploggedin extends StatelessWidget {
  final usermodel userModel;
  final User firebaseUser;

  const MyApploggedin({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homepage(UserModel: userModel, firebaseuser: firebaseUser),
      // home: signuppage(),
    );
  }
}
