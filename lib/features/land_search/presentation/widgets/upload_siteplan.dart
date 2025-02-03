import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';

import 'package:flutter/material.dart';

import '../../../../core/api/simple_upload_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final LandSearchController _landSearchController = Get.find();
  List<PlatformFile> _files = [];
  bool uploadingState = false;

  void closeDialog(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _files = result.files;
      });
    }
  }

  void _submitFiles(BuildContext parentContext) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
            child: AlertDialog(
          icon: const Icon(
            Icons.upload_file,
            color: AppColors.primary,
          ),
          title: Text(
            uploadingState == false
                ? "Uploading documents"
                : "Documents upload complete",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  uploadingState == false
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  // Clear uploaded files
                                  setState(() {
                                    _files.clear();
                                  });
                                },
                                child: const Text("Upload More")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(parentContext);
                                  Navigator.of(parentContext).pop();

                                  // Clear uploaded files
                                  setState(() {
                                    _files.clear();
                                  });
                                },
                                child: const Text("Manage Uploads"))
                          ],
                        ),
                ]),
          ),
        )),
      );

      await uploadFiles(_files).then((res) async {
        setState(() {
          uploadingState = true;
        });
        await _landSearchController.loadUnApprovedSitePlans();
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
              child: AlertDialog(
            icon: const Icon(
              Icons.upload_file,
              color: AppColors.primary,
            ),
            title: const Text("File upload complete",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Clear uploaded files
                              setState(() {
                                _files.clear();
                              });
                            },
                            child: const Text("Upload More")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(parentContext);
                              Navigator.of(parentContext).pop();

                              // Clear uploaded files
                              setState(() {
                                _files.clear();
                              });
                            },
                            child: const Text("Manage Uploads"))
                      ],
                    ),
                  ]),
            ),
          )),
        );
      });
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                Navigator.pop(context);
                _submitFiles(context);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Documents',
            style: TextStyle(fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Upload Card
                Visibility(
                  visible: !_files.isNotEmpty,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.05),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 4),
                      //   )
                      // ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Drag & Drop files here',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _pickFiles,
                                icon: const Icon(Icons.add, size: 20, color: Colors.white,),
                                label: const Text('Browse Files'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Supported formats: PDF, JPG, PNG',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_files.isNotEmpty) ...[
                  const SizedBox(height: 24),

                  // Files Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Selected Files',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_files.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: _pickFiles,
                            icon: const Icon(
                              Icons.upload_file,
                              color: AppColors.primary,
                            ))
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Files List
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListView.separated(
                        itemCount: _files.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          final isImage = [
                            '.jpg',
                            '.jpeg',
                            '.png'
                          ].contains(path.extension(file.name).toLowerCase());

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // File Icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isImage
                                        ? Icons.image
                                        : Icons.picture_as_pdf,
                                    color: Colors.blue[400],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // File Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(file.size / 1024).toStringAsFixed(1)} KB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Remove Button
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  color: Colors.grey[400],
                                  onPressed: () {
                                    setState(() {
                                      _files.removeAt(index);
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Upload Button
                const SizedBox(height: 24),
                Visibility(
                  visible: _files.isNotEmpty,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _files.isEmpty ? null : _submitFiles(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        _files.isEmpty
                            ? 'Select Files to Upload'
                            : 'Upload ${_files.length} Files',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
