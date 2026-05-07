import 'package:file_picker/file_picker.dart';

import '../models/uploaded_file_model.dart';
import 'api_service.dart';

class FileUploadService {
  FileUploadService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  static const int maxFileBytes = 500 * 1024 * 1024;

  Future<PlatformFile?> pickEvidenceFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'aac', 'm4a', 'mp3'],
    );
    return result?.files.single;
  }

  Future<UploadedFileModel> uploadPickedFile(PlatformFile file) async {
    if (file.bytes == null) {
      throw Exception('Selected file bytes are not available.');
    }
    if (file.size > maxFileBytes) {
      throw Exception('File exceeds 500MB limit.');
    }

    return _apiService.uploadFile(
      fileBytes: file.bytes!,
      filename: file.name,
    );
  }
}
