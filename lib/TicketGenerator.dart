import 'package:flutter/material.dart';
import 'package:find_my_bus/my_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart' ;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ticketGeneration extends StatefulWidget {
  final String name;
  
  final String email;
  final String phone;
  final String url;
  final String busid;
  final String busnumber;
  final int number;
  const ticketGeneration(
      {Key? key,
      required this.name,
      required this.email,
      required this.phone,
      required this.url,
      required this.busid,
      required this.busnumber,
      required this.number})
      : super(key: key);

  @override
  _ticketGenerationState createState() => _ticketGenerationState();
}

class _ticketGenerationState extends State<ticketGeneration> {
  final controller = ScrollController();
  double offset = 0;
  String start = '';
  String end = '';
  int num = 0;
  bool approved = false;
  Future<void> _showMyDialog(String name,  String end, String start) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:  false ,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New  Group'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Approve Ticket For : $name \n From :  $start \n To: $end'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                TextButton(
                  child: const Text('Deny'),
                  onPressed: () {
                    Navigator.pop(context,  false);
                    Navigator.pop(context,  false);
                  },
                ),
                TextButton(
                  child: const Text('Approve'),
                  onPressed: () {
                    setState(() {
                      approved = true;
                      num = widget.number + 1;
                    });
                    FirebaseFirestore.instance
                        .collection('tickets')
                        .doc(widget.email)
                        .set({
                      'name': widget.name,
                      'email': widget.email,
                      'end': end,
                      'start': start,
                      'busid': widget.busid,
                      'busnumber': widget.busnumber,
                      'endlat': endlat ,
                      'endlong': endlong ,
                      'startlat': startlat,
                      'startlong':   startlong,
                      'seatnumber': num,
                    });
                    Navigator.pop(context, true);
                    Navigator.pop(context,  true);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  double startlat = 0;
  double startlong = 0;
  double endlat = 0;
  double endlong = 0;
  String url = '';
  Future<dynamic> getResponseDataStart(String  cityName) async {
    url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=ac69515796e0ac5fb9303bcef657eece';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        startlat = data['coord']['lat'];
        startlong = data['coord']['lon'];
      });
    } else {
      return print(response.statusCode);
    }
  }

  Future<dynamic> getResponseDataEnd(String cityName) async {
    url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=ac69515796e0ac5fb9303bcef657eece';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        endlat = data['coord']['lat']  ;
        endlong = data['coord']['lon'];
      });
    } else {
      return print(response.statusCode)  ;
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll) ;
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients ) ? controller.offset : 0;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose()  ;
  }

  @override
  Widget build(BuildContext context)   {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF11249F),
        title: Text('Generate Ticket'),
      ),
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyHeader(
              image: "images/3855345.png",
              textTop: "Hello",
              textBottom: '',
              offset: offset ,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20) ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
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
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 21,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 31,
                          ),
                          Text(
                            "Name-",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${widget.name}",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 30,
                            
                          ),
                          Text(
                            "Email-",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${widget.email}",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          autofocus: true,
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
                            getResponseDataStart(start);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: TextField(
                          autofocus: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Destination",
                            hintText: "Thane",
                            prefixIcon: Icon(
                              Icons.location_history,
                            ),
                          ),
                          onChanged: (value) {
                            end = value;
                            getResponseDataEnd(end);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        
                        
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _showMyDialog(widget.name,   end, start);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          child: Text(
                            "Book Ride",
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
