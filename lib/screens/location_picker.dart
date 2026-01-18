import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(6.9271, 79.8612),
          zoom: 14,
        ),
        onTap: (latLng) {
          setState(() => selected = latLng);
        },
        markers: selected == null
            ? {}
            : {
                Marker(markerId: const MarkerId("m1"), position: selected!)
              },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, selected),
        child: const Icon(Icons.check),
      ),
    );
  }
}
