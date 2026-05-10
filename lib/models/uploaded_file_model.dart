class UploadedFileModel {
  const UploadedFileModel({
    required this.fileId,
    required this.filename,
    required this.contentType,
    required this.signedUrl,
    required this.gcsUri,
    required this.sizeBytes,
  });

  final String fileId;
  final String filename;
  final String contentType;
  final String signedUrl;
  final String gcsUri;
  final int sizeBytes;

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      fileId: json['file_id'] as String,
      filename: json['filename'] as String,
      contentType: json['content_type'] as String,
      signedUrl: json['signed_url'] as String,
      gcsUri: json['gcs_uri'] as String,
      sizeBytes: (json['size_bytes'] as num).toInt(),
    );
  }
}
