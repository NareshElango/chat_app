class chatroommodel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastmessage;
  List<dynamic>? users;
  DateTime? createdon;
  chatroommodel(
      {this.chatroomid, this.participants, this.lastmessage, this.users,this.createdon});

  chatroommodel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastmessage = map["lastmessage"];
    users = map["users"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastmessage,
      "users": users,
      "createdon":createdon
    };
  }
}
