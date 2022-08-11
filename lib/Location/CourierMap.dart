import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constant.dart';
import 'package:geocoding/geocoding.dart';

import 'FastDeliveryAlgrorithm.dart';

late LatLng currentLatLng;

class MapPage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

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

  double zoomVal = 5.0;
  bool showPopUp = false;
  IconData dropdownvalue = Icons.home;
  String address = "";
  String buildingNo = "";
  TextEditingController _buildingNoController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();

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
            visible: !showPopUp,
            child: Positioned(
              left: 25,
              bottom: 10,
              child: FloatingActionButton(
                highlightElevation: 50,
                elevation: 12,
                backgroundColor: Colors.blue.withOpacity(0.8),
                child: Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                ),
                onPressed: () async {
                  /*;*/
                  Position position = await _determinePosition();

                  List<Placemark> newPlace = await placemarkFromCoordinates(
                      position.latitude, position.longitude);

                  Placemark placeMark = newPlace.first;
                  String? subAdministrativeArea =
                      placeMark.subAdministrativeArea;
                  String? name3 = placeMark.thoroughfare;
                  String? subLocality = placeMark.subLocality;
                  String? locality = placeMark.locality;
                  String? administrativeArea = placeMark.administrativeArea;
                  String? postalCode = placeMark.postalCode;

                  buildingNo = placeMark.name!;

                  address =
                      "${administrativeArea} ${postalCode}, ${subAdministrativeArea}, ${name3}";

                  _gotoLocation(
                    LatLng(position.latitude, position.longitude).latitude,
                    LatLng(position.latitude, position.longitude).longitude,
                  );

                  generateList();

                  setState(() {
                    showPopUp = true;
                  });
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
          //_zoomminusfunction(),
          //_zoomplusfunction(),
          //_buildContainer(),
          Visibility(
            visible: showPopUp,
            child: _popUp(),
          ),
        ],
      ),
    );
  }

  Widget _popUp() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          height: MediaQuery.of(context).size.height * 0.48,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                spreadRadius: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: DropdownButton(
                              // Initial Value
                              value: dropdownvalue,
                              underline: Container(),

                              // Down Arrow Icon
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: kOrderPageButtonColor,
                              ),

                              // Array list of items
                              items: iconList.map((IconData items) {
                                return DropdownMenuItem(
                                  alignment: Alignment.center,
                                  value: items,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Icon(
                                          items,
                                          size: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (IconData? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Expanded(
                        flex: 8,
                        child: TextField(
                          cursorColor: Colors.yellow[600],
                          decoration: InputDecoration(
                            isDense: true,
                            fillColor: kOrderPageButtonColor,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: kOrderPageButtonColor,
                                width: 2.0,
                              ),
                            ),
                            labelText: 'Başlık(Ev, İşyeri)',
                            labelStyle: TextStyle(color: kOrderPageTextColor),
                          ),
                        )),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        cursorColor: Colors.yellow[600],
                        controller: _addressController..text = address,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kOrderPageButtonColor,
                              width: 2.0,
                            ),
                          ),
                          labelText: 'Adres',
                          labelStyle: TextStyle(color: kOrderPageTextColor),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        cursorColor: Colors.yellow[600],
                        controller: _buildingNoController..text = buildingNo,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kOrderPageButtonColor,
                              width: 2.0,
                            ),
                          ),
                          labelText: 'Bina',
                          labelStyle: TextStyle(color: kOrderPageTextColor),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        cursorColor: Colors.yellow[600],
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kOrderPageButtonColor,
                              width: 2.0,
                            ),
                          ),
                          labelText: 'Kat',
                          labelStyle: TextStyle(color: kOrderPageTextColor),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Expanded(
                        flex: 4,
                        child: TextField(
                          cursorColor: Colors.yellow[600],
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: kOrderPageButtonColor,
                                width: 2.0,
                              ),
                            ),
                            labelText: 'Daire',
                            labelStyle: TextStyle(color: kOrderPageTextColor),
                          ),
                        )),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: TextField(
                          cursorColor: Colors.yellow[600],
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: kOrderPageButtonColor,
                                width: 2.0,
                              ),
                            ),
                            labelText: 'Adres Tarifi',
                            labelStyle: TextStyle(color: kOrderPageTextColor),
                          ),
                        )),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (() {
                          //Save Address Data
                          print("Save Address Data");
                        }),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: const Text(
                              "Kaydet",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: kOrderPageButtonColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(),
              ],
            ),
          )),
    );
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: const Icon(FontAwesomeIcons.magnifyingGlassMinus,
              color: kOrderPageButtonColor),
          onPressed: () {
            zoomVal--;
            _minus(zoomVal);
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: const Icon(FontAwesomeIcons.magnifyingGlassPlus,
              color: kOrderPageButtonColor),
          onPressed: () {
            zoomVal++;
            _plus(zoomVal);
          }),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    //final _locationData = await location.getLocation();

    Position position = await Geolocator.getCurrentPosition();

    //  var lat = LatLng(_locationData.latitude);

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        //  target: LatLng(_locationData.latitude, _locationData.longitude),
        target: LatLng(LatLng(position.latitude, position.longitude).latitude,
            LatLng(position.latitude, position.longitude).longitude),
        zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    Position position = await Geolocator.getCurrentPosition();

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(LatLng(position.latitude, position.longitude).latitude,
          LatLng(position.latitude, position.longitude).longitude),
    )));
  }

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
////////////////////////////////////////////////////////////////////////////////
  Widget _buildGoogleMap(BuildContext context) {
    // Builds google map with initial manuel target.
    // Updates the target "_gotoLocation" function
    /*
    Future<Position> myLatLng() async {
      Position position = await _determinePosition();
      return position;
    }
    */
    Set<Marker> _markers = Set<Marker>();

    return SizedBox(
      height: !showPopUp
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height * 0.42,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        myLocationButtonEnabled: false,
        tiltGesturesEnabled: false,
        markers: _markers,

        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
            target: LatLng(38.457844, 27.206515), zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },

        //markers: {kartalMarker, donerciomerustaMarker, donercivedatMarker},
      ),
    );
  }

  Marker myloc = Marker(
    markerId: MarkerId('kartalbufe'),
    position: LatLng(38.432559, 27.190210),
    infoWindow: InfoWindow(title: 'Kartal Büfe'),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    ),
  );

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

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    print("XXXXXXXXXXXX  LOC : $lat  $long ");
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 18,
    )));
  }
}

class Pos {
  String? title;
  String? address;
  String? buildingNo;
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

  List<Placemark> newPlace =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  Placemark placeMark = newPlace.first;

  String? name = placeMark.name;
  String? name2 = placeMark.subAdministrativeArea;
  String? name3 = placeMark.thoroughfare;
  String? subLocality = placeMark.subLocality;
  String? locality = placeMark.locality;
  String? administrativeArea = placeMark.administrativeArea;
  String? postalCode = placeMark.postalCode;
  String? country = placeMark.country;
  String address =
      "${name}, ${name2}, ${name3}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

  print(address);

  print(position);

  return position;
}

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
