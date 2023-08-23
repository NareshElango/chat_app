import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroommodel.dart';
import 'package:chat_app/models/messagemodel.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chatroompage extends StatefulWidget {
  final usermodel targetuser;
  final chatroommodel chatroom;
  final usermodel userModel;
  final User firebaseuser;
  const chatroompage(
      {Key? key,
      required this.targetuser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseuser})
      : super(key: key);

  @override
  State<chatroompage> createState() => _chatroompageState();
}

class _chatroompageState extends State<chatroompage> {
  TextEditingController msgcon = TextEditingController();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   msgcon = TextEditingController();
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   msgcon.dispose();
  // }

  void sendmsg() async {
    String msg = msgcon.text.trim();
    msgcon.clear();
    if (msg != "") {
      messagemodel newmessage = messagemodel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newmessage.messageid)
          .set(newmessage.toMap());

      widget.chatroom.lastmessage = msg;
      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => homepage(UserModel: widget.userModel , firebaseuser: widget.firebaseuser,)));
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.targetuser.profilepic.toString()),
              backgroundColor: Colors.grey[500],
            ),
            SizedBox(
              width: 20,
            ),
            Text(widget.targetuser.fullname.toString())
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chatroom")
                          .doc(widget.chatroom.chatroomid)
                          .collection("messages")
                          .orderBy("createdon", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot datasnapshot =
                                snapshot.data as QuerySnapshot;

                            return ListView.builder(
                              reverse: true,
                              itemCount: datasnapshot.docs.length,
                              itemBuilder: ((context, index) {
                                messagemodel currentmsg = messagemodel.fromMap(
                                    datasnapshot.docs[index].data()
                                        as Map<String, dynamic>);
                                return Row(
                                  mainAxisAlignment: (currentmsg.sender ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: (currentmsg.sender ==
                                                  widget.userModel.uid)
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        currentmsg.text.toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                            ;
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'An error has occured, check your internet connection'),
                            );
                          } else {
                            return Center(
                              child: Text("Say Hi to your friend!"),
                            );
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                )),
                Container(
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                        controller: msgcon,
                        maxLines: null,
                        decoration: InputDecoration(
                            hintText: 'Enter message',
                            border: InputBorder.none),
                      )),
                      IconButton(
                        onPressed: () {
                          sendmsg();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
