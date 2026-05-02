import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class CustomerUploadScreen extends StatefulWidget {
  const CustomerUploadScreen({super.key});

  @override
  State<CustomerUploadScreen> createState() => _CustomerUploadScreenState();
}

class _CustomerUploadScreenState extends State<CustomerUploadScreen> {
  final TextEditingController _descController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String? _claimId;
  String? _status;
  String? _message;
  Timer? _pollingTimer;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.media,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitClaim() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video or image file first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _message = "Uploading evidence to Google Cloud Storage...";
    });

    try {
      final response = await ApiService.uploadClaim(
        'user_123', // Dummy user ID for prototype
        _descController.text,
        _selectedFile!.bytes!,
        _selectedFile!.name,
      );

      setState(() {
        _claimId = response['claim_id'];
        _status = response['status'];
        _message = "Claim submitted. AI Engine is analyzing the evidence...";
      });

      _startPolling();
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_claimId == null) return;
      try {
        final claim = await ApiService.getClaimStatus(_claimId!);
        setState(() {
          _status = claim['status'];
        });
        
        // Stop polling if a final decision is reached
        if (_status == 'APPROVED' || _status == 'REJECTED' || _status == 'PENDING_REVIEW' || _status == 'AWAITING_USER_INPUT' || _status == 'ERROR') {
          timer.cancel();
          setState(() {
            _message = "Decision Reached: ${claim['decision']} \nAction: ${claim['action_taken']}";
          });
          _showDecisionDialog(claim);
        }
      } catch (e) {
        print("Polling error: $e");
      }
    });
  }

  void _showDecisionDialog(Map<String, dynamic> claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Claim ${_status!}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decision: ${claim['decision']}'),
            const SizedBox(height: 8),
            Text('Action Taken: ${claim['action_taken']}'),
            const SizedBox(height: 16),
            const Text('AI Explanation:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${claim['ai_explanation']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Claim')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Evidence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_library),
                title: Text(_selectedFile?.name ?? 'No file selected'),
                subtitle: const Text('Select unboxing video or image'),
                trailing: IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Audio/Text Description',
                hintText: 'e.g., "The seal was broken when it arrived"',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading || _claimId != null ? null : _submitClaim,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Submit Claim'),
            ),
            const SizedBox(height: 24),
            if (_claimId != null) ...[
              const Divider(),
              const Text('Live Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Status: $_status', style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 8),
              Text(_message ?? '', style: const TextStyle(fontStyle: FontStyle.italic)),
              if (_status == 'PROCESSING')
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: LinearProgressIndicator(),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
