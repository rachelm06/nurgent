// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(const MyApp());

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  List<Widget> _buildReviews() {
    List <Map<String, String>> places = [
      {
      "name": "Agnes Haywood Playground Public Restroom",
      "address": "East 215 Street, Barnes Avenue, East 216 Street",
      },
      {
        "name": "Allerton Playground Public Restroom",
        "address": "Allerton Avenue between Throop Avenue & Stedman Place",
      },
      {
        "name": "Aqueduct Walk Public Restroom",
        "address": "Aqueduct Ave. E & W. 182nd St.",
      },
      {
        "name": "Barnes & Nobles",
        "address": "2289 Broadway",
      },
      {
        "name": "McDonalds",
        "address": "125th St & Lexington Ave",
      },
      {
        "name": "Burger King",
        "address": "1380 Jerome Ave",
      },
    
  
  ];
  List<Widget> reviews = [];

    for (var place in places) {
      double rating = 1 + (4 * Random().nextDouble());

      reviews.add(
        Container(
          margin: EdgeInsets.only(top: 16.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['name'] ?? 'Unknown Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                place['address'] ?? 'Unknown Address',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              Row(
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 70.0,
            backgroundImage: NetworkImage(
                'https://placekitten.com/200/200'), // Add your image URL here
          ),
          SizedBox(height: 10.0),
          Text(
            'Jane Doe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            '23 bathrooms visited in 2023',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 20.0),
          Text(
              'Your Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
             Expanded(
              child: ListView(
                children: _buildReviews(),
              ),
      )],
      ),
    ));
  }
}

class Toilet {
  final String name;
  final String address;
  final LatLng coordinates;
  final double? rating;

  Toilet({required this.name, required this.address, required this.coordinates, this.rating});
}

class ToiletPage extends StatefulWidget {
  final Set<Toilet> toilets;

  ToiletPage({Key? key, required this.toilets}) : super(key: key);

  @override
  _ToiletPageState createState() => _ToiletPageState();
}

class _ToiletPageState extends State<ToiletPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Search by address...',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: widget.toilets.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final toilet = widget.toilets.elementAt(index);
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(toilet.name),
                    ),
                    if (toilet.rating != null) ...[ // Use the spread operator with the conditional check
                      Text(
                        toilet.rating!.toStringAsFixed(1), // Use the ! to assert non-null
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),  
                    ],
                    Icon(Icons.star, color: Colors.yellow),
                  ],
                ),
                subtitle: Text(toilet.address),
                onTap: () {
                  // Handle tap action
                },
              );
            }
          )
        )
      ],
    );
  }
}


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
  Set<Marker> toiletData = {};
  late BitmapDescriptor customIcon;

  Future<void> loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(1, 1)), // Adjust the size as needed
      'assets/images/toilet.png',
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    loadCustomIcon();
    _loadData();
  }

  Future<Set<Marker>> loadMarkersFromJson() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/toilets.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final Set<Marker> markers = jsonList.map((json) {
        final String coords = json['coords'];
        final double latitude =
            double.parse(coords.substring(0, coords.indexOf(',')));
        final double longitude =
            double.parse(coords.substring(coords.indexOf(',') + 2));
        final String name = json['name'];
        final String address = json['address'];

        return Marker(
          markerId: MarkerId(name),
          position: LatLng(latitude, longitude),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: name,
            snippet: address,
          ),
        );
      }).toSet();
      return markers;
    } catch (e) {
      print("Error in loadMarkersFromJson: $e");
      // Handle the error or return an empty set of markers if there's an issue.
      return <Marker>{};
    }
  }

  List<Toilet> toiletList = [];

  Future<void> _loadData() async {
  final data = await loadMarkersFromJson();
  final random = Random();
  setState(() {
    toiletData = data;
    
    toiletList = data.map((marker) {
      final double randomRating = (random.nextDouble() * 4 + 1).toDouble(); // Random rating between 1 to 5
    
      return Toilet(
        name: marker.infoWindow.title!,
        address: marker.infoWindow.snippet!,
        coordinates: marker.position,
        rating: randomRating, // Random rating between 1 to 5
      );
    }).toList();
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
              CameraPosition(target: _currentLocation, zoom: 20.0),
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
      ToiletPage(toilets: Set.from(toiletList)), 
      const ProfileCard(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Image.asset(
              'assets/images/logo-no-background_1_240x60.png',
              fit: BoxFit
                  .contain, // You can use different BoxFit properties to fit the image appropriately
              height: 40.0, // You can adjust the height as required
            ),
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
                      icon: Icons.wc,
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