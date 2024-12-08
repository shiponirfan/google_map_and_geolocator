import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Position? currentLocation;
  GoogleMapController? googleMapController;

  @override
  void initState() {
    super.initState();
    getUserCurrentPosition();
  }

  Future<void> getUserCurrentPosition() async {
    final appPermission = await isAppLocationGranted();
    if (appPermission) {
      final getGPSPermission = await isGPSServiceEnable();
      if (getGPSPermission) {
        // Position position = await Geolocator.getCurrentPosition();
        Geolocator.getPositionStream(
                locationSettings:
                    const LocationSettings(timeLimit: Duration(seconds: 10)))
            .listen(
          (position) {
            currentLocation = position;
            setState(() {});
            getUserCurrentLocation();
          },
        );
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final requestAppLocation = await requestAppLocationPermission();
      if (requestAppLocation) {
        getUserCurrentPosition();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isAppLocationGranted() async {
    LocationPermission isGranted = await Geolocator.checkPermission();
    if (isGranted == LocationPermission.always ||
        isGranted == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestAppLocationPermission() async {
    LocationPermission requestPermission = await Geolocator.requestPermission();
    if (requestPermission == LocationPermission.always ||
        requestPermission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isGPSServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  void getUserCurrentLocation() {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 16,
          target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Tracker'),
      ),
      body: currentLocation == null
          ? Center(
              child: Image.asset(
                'assets/images/map_icon.png',
                width: 120,
              ),
            )
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                zoom: 8,
                target: LatLng(
                  24.27037857877728,
                  90.27157335388725,
                ),
              ),
              onMapCreated: (controller) {
                googleMapController = controller;
              },
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId('User Current Location'),
                  position: LatLng(
                      currentLocation!.latitude, currentLocation!.longitude),
                )
              },
            ),
    );
  }
}
