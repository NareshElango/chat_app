import 'dart:io';
import 'dart:math';

import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class completeprofile extends StatefulWidget {
  final usermodel UserModel;
  final User firebaseuser;
  const completeprofile(
      {Key? key, required this.UserModel, required this.firebaseuser})
      : super(key: key);

  @override
  State<completeprofile> createState() => _completeprofileState();
}

class _completeprofileState extends State<completeprofile> {
  File? imagefile = null;
  TextEditingController name = TextEditingController();
  void selectimg(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropimg(pickedFile);
    }
  }

  // void cropimg(XFile file) async {
  //   File? croppedimage = (await ImageCropper().cropImage(
  //       sourcePath: file.path,
  //       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //       compressQuality: 20)) as File?;
  //   if (croppedimage != null) {
  //     setState(() {
  //       imagefile = File(croppedimage.path);
  //     });
  //   }
  // }

  void cropimg(XFile file) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedFile != null) {
      setState(() {
        imagefile = File(croppedFile.path);
      });
    }
  }

  void showphoto() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Upload the profile pic'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Select from Gallery'),
                  leading: const Icon(Icons.photo),
                  onTap: () {
                    Navigator.pop(context);
                    selectimg(ImageSource.gallery);
                  },
                ),
                ListTile(
                  title: const Text('Take a photo'),
                  leading: const Icon(Icons.camera_alt),
                  onTap: () {
                    Navigator.pop(context);
                    selectimg(ImageSource.camera);
                  },
                )
              ],
            ),
          );
        });
  }

  void checkvalues() {
    String fullname = name.text.trim();
    if (fullname == "" || imagefile == null) {
      print('Fill the fields');
      uihelper.showalertdialog(context, "Incomplete data", "Fill the fields");
    } else {
      //log("Data uploaded......" as num);
      upload();
    }
  }

  void upload() async {
    uihelper.showloadingdialog(context, "Uploading image...");
    UploadTask uploadtask = FirebaseStorage.instance
        .ref("profilepic")
        .child(widget.UserModel!.uid.toString())
        .putFile(imagefile!);

    TaskSnapshot snapshot = await uploadtask;
    String? imageurl = await snapshot.ref.getDownloadURL();
    String? fullname = name.text.trim();

    widget.UserModel.fullname = fullname;
    widget.UserModel.profilepic = imageurl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.UserModel.uid)
        .set(widget.UserModel.toMap())
        .then((value) {
      //log("Data uploaded" as num);
      print('successfully uploaded');
      print('before');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return homepage(
            UserModel: widget.UserModel, firebaseuser: widget.firebaseuser);
      }));
      print("After");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            CupertinoButton(
              onPressed: () {
                showphoto();
              },
              padding: const EdgeInsets.all(0),
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    (imagefile != null) ? FileImage(imagefile!) : null,
                child: (imagefile == null)
                    ? Icon(
                        Icons.person,
                        size: 50,
                      )
                    : null,
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: name,
              decoration: InputDecoration(
                hintText: 'Enter the FullName',
              ),
            ),
            //  const SizedBox(height: 20,),
            // const TextField(
            //   decoration: InputDecoration(
            //     hintText: 'Enter the Email',
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
              child: const Text('Submit'),
              onPressed: () {
                checkvalues();
              },
              color: Theme.of(context).colorScheme.secondary,
            )
          ],
        ),
      )),
    );
  }
}
