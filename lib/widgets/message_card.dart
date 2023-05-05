import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/APIs.dart';
import 'package:chat_app/utils/date_util.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return FirebaseServices.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  //sender or another user messages
  Widget _blueMessage() {
    //update the last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      FirebaseServices.updateMessageReadStatus(widget.message);
      log('message read updated');
    }

    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type== Type.image? size.width*.03 :size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: size.width * .04, vertical: size.height * .01),
            decoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.black87),
                  )
                : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                height: size.height*0.3,
                width:size.width*0.5 ,
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,

                placeholder: (context, url) =>
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2,)),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.image,
                  size: 70,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: size.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  //user messages
  Widget _greenMessage() {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: size.width * .04,
              ),
              if (widget.message.read.isNotEmpty)
                const Icon(
                  Icons.done_all_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              const SizedBox(
                width: 2,
              ),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(widget.message.type== Type.image? size.width*.03 : size.width * .04),
              decoration: BoxDecoration(
                  color: Colors.greenAccent.shade100,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30)),
                  border: Border.all(color: Colors.green)),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style: const TextStyle(color: Colors.black87),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: size.height*0.3,
                        width:size.width*0.5 ,
                        imageUrl: widget.message.msg,

                        placeholder: (context, url) =>
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2,)),
                            ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
