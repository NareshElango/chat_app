import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroommodel.dart';
import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/chatroompage.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class searchpage extends StatefulWidget {
  final usermodel userModel;
  final User firebaseuser;

  const searchpage(
      {Key? key, required this.userModel, required this.firebaseuser})
      : super(key: key);

  @override
  State<searchpage> createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  TextEditingController search = TextEditingController();

  Future<chatroommodel?> getchatroommodel(usermodel targetuser) async {
    chatroommodel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatroom")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetuser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docdata = snapshot.docs[0].data();
      chatroommodel existingchatroom =
          chatroommodel.fromMap(docdata as Map<String, dynamic>);

      chatroom = existingchatroom;
    } else {
      chatroommodel newchatroom = chatroommodel(
          chatroomid: uuid.v1(),
          lastmessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetuser.uid.toString(): true
          },
          users: [widget.userModel.uid.toString(),
          targetuser.uid.toString()],

          createdon: DateTime.now(),
          );

      await FirebaseFirestore.instance
          .collection("chatroom")
          .doc(newchatroom.chatroomid)
          .set(newchatroom.toMap());

      chatroom = newchatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Search'),
        leading: BackButton(
          onPressed: () {
            // uihelper.showloadingdialog(context, "Loading...");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => homepage(UserModel: widget.userModel , firebaseuser: widget.firebaseuser,)));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: search,
                decoration: InputDecoration(
                    hintText: 'Enter the Account',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                  child: Text('Search'),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    setState(() {});
                  }),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: search.text)
                      .where("email", isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot datasnapshot =
                            snapshot.data as QuerySnapshot;
                        if (datasnapshot.docs.length > 0) {
                          Map<String, dynamic> usermap = datasnapshot.docs[0]
                              .data() as Map<String, dynamic>;
                          usermodel searchuser = usermodel.fromMap(usermap);

                          return ListTile(
                            onTap: () async {
                              chatroommodel? chatroomModel =
                                  await getchatroommodel(searchuser);

                              if (chatroomModel != null) {
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return chatroompage(
                                    targetuser: searchuser,
                                    firebaseuser: widget.firebaseuser,
                                    userModel: widget.userModel,
                                    chatroom: chatroomModel,
                                  );
                                }));
                              }
                              //
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(searchuser.profilepic!),
                              backgroundColor: Colors.grey[500],
                            ),
                            title: Text(searchuser.fullname!),
                            subtitle: Text(searchuser.email!),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return Text('No results found');
                        }
                      } else if (snapshot.hasError) {
                        return Text('An error has been occured');
                      } else {
                        return Text('No results found');
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        )),
      ),
    );
  }
}
