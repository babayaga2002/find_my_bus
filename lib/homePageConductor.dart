import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:find_my_bus/constants.dart';
import 'package:find_my_bus/welcomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:find_my_bus/TicketGenerator.dart';
import 'dart:math';
import 'dart:io';

class HomePageConductor extends StatefulWidget {
  static final String id = 'home_page_consuctor';
  final String BusId;
  final String BusNumber;
  final String email;
  HomePageConductor(
      {Key? key,
      required this.BusId,
      required this.BusNumber,
      required this.email})
      : super(key: key);

  @override
  _HomePageConductorState createState() => _HomePageConductorState();
}

class _HomePageConductorState extends State<HomePageConductor> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
  }

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

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  int num = 0;
  Future<void> _showMyDialog(String name, String email) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passenger Departed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Passenger Details: \nName: $name \nEmail: $email'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                setState(() {
                  num = num - 1;
                });
                setData();
                FirebaseFirestore.instance
                    .collection('tickets')
                    .doc(email)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFloatDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Number of Passengers'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Number of Passengers",
                    hintText: "25",
                    prefixIcon: Icon(
                      Icons.account_circle,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      num = int.parse(value);
                    });
                    print(num);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                setData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int number = 0;
  Future<void> _PassengerDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Number of Passengers Rejected'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Number of Passengers",
                    hintText: "25",
                    prefixIcon: Icon(
                      Icons.account_circle,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      number = int.parse(value);
                    });
                    print(number);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('callbacks')
                    .doc(widget.BusId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String emergname = '';
  int emergSeat = 0;
  bool emergencyb = false;
  void emergency() {
    if (!emergencyb) {
      FirebaseFirestore.instance
          .collection('callbacks')
          .doc(widget.BusId)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            emergSeat = doc['seatnumber'];
            emergname = doc['name'];
          });
          setState(() {
            emergencyb = true;
          });
          EmergencyDialog();
        }
      });
    }
  }

  Future<void> EmergencyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Call'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Emergency Call From Seat Number: $emergSeat \n Name : $emergname'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToSecondPage(
      String name, String email, String phone, String url) async {
    final answer = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ticketGeneration(
                name: name,
                email: email,
                phone: phone,
                url: url,
                busid: widget.BusId,
                busnumber: widget.BusNumber,
                number: num,
              )),
    );
    print(answer);
    if (answer == true) {
      setState(() {
        num = num + 1;
      });
      print(num);
      setData();
    }
  }

  bool pushed = false;
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      // print("%%%%%%%%%%%%%%%%");
      setState(() {
        result = scanData;
      });
      // Map valueMap = json.decode(scanData!.code.toString());
      print("*****************************");
      print(scanData.code);
      print("*****************************");
      final split = scanData.code!.split(',');
      if (split.length == 5 && !pushed) {
        if (split[4] == true) {
          _showMyDialog(split[0], split[1]);
        } else {
          moveToSecondPage(split[0], split[1], split[2], split[3]);
        }
        pushed = true;
      } else {
        print("/////QR Code Shown isn't Correct");
      }
    });
  }

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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  Future _signOut() async {
    await _auth.signOut();
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

  double lat = 0;
  double long = 0;

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
    setState(() {
      lat = _locationData!.latitude!;
      long = _locationData!.longitude!;
    });
    location.enableBackgroundMode(enable: true);
    FirebaseFirestore.instance
        .collection('buslocations')
        .doc(widget.BusId)
        .set({
      'BusId': widget.BusId,
      'BusNumber': widget.BusNumber,
      'lat': _locationData!.latitude,
      'long': _locationData!.longitude,
      'number': number,
    });
  }

  int calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).round();
  }

  void setData() {
    FirebaseFirestore.instance.collection('passengers').doc(widget.BusId).set({
      'busnumber': widget.BusNumber,
      'busid': widget.BusId,
      'number': num,
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    download();
    _getLoctaion();
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    location.onLocationChanged.listen((LocationData current) {
      _getLoctaion();
      emergency();
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Find My Bus'),
        backgroundColor: Colours.orangyish,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text('Code Scanned')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFloatDialog();
        },
        backgroundColor: Color(0xFF3383CD),
        child: const Icon(Icons.add),
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
              leading: Icon(Icons.map),
              title: const Text('More Buses Required'),
              onTap: () {
                _PassengerDialog();
              },
            ),
          ],
        ),
      ),
    );
  }
}
