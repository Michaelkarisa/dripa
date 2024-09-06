import 'package:dripa/notications_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'main.dart';
import 'package:location/location.dart';
class TripPage extends StatefulWidget {
  final Person person;

  TripPage({super.key, required this.person});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final _formKey = GlobalKey<FormState>();

  String? _startLocation;
  String? _destination;
  double? _radius;

  void _startTrip() {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement the logic to start the trip
      print('Trip started from $_startLocation to $_destination with radius $_radius');
    }
  }

  void _searchTrip() {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement the logic to search trips
      print('Searching trips from $_startLocation to $_destination within radius $_radius');
    }
  }
  bool isLoading =false;
  Future<void> checkLocationPermissions() async {
    setState(() {
      isLoading=true;
    });
    Location locationService = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationService.requestService();
      if (!_serviceEnabled) {
        Fluttertoast.showToast(msg: 'Location services are disabled.');
        return;
      }
    }

    // Check location permission
    _permissionGranted = await locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: 'Location permission denied.');
        return;
      }
    }
    LocationData _locationData = await locationService.getLocation();
    setState(() {
      isLoading=false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => MapsPage(currentPosition:LatLng( _locationData.latitude!,_locationData.longitude!),)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip for ${widget.person.name}'),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2675,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Start Location',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Enter your starting location',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the start location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _startLocation = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Destination',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Enter your destination',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the destination';
                  }
                  return null;
                },
                onSaved: (value) {
                  _destination = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Radius (in m)',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Enter radius in meters',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the radius';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid radius';
                  }
                  return null;
                },
                onSaved: (value) {
                  _radius = double.tryParse(value!);
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.person.collectionName == "Driver"
                      ? ElevatedButton(
                    onPressed: ()async{
                      await checkLocationPermissions();
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        _startTrip();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child:  isLoading?CircularProgressIndicator():Text('Start Trip'),
                  )
                      : ElevatedButton(
                    onPressed: ()async{
                      await checkLocationPermissions();
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        _searchTrip();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child:  isLoading?CircularProgressIndicator():Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MapsPage extends StatefulWidget {
  final LatLng currentPosition; // Marked as final
  MapsPage({super.key,
    required this.currentPosition});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.3861, -122.0839);
  BitmapDescriptor? bus;
  BitmapDescriptor? taxi;
  BitmapDescriptor? tuktuk;
  BitmapDescriptor? truck;
  BitmapDescriptor? matatu;
  BitmapDescriptor? motorbike;
  BitmapDescriptor? passenger;
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  LatLng? _currentPosition1;
  LatLng? _currentPosition2;
  LatLng? _currentPosition3;
  LatLng? _currentPosition4;
  LatLng? _currentPosition5;
  LatLng? _currentPosition6;
  final Location _locationService = Location();
  bool isLoading = false;
  Future<void> _settaxiMarker() async {
    taxi = await BitmapDescriptor.asset(
      height: 20,
      width: 20,
      const ImageConfiguration(size: Size(20, 20)), // Set the size of the marker
      'assets/taxi.png', // Path to the custom marker image
    );
  }
  Future<void> _setbusMarker() async {
    bus = await BitmapDescriptor.asset(
      height: 20,
      width: 20,
      const ImageConfiguration(size: Size(20, 20)), // Set the size of the marker
      'assets/bus.png', // Path to the custom marker image
    );
  }
  Future<void> _setmotorbikeMarker() async {
    motorbike = await BitmapDescriptor.asset(
      height: 20,
      width: 20,
      const ImageConfiguration(size: Size(20, 20)), // Set the size of the marker
      'assets/motorbike.png', // Path to the custom marker image
    );
  }
  Future<void> _settruckMarker() async {
    truck = await BitmapDescriptor.asset(
      height: 20,
      width: 20,
      const ImageConfiguration(size: Size(20, 20)), // Set the size of the marker
      'assets/truck.png', // Path to the custom marker image
    );
  }
  Future<void> _settuktukMarker() async {
    tuktuk = await BitmapDescriptor.asset(
      height: 20,
      width: 20,
      const ImageConfiguration(size: Size(20, 20)), // Set the size of the marker
      'assets/tuktuk.png', // Path to the custom marker image
    );
  }
  Future<void> _setmatatuMarker() async {
    matatu = await BitmapDescriptor.asset(
      height: 20,
      width: 20,
      const ImageConfiguration(size: Size(20, 20)),
      // Set the size of the marker
      'assets/matatu.png', // Path to the custom marker image
    );
  }
    Future<void> _setpassengerMarker() async {
      passenger = await BitmapDescriptor.asset(
        height: 20,
        width: 20,
        const ImageConfiguration(size: Size(20, 20)),
        // Set the size of the marker
        'assets/passenger.png', // Path to the custom marker image
      );
      _addMarkers();
  }
  List<Marker> markers = [];
  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentPosition; // Set initial position
    _currentPosition1 = LatLng(widget.currentPosition.latitude-0.008, widget.currentPosition.longitude-0.008);
    _currentPosition2 = LatLng(widget.currentPosition.latitude+0.008, widget.currentPosition.longitude+0.008);
    _currentPosition3 = LatLng(widget.currentPosition.latitude-0.016, widget.currentPosition.longitude-0.016);
    _currentPosition4 = LatLng(widget.currentPosition.latitude+0.016, widget.currentPosition.longitude+0.016);
    _currentPosition5 = LatLng(widget.currentPosition.latitude-0.03, widget.currentPosition.longitude-0.03);
    _currentPosition6 = LatLng(widget.currentPosition.latitude+0.03, widget.currentPosition.longitude+0.03);
    _checkPermissionsAndStartListener();
    _setmatatuMarker();
    _settuktukMarker();
    _settruckMarker();
    _setmotorbikeMarker();
    _setbusMarker();
    _settaxiMarker();
    _setpassengerMarker();
     // Call to populate the markers list
  }

  void _addMarkers() {
    markers.addAll([
      if (_currentPosition != null)
        Marker(
          markerId: const MarkerId("currentLocation"),
          icon: passenger ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: _currentPosition!,
        ),
      Marker(
        markerId: const MarkerId("taxiLocation"),
        icon: taxi ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        position: _currentPosition1!,
      ),
      Marker(
        markerId: const MarkerId("motorbikeLocation"),
        icon: motorbike ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: _currentPosition2!,
      ),
      Marker(
        markerId: const MarkerId("busLocation"),
        icon: bus ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        position: _currentPosition3!,
      ),
      Marker(
        markerId: const MarkerId("matatuLocation"),
        icon: matatu ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: _currentPosition4!,
      ),
      Marker(
        markerId: const MarkerId("truckLocation"),
        icon: truck ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        position: _currentPosition5!,
      ),
      Marker(
        markerId: const MarkerId("tuktukLocation"),
        icon: tuktuk ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: _currentPosition6!,
      ),
    ]);
  }
  // Check for permissions and start the location listener
  Future<void> _checkPermissionsAndStartListener() async {
    await _getCurrentLocation(); // Get the user's initial location
    _locationService.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      });

      // Move the camera to the new position when the location updates
      if (_mapController != null) {
        _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
      }
    });
  }

  // Get initial location
  Future<void> _getCurrentLocation() async {
    LocationData _locationData = await _locationService.getLocation();
    LatLng initialPosition = LatLng(_locationData.latitude!, _locationData.longitude!);
    LatLng initialPosition1 = LatLng(_locationData.latitude!-0.008, _locationData.longitude!-0.008);
    LatLng initialPosition2 = LatLng(_locationData.latitude!+0.008, _locationData.longitude!+0.008);

    setState(() {
      _currentPosition = initialPosition;
      _currentPosition1 = initialPosition1;
      _currentPosition2 = initialPosition2;
    });

    // Move the camera to the user's current location after the map is created
    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: _currentPosition!,
        zoom: 13,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.currentPosition, // Use the initial position
                  zoom: 13,
                ),
                markers: Set<Marker>.of(markers),
                myLocationEnabled: true, // Enables the blue dot for user's location
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller; // Save the controller instance

                  // Move camera to current position once map is ready
                  if (_currentPosition != null) {
                    _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
                  }
                },
              ),
            ),
            if (isLoading)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
