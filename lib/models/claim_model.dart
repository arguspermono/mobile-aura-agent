import 'decision_model.dart';

class ClaimModel {
  const ClaimModel({
    required this.claimId,
    required this.userId,
    required this.orderId,
    required this.claimType,
    required this.fileIds,
    required this.voiceDescription,
    required this.status,
    required this.currentStep,
    required this.createdAt,
    required this.updatedAt,
    this.decisionResult,
  });

  final String claimId;
  final String userId;
  final String orderId;
  final String claimType;
  final List<String> fileIds;
  final String voiceDescription;
  final String status;
  final String currentStep;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DecisionModel? decisionResult;

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      claimId: json['claim_id'] as String,
      userId: json['user_id'] as String,
      orderId: json['order_id'] as String,
      claimType: json['claim_type'] as String,
      fileIds: (json['file_ids'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      voiceDescription: json['voice_description'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      currentStep: json['current_step'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      decisionResult: json['decision_result'] is Map<String, dynamic>
          ? DecisionModel.fromJson(json['decision_result'] as Map<String, dynamic>)
          : null,
    );
  }
}
