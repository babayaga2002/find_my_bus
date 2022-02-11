import 'package:find_my_bus/homePageConductor.dart';
import 'package:flutter/material.dart';
import 'package:find_my_bus/constants.dart';
import 'package:find_my_bus/signupUser.dart';
import 'package:find_my_bus/forgotPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class LoginPageConductor extends StatefulWidget {
  const LoginPageConductor({Key? key}) : super(key: key);
  static String id = 'login_screen_conductor';
  @override
  _LoginPageConductorState createState() => _LoginPageConductorState();
}

class _LoginPageConductorState extends State<LoginPageConductor> {
  @override
  String email = '';
  String pass = '';
  String BusId = '';
  String BusNumber = '';
  Future<File> urlToFile(String imageUrl) async {
    Uri myUri = Uri.parse(imageUrl);
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(myUri);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  int num = 0;
  void checknumberofPassengers() {
    FirebaseFirestore.instance
        .collection('passengers')
        .doc(BusId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          num = doc['number'];
        });
      }
    });
  }

  Location location = new Location();
  LocationData? _locationData;
  Future<dynamic> _getLoctaion() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    location.enableBackgroundMode(enable: true);
  }

  UserCredential? userCredential;
  @override
  void initState() {
    super.initState();
    _getLoctaion();
  }

  void dispose() {
    super.dispose();
  }

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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Image.asset('images/bus2.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 15.0,
                  right: 15.0,
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
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
              Padding(
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
                  onChanged: (value) {
                    pass = value;
                    print(pass);
                  },
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ForgotPage.id);
                  },
                  child: Text(
                    'Forgot Password ?     ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                ),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Bus Id",
                    hintText: "PB05APGB",
                    prefixIcon: Icon(
                      Icons.directions_bus,
                    ),
                  ),
                  onChanged: (value) {
                    BusId = value;
                    print(BusId);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 15.0,
                  right: 15.0,
                ),
                child: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Bus Number",
                    hintText: "PB05N7024",
                    prefixIcon: Icon(
                      Icons.map_outlined,
                    ),
                  ),
                  onChanged: (value) {
                    BusNumber = value;
                    print(BusNumber);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 15.0),
                child: FlatButton(
                  onPressed: () async {
                    try {
                      userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: pass);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      }
                    }
                    if (userCredential != null) {
                      FirebaseFirestore.instance
                          .collection('buslocations')
                          .doc(BusId)
                          .set({
                        'BusId': BusId,
                        'BusNumber': BusNumber,
                        'lat': _locationData!.latitude!,
                        'long': _locationData!.longitude!,
                      });
                      checknumberofPassengers();
                      FirebaseFirestore.instance
                          .collection('passengers')
                          .doc(BusId)
                          .set({
                        'busnumber': BusNumber,
                        'busid': BusId,
                        'number': num,
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePageConductor(
                              BusId: BusId, BusNumber: BusNumber, email: email),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Log In',
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
              SizedBox(
                height: 80.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Do you have an account?',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignupPage.id);
                    },
                    child: Text(
                      'Sign Up Here!',
                      style: TextStyle(
                        color: Colours.orangyish,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colours.purplish),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
