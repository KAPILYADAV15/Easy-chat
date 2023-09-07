import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_chat/api/apis.dart';
import 'package:easy_chat/main.dart';
import 'package:easy_chat/models/chat_user.dart';
import 'package:easy_chat/screens/auth/loginScreen.dart';
import 'package:easy_chat/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Profile Screen"),
            automaticallyImplyLeading: true,
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Are you trying to logout ?"),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                // to pop up the dialog box
                                Navigator.pop(context);

                                Dialogs.showProgressIndicator(context);

                                await Apis.updateActiveStatus(false);

                                await Apis.auth.signOut().then((value) async {
                                  await GoogleSignIn().signOut().then((value) {
                                    // to hide progress indicator
                                    Navigator.pop(context);

                                    // to pop up home screen
                                    Navigator.pop(context);

                                    Apis.auth = FirebaseAuth.instance;

                                    // go to Login screen
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
                                  });
                                });
                              },
                              child: Text(
                                "Yes Logout",
                                style: TextStyle(fontSize: 17),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel",
                                  style: TextStyle(fontSize: 17)))
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Logout'),
              backgroundColor: Colors.redAccent,
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * .05),
              child: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                      width: screenSize.width,
                      height: screenSize.height * 0.03),
                  Stack(
                    children: [
                      _image != null
                          ?
                          // local image
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(screenSize.height * .1),
                              child: Image.file(
                                File(_image!),
                                fit: BoxFit.cover,
                                width: screenSize.height * .2,
                                height: screenSize.height * .2,
                              ),
                            )

                          // image from server
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(screenSize.height * .1),
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                width: screenSize.height * .2,
                                height: screenSize.height * .2,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                          bottom: 0,
                          right: -10,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: CircleBorder(),
                            color: Colors.white,
                            child: Icon(Icons.edit, color: Colors.blue),
                          ))
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16)),
                  SizedBox(height: screenSize.height * 0.05),
                  TextFormField(
                    onSaved: (value) => Apis.myself.name = value ?? " ",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Required field",
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'e.g. KAPIL YADAV',
                        label: Text('Name')),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  TextFormField(
                    onSaved: (value) => Apis.myself.about = value ?? " ",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Required field",
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'e.g. Feeling Happy',
                        label: Text('About')),
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Apis.updateUser().then((value) => {
                              Dialogs.showSnackbar(
                                  context,
                                  "Profile is successfully updated",
                                  Colors.green)
                            });
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 28,
                    ),
                    label: Text(
                      'Update',
                      style: TextStyle(fontSize: 19),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(
                            screenSize.width * .5, screenSize.height * .06)),
                  )
                ]),
              ),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: screenSize.height * 0.03, bottom: screenSize.height * 0.1),
            children: [
              Text(
                "Pick profile picture",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(screenSize.width * 0.3,
                              screenSize.height * 0.15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("assets/images/gallery.png")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(screenSize.width * 0.3,
                              screenSize.height * 0.15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("assets/images/camera.png"))
                ],
              )
            ],
          );
        });
  }
}
