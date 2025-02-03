import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landsearch_platform/features/land_search/presentation/widgets/site_plan_details.dart';
import 'package:landsearch_platform/core/theme/app_colors.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:landsearch_platform/features/land_search/presentation/pages/document_search_page.dart';

class SearchablePlotTable extends StatefulWidget {
  final List<ProcessedLandData> plots;
  final Function(ProcessedLandData data) saveSitePlan;
  final Function(ProcessedLandData data) updateSitePlan;
  final Function(ProcessedLandData data)? deleteSitePlan;
  final Function(List<ProcessedLandData> data) getCameraPosition;
  final CameraPosition cameraPosition;
  final Widget? mapView;
  final bool hideSearchBar;
  final bool showEditButton;

  const SearchablePlotTable(
      {super.key,
      required this.plots,
      required this.updateSitePlan,
      required this.saveSitePlan,
      required this.getCameraPosition,
      required this.cameraPosition,
      this.mapView,
      this.hideSearchBar = false,
      this.showEditButton = true,
      this.deleteSitePlan});

  @override
  State<SearchablePlotTable> createState() => _SearchablePlotTableState();
}

class _SearchablePlotTableState extends State<SearchablePlotTable> {
  late List<ProcessedLandData> filteredPlots;
  final TextEditingController _searchController = TextEditingController();
  bool _isTableView = true; // Toggle between table and map view

  GoogleMapController? mapController;
  BitmapDescriptor? dotMarker;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    filteredPlots = widget.plots;
    _searchController.addListener(_filterPlots);
    _createDotMarker();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlots() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPlots = widget.plots.where((plot) {
        return plot.plotInfo.locality?.toLowerCase().contains(query) == true ||
            plot.plotInfo.district?.toLowerCase().contains(query) == true ||
            plot.plotInfo.region?.toLowerCase().contains(query) == true ||
            plot.id?.toLowerCase().contains(query) == true;
      }).toList();
    });
  }

  void _toggleView() {
    setState(() {
      _isTableView = !_isTableView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar and Document Search Button
          widget.hideSearchBar == true
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText:
                                'Search by Locality, District, Region, or ID',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                const DocumentSearchDashboard(),
                          );
                        },
                        icon: const Icon(Icons.file_copy_outlined,
                            size: 18, color: Colors.white),
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
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
          // Table or Map View
          Expanded(
            child: _isTableView
                ? Stack(
                    children: [
                      _buildTableView(),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _buildMapControl(
                          icon: Icons.map,
                          onTap: _toggleView,
                        ),
                      )
                    ],
                  )
                : _buildMapView(mapView: widget.mapView),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.0),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          source: PlotDataSource(filteredPlots, context, _showPlotDetails),
          columns: [
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Locality',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'District',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Region',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Area',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],

          // rowsPerPage: 5,
          showEmptyRows: false,
          showCheckboxColumn: false,
          horizontalMargin: 24,
          headingRowHeight: 56,
        ),
      ),
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

  Widget _buildMapView({Widget? mapView}) {
    // Placeholder for map view (replace with your map implementation)
    return Stack(
      children: [
        mapView ??
            GoogleMap(
              initialCameraPosition: widget.cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                  isMapReady = true;
                });
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              markers: _buildMarkers(widget.plots),
              polygons: _buildPolygons(widget.plots),
            ),
        if (mapView != null)
          Positioned(
            right: 16,
            top: 16,
            child: _buildMapControl(
              icon: Icons.map,
              onTap: _toggleView,
            ),
          )
        // Enhanced Map Controls
       else
         Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.add,
                onTap: () =>
                    mapController?.animateCamera(CameraUpdate.zoomIn()),
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.remove,
                onTap: () =>
                    mapController?.animateCamera(CameraUpdate.zoomOut()),
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.my_location,
                onTap: () => mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(widget.cameraPosition),
                ),
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.map,
                onTap: _toggleView,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPlotDetails(BuildContext context, ProcessedLandData plot) {
    showDialog(
      context: context,
      builder: (context) {
        return SitePlanDetails(
          sitePlans: [plot],
          updateSitePlan: widget.updateSitePlan,
          saveSitePlan: widget.saveSitePlan,
          getCameraPosition: widget.getCameraPosition,
          showEditButton: widget.showEditButton,
          deleteSitePlan: widget.deleteSitePlan,
        );
      },
    );
  }

  Set<Marker> _buildMarkers(List<ProcessedLandData> data) {
    Set<Marker> markers = {};
    for (var land in data) {
      // Check if point_list exists and is not empty
      if (land.pointList.isNotEmpty) {
        // Create markers for each point in the point list
        markers.addAll(
          land.pointList.map((point) => Marker(
                markerId: MarkerId('${land.id}_${point.hashCode}'),
                position: LatLng(point.latitude ?? 0, point.longitude ?? 0),
                icon: dotMarker ?? BitmapDescriptor.defaultMarker,
                anchor: const Offset(0.5, 0.5),
                // Center of the marker
                zIndex: 2,
                // Ensure markers appear above polygon
                // Make marker flat against the map
                flat: true,
                onTap: () {
                  _showPlotDetails(context, land);
                },
              )),
        );
      }
    }

    return markers;
  }

  // Add this method to create polygons
  Set<Polygon> _buildPolygons(List<ProcessedLandData> data) {
    return data
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
              _showPlotDetails(context, land);
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

class PlotDataSource extends DataTableSource {
  final List<ProcessedLandData> plots;
  final BuildContext context;
  Function(BuildContext, ProcessedLandData) showPlotDetails;

  PlotDataSource(this.plots, this.context, this.showPlotDetails);

  @override
  DataRow getRow(int index) {
    final plot = plots[index];
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.primary.withOpacity(0.05);
        }
        return null;
      }),
      cells: [
        plot.plotInfo.isSearchPlan == true ? _buildDataCell("${plot.id} - Searched Plan", textColor: Colors.redAccent) :  _buildDataCell(plot.id ?? 'N/A'),
        _buildDataCell(plot.plotInfo.locality ?? 'N/A'),
        _buildDataCell(plot.plotInfo.district ?? 'N/A'),
        _buildDataCell(plot.plotInfo.region ?? 'N/A'),
        _buildDataCell('${plot.plotInfo.area} ${plot.plotInfo.metric}'),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.remove_red_eye),
                color: AppColors.primary,
                onPressed: () => showPlotDetails(context, plot),
                hoverColor: AppColors.primary.withOpacity(0.1),
                splashRadius: 24,
                tooltip: 'View Details',
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataCell _buildDataCell(String text, {Color? textColor}) {
    return DataCell(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor ?? Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => plots.length;

  @override
  int get selectedRowCount => 0;
}
