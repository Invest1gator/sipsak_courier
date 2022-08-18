import 'package:courier_app/Location/CourierMap.dart';
import 'package:flutter/material.dart';

import '../Screens/constant.dart';
import 'MapPage2.dart';

class CourierBuildOptimumMap extends StatefulWidget {
  const CourierBuildOptimumMap({Key? key}) : super(key: key);

  @override
  State<CourierBuildOptimumMap> createState() => _CourierBuildOptimumMapState();
}

class _CourierBuildOptimumMapState extends State<CourierBuildOptimumMap> {
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
      body: MapPage2(),
    );
    ;
  }
}
