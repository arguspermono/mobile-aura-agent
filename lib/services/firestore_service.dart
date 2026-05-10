import 'dart:async';

import '../models/claim_status_model.dart';
import 'api_service.dart';

class FirestoreService {
  FirestoreService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Stream<ClaimStatusModel> watchClaimStatus(
    String claimId, {
    Duration interval = const Duration(seconds: 1),
  }) async* {
    while (true) {
      final status = await _apiService.getClaimStatus(claimId);
      yield status;
      if (status.isTerminal) {
        break;
      }
      await Future<void>.delayed(interval);
    }
  }
}
