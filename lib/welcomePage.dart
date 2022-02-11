import 'package:find_my_bus/loginPageConductor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:find_my_bus/loginPageUser.dart';
import 'package:find_my_bus/constants.dart';

class WelcomePage extends StatelessWidget {
  static String id = 'welcome_screen';
  @override
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
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 100.0,
                      bottom: 16.0,
                    ),
                    child: Carousel(
                      images: [
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'images/city-bus-map-application-mobile-phone-flat-cartoon-vector-illustration-puplic-transport-route-around-town-urban-150468065.jpg',
                          ),
                        ),
                        Image.asset(
                          'images/concept-bus-route-map-d-rendering-207755719.jpg',
                        ),
                        Image.asset(
                          'images/events-1.png',
                        ),
                      ],
                      autoplay: true,
                      animationDuration: Duration(milliseconds: 1000),
                      dotSize: 6.0,
                      dotSpacing: 15.0,
                      dotIncreasedColor: Colours.orangyish,
                      dotColor: Colours.orangyish,
                      borderRadius: false,
                      dotBgColor: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Find My Bus : Daily Travellers',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 4),
                  child: Text(
                    'Bus Solutions At Your Doorstep',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                Text(
                  'New! Lighter and Faster',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Login As',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colours.orangyish),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginPage.id);
                        },
                        child: Text(
                          'Passenger',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11249F),
                          ),
                        ),
                        color: Colours.orangyish,
                        padding: EdgeInsetsDirectional.all(2.0),
                        minWidth: 120.0,
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginPageConductor.id);
                        },
                        child: Text(
                          'Conductor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11249F),
                          ),
                        ),
                        color: Colours.orangyish,
                        padding: EdgeInsetsDirectional.all(2.0),
                        minWidth: 120.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
