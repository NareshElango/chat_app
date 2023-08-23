import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();

  void checkvalues() {
    String email = _email.text.trim();
    String password = _pass.text.trim();
    if (email == "" || password == "") {
      uihelper.showalertdialog(
        context,
        "Complete the fields",
        "fill all the fields",
      );
      print('fill the fields');
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credentials;
    uihelper.showloadingdialog(context, "Logging in...");
    try {
      credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      uihelper.showalertdialog(
          context, "An error occured", e.message.toString());
      print(e.code.toString());
    }
    if (credentials != null) {
      String uid = credentials.user!.uid;
      DocumentSnapshot userdata =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      usermodel user =
          usermodel.fromMap(userdata.data() as Map<String, dynamic>);
      print('Logged in successfully');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return homepage(UserModel: user, firebaseuser: credentials!.user!);
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
                CupertinoButton(
                  child: Text(
                    'Login',
                  ),
                  onPressed: () {
                    checkvalues();
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
              "Don't have an account ?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
              child: const Text(
                "Signup",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const signuppage()));
              },
            )
          ],
        ),
      ),
    );
  }
}
