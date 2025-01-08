// lib/features/land_search/presentation/pages/explorer_dashboard.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';
import '../../data/models/app_status.dart';
import '../../data/models/site_plan_model.dart';
import '../widgets/land_details_card.dart';
import '../widgets/region_card.dart';
import 'document_search_page.dart';

class ExplorerDashboard extends StatefulWidget {
  const ExplorerDashboard({super.key});

  @override
  State<ExplorerDashboard> createState() => _ExplorerDashboardState();
}

class _ExplorerDashboardState extends State<ExplorerDashboard> {
  final LandSearchController _landSearchController = Get.find();
  GoogleMapController? mapController;
  bool isMapReady = false;
  BitmapDescriptor? dotMarker;
  int selectedRegionIndex = -1;
  ProcessedLandData? selectedSitePlan;

  @override
  void initState() {
    super.initState();
    // Initialize search with default parameters if needed
    _landSearchController.searchLands();
    _createDotMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Enhanced Region Cards
                Obx(() {
                  if (_landSearchController.regionsData.isEmpty) {
                    // return const SizedBox();
                    return const SizedBox(
                      height: 0,
                      width: 0,
                    );
                  } else {
                    return Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _landSearchController.regionsData[0].length,
                        itemBuilder: (context, index) {
                          return RegionCard(
                            name: _landSearchController
                                .regionsData[0][index].name,
                            image: _landSearchController
                                .regionsData[0][index].image,
                            activePlots: _landSearchController
                                .regionsData[0][index].activePlots,
                            onTap: () {
                              _landSearchController.searchLands(
                                  match: _landSearchController
                                      .regionsData[0][index].name
                                      .toLowerCase());
                            },
                          );
                        },
                      ),
                    );
                  }
                }),

                // Enhanced Search Bar
                Obx(() {
                  if (_landSearchController.regionsData.isEmpty) {
                    // return const SizedBox();
                    return const SizedBox(
                      height: 0,
                      width: 0,
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(child: _buildSearchBar()),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // _landSearchController.setActivePage(2);
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) =>
                                      const DocumentSearchDashboard());
                            },
                            icon: const Icon(Icons.file_copy_outlined,
                                size: 18), // Icon for the button
                            label: const Text(
                              "Document Search",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              maximumSize: const Size(213, 50),
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // Text color
                              elevation: 5, // Shadow
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }),

                // Enhanced Map View
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    width: Size.infinite.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Obx(() {
                      // Handle different search statuses
                      switch (_landSearchController.status.value) {
                        case LandSearchStatus.loading:
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        case LandSearchStatus.error:
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_landSearchController.errorMessage.value),
                                ElevatedButton(
                                  onPressed: () =>
                                      _landSearchController.clearError(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        case LandSearchStatus.noConnection:
                          return const Center(
                            child:
                                Center(child: Text('No internet connection')),
                          );
                        case LandSearchStatus.success:
                          return Row(
                            children: [
                              Visibility(
                                  visible: selectedSitePlan != null,
                                  child: SizedBox(
                                    width: 400,
                                    child: LandDetailsInfoWidget(
                                      data: selectedSitePlan,
                                      showEditButton: true,
                                      onSave: (ProcessedLandData update) async {
                                        final updatedData =
                                            await _landSearchController
                                                .updateSitePlanGeneral(update);

                                        if (updatedData != null) {
                                          await _landSearchController
                                              .saveSitePlanGeneral(updatedData);

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Changes saved successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  )),
                              Expanded(
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      initialCameraPosition:
                                          _landSearchController
                                              .initialCameraPosition.value!,
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        setState(() {
                                          mapController = controller;
                                          isMapReady = true;
                                        });
                                      },
                                      myLocationEnabled: false,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      mapType: MapType.normal,
                                      markers: _buildMarkersFromSearchResults(
                                          _landSearchController),
                                      polygons:
                                          _buildPolygonsFromSearchResults(),
                                    ),
                                    if (!isMapReady)
                                      const Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary),
                                      ),

                                    // Enhanced Map Controls
                                    Positioned(
                                      right: 16,
                                      bottom: 16,
                                      child: Column(
                                        children: [
                                          _buildMapControl(
                                            icon: Icons.add,
                                            onTap: () =>
                                                mapController?.animateCamera(
                                                    CameraUpdate.zoomIn()),
                                          ),
                                          SizedBox(height: 8),
                                          _buildMapControl(
                                            icon: Icons.remove,
                                            onTap: () =>
                                                mapController?.animateCamera(
                                                    CameraUpdate.zoomOut()),
                                          ),
                                          SizedBox(height: 8),
                                          _buildMapControl(
                                            icon: Icons.my_location,
                                            onTap: () =>
                                                mapController?.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  _landSearchController
                                                      .initialCameraPosition
                                                      .value!),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        default:
                          return const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Your siteplan database is empty!")
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // ElevatedButton.icon(
                              //   onPressed: () {
                              //     _landSearchController.setActivePage(0);
                              //   },
                              //   icon: const Icon(Icons.upload_file_outlined,
                              //       size: 18), // Icon for the button
                              //   label: const Text(
                              //     "Upload Documents",
                              //     style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold),
                              //   ),
                              //   style: ElevatedButton.styleFrom(
                              //     maximumSize: const Size(213, 50),
                              //     foregroundColor: Colors.white,
                              //     backgroundColor: AppColors.primary,
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 24, vertical: 20),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //     // Text color
                              //     elevation: 5, // Shadow
                              //   ),
                              // )
                            ],
                          ));
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard({
    required RegionData region,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 12),
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                region.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${region.activePlots} active plots',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name or plot ID',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        // Implement search logic
        _landSearchController.searchLands(match: value);
      },
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Set<Marker> _buildMarkersFromSearchResults(LandSearchController controller) {
    Set<Marker> markers = {};
    for (var land in _landSearchController.searchResults) {
      // Check if point_list exists and is not empty
      if (land.pointList.isNotEmpty) {
        // Create markers for each point in the point list
        markers.addAll(
          land.pointList.map((point) => Marker(
                markerId: MarkerId('${land.id}_${point.hashCode}'),
                position: LatLng(point.latitude ?? 0, point.longitude ?? 0),
                infoWindow: InfoWindow(
                  title: land.plotInfo.plotNumber != ''
                      ? "Plot Number ${land.plotInfo.plotNumber}"
                      : "${land.plotInfo.locality}",
                  snippet: _buildPlotInfoSnippet(land),
                ),
                icon: dotMarker ?? BitmapDescriptor.defaultMarker,
                anchor: const Offset(0.5, 0.5),
                // Center of the marker
                zIndex: 2,
                // Ensure markers appear above polygon
                // Make marker flat against the map
                flat: true,
                onTap: () {
                  // Show detailed land information
                  // _showLandDetailsBottomSheet(land);
                },
              )),
        );
      }
    }

    return markers;
  }

// Helper method to build a detailed snippet for the info window
  String _buildPlotInfoSnippet(dynamic land) {
    final plotInfo = land.plotInfo;
    return '''
       Locality: ${plotInfo?.locality ?? 'N/A'} | \n
        District: ${plotInfo?.district ?? 'N/A'} | \n
        Region: ${plotInfo?.region ?? 'N/A'} | \n
        Plot Number: ${plotInfo?.plotNumber ?? 'N/A'} |  \n
        Area: ${plotInfo?.area ?? 0} ${plotInfo?.metric ?? ''} | \n
          ''';
  }

// Method to show a bottom sheet with full land details
  void _showLandDetailsBottomSheet(dynamic land) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plot Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                  'Plot Number', land.plotInfo?.plotNumber ?? 'N/A'),
              _buildDetailRow('Locality', land.plotInfo?.locality ?? 'N/A'),
              _buildDetailRow('District', land.plotInfo?.district ?? 'N/A'),
              _buildDetailRow('Region', land.plotInfo?.region ?? 'N/A'),
              _buildDetailRow('Area',
                  '${land.plotInfo?.area ?? 0} ${land.plotInfo?.metric ?? ''}'),
              _buildDetailRow('Date', land.plotInfo?.date ?? 'N/A'),
              _buildDetailRow(
                  'Surveyors Name', land.plotInfo?.surveyorsName ?? 'N/A'),
              const SizedBox(height: 16),
              const Text(
                'Owners',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              ...?land.plotInfo?.owners?.map((owner) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(owner),
                  )),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

// Helper method to build a detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to create polygons
  Set<Polygon> _buildPolygonsFromSearchResults() {
    return _landSearchController.searchResults
        .where((land) => land.pointList.isNotEmpty)
        .map((land) => Polygon(
            polygonId: PolygonId(land.id ?? 'polygon'),
            points: land.pointList
                .map((point) =>
                    LatLng(point.latitude ?? 0, point.longitude ?? 0))
                .toList(),
            strokeColor: AppColors.primary.withOpacity(0.7),
            fillColor: AppColors.primary.withOpacity(0.2),
            strokeWidth: 2,
            onTap: () {
              setState(() {
                selectedSitePlan = land;
              });
              // _showLandDetailsBottomSheet(land);
            }))
        .toSet();
  }

  Future<void> _createDotMarker() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    // Make size smaller for more precise placement
    const size = Size(8, 8); // Reduced from 16,16

    CircleMarkerPainter(
      color: AppColors.primary,
      radius: 3, // Smaller radius
      withBorder: true,
      borderWidth: 1, // Add border width control
    ).paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      final bytes = byteData.buffer.asUint8List();
      setState(() {
        dotMarker = BitmapDescriptor.bytes(bytes);
      });
    }
  }
}

class CircleMarkerPainter extends CustomPainter {
  final Color color;
  final double radius;
  final bool withBorder;
  final double borderWidth;

  CircleMarkerPainter({
    this.color = Colors.blue,
    this.radius = 3, // Smaller default radius
    this.withBorder = true,
    this.borderWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (withBorder) {
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + borderWidth, borderPaint);
    }

    // Draw main circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
