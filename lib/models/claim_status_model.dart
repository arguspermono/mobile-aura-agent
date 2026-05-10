class ClaimStatusModel {
  const ClaimStatusModel({
    required this.claimId,
    required this.status,
    required this.currentStep,
    required this.updatedAt,
  });

  final String claimId;
  final String status;
  final String currentStep;
  final DateTime updatedAt;

  bool get isTerminal =>
      status == 'APPROVED' || status == 'NEEDS_REVIEW' || status == 'REJECTED' || status == 'ERROR';

  factory ClaimStatusModel.fromJson(Map<String, dynamic> json) {
    return ClaimStatusModel(
      claimId: json['claim_id'] as String,
      status: json['status'] as String,
      currentStep: json['current_step'] as String? ?? 'pending',
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
