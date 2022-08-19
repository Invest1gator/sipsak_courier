import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:courier_app/models/directionDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker_updates.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../Screens/CourierPage/courier_page.dart';
import 'FastDeliveryAlgrorithm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
// https://maps.googleapis.com/maps/api/directions/json?origin=38.396901,%2027.070646&destination=38.467249,%2027.208174&key=AIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU

late LatLng currentLatLng;
String googleAPiKey = "AIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU";
LatLng endLocation = LatLng(0, 0);
LatLng startLocation = LatLng(0, 0);
DirectionDetails directionDetails = DirectionDetails(10, 10, "", "", "");
String? a = " ";
String? b = " ";

// -1 idle, 0 to restaurant, 1 to customer, 2 waiting point

class MapPage extends StatefulWidget {
  final String? firstEndLocation;
  final String? secondEndLocation;
  final int? courrierState;
  const MapPage(
      {Key? key,
      this.firstEndLocation,
      this.secondEndLocation,
      this.courrierState})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction
  Set<Marker> _markers = Set<Marker>();
  PolylinePoints polylinePoints = PolylinePoints();
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GPS Button
      floatingActionButton: Stack(
        children: [
          Visibility(
            child: Positioned(
              left: 25,
              bottom: 10,
              child: FloatingActionButton(
                highlightElevation: 50,
                elevation: 12,
                backgroundColor: Colors.blue.withOpacity(0.8),
                child: const Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                ),
                onPressed: () async {
                  /*;*/
                  getDirections(
                      context); //fetch direction polylines from Google API
                  Position position = await _determinePosition(
                      widget.firstEndLocation!,
                      widget.secondEndLocation!,
                      widget.courrierState!);
                  _gotoLocation(
                    LatLng(position.latitude, position.longitude).latitude,
                    LatLng(position.latitude, position.longitude).longitude,
                  );
                  setState(() {
                    polylines.clear();
                  });

                  Timer.periodic(const Duration(seconds: 5),
                      (Timer t) => getDirections(context));

                  Timer.periodic(const Duration(seconds: 5),
                      (Timer t) => upDateMarkers(position));
                  // generateList();
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            compassEnabled: true,
            myLocationButtonEnabled: false,
            tiltGesturesEnabled: false,
            markers: _markers,
            polylines: Set<Polyline>.of(polylines.values),
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
                target: LatLng(38.454659, 27.202257), zoom: 16),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Container(
            margin: EdgeInsets.fromLTRB(width * 0.33, 0, width * 0.25, 0),
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 350.0,
                height: 50.0,
                child: Card(
                  child: Text(
                    'Süre: $a \nMesafe: $b',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

/*
  Future<BitmapDescriptor> setCustomerMarkerIcon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset("assets/images/moto.png", 100);

    currentLocationIcon = markerIcon as BitmapDescriptor;

    return currentLocationIcon;
  }
*/
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> upDateMarkers(Position pos) async {
    List<Marker> updatedMarkers =
        []; //new markers with updated position go here
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    LatLng currentPos = LatLng(position.latitude, position.longitude);

    updatedMarkers = [];

    /// Then call the SetState function.
    /// I called the MarkersUpdate class inside the setState function.
    /// You can do it your way but remember to call the setState function so that the updated markers reflect on your Flutter app.
    /// Ps: I did not try the second way where the MarkerUpdate is called outside the setState buttechnically it should work.

    setState(() async {
      final Uint8List markerIcon =
          await getBytesFromAsset("assets/images/moto.png", 200);
      _markers.clear();
      print("setstate içindeki startlocation: $startLocation");
      _markers.add(
        Marker(
          //add start location marker
          markerId: MarkerId("1"),
          position: currentPos, //position of marker
          infoWindow: const InfoWindow(
            //popup info
            title: 'Başlangıç Noktası',
            snippet: 'Canlı konum',
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon), //Icon for Marker
        ),
      );
      LatLng destPos = LatLng(pos.latitude, pos.longitude);
      print("endLocation= $endLocation");
      _markers.add(Marker(
        //add destination location marker
        markerId: MarkerId("2"),
        position: endLocation, //position of marker
        infoWindow: const InfoWindow(
          //popup info
          title: 'Hedef Noktası_',
          snippet: 'Destination Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
      print(
          "  MARKERS CHANGED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      //swap of markers so that on next marker update the previous marker would be the one which you updated now.
// And even on the next app startup, it takes the updated markers to show on the map.
    });
  }

/*
  Future<void> initStartLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng startLocation = LatLng(position.latitude, position.longitude);
  }
*/
  getDirections(BuildContext context) async {
    List<LatLng> polylineCoordinates = [];

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng startLocation = LatLng(position.latitude, position.longitude);
    print(" Current Location  ----------------->  $startLocation");
    print(" END LOCATION  ----------------->  $endLocation");

    var customerAdress =
        Provider.of<AddressesProvider>(context, listen: false).orderAddress;

    var restaurantAdress =
        Provider.of<AddressesProvider>(context, listen: false)
            .restaurantAddress;
    print(
        "------> CUSTOMER_ADRESS = $customerAdress   ----  Restaurant_ADRES = $restaurantAdress");

    LatLng destination = LatLng(0.0, 0.0);

    List<Location> custAdress = await locationFromAddress(customerAdress);
    List<Location> restAdress = await locationFromAddress(restaurantAdress);

    LatLng customerLATLONG =
        LatLng(custAdress.first.latitude, custAdress.first.longitude);
    LatLng restaurantLATLONG =
        LatLng(restAdress.first.latitude, restAdress.first.longitude);

    if (widget.courrierState == 0) {
      destination = restaurantLATLONG;
    } else if (widget.courrierState == 1) {
      destination = customerLATLONG;
    }

    endLocation = destination;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("POLYLINE LAR BOS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(result.errorMessage);
    }

    addPolyLine(polylineCoordinates);
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    print("XXXXXXXXXXXX  LOC : $lat  $long ");
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 18,
    )));
  }
}

Future<Position> _determinePosition(
    String restaurantAdress, String customerAdress, int courrierState) async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return Future.error('Location services are disabled');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error("Location permission denied");
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  print(position);

  print(
      "------> CUSTOMER_ADRESS = $customerAdress   ----  Restaurant_ADRES = $restaurantAdress");

  LatLng destination = LatLng(0.0, 0.0);

  List<Location> custAdress = await locationFromAddress(customerAdress);
  List<Location> restAdress = await locationFromAddress(restaurantAdress);

  LatLng customerLATLONG =
      LatLng(custAdress.first.latitude, custAdress.first.longitude);
  LatLng restaurantLATLONG =
      LatLng(restAdress.first.latitude, restAdress.first.longitude);

  if (courrierState == 0) {
    destination = restaurantLATLONG;
  } else if (courrierState == 1) {
    destination = customerLATLONG;
  }

  obtainPlaceDirectionDetails(restaurantAdress, customerAdress, courrierState);

  return position;
}

Future<DirectionDetails> obtainPlaceDirectionDetails(
    String restaurantAdress, String customerAdress, int courrierState) async {
  // var mapKey = "AAIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU";
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  LatLng startLocation = LatLng(position.latitude, position.longitude);

  print(
      "------> CUSTOMER_ADRESS = $customerAdress   ----  Restaurant_ADRES = $restaurantAdress");
  LatLng destination = LatLng(0.0, 0.0);

  List<Location> custAdress = await locationFromAddress(customerAdress);
  List<Location> restAdress = await locationFromAddress(restaurantAdress);

  LatLng customerLATLONG =
      LatLng(custAdress.first.latitude, custAdress.first.longitude);
  LatLng restaurantLATLONG =
      LatLng(restAdress.first.latitude, restAdress.first.longitude);

  if (courrierState == 0) {
    destination = restaurantLATLONG;
  } else if (courrierState == 1) {
    destination = customerLATLONG;
  }
  print("-------------DESTINATION $destination");
  String directionURL =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${startLocation.latitude},${startLocation.longitude}&destination=${destination.latitude},${destination.longitude}&key=AIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU";
  var res = await http.get(Uri.parse(directionURL));
  var responseData = jsonDecode(res.body);

  DirectionDetails directionDetails = DirectionDetails(10, 10, "", "", "");

  directionDetails.encodedPoints =
      responseData["routes"][0]['overview_polyline']['points'];
  directionDetails.distanceText =
      responseData["routes"][0]['legs'][0]['distance']["text"];
  directionDetails.distanceValue =
      responseData["routes"][0]['legs'][0]['distance']["value"];
  directionDetails.durationText =
      responseData["routes"][0]['legs'][0]['duration']["text"];
  directionDetails.durationValue =
      responseData["routes"][0]['legs'][0]['duration']["value"];
  a = directionDetails.durationText;
  b = directionDetails.distanceText;
  print("HEEEEEIIYOOOOOOOOO durationText :$a");
  print("HEEEEEIIYOOOOOOOOO distanceText :$b");
  return directionDetails;
}
