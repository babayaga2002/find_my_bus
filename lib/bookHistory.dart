import 'package:flutter/material.dart';

import 'package:find_my_bus/my_header.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:find_my_bus/constants.dart';

class Booking extends StatefulWidget {
  final String email;
  const Booking({Key? key, required this.email}) : super(key: key);

  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final controller = ScrollController();
  double offset = 0;
  String start = '';
  String end = '';
  String busid = '';
  String busnumber = '';
  String name = '';
  void _getUserData() {
    FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.email)
        .get()
        .then((doc) {
      setState(() {
        busid = doc['busid'];
        busnumber = doc['busnumber'];
        end = doc['end'];
        start = doc['start'];
        name = doc['name'];
      });
    });
  }


  
    @override
  void initState() {
    super.initState();
    _getUserData();
    controller.addListener(onScroll);
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  
  
  
  
  
  Widget getwidget() {
    if (name.length != 0) {
      return PreventCard(
          image: 'images/bus1.jpg',
          title: '$busnumber',
          text: ' Name: $name \n From : ${start} \n End : ${end}');
    }
    return Center(
      child: Container(
        padding: EdgeInsets.all(40.0),
        child: Text("No Bookings Found", textAlign:     TextAlign.center),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  
  Widget build(BuildContext   context) {
    _getUserData();
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
              textTop: "Bookings",
              textBottom: '',
              offset: offset,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      getwidget(),
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





class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  PreventCard({
    Key? key,
    required this.image,
    required this.title,
    required this.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        fontSize: 21,
                        
                        
                      ),
                    ),
                    
                    Expanded(
                      child: Text(
                        text  ,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
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
    );
  }
}
