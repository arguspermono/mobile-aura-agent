import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Tambahkan ini
import 'package:mime/mime.dart';

import '../models/claim_model.dart';
import '../models/notification_model.dart';
import '../models/claim_status_model.dart';
import '../models/uploaded_file_model.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _configuredBaseUrl = String.fromEnvironment('AURA_API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  final http.Client _client;

  // Future<UploadedFileModel> uploadFile({
  //   required List<int> fileBytes,
  //   required String filename,
  // }) async {
  //   final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));
  //   request.files.add(
  //     http.MultipartFile.fromBytes(
  //       'file',
  //       fileBytes,
  //       filename: filename,
  //     ),
  //   );
  //   request.headers['accept'] = 'application/json';
  //   final streamed = await request.send();
  //   final rawBody = await streamed.stream.bytesToString();
  //   final payload = _decodeEnvelope(rawBody, streamed.statusCode);
  //   return UploadedFileModel.fromJson(payload);
  // }
  Future<UploadedFileModel> uploadFile({
    required List<int> fileBytes,
    required String filename,
  }) async {

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));

    final mimeType = lookupMimeType(filename) ?? 'application/octet-stream';
    final mimeSplit = mimeType.split('/');

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]), // Ini kunci perbaikannya
      ),
    );

    request.headers['accept'] = 'application/json';
    final streamed = await request.send();
    final rawBody = await streamed.stream.bytesToString();

    print('DEBUG UPLOAD RESPONSE: $rawBody'); // TAMBAHKAN INI

    final payload = _decodeEnvelope(rawBody, streamed.statusCode);
    return UploadedFileModel.fromJson(payload);
  }

  Future<ClaimModel> createClaim({
    required String userId,
    required String orderId,
    required String claimType,
    required List<String> fileIds,
    String voiceDescription = '',
  }) async {
    final payload = {
      'user_id': userId,
      'order_id': orderId,
      'claim_type': claimType,
      'file_ids': fileIds,
      'voice_description': voiceDescription,
    };
    debugPrint('--- [SENDING CREATE CLAIM] ---');
    debugPrint('Payload: ${jsonEncode(payload)}');

    final response = await _client.post(
      Uri.parse('$baseUrl/claims/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'order_id': orderId,
        'claim_type': claimType,
        'file_ids': fileIds,
        'voice_description': voiceDescription,
      }),
    );
    return ClaimModel.fromJson(_decodeEnvelope(response.body, response.statusCode));
  }

  Future<ClaimModel> getClaim(String claimId) async {
    final response = await _client.get(Uri.parse('$baseUrl/claims/$claimId'));
    return ClaimModel.fromJson(_decodeEnvelope(response.body, response.statusCode));
  }

  Future<List<ClaimModel>> listClaims({String? userId}) async {
    final uri = Uri.parse('$baseUrl/claims/').replace(
      queryParameters: userId == null ? null : {'user_id': userId},
    );
    final response = await _client.get(uri);
    final data = _decodeEnvelope(response.body, response.statusCode) as List<dynamic>;
    return data
        .map((item) => ClaimModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotificationModel>> listNotifications({required String userId}) async {
    final uri = Uri.parse('$baseUrl/notifications/').replace(
      queryParameters: {'user_id': userId},
    );
    final response = await _client.get(uri);
    final data = _decodeEnvelope(response.body, response.statusCode) as List<dynamic>;
    return data
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ClaimStatusModel> analyzeClaim(String claimId) async {
    final response = await _client.post(Uri.parse('$baseUrl/claims/$claimId/analyze'));
    return ClaimStatusModel.fromJson(_decodeEnvelope(response.body, response.statusCode));
  }

  Future<ClaimStatusModel> getClaimStatus(String claimId) async {
    final response = await _client.get(Uri.parse('$baseUrl/claims/$claimId/status'));
    return ClaimStatusModel.fromJson(_decodeEnvelope(response.body, response.statusCode));
  }

  Future<Map<String, dynamic>> overrideClaim({
    required String claimId,
    required String newStatus,
    required String sellerNotes,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/claims/$claimId/override'),
    );
    request.fields['new_status'] = newStatus;
    request.fields['seller_notes'] = sellerNotes;
    final streamed = await request.send();
    final rawBody = await streamed.stream.bytesToString();
    return _decodeEnvelope(rawBody, streamed.statusCode) as Map<String, dynamic>;
  }

  dynamic _decodeEnvelope(String rawBody, int statusCode) {
    // 1. Tambahkan print ini untuk melihat log di terminal
    debugPrint('HTTP Status Code: $statusCode');
    debugPrint('HTTP Raw Body: $rawBody');

    try {
      final body = jsonDecode(rawBody) as Map<String, dynamic>;
      if (statusCode >= 400 || body['status'] != 'ok') {
        // 2. Tampilkan rawBody di Exception agar terlihat di UI/Log
        throw Exception(body['message'] ?? 'Request failed. Status: $statusCode, Body: $rawBody');
      }
      return body['data'];
    } catch (e) {
      throw Exception('Format response bukan JSON. Raw: $rawBody');
    }
  }
}
