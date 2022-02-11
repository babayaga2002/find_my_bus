import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:find_my_bus/my_header.dart';
import 'constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:find_my_bus/welcomePage.dart';
import 'package:find_my_bus/QRCodeGenerator.dart';
import 'dart:math';
import 'package:find_my_bus/bookHistory.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Buses extends StatefulWidget {
  final String Busid;
  final String name;
  final int seatnumber;
  final String text;
  final String url;
  final String map;
  final String start;
  final String end;
  final double lat;
  final double long;
  final String email;
  const Buses(
      {Key? key,
      required this.text,
      required this.url,
      required this.map,
      required this.start,
      required this.end,
      required this.lat,
      required this.long,
      required this.Busid,
      required this.name,
      required this.seatnumber,
      required this.email})
      : super(key: key);

  @override
  _BusesState createState() => _BusesState();
}

class _BusesState extends State<Buses> {
  final controller = ScrollController();
  double offset = 0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  final ImagePicker _picker = ImagePicker();

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

  String downloadURL = '';
  void download() {
    FirebaseStorage.instance
        .ref('${user!.email}/profile.png')
        .getDownloadURL()
        .then((value) {
      setState(() {
        downloadURL = value;
      });
    });
  }

  int calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).round();
  }

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

  int passengers(String busid) {
    FirebaseFirestore.instance
        .collection('passengers')
        .doc(busid)
        .get()
        .then((doc) {
      if (doc.exists) {
        return doc['number'];
      }
    });
    return 0;
  }

  bool emergency = false;
  Future<void> PassengerDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Call Made'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    download();
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    download();
    Stream<QuerySnapshot> ds =
        FirebaseFirestore.instance.collection('buslocations').snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF11249F),
      ),
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyHeader(
              image: "images/3855345.png",
              textTop: "Hello",
              textBottom: widget.text,
              offset: offset,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Buses",
                    style: kHeadingTextStyle,
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Container(
                        height: 250,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: ds,
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              List<QueryDocumentSnapshot<Object?>> groupdata =
                                  snapshot.data!.docs;
                              if (groupdata.length != 0) {
                                return ListView.builder(
                                    itemCount: groupdata.length,
                                    itemBuilder: (context, index) {
                                      int distance = calculateDistance(
                                          widget.lat,
                                          widget.long,
                                          groupdata[index]['lat'],
                                          groupdata[index]['long']);
                                      int pass =
                                          passengers(groupdata[index]['BusId']);
                                      if (distance >= 0 && distance < 100) {
                                        return PreventCard(
                                          title:
                                              '${groupdata[index]['BusNumber']}',
                                          text:
                                              ' From : ${widget.start} \n End : ${widget.end} \n Distance : ${distance} \n Expected Time :${(distance * 1.5).round()} mins \n Passengers: $pass',
                                          image:
                                              'images/bus${(index % 3) + 1}.jpg',
                                          latlng: LatLng(
                                              groupdata[index]['lat'],
                                              groupdata[index]['long']),
                                        );
                                      } else {
                                        return SizedBox();
                                      }
                                    });
                              } else {
                                return Center(
                                  child: Container(
                                    padding: EdgeInsets.all(40.0),
                                    child: Text("No Buses on this Route Found",
                                        textAlign: TextAlign.center),
                                  ),
                                );
                              }
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange[300],
              ),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                widget.url,
                              ))),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _showPicker(context);
                            if (_image != null) {
                              try {
                                FirebaseStorage.instance
                                    .ref('${widget.email}/profile.png')
                                    .putFile(File(_image!.path));
                              } on FirebaseException catch (err) {
                                print(err);
                              }
                            } else {
                              try {
                                FirebaseStorage.instance
                                    .ref('${widget.email}/profile.png')
                                    .putFile(File('images/images-2.jpg'));
                              } on FirebaseException catch (err) {
                                print(err);
                              }
                              download();
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 4,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code),
              title: const Text('QR Code'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Qr(
                            uid: widget.map,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.document_scanner),
              title: const Text('Book History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Booking(email: user!.email!)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.do_disturb_on),
              title: const Text('Emergency Call'),
              onTap: () {
                setState(() {
                  emergency = !emergency;
                });
                if (emergency) {
                  FirebaseFirestore.instance
                      .collection('callbacks')
                      .doc(widget.Busid)
                      .set({
                    'seatnumber': widget.seatnumber,
                    'name': widget.name,
                  });
                  PassengerDialog();
                } else {
                  FirebaseFirestore.instance
                      .collection('callbacks')
                      .doc(widget.Busid)
                      .delete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  final LatLng latlng;
  PreventCard(
      {Key? key,
      required this.image,
      required this.title,
      required this.text,
      required this.latlng})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, latlng);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: 126,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                height: 136,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 24,
                      color: kShadowColor,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                width: 180,
                child: Image.asset(image),
              ),
              Positioned(
                left: 180,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  height: 136,
                  width: MediaQuery.of(context).size.width - 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        title,
                        style: kTitleTextstyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
