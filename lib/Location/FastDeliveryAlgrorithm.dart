import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FastDelivery extends StatefulWidget {
  const FastDelivery({Key? key}) : super(key: key);

  @override
  FastDelPage createState() => FastDelPage();
}

class FastDelPage extends State<FastDelivery> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  final Set<Circle> _circles = Set<Circle>();
  var radiusValue = 3000.0;

// point i verip circle ı oluşturabiliriz
  void _setCircle(LatLng point) async {
    Completer<GoogleMapController> _controller = Completer();
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 12)));
    setState(() {
      _circles.add(Circle(
          circleId: CircleId('raj'),
          center: point,
          fillColor: Colors.blue.withOpacity(0.1),
          radius: radiusValue,
          strokeColor: Colors.blue,
          strokeWidth: 1));
      // getDirections = false;
      // searchToggle = false;
      // radiusSlider = true;
    });
  }

  List<num> randomDouble() {
    // İzmir içinden büyük bir dikdörtgen aldım. Köşeleri:
    // Faltay - Aşıkveysel - Optimum - EgePark
    num LAT_random = (Random().nextDouble() * 0.129325 + 38.337924);
    num LONG_random = (Random().nextDouble() * 0.203193 + 27.070646);
    // Random() generate random double within 0.00 - 1.00;
    List<num> intArr = [LAT_random, LONG_random];
    print(intArr);
    return intArr;
    //double.parse(randomdouble.toStringAsFixed(6));
    //toStringAsFixed will fix decimal length to 4, 0.3454534 = 0.3454
  }

  void generateList() {
    // 2 ye 20 lik izmir icinde random lat lang lar generatelendi
    var twoDList = List.generate(
        20, (i) => List.filled(2, 0.0, growable: false),
        growable: false);

//For fill;
    for (var row = 0; row < 20; row++) {
      twoDList[row][0] = randomDouble().first.toDouble();
      twoDList[row][1] = randomDouble().last.toDouble();
    }
    print(twoDList);
  }
}
