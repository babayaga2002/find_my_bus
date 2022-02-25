import 'package:flutter/material.dart';
import 'package:find_my_bus/constants.dart';
import 'package:find_my_bus/signupUser.dart';
import 'package:find_my_bus/forgotPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:find_my_bus/homePageUser.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) :  super(key: key);
  static String id = 'login_screen';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  String email = '';
  String pass = '';
  Future<File> urlToFile(String imageUrl) async {
    Uri myUri = Uri.parse(imageUrl);
    var rng = new Random()  ;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path ;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(myUri);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  UserCredential? userCredential;
  Widget build(BuildContext context)
  {
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
                height: MediaQuery.of(context).size.height * 0.32,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 40.0,
                  ),
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                        'images/city-bus-map-application-mobile-phone-flat-cartoon-vector-illustration-puplic-transport-route-around-town-urban-150468065.jpg',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only  (
                  top: 50.0,
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
                padding: const EdgeInsets.onl y(
                  top: 31.0,
                  left: 14.0,
                  right: 13.0,
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
                  onChanged: (value) 
                  
                  {
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
                  child:
                  Text(
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
                padding: const EdgeInsetsDirectional.only(top: 40.0),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  email: email,
                                )),
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
                height: 130.0,
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
