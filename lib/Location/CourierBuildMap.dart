import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'CourierMap.dart';
import '../constant.dart';

class CourierBuildMap extends StatefulWidget {
  final String? firstEndLocation;
  final String? secondEndLocation;
  final int? courrierState;
  const CourierBuildMap(
      {Key? key,
      this.firstEndLocation,
      this.secondEndLocation,
      this.courrierState})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<CourierBuildMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Container(
            width: 250.0,
            height: 200.0,
            child: Row(
              children: <Widget>[
                Text(
                  "  GPS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: Icon(
                    Icons.gps_fixed_outlined,
                    color: Colors.yellow[600],
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: kOrderPageButtonColor,
      ),
      body: MapPage(
          firstEndLocation: widget.firstEndLocation,
          secondEndLocation: widget.secondEndLocation,
          courrierState: widget.courrierState),
    );
  }
}
