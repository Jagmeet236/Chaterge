import 'package:cached_network_image/cached_network_image.dart';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/utils/date_util.dart';
import 'package:chat_app/view/Chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


import '../Authentication/APIs.dart';
import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final Chatuser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if nul => no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: FirebaseServices.getLastMessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                leading: Container(
                  width: size.width * 0.14,
                  height: size.height * 0.07,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.height * .5),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.user.imageurl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              child: Icon(CupertinoIcons.person),
                            )),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  _message != null ?
                      _message!.type==Type.image?'Image':
                  _message!.msg : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != FirebaseServices.user.uid
                        ? Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
              );
            },
          )),
    );
  }
}
