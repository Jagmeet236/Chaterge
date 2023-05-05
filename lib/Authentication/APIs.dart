import 'dart:developer';

import 'dart:io' as io;
import 'dart:io';

import 'package:chat_app/Authentication/LogIn_screen.dart';
import 'package:chat_app/animation/page_transition_screen.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage storage = FirebaseStorage.instance;
//for users to logout from their accounts
Future logOut(BuildContext context) async {
  try {
    await GoogleSignIn().signOut().then((value) {
      Navigator.pushAndRemoveUntil(
        context,
        SlideTopRoute(builder: (context) => const loginscreen()),
        (Route<dynamic> route) => false,
      );
    });
    await auth.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
        context,
        SlideTopRoute(builder: (context) => const loginscreen()),
        (Route<dynamic> route) => false,
      );
    });
  } catch (e) {
    print("error");
  }
}

class FirebaseServices {
  static User get user => auth.currentUser!;
  static late Chatuser me;

//for getting the user's id

  Future<DocumentSnapshot> getuserId(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("users").doc(user.uid).get();
    return doc;
  }

//checking if the user exists
  static Future<bool> userExists() async {
    return (await _firestore.collection('users').doc(user.uid).get()).exists;
  }

//checking for the current user if exists or create one
  static Future<void> getCurrentUser() async {
    await _firestore.collection('users').doc(user.uid).get().then((user) {
      if (user.exists) {
        me = Chatuser.fromJson(user.data()!);
        log('My Data:${user.data()}');
      } else {
        createUser().then((value) => getCurrentUser());
      }
    });
  }

//for creating the user using the models

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatuser = Chatuser(
        uid: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using Chaterge!",
        imageurl: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await _firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

//for getting all the users that are stored in firebase collection
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .snapshots();
  }

//getting the users information updated
  static Future<void> UpdateUserInfo() async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

//for uploading the profile picture
  static Future<void> updateProfilePicture(io.File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension:$ext');
    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'images/$ext')).then(
        (p0) => {log('Data Transferred: ${p0.bytesTransferred / 1000} kb')});
    //for updating the profile picture
    me.imageurl = await ref.getDownloadURL();
    await _firestore.collection('users').doc(user.uid).update({
      'imageurl': me.imageurl,
    });
  }

  ///**********Chat Related APIs*********************

  ///chats(collection) --> collection_id(doc) --> message(collection) --> message(doc)

  //for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      Chatuser user) {
    return _firestore
        .collection('chats/${getConversationID(user.uid)}/messages/')
    .orderBy('sent',descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(Chatuser chatUser, String msg, Type type) async {
    //message sending time used as id
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    //sending the message
    final Message message = Message(
        msg: msg,
        toId: chatUser.uid,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = _firestore
        .collection('chats/${getConversationID(chatUser.uid)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    _firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  //getting only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      Chatuser user) {
    return _firestore
        .collection('chats/${getConversationID(user.uid)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
  static Future<void> sendChatImage(Chatuser chatuser, File file)
  async {
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child('images/${getConversationID(chatuser.uid)}/${DateTime.now().microsecondsSinceEpoch}.$ext');
    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'images/$ext')).then(
            (p0) => {log('Data Transferred: ${p0.bytesTransferred / 1000} kb')});
    //for updating the profile picture
   final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageUrl, Type.image);

  }
}

Future<void> refreshData() async {
  // Here you can implement the logic for refreshing data, such as calling an API

  // Wait for some time to simulate the data fetching process
  await Future.delayed(Duration(seconds: 2));

  // After fetching data, you can update the UI accordingly
}
