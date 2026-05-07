class DecisionModel {
  const DecisionModel({
    required this.confidenceScore,
    required this.decision,
    required this.visualScore,
    required this.exifScore,
    required this.trustScore,
    required this.aiExplanation,
    required this.damageType,
    required this.refundValue,
    required this.coverage,
  });

  final double confidenceScore;
  final String decision;
  final double visualScore;
  final double exifScore;
  final double trustScore;
  final String aiExplanation;
  final String damageType;
  final int refundValue;
  final String coverage;

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0,
      decision: json['decision'] as String? ?? 'PENDING',
      visualScore: (json['visual_score'] as num?)?.toDouble() ?? 0,
      exifScore: (json['exif_score'] as num?)?.toDouble() ?? 0,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0,
      aiExplanation: json['ai_explanation'] as String? ?? '',
      damageType: json['damage_type'] as String? ?? '',
      refundValue: (json['refund_value'] as num?)?.toInt() ?? 0,
      coverage: json['coverage'] as String? ?? '',
    );
  }
}
