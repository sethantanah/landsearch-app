import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';

import '../../config/environment_config.dart';

Future<List<dynamic>> uploadFiles(List<PlatformFile> files, {bool store = true}) async {
  final url = '$API_BASE_URL/api/document-processing/upload';
  const userId = '123456'; // Get from auth service
  const uploadId = '$userId-upload';

  try {
    var formData = FormData.fromMap({'user_id': userId, 'upload_id': uploadId, 'store': store});

    for (var file in files) {
      formData.files.addAll([
        MapEntry(
          'files',
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ),
      ]);
    }

    final response = await Dio().post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
      onSendProgress: (sent, total) {
        final progress = (sent / total) * 100;
        if (kDebugMode) {
          print('Upload Progress: $progress%');
        }
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Files uploaded successfully');
      }
      return response.data;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading files: $e');
    }
    rethrow;
  }

  return [];
}

Future<Map<String, dynamic>> getUneditedFiles(String userId) async {
  final url = '$API_BASE_URL/api/site-plans/unprocessed';
  try {
    var formData = FormData.fromMap({
      'user_id': userId,
    });

    final response = await Dio().get(url,
        queryParameters: {'user_id': userId, 'upload_id': '$userId-upload'},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ));

    if (response.statusCode == 200) {}

    print(response.data);

    return response.data;
  } catch (e) {
    print('Error uploading files: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> updateSitePlanData(
    String userId, ProcessedLandData data) async {
  final url = '$API_BASE_URL/api/document-processing/update';
  try {
    final response = await Dio().get(url,
        queryParameters: {'user_id': userId, 'data': data.toJson()},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ));

    if (response.statusCode == 200) {}

    print(response.data);

    return response.data;
  } catch (e) {
    print('Error uploading files: $e');
    rethrow;
  }
}
