import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:chat_app/pages/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class signuppage extends StatefulWidget {
  const signuppage({super.key});

  @override
  State<signuppage> createState() => _signuppageState();
}

class _signuppageState extends State<signuppage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _conpass = TextEditingController();

  void checkvalues() {
    String email = _email.text.trim();
    String password = _pass.text.trim();
    String conpassword = _conpass.text.trim();

    if (email == " " || password == " " || conpassword == "") {
      uihelper.showalertdialog(
          context, "Incomplete fields", "fill all the fields");
      print('fill the fields');
    } else if (password != conpassword) {
      uihelper.showalertdialog(
          context, "Password mismatch", "the entered password do not match ");
      print('fill the fields');
      print('password does not match');
    } else {
      signup(email, password);
    }
  }

  void signup(String email, String password) async {
    UserCredential? credentials;

    uihelper.showloadingdialog(context, "Creating new account...");
    try {
      credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      uihelper.showalertdialog(
          context, "An error occured", e.message.toString());
      print(e.code.toString());
    }
    if (credentials != null) {
      String uid = credentials.user!.uid;
      usermodel newuser =
          usermodel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) => print('new user created'));
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return completeprofile(
            UserModel: newuser, firebaseuser: credentials!.user!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Chat App",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _pass,
                  decoration: const InputDecoration(
                      hintText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _conpass,
                  decoration: const InputDecoration(
                      hintText: 'Conform Password',
                      border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  child: const Text(
                    'SignUp',
                  ),
                  onPressed: () {
                    checkvalues();
                    // Navigator.pushReplacement(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => completeprofile()));
                  },
                  color: Theme.of(context).colorScheme.secondary,
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account ?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => loginpage()));
              },
            )
          ],
        ),
      ),
    );
  }
}
