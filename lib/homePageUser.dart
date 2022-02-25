import 'package:flutter/material.dart';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:find_my_bus/constants.dart';
import 'package:find_my_bus/welcomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_my_bus/QRCodeGenerator.dart';
import 'package:find_my_bus/BusList.dart';
import 'package:find_my_bus/bookHistory.dart';
import 'dart:io';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomePage extends StatefulWidget {
  static final String id = 'home_page';
  final String email;
  const HomePage({Key? key, required this.email}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
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

  String api_key = 'AIzaSyAjaN-Rfa7wRo4eW3lhUkTWy_O_WCQsnTY';
  void moveToBusList() async {
    final answer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Buses(
          text: name,
          url: downloadURL,
          map: _map.toString(),
          start: start,
          end: end,
          lat: lat,
          long: long,
          seatnumber: seatNumber,
          Busid: Busid,
          name: name,
          email: widget.email,
        ),
      ),
    );
    print(answer);
    if (answer != null) {
      // Polyline _poly = Polyline(
      //   polylineId: PolylineId('Route'),
      //   points: [
      //     LatLng(lat, long),
      //     answer,
      //   ],
      //   width: 5,
      // );
      // setState(() {
      //   poly.add(_poly);
      // });
      await _zoomPolyline(answer);
    }
  }

  _zoomPolyline(LatLng ans) async {
    double startLatitude = lat;
    double startLongitude = long;

    double destinationLatitude = ans.latitude;
    double destinationLongitude = ans.longitude;
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

    await _createPolylines(startLatitude, startLongitude, destinationLatitude,
        destinationLongitude);
  }

  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];

  _createPolylines(double startlat, double startlong, double destlat,
      double destlong) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      api_key,
      PointLatLng(startlat, startlong),
      PointLatLng(destlat, destlong),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 3,
    );
    setState(() {
      poly.add(polyline);
    });
  }

  int seatNumber = 0;
  String Busid = '';
  bool bookhistory = false;
  void checkbookhistory() async {
    FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.email)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          seatNumber = doc['seatnumber'];
          Busid = doc['busid'];
          bookhistory = true;
        });
      }
    });
  }

  bool mapToggle = false;
  String end = '';
  String start = '';
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
                      title: new Text('Photo Library '),
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  String name = '';
  String _map = '';

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

  void _getUserData() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .get()
        .then((doc) {
      _map =
          "${doc['name']},${doc['email']},${doc['phone']},${downloadURL},$bookhistory";
      name = doc['name'];
    });
  }

  late GoogleMapController mapController;
  void _getData() {
    FirebaseFirestore.instance
        .collection('buslocations')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        _addMarker(doc['BusNumber'], doc['lat'], doc['long']);
      });
    });
  }

  List<Marker> markers = [];
  List<Polyline> poly = [];
  void _addMarker(String user, double la, double lo) {
    var _marker = Marker(
        markerId: MarkerId(user),
        position: LatLng(la, lo),
        icon: user == widget.email
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: user, snippet: '$la,$lo'));
    setState(() {
      markers.add(_marker);
    });
  }

  void zoomInMarker(double lat, double long) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, long), zoom: 17.0, bearing: 90.0, tilt: 45.0)));
  }

  Location location = new Location();
  LocationData? _locationData;
  double lat = 0;
  double long = 0;
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
    _addMarker(
        widget.email, _locationData!.latitude!, _locationData!.longitude!);
    setState(() {
      lat = _locationData!.latitude!;
      long = _locationData!.longitude!;
      mapToggle = true;
    });
    FirebaseFirestore.instance
        .collection('userlocations')
        .doc(widget.email)
        .set({
      'email': widget.email,
      'lat': lat,
      'long': long,
    });
  }

  void onMapCreate(controller) {
    setState(() {
      mapController = controller;
    });
    zoomInMarker(lat, long);
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
    _getData();
    _getLoctaion();
    checkbookhistory();
    _getUserData();
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    location.onLocationChanged.listen((LocationData current) {
      _getLoctaion();
    });
    _getUserData();
    download();
    return Scaffold(
      appBar: AppBar(
        title: Text('Find My Bus'),
        backgroundColor: Colours.orangyish,
      ),
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: GoogleMap(
                onMapCreated: onMapCreate,
                initialCameraPosition:
                    CameraPosition(target: LatLng(0, 0), zoom: 15),
                markers: markers.toSet(),
                polylines: poly.toSet(),
                trafficEnabled: true,
              )),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TextField(
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Source",
                                hintText: "Goregaon",
                                prefixIcon: Icon(
                                  Icons.location_pin,
                                ),
                              ),
                              onChanged: (value) {
                                start = value;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, bottom: 40),
                            child: TextField(
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Destination",
                                hintText: "Thane",
                                prefixIcon: Icon(
                                  Icons.location_pin,
                                ),
                              ),
                              onChanged: (value) {
                                end = value;
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                if (start.length != 0 && end.length != 0) {
                                  moveToBusList();
                                } else {
                                  print('Fill Source and Destination');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                              ),
                              child: Text(
                                "Find Buses Near Me",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  wordSpacing: 1.5,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
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
                                downloadURL,
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
                            uid: _map.toString(),
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
                      builder: (context) => Booking(email: widget.email)),
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
                checkbookhistory();
                if (emergency) {
                  FirebaseFirestore.instance
                      .collection('callbacks')
                      .doc(Busid)
                      .set({
                    'seatnumber': seatNumber,
                    'name': name,
                  });
                  PassengerDialog();
                } else {
                  FirebaseFirestore.instance
                      .collection('callbacks')
                      .doc(Busid)
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
