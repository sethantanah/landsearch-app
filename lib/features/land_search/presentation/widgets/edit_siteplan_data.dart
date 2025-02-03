// lib/features/land_search/presentation/pages/plot_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:landsearch_platform/features/land_search/presentation/widgets/map_view.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';
import '../../data/models/site_plan_model.dart';
import 'custom_map.dart';

class PlotForm extends StatefulWidget {
  final ProcessedLandData landData;
  late String? title = "";
  late String? actionText = "Save Changes";
  late bool? validate = true;
  final Function(ProcessedLandData) onSave;
  final Function(ProcessedLandData) onUpdate;
  final Function(ProcessedLandData)? onDelete;

  PlotForm(
      {super.key,
      required this.landData,
      required this.onSave,
      this.validate,
      this.title,
      this.actionText,
      required this.onUpdate,
      this.onDelete});

  @override
  State<PlotForm> createState() => _PlotFormState();
}

class _PlotFormState extends State<PlotForm>
    with SingleTickerProviderStateMixin {
  final LandSearchController _landSearchController = Get.find();
  final MapController myMapController = MapController();

  late ProcessedLandData _landData;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Expansion states
  bool isPlotInfoExpanded = true;
  bool isSurveyPointsExpanded = false;
  bool isBoundaryPointsExpanded = false;

  bool refreshMap = false;

  @override
  void initState() {
    super.initState();
    _landData = widget.landData;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController.index == 2) {
      // if(widget.validate == false){
      //   setState(() {
      //     _landData.id = "search-site-plan";
      //   });
      // }
      _formKey.currentState!.save();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plot Details'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: ElevatedButton(
              onPressed: () {
                _saveForm(context);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0),
              child: Text(
                widget.actionText!,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            ),
          ),

         if(widget.validate == true)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: ElevatedButton(
              onPressed: () {
                _deleteSitePlan(context);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0),
              child: const Text(
                "Delete",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline),
              text: 'Plot Info',
            ),
            Tab(
              icon: Icon(Icons.map_outlined),
              text: 'Survey Points',
            ),
            // Tab(
            //   icon: Icon(Icons.area_chart_outlined),
            //   text: 'Boundary',
            // ),
            Tab(
              icon: Icon(Icons.preview_outlined),
              text: 'Preview',
            ),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildExpandableSection(
                          title: 'Plot Information',
                          isExpanded: true,
                          onExpansionChanged: (value) =>
                              setState(() => isPlotInfoExpanded = value),
                          child: Column(
                            children: [
                              _buildPlotInfoSection(),
                              _buildOwnersField(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildExpandableSection(
                          title: 'Survey Points',
                          isExpanded: true,
                          onExpansionChanged: (value) =>
                              setState(() => isBoundaryPointsExpanded = value),
                          child: _buildSurveyPointsSection(),
                        ),
                      ],
                    ),
                  ),
                  // SingleChildScrollView(
                  //   padding: const EdgeInsets.all(16),
                  //   child: Column(
                  //     children: [
                  //       _buildExpandableSection(
                  //         title: 'Boundary Points',
                  //         isExpanded: true,
                  //         onExpansionChanged: (value) =>
                  //             setState(() => isBoundaryPointsExpanded = value),
                  //         child: _buildBoundaryPointsSection(),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Expanded(child: MapPreview(data: _landData))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required Widget child,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          childrenPadding: const EdgeInsets.all(16),
          children: [child],
        ),
      ),
    );
  }

  Widget _buildPlotInfoSection() {
    List<String> dropDownItems = ['Acres', 'Hectares', 'Square Meters'];
    String dropDownValue = (_landData.plotInfo.metric ?? '').toString();

    if (!dropDownItems.contains(dropDownValue)) {
      dropDownValue = 'Hectares';
    }

    return GridView.count(
      crossAxisCount: 3, // Number of columns
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      childAspectRatio: 7, // Adjust this to control height of grid items
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildFormField(
          label: 'Plot Number',
          value: _landData.plotInfo.plotNumber,
          onChanged: (value) {
            _landData.plotInfo.plotNumber = value;
          },
          validator: (value) => (widget.validate! && (value?.isEmpty ?? true))
              ? 'Required'
              : null,
        ),
        _buildFormField(
          label: 'Area',
          value: _landData.plotInfo.area.toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) =>
              _landData.plotInfo.area = double.tryParse(value) ?? 0,
          validator: (value) =>
              (widget.validate! && ((double.tryParse(value ?? '') ?? 0) <= 0))
                  ? 'Invalid area'
                  : null,
        ),
        _buildDropdownField(
          label: 'Metric',
          value: dropDownValue,
          items: dropDownItems,
          onChanged: (value) =>
              setState(() => _landData.plotInfo.metric = value!),
        ),
        _buildFormField(
          label: 'Locality',
          value: _landData.plotInfo.locality,
          onChanged: (value) => _landData.plotInfo.locality = value,
          validator: (value) => (widget.validate! && (value?.isEmpty ?? true))
              ? 'Required'
              : null,
        ),
        _buildFormField(
          label: 'District',
          value: _landData.plotInfo.district,
          onChanged: (value) => _landData.plotInfo.district = value,
          validator: (value) => (widget.validate! && (value?.isEmpty ?? true))
              ? 'Required'
              : null,
        ),
        _buildFormField(
          label: 'Region',
          value: _landData.plotInfo.region,
          onChanged: (value) => _landData.plotInfo.region = value,
          validator: (value) => (widget.validate! && (value?.isEmpty ?? true))
              ? 'Required'
              : null,
        ),

        _buildFormField(
          label: 'Date',
          value: _landData.plotInfo.date,
          onChanged: (value) => _landData.plotInfo.date = value,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
        _buildFormField(
          label: 'Scale',
          value: _landData.plotInfo.scale,
          onChanged: (value) => _landData.plotInfo.scale = value,
        ),
        // _buildFormField(
        //   label: 'Other Location Details',
        //   value: _landData.plotInfo.otherLocationDetails,
        //   onChanged: (value) => _landData.plotInfo.otherLocationDetails = value,
        //   maxLines: 2,
        // ),
        _buildFormField(
          label: 'Surveyor\'s Name',
          value: _landData.plotInfo.surveyorsName,
          onChanged: (value) => _landData.plotInfo.surveyorsName = value,
          validator: (value) => (widget.validate! && (value?.isEmpty ?? true))
              ? 'Required'
              : null,
        ),
        _buildFormField(
          label: 'Surveyor\'s Location',
          value: _landData.plotInfo.surveyorsLocation,
          onChanged: (value) => _landData.plotInfo.surveyorsLocation = value,
          maxLines: 2,
        ),
        _buildFormField(
          label: 'Surveyor\'s Reg Number',
          value: _landData.plotInfo.surveyorsRegNumber,
          onChanged: (value) => _landData.plotInfo.surveyorsRegNumber = value,
          validator: (value) => (widget.validate! && (value?.isEmpty ?? true))
              ? 'Required'
              : null,
        ),
        _buildFormField(
          label: 'Regional Number',
          value: _landData.plotInfo.regionalNumber,
          onChanged: (value) => _landData.plotInfo.regionalNumber = value,
        ),
        _buildFormField(
          label: 'Reference Number',
          value: _landData.plotInfo.referenceNumber,
          onChanged: (value) => _landData.plotInfo.referenceNumber = value,
        ),
      ],
    );
  }

  Widget _buildOwnersField() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Only take needed height
        children: [
          GridView.builder(
            shrinkWrap: true, // Important for nested scrolling
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: _landData.plotInfo.owners.length,
            itemBuilder: (context, index) {
              final owner = _landData.plotInfo.owners[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildFormField(
                      label: '',
                      value: owner,
                      onChanged: (value) {
                        setState(() {
                          _landData.plotInfo.owners[index] = value;
                        });
                      },
                      validator: (value) =>
                          (widget.validate! && (value?.isEmpty ?? true))
                              ? 'Required'
                              : null,
                    )),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          _landData.plotInfo.owners.removeAt(index);
                        });
                      },
                      constraints:
                          const BoxConstraints(), // Minimize icon button size
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 7,
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Owner'),
            onPressed: () {
              setState(() {
                _landData.plotInfo.owners.add('');
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyPointsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Point'),
              onPressed: _addSurveyPoint,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // Ensures GridView gets proper constraints
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _landData.surveyPoints.length,
                itemBuilder: (context, index) => _buildSurveyPointCard(index),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 2,
                ),
              ),
            ),
            //_formKey.currentState!.save();
            Stack(children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.4,
                child: CoordinatesMap(
                  coordinates: [
                    _landData.pointList
                        .toList()
                        .map((point) => LatLng(point.latitude, point.longitude))
                        .toList()
                  ],
                  initialZoom: 17.0,
                  borderRadius: 16,
                ),
              ),
              Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        child: InkWell(
                          onTap: () {
                            _refreshMap();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: refreshMap == false
                                ? const Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: AppColors.primary,
                                  )
                                : const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ])
          ],
        )
      ],
    );
  }

  Widget _buildSurveyPointCard(int index) {
    final point = _landData.surveyPoints[index];
    final TextEditingController xtextController =
        TextEditingController.fromValue(
            TextEditingValue(text: point.originalCoords?.x.toString() ?? '0'));
    final TextEditingController ytextController =
        TextEditingController.fromValue(
            TextEditingValue(text: point.originalCoords?.y.toString() ?? '0'));
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Point ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      _landData.surveyPoints.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Point Name',
              value: point.pointName,
              onChanged: (value) => point.pointName = value,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: '',
                    textController: xtextController,
                    value: point.originalCoords?.x.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        point.originalCoords?.x = double.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _buildFormField(
                    label: '',
                    value: point.originalCoords?.y.toString(),
                    keyboardType: TextInputType.number,
                    textController: ytextController,
                    onChanged: (value) =>
                        point.originalCoords?.y = double.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  onPressed: () {
                    var coordsAtIndex = _landData.surveyPoints[index];
                    final lat = coordsAtIndex.originalCoords?.x;
                    final lon = coordsAtIndex.originalCoords?.y;

                    setState(() {
                      point.originalCoords?.x = lon!;
                      point.originalCoords?.y = lat!;
                      xtextController.value =
                          TextEditingValue(text: lon.toString());
                      ytextController.value =
                          TextEditingValue(text: lat.toString());
                      _landData.surveyPoints[index].originalCoords?.x = lon!;
                      _landData.surveyPoints[index].originalCoords?.y = lat!;
                    });
                  },
                  icon: const Icon(Icons.swap_horizontal_circle_outlined),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoundaryPointsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // const Text(
            //   'Points',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Point'),
              onPressed: _addBoundaryPoint,
            ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _landData.boundaryPoints.length,
          itemBuilder: (context, index) => _buildBoundaryPointCard(index),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBoundaryPointCard(int index) {
    final point = _landData.boundaryPoints[index];
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Point ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      _landData.boundaryPoints.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Point',
              value: point.point,
              onChanged: (value) => point.point = value,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: '',
                    value: point.northing.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        point.northing = double.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    label: '',
                    value: point.easting.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        point.easting = double.tryParse(value) ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String? value,
    required Function(String) onChanged,
    TextEditingController? textController,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    Widget? prefixIcon,
    int? maxLines,
    bool isPassword = false,
  }) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: TextFormField(
          key: Key("$label$value"),
          controller: textController,
          initialValue: textController == null ? value : null,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            label: Text(label),
            hintText: 'Enter $label',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines ?? 1,
          onChanged: onChanged,
          obscureText: isPassword,
        ));
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items
            .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _landData.plotInfo.date =
            "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  void _addSurveyPoint() {
    setState(() {
      _landData.surveyPoints.add(
        SurveyPoint(
          pointName: '',
          originalCoords: OriginalCoords(x: 0, y: 0, refPoint: false),
          convertedCoords: ConvertedCoords(latitude: 0, longitude: 0),
          nextPoint: NextPoint(),
        ),
      );
    });
  }

  void _addBoundaryPoint() {
    setState(() {
      _landData.boundaryPoints.add(
        BoundaryPoint(
          point: '',
          northing: 0,
          easting: 0,
          latitude: 0,
          longitude: 0,
        ),
      );
    });
  }

  Future<void> _saveForm(BuildContext parentContext) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call the save callback
      await widget.onSave(_landData);

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(parentContext);
      }

      // Show success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Changes saved successfully'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSitePlan(BuildContext parentContext) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.redAccent,
        ),
      ),
    );

    // Call the save callback
    await widget.onDelete!(_landData);

    // Hide loading indicator
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(parentContext);
    }
  }

  Future<void> _refreshMap() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        refreshMap = true;
      });

      final results =
          await _landSearchController.reComputeCoordinates(_landData);

      if (results != null) {
        setState(() {
          _landData = results;
          refreshMap = false;
        });
      } else {
        setState(() {
          refreshMap = false;
        });
      }
    } else {}
  }
}
