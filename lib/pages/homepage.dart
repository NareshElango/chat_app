import 'package:chat_app/models/chatroommodel.dart';
import 'package:chat_app/models/firebasehelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/chatroompage.dart';
import 'package:chat_app/pages/loginpage.dart';
import 'package:chat_app/pages/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  final usermodel UserModel;
  final User firebaseuser;

  const homepage(
      {super.key, required this.UserModel, required this.firebaseuser});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chat App'),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return loginpage();
                }));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatroom")
                .where("users", arrayContains: widget.UserModel.uid)
                .orderBy("createdon")
                // .where("participants.${widget.UserModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatroomsnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatroomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      chatroommodel chatroomModel = chatroommodel.fromMap(
                          chatroomsnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatroomModel.participants!;

                      List<String> participantkeys = participants.keys.toList();

                      participantkeys.remove(widget.UserModel.uid);

                      return FutureBuilder(
                          future: firebasehelper
                              .getusermodelbyid(participantkeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                usermodel targetuser =
                                    userData.data as usermodel;

                                return ListTile(
                                  onTap: () {
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                      return chatroompage(
                                          targetuser: targetuser,
                                          chatroom: chatroomModel,
                                          userModel: widget.UserModel,
                                          firebaseuser: widget.firebaseuser);
                                    }));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetuser.profilepic.toString()),
                                  ),
                                  title: Text(targetuser.fullname.toString()),
                                  subtitle: (chatroomModel.lastmessage
                                              .toString() !=
                                          "")
                                      ? Text(
                                          chatroomModel.lastmessage.toString())
                                      : Text(
                                          "Say hi to your new friend",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                );
                                Divider();
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text('No chat'),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return searchpage(
                userModel: widget.UserModel, firebaseuser: widget.firebaseuser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
