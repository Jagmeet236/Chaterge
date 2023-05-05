class Chatuser {
  Chatuser({
    required this.uid,
    required this.name,
    required this.email,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.imageurl,
    required this.isOnline,
    required this.pushToken,

  });

  late  String uid;
  late  String name;
  late  String email;
  late String about;
  late  String createdAt;
  late  String lastActive;
  late  String imageurl;

  late final bool isOnline;
  late final String pushToken;



  Chatuser.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] ?? "";
    name = json['name'] ?? "";
    email = json['email'] ?? "";
    about =json['about']??"";
    createdAt = json['createdAt'] ?? "";
    lastActive = json['lastActive'] ?? "";
    imageurl = json['imageurl'] ?? "";

    isOnline = json['isOnline'] ?? "";
    pushToken = json['pushToken'] ?? "";


  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['uid'] = uid;
    data['name'] = name;
    data['email'] = email;
    data['about']= about;
    data['createdAt'] = createdAt;
    data['lastActive'] = lastActive;
    data['imageurl'] = imageurl;
    data['isOnline'] = isOnline;
    data['pushToken'] = pushToken;


    return data;
  }
}
