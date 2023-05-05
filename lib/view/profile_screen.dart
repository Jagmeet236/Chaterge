import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/APIs.dart';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/utils/dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final Chatuser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        appBar: AppBar(
          title: Text(
            "Profile",
            style: GoogleFonts.abel(fontSize: 19, letterSpacing: 1),
          ),
          elevation: 0,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () {
                Dialogs.showProgressBar(context);
                logOut(context);
              },
              icon: const Icon(Icons.logout),
              label: Text(
                "Logout",
                style: GoogleFonts.abel(fontSize: 16),
              )),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.height * 0.1),
                              child: Image.file(
                                File(_image!),
                                width: size.width * 0.4,
                                height: size.height * 0.2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.height * 0.1),
                              child: CachedNetworkImage(
                                height: size.height * .2,
                                width: size.height * .2,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.imageurl,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showmodalsheet();
                          },
                          elevation: 5,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style: GoogleFonts.abel(fontSize: 16, letterSpacing: 1),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  TextFormField(
                    onSaved: (val) => FirebaseServices.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.person,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Text("Name")),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  TextFormField(
                    onSaved: (val) => FirebaseServices.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.info_circle,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Text("About")),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: const StadiumBorder(),
                      minimumSize: Size(size.width * .5, size.height * .06),
                    ),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        FirebaseServices.UpdateUserInfo().then((value) => {
                              Dialogs.showToast("Profile Updated Successfully")
                            });
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 28,
                      color: Colors.white,
                    ),
                    label: Text(
                      'UPDATE',
                      style: GoogleFonts.abel(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showmodalsheet() {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                top: size.height * 0.03, bottom: size.width * 0.05),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.abel(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(size.width * .3, size.height * .15),
                          shape: const CircleBorder(),
                        ),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
// Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,imageQuality: 80);
                          if (image != null) {
                            log('image path ${image.path}');
                            setState(() {
                              _image = image.path;
                            });
                            FirebaseServices.updateProfilePicture(File(_image!));

                            Navigator.pop(context);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('images/gallery.png'),
                        )),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(size.width * .3, size.height * .15),
                        shape: const CircleBorder(),
                      ),
                      onPressed: () async { final ImagePicker picker = ImagePicker();
// Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,imageQuality: 80);
                      if (image != null) {
                        log('image path ${image.path}');
                        setState(() {
                          _image = image.path;
                        });
                        FirebaseServices.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('images/camera.png'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}
