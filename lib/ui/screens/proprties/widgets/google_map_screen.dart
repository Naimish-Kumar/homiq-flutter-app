import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {

  const GoogleMapScreen({
    required this.latitude, required this.longitude, required this.kInitialPlace, required this.controller, super.key,
  });
  final double latitude;
  final double longitude;
  final CameraPosition kInitialPlace;
  final Completer<GoogleMapController> controller;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('location'),
        position: LatLng(widget.latitude, widget.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: widget.kInitialPlace,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        if (!widget.controller.isCompleted) {
          widget.controller.complete(controller);
        }
      },
    );
  }
}
