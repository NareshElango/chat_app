import 'package:cloud_firestore/cloud_firestore.dart';

class messagemodel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  messagemodel(
      {this.messageid, this.sender, this.text, this.seen, this.createdon});

  messagemodel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = (map["createdon"] as Timestamp).toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid":messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
