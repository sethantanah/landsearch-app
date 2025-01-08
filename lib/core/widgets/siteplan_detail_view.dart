// lib/features/land_search/presentation/pages/map_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'custome_info_window.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  LandModel? selectedLand;
  Offset? infoWindowPosition;
  final List<LandModel> lands = []; // Initialize with your data

  // Initial camera position (Ghana)
  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(5.6037, -0.1870),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialPosition,
          onMapCreated: (GoogleMapController controller) {
            setState(() {
              mapController = controller;
            });
          },
          markers: Set<Marker>.of(
            lands.map(
                  (land) => Marker(
                markerId: MarkerId(land.id),
                position: LatLng(
                  land.plotInfo.latitude,
                  land.plotInfo.longitude,
                ),
                onTap: () => _handleMarkerTap(land),
              ),
            ),
          ),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          onCameraMove: (_) {
            // Close info window when map moves
            _closeInfoWindow();
          },
        ),
        if (selectedLand != null && infoWindowPosition != null)
          CustomInfoWindow(
            land: selectedLand!,
            position: infoWindowPosition!,
            onClose: _closeInfoWindow,
            onViewDetails: () => _handleViewDetails(selectedLand!),
          ),
      ],
    );
  }

  void _handleMarkerTap(LandModel land) {
    // Get the screen coordinates of the marker
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);

    setState(() {
      selectedLocation = LatLng(
        land.plotInfo.latitude,
        land.plotInfo.longitude,
      );
      selectedLand = land;
      infoWindowPosition = position;
    });
  }

  void _closeInfoWindow() {
    setState(() {
      selectedLand = null;
      infoWindowPosition = null;
    });
  }

  void _handleViewDetails(LandModel land) {
    _closeInfoWindow();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LandDetailsPage(land: land),
      ),
    );
  }
}

// lib/features/land_search/models/land_model.dart
class LandModel {
  final String id;
  final PlotInfo plotInfo;
  final double latitude;
  final double longitude;

  LandModel({
    required this.id,
    required this.plotInfo,
    required this.latitude,
    required this.longitude,
  });

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['id'] as String,
      plotInfo: PlotInfo.fromJson(json['plot_info']),
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}

class PlotInfo {
  final String? plotNumber;
  final double? area;
  final String? metric;
  final String? locality;
  final String? district;
  final String? region;
  final String? date;
  final double latitude;
  final double longitude;

  PlotInfo({
    this.plotNumber,
    this.area,
    this.metric,
    this.locality,
    this.district,
    this.region,
    this.date,
    required this.latitude,
    required this.longitude,
  });

  factory PlotInfo.fromJson(Map<String, dynamic> json) {
    return PlotInfo(
      plotNumber: json['plot_number'] as String?,
      area: json['area'] as double?,
      metric: json['metric'] as String?,
      locality: json['locality'] as String?,
      district: json['district'] as String?,
      region: json['region'] as String?,
      date: json['date'] as String?,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}

// lib/features/land_search/presentation/pages/land_details_page.dart
class LandDetailsPage extends StatelessWidget {
  final LandModel land;

  const LandDetailsPage({
    super.key,
    required this.land,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plot ${land.plotInfo.plotNumber ?? ''}'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implement details view
            Text('Details coming soon...'),
          ],
        ),
      ),
    );
  }
}

// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF424242);
// Add more colors as needed
}