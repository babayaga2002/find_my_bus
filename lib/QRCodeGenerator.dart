import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qr extends StatefulWidget {
  final String uid;
  const Qr({Key? key, required this.uid}) : super(key: key);
  @override
  _QrState createState() => _QrState();
}

class _QrState extends State<Qr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Center(
        child: Container(
          child: QrImage(
            data: widget.uid,
            version: QrVersions.auto,
            size: 320,
            gapless: false,
          ),
        ),
      ),
    );
  }
}
