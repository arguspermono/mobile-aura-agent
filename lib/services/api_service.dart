import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 if running on Android Emulator to connect to localhost FastAPI
  // Use localhost or 127.0.0.1 if running on web/desktop
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<Map<String, dynamic>> uploadClaim(String userId, String description, List<int> fileBytes, String filename) async {
    var uri = Uri.parse('$baseUrl/claims/upload');
    var request = http.MultipartRequest('POST', uri);
    
    request.fields['user_id'] = userId;
    request.fields['description'] = description;
    
    var multipartFile = http.MultipartFile.fromBytes(
      'files',
      fileBytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Failed to upload claim: $responseData');
    }
  }

  static Future<Map<String, dynamic>> getClaimStatus(String claimId) async {
    var uri = Uri.parse('$baseUrl/claims/$claimId');
    var response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch claim status');
    }
  }

  static Future<List<dynamic>> getAllClaims() async {
    var uri = Uri.parse('$baseUrl/claims');
    var response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch all claims');
    }
  }

  static Future<Map<String, dynamic>> overrideClaim(String claimId, String newStatus, String sellerNotes) async {
    var uri = Uri.parse('$baseUrl/claims/$claimId/override');
    var response = await http.post(
      uri,
      body: {
        'new_status': newStatus,
        'seller_notes': sellerNotes,
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to override claim');
    }
  }
}
