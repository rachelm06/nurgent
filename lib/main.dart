// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(40.730610, -73.935242);
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  int _selectedIndex = 0;
  late Set<Marker> toiletData;
  @override
  void initState() {
    super.initState();
    _loadData();
    _getUserLocation();
  }

  Future<Set<Marker>> loadMarkersFromJson() async {
    final jsonString = await rootBundle.loadString('assets/data/toilets.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    final Set<Marker> markers = jsonList.map((json) {
      final double latitude = json['latitude'];
      final double longitude = json['longitude'];
      final String name = json['name'];
      final String address = json['address'];

      return Marker(
        markerId: MarkerId(name),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: name,
          snippet: address,
        ),
      );
    }).toSet();

    return markers;
  }

  void _loadData() async {
    final data = await loadMarkersFromJson();
    setState(() {
      toiletData = data;
    });
  }

  _getUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      // Note the NOT (!) here
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLoc) {
      if (_currentLocation.latitude != null &&
          _currentLocation.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(currentLoc.latitude!, currentLoc.longitude!);
        });
        if (mapController != null) {
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentLocation, zoom: 11.0),
            ),
          );
        }
      }
    });
  }

  List<Widget> _getWidgetOptions() {
    return [
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 11.0,
        ),
        markers: toiletData,
        myLocationEnabled: true,
      ),
      const Text('Toilets Page'),
      const Text('Profile Page'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('NURGENT'),
            backgroundColor: const Color.fromARGB(255, 34, 49, 131),
            centerTitle: true),
        body: _getWidgetOptions().elementAt(_selectedIndex),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: SizedBox(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconBottomBar(
                      text: "Map",
                      icon: Icons.map,
                      selected: _selectedIndex == 0,
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      }),
                  IconBottomBar(
                      text: "Toilets",
                      icon: Icons.restaurant,
                      selected: _selectedIndex == 1,
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      }),
                  IconBottomBar(
                      text: "Profile",
                      icon: Icons.person,
                      selected: _selectedIndex == 2,
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconBottomBar extends StatelessWidget {
  const IconBottomBar(
      {Key? key,
      required this.text,
      required this.icon,
      required this.selected,
      required this.onPressed})
      : super(key: key);
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: selected ? const Color(0xff15BE77) : Colors.grey,
          ),
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 14,
              height: .1,
              color: selected ? const Color(0xff15BE77) : Colors.grey),
        )
      ],
    );
  }
}
