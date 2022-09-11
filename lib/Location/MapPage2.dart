import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'FastDeliveryAlgrorithm.dart';

final Set<Marker> _markers = Set<Marker>();
var twoDList = List.generate(50, (i) => List.filled(2, 0.0, growable: false),
    growable: false);
BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
final Completer<GoogleMapController> _controller = Completer();

class MapPage2 extends StatefulWidget {
  const MapPage2({Key? key}) : super(key: key);

  @override
  State<MapPage2> createState() => _MapPage2State();
}

class _MapPage2State extends State<MapPage2> {
  @override
  void initState() {
    twoDList = generateList();
    centerOfCircle();
    addAllMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return _buildGoogleMap(context);
  }
}

Widget _buildGoogleMap(BuildContext context) {
  // Builds google map with initial manuel target.
  // Updates the target "_gotoLocation" function
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;

  return SizedBox(
    child: Stack(
      children: <Widget>[
        GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          myLocationButtonEnabled: false,
          tiltGesturesEnabled: false,
          markers: _markers,
          mapType: MapType.normal,
          initialCameraPosition: const CameraPosition(
              target: LatLng(38.454659, 27.202257), zoom: 13),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },

          //markers: {kartalMarker, donerciomerustaMarker, donercivedatMarker},
        ),
        //from 0-1, 0.5 = 50% opacity
      ],
    ),
  );
}

void addAllMarkers() {
  double Lat, Long;
  for (var row = 0; row < 50; row++) {
    Lat = twoDList[row][0];
    Long = twoDList[row][1];
    LatLng startloc = LatLng(Lat, Long);

    _markers.add(Marker(
//add start location marker
      markerId: MarkerId(startloc.toString()),
      position: startloc, //position of marker
      infoWindow: InfoWindow(
//popup info
        title: 'Restaurant' + (row + 1).toString(),
        snippet: 'Start Marker',
      ),
      icon: currentLocationIcon, //Icon for Marker
    ));
  }
}

double distance = -1.0;

LatLng centerOfCircle() {
  LatLng? centerLocation;
  CenterCandidate cc = new CenterCandidate();
  for (var row1 = 0; row1 < 50; row1++) {
    var count = 0;
    for (var row2 = 0; row2 < 50; row2++) {
      distance = calcDistance(twoDList[row1][0], twoDList[row1][1],
          twoDList[row2][0], twoDList[row2][1]);
      if (distance < 0.5 && distance != 0) {
        count++;
      }
    }

    cc.addToCenterCanList(CenterCandidateLoc(
        LatLng(twoDList[row1][0], twoDList[row1][1]), count));
    print("-------------------------------------------" + count.toString());
  }

  centerLocation =
      cc.findMaxCount(); // count'ı en yüksek konum centerLoc olarak belirlendi.

  cc.addToCenterLocList(centerLocation); // Center Loc belirlendi.

  return centerLocation;
}

class CenterCandidateLoc {
  final LatLng location;
  final int count;

  CenterCandidateLoc(this.location, this.count);
}

class CenterCandidate {
  List<CenterCandidateLoc> centerCanList = [];
  List<LatLng> centerLocList = [];
  List<LatLng> centerElimList = [];

  void addToCenterCanList(CenterCandidateLoc center_can) {
    centerCanList.add(center_can);
  }

  void addToCenterLocList(LatLng center_loc) {
    centerLocList.add(center_loc);
  }

  LatLng findMaxCount() {
    int maxValue = -1;
    int maxValueIndex = -1;
    for (int i = 0; i < centerCanList.length; i++) {
      if (centerCanList[i].count > maxValue) {
        maxValue = centerCanList[i].count;
        maxValueIndex = i;
      }
    }
    print("Max Value" + maxValue.toString());
    print("Location" +
        centerCanList[maxValueIndex].location.latitude.toString() +
        "/" +
        centerCanList[maxValueIndex].location.longitude.toString());

    return centerCanList[maxValueIndex].location;
  }

  void removeFromTwoDList() {}
}

double calcDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
  // return sqrt(pow(x1 - x2, 2)) + sqrt(pow(y1 - y2, 2)) * 1000;
}
