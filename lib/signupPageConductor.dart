import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_my_bus/loginPageConductor.dart';
import 'package:flutter/material.dart';
import 'package:find_my_bus/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignupPageConductor extends StatefulWidget {
  const SignupPageConductor({Key? key}) : super(key: key);
  static String id = 'signup_screen_conductor';

  @override
  _SignupPageConductorState createState() => _SignupPageConductorState();
}

class _SignupPageConductorState extends State<SignupPageConductor> {
  @override
  XFile? _image;
  _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  final ImagePicker _picker = ImagePicker();
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool usernameExists = false;
  String name = '';
  String email = '';
  String pass = '';
  String phonenumber = '';
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF3383CD),
                  Color(0xFF11249F),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 80.0,
              ),
              GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 90,
                  backgroundColor:
                      _image != null ? Colors.transparent : Colours.orangyish,
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(90),
                          child: Image.file(
                            File(_image!.path),
                            fit: BoxFit.fill,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(60)),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Name",
                      hintText: "Sidharth Malhotra",
                      prefixIcon: Icon(
                        Icons.account_circle,
                      ),
                    ),
                    onChanged: (value) {
                      name = value;
                      print(name);
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Phone Number",
                      hintText: "+91 9876543210",
                      prefixIcon: Icon(
                        Icons.phone,
                      ),
                    ),
                    onChanged: (value) {
                      phonenumber = value;
                      print(phonenumber);
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email address",
                      hintText: "mtechviral@gmail.com",
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                    ),
                    onChanged: (value) {
                      email = value;
                      print(email);
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    obscureText: true,
                    obscuringCharacter: "*",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Password",
                      hintText: "Password",
                      prefixIcon: Icon(
                        Icons.lock,
                      ),
                    ),
                    minLines: 1,
                    onChanged: (value) {
                      pass = value;
                      print(pass);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 80.0,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 20.0),
                child: FlatButton(
                  onPressed: () async {
                    try {
                      UserCredential? userCredential =
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                        email: email,
                        password: pass,
                      )
                              .then((value) {
                        FirebaseFirestore.instance
                            .collection('busconductors')
                            .doc(email)
                            .set({
                          'name': name,
                          'email': email,
                          'phone': phonenumber,
                        }).then((value) {
                          if (_image != null) {
                            try {
                              FirebaseStorage.instance
                                  .ref('$email/profile.png')
                                  .putFile(File(_image!.path));
                            } on FirebaseException catch (err) {
                              print(err);
                            }
                          } else {
                            try {
                              FirebaseStorage.instance
                                  .ref('$email/profile.png')
                                  .putFile(File('images/images-2.jpg'));
                            } on FirebaseException catch (err) {
                              print(err);
                            }
                          }
                          Navigator.pushNamed(context, LoginPageConductor.id);
                        });
                      });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  color: Colours.orangyish,
                  padding: EdgeInsetsDirectional.all(2.0),
                  minWidth: 120.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
