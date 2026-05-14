class UploadedFileModel {
  final String fileId;

  final String signedUrl;

  const UploadedFileModel({
    required this.fileId,

    required this.signedUrl,

  });
  //
  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      fileId: json['file_id'] as String,


      signedUrl: json['signed_url'] as String,

    );
  }
}
