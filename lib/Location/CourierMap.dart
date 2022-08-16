import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courier_app/models/directionDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../constant.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

// Location location = new Location();

// https://maps.googleapis.com/maps/api/directions/json?origin=38.396901,27.070646&destination=38.467249,%2027.208174&key=AIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU

late LatLng currentLatLng;
String googleAPiKey = "AIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU";
LatLng endLocation = const LatLng(38.467249, 27.208174);
LatLng startLocation = const LatLng(0, 0);
DirectionDetails directionDetails = DirectionDetails(10, 10, "", "", "");
String? a = " ";
String? b = " ";

class MapPage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<MapPage> {
  // final Location location = Location();
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction
  Set<Marker> _markers = Set<Marker>();

  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    initStartLoc();

    _markers.add(Marker(
      //add start location marker
      markerId: MarkerId(startLocation.toString()),
      position: startLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Starting Point ',
        snippet: 'Start Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    _markers.add(Marker(
      //add distination location marker
      markerId: MarkerId(endLocation.toString()),
      position: endLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Destination Point ',
        snippet: 'Destination Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));
    super.initState();

    getDirections(); //fetch direction polylines from Google API
  }

  Future<void> initStartLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng startLocation = LatLng(position.latitude, position.longitude);
    print(" START LOCATION  ----------------->  $startLocation");
    print(" END LOCATION  ----------------->  $endLocation");
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
    print("------------> My polyline points");
    print(result.points);
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(160, 0, 144, 138),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double zoomVal = 5.0;
  bool showPopUp = false;
  IconData dropdownvalue = Icons.home;
  String address = "";
  String buildingNo = "";

  var iconList = [
    Icons.home,
    Icons.work,
    Icons.park,
  ];
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
                  Position positio = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.best);
                  LatLng pos = LatLng(positio.latitude, positio.longitude);
                  _setCircle(pos);

                  /*;*/
                  Position position = await _determinePosition();
                  _gotoLocation(
                    LatLng(position.latitude, position.longitude).latitude,
                    LatLng(position.latitude, position.longitude).longitude,
                  );

                  setState(() {
                    a = directionDetails.distanceText;
                    b = directionDetails.durationText;
                  });
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

////////////////////////////////////////////////////////////////////////////////
  Widget _buildGoogleMap(BuildContext context) {
    // Builds google map with initial manuel target.
    // Updates the target "_gotoLocation" function
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: !showPopUp
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height * 0.42,
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

            //markers: {kartalMarker, donerciomerustaMarker, donercivedatMarker},
          ),
          //from 0-1, 0.5 = 50% opacity
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

/*
  Future<String> _getRestaurantLocation() async {
    try {
      await FirebaseFirestore.instance
          .collection(user.uid + '.CurrentMarketBasket')
          .doc(basketItem.name)
          .(basketItem.toJson());
    } catch (e) {
      await FirebaseFirestore.instance
          .collection(user.uid + '.CurrentMarketBasket')
          .doc(basketItem.name)
          .update(basketItem.toJson());
    }
  }
*/

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    print("XXXXXXXXXXXX  LOC : $lat  $long ");
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 18,
    )));
  }

  final Set<Circle> _circles = Set<Circle>();
  var radiusValue = 3000.0;

  // point i verip circle ı oluşturabiliriz
  Future<void> _setCircle(LatLng point) async {
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
      //getDirections = false;
      //searchToggle = false;
      //radiusSlider = true;
    });
    print("------------------------> CIRCLE SET.");
  }

  Future<Position> _determinePosition() async {
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
    LatLng pos = LatLng(position.latitude, position.longitude);
    // _setCircle(pos);
    obtainPlaceDirectionDetails(startLocation, endLocation);

    return position;
  }

// COMMENTLER

  Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initPos, LatLng finalPos) async {
    var mapKey = "AAIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU";
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng startLocation = LatLng(position.latitude, position.longitude);
    print("iste bu : ${startLocation.latitude}");
    String directionURL =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startLocation.latitude},${startLocation.longitude}&destination=38.467249,27.208174&key=AIzaSyCy8ocZ7I8dZQ4-Xq-KUGmA1lF7a6aLuIU";
    var res = await http.get(Uri.parse(directionURL));
    var responseData = jsonDecode(res.body);

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
}

