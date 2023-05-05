import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/APIs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final Chatuser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];
  final _textController = TextEditingController();

  //for storing value of showing and hiding emoji
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown and back button is pressed then hide emojis
          //or else simply close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: FirebaseServices.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();
                          //  if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;

                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return Padding(
                                padding:
                                    EdgeInsets.only(top: size.height * 0.01),
                                child: ListView.builder(
                                    reverse: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _list.length,
                                    itemBuilder: (context, index) {
                                      return MessageCard(
                                        message: _list[index],
                                      );
                                    }),
                              );
                            } else {
                              return Center(
                                child: Text(
                                  "Say Hii! 👋",
                                  style: GoogleFonts.acme(
                                    fontSize: 30,
                                  ),
                                ),
                              );
                            }
                        }
                      }),
                ),
                //progress indicator that shows something is uploading
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),
                _chatInput(),
                //show emojis on keyboard emoji button click and vice versa
                if (_showEmoji)
                  SizedBox(
                    height: size.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.black54,
            )),
        Container(
          width: size.width * 0.14,
          height: size.height * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size.height * .5),
            child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.user.imageurl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    )),
          ),
        ),
        SizedBox(
          width: size.width * 0.03,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: GoogleFonts.acme(
                  fontSize: 16,
                  letterSpacing: 1,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              "Last Seen not available",
              style: GoogleFonts.acme(
                  fontSize: 16,
                  letterSpacing: 1,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chatInput() {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: size.height * .01, horizontal: size.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.greenAccent,
                      size: 25,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        hintText: "Type Something...",
                        hintStyle: GoogleFonts.abel(
                            color: Colors.greenAccent, fontSize: 18),
                        border: InputBorder.none),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      //uploading & sending the image oe by one
                      for (var i in images) {
                        log('image path ${i.path}');
                        setState(() {
                          _isUploading = true;
                        });
                        FirebaseServices.sendChatImage(
                            widget.user, File(i.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.greenAccent,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('image path ${image.path}');
                        setState(() {
                          _isUploading = true;
                        });

                        FirebaseServices.sendChatImage(
                            widget.user, File(image.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.greenAccent,
                      size: 26,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                FirebaseServices.sendMessage(
                    widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            shape: const CircleBorder(),
            color: Colors.greenAccent,
            child: const Padding(
              padding:
                  EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 5),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
