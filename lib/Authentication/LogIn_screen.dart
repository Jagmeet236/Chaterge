import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_app/Authentication/APIs.dart';

import 'package:chat_app/utils/dialog.dart';
import 'package:chat_app/view/Home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../animation/animation_screen.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({Key? key}) : super(key: key);

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : ListView(physics: const BouncingScrollPhysics(), children: [
              Column(
                children: [
                  Row(children: [
                    SizedBox(height: size.height*0.1,width: size.width*0.04,),
                    FadeInText(
                      text: "Welcome to Chaterge... ",
                      duration: Duration(seconds: 2), textStyle:GoogleFonts.abel(fontSize: 30,color: Colors.black,letterSpacing: 1),

                    ),
                  ]),
                  SizedBox(
                    height: size.height * .1,
                  ),
                  Center(
                      child: ImageSlideAnimation(
                    assetName: 'images/chat.png',
                    height: size.height / 2.8,
                  )),
                  SizedBox(
                    height: size.height * 0.15,
                  ),
                  Center(
                    child: Center(
                      child: FloatingActionButton.extended(
                          elevation: 1,
                          onPressed: () {
                            Dialogs.showProgressBar(context);
                            loginWithGoogle(context).then(
                              (value) => Navigator.pop(context),
                            );
                          },
                          backgroundColor: Colors.white,

                          // icon: Icon(Icons.add),
                          label: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Image(
                                      height: 20,
                                      image: AssetImage('images/google.png'),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, top: 12),
                                  child: Text(
                                    'Sign in with Google',
                                    style: GoogleFonts.abel(
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                  ),
                                )
                              ])),
                    ),
                  ),
                ],
              ),
            ]),
    );
  }
}

Future loginWithGoogle(context) async {
  FirebaseServices services = FirebaseServices();

  final googleSignIn = GoogleSignIn(scopes: ['email']);
  try {
    await InternetAddress.lookup('google.com');
    final googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      return false;
    }
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) =>
        {
          if (value != null)
            {
              services.getuserId(value.user!.uid).then((snapshot) async => {
                    if (snapshot.exists)
                      {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false),
                      }
                    else
                      {
                        await FirebaseServices.createUser().then((value) => {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()),
                                  (route) => false),
                            })
                      }
                  })
            }
        });
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        Dialogs.showSnackBar(context, 'Account Already exist');
        break;
      case 'invalid-credential':
        Dialogs.showSnackBar(context, 'Unknown error has occurred');
        break;
      case 'Internet Connection':
        Dialogs.showSnackBar(context,
            "Something went wrong please check your internet connection");
        break;
      case 'user-disabled':
        Dialogs.showSnackBar(
            context, 'The user you tried to log into is disabled');
        break;
      case 'user-not-found':
        Dialogs.showSnackBar(
            context, 'The user you tried to log into is not found');
        break;
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Log in with google failed'),
              content: Text(
                'Log in with google failed',
                style: GoogleFonts.acme(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  // fontStyle: FontStyle.italic,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'))
              ],
            ));
  }
}