// Polyline: It's a list of points, where line segments are drawn between consecutive points.
// Don't call the API every time the location changes, instead call it once using the current location. And the response contains everything you need to navigate the user. Check the maneuver key inside each step of a leg
// Off-route detection
// fastest route default a göre hesaplanmıştır.
//import 'package:geocoding/geocoding.dart';
// List<Location> locations = await locationFromAddress("Gronausestraat 710, Enschede");
/*
  print("XXX res.body= :");
  print(res.body);
  print("2");
  print(responseData);
  print("3");
  print(responseData["routes"]);
  print("4");
 */

// print(responseData["routes"][0]['legs'][0]['duration']);
// print("5");

/*
  Dio dio = Dio();
  Response response = await dio.get(
      "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=AIzaSyDi48IpaybbVdmJ9rTgSVfnTiOxxv8GAPo");
  print("XXXXXXXXXXXXXXXXXXXXXXX::::");
  print(response.data);
  print("XXXXXXXXXXXXXXXXXXXXXXX::::");
  */

/*
  void goToCurrentLoc() {
    Geolocator.getCurrentPosition().then((currLocation) {
      setState(() {
        currentLatLng =
            new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });

    print("currentLatLng : $currentLatLng.longitude  $currentLatLng.latitude ");
    _gotoLocation(currentLatLng.latitude, currentLatLng.longitude);
  }
*/

/*
  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            const SizedBox(width: 5.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://post.healthline.com/wp-content/uploads/2020/07/pizza-beer-1200x628-facebook-1200x628.jpg",
                  38.432559,
                  27.190210,
                  "Kartal Büfe"),
            ),
            const SizedBox(width: 5.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipMKRN-1zTYMUVPrH-CcKzfTo6Nai7wdL7D8PMkt=w340-h160-k-no",
                  38.434478,
                  27.203072,
                  "Dönerci Ömer Usta"),
            ),
            const SizedBox(width: 5.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                  38.428505,
                  27.205304,
                  "Dönerci Vedat"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String restaurantName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: FittedBox(
        child: Material(
            color: Colors.white,
            elevation: 14.0,
            borderRadius: BorderRadius.circular(24.0),
            shadowColor: Color(0x802196F3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image(
                      fit: BoxFit.fill,
                      image: NetworkImage(_image),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: myDetailsContainer1(restaurantName),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget myDetailsContainer1(String restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            restaurantName,
            style: TextStyle(
                color: kOrderPageTextColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                child: Text(
              "4.3",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStarHalf,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
                child: Text(
              "(133)",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
          ],
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          "  1.6 km",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18.0,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          " Açık: 10:00 - 22:00",
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
      ],
    );
  }
*/

/*
  Marker kartalMarker = Marker(
    markerId: MarkerId('kartalbufe'),
    position: LatLng(38.432559, 27.190210),
    infoWindow: InfoWindow(title: 'Kartal Büfe'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    ),
  );

  Marker donerciomerustaMarker = Marker(
    markerId: MarkerId('Dönerci Ömer Usta'),
    position: LatLng(38.434478, 27.203072),
    infoWindow: InfoWindow(title: 'Dönerci Ömer Usta'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueYellow,
    ),
  );
  Marker donercivedatMarker = Marker(
    markerId: MarkerId('Dönerci Vedat'),
    position: LatLng(38.428505, 27.205304),
    infoWindow: InfoWindow(title: 'Dönerci Vedat'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    ),
  );
*/

/*
  void getLocationOnChanged() async {
    var location = await currentLocation.getLocation();

    Completer<GoogleMapController> _controller = Completer()!;
    final _controller_ = await _controller.future!;
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller_
          ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 12.0,
      )));
      print(loc.latitude);
      print(loc.longitude);
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('Home'),
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      });
    });
  }
  */
