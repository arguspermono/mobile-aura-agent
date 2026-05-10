class NotificationModel {
  const NotificationModel({
    required this.claimId,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String claimId;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      claimId: json['claim_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
