import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/file_upload_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'ai_analysis_screen.dart';
import 'hub_screen.dart';

class EvidenceCollectionScreen extends StatefulWidget {
  const EvidenceCollectionScreen({super.key});

  @override
  State<EvidenceCollectionScreen> createState() => _EvidenceCollectionScreenState();
}

class _EvidenceCollectionScreenState extends State<EvidenceCollectionScreen> {
  static const String demoUserId = 'demo-user-001';

  final _descriptionController = TextEditingController();
  final _voiceDescriptionController = TextEditingController();
  final _apiService = ApiService();
  final _fileUploadService = FileUploadService();

  String _selectedClaimType = 'Product Defect';
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;
  String? _errorMessage;

  final Color primaryColor = const Color(0xFF4648D4);
  final Color secondaryColor = const Color(0xFF006E2A);
  final Color backgroundColor = const Color(0xFFF9F9FF);

  @override
  void dispose() {
    _descriptionController.dispose();
    _voiceDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await _fileUploadService.pickEvidenceFile();
    if (file == null) {
      return;
    }
    setState(() {
      _selectedFile = file;
      _errorMessage = null;
    });
  }

  Future<void> _submitClaim() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Select one photo, video, or audio file before continuing.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final uploadedFile = await _fileUploadService.uploadPickedFile(_selectedFile!);
      final claim = await _apiService.createClaim(
        userId: demoUserId,
        orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        claimType: _selectedClaimType,
        fileIds: [uploadedFile.fileId],
        voiceDescription: _mergedDescription,
      );

      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiAnalysisScreen(claimId: claim.claimId),
        ),
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String get _mergedDescription {
    final description = _descriptionController.text.trim();
    final voiceDescription = _voiceDescriptionController.text.trim();
    return [description, voiceDescription].where((entry) => entry.isNotEmpty).join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: const AuraBottomNavBar(currentIndex: 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressSection(),
                const SizedBox(height: 32),
                _buildClaimTypeSelector(),
                const SizedBox(height: 32),
                _buildUploadEvidenceZone(),
                const SizedBox(height: 32),
                _buildTextContext(),
                const SizedBox(height: 32),
                _buildVoiceContext(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  _buildErrorBanner(),
                ],
              ],
            ),
          ),
          _buildBottomCTA(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: primaryColor),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HubScreen()),
            );
          }
        },
      ),
      centerTitle: true,
      title: Text(
        'AURA AI',
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 1.2,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Step 1 of 3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'SMART CLAIM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: secondaryColor,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1 / 3,
            backgroundColor: Colors.grey.shade200,
            color: secondaryColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildClaimTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Claim Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        _buildClaimCard('Product Defect', Icons.inventory_2_outlined),
        const SizedBox(height: 12),
        _buildClaimCard('Shipping Damage', Icons.local_shipping_outlined),
        const SizedBox(height: 12),
        _buildClaimCard('Missing Item', Icons.search_off),
      ],
    );
  }

  Widget _buildClaimCard(String title, IconData icon) {
    final isSelected = _selectedClaimType == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedClaimType = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? secondaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? secondaryColor : Colors.grey.shade100,
              radius: 20,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadEvidenceZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Evidence',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.08),
                ),
                child: Icon(Icons.cloud_upload_outlined, color: primaryColor, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Photo, video, or audio evidence',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1 file per claim, maximum 500MB.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isSubmitting ? null : _pickFile,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _selectedFile == null ? 'BROWSE FILES' : 'REPLACE FILE',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined, color: primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFile!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                              style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextContext() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Claim Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          hintText: 'Describe the damage, missing item, or defect.',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildVoiceContext() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Description (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.mic, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Recorder integration is mocked in this demo. Enter the voice transcript below.',
                      style: TextStyle(color: Colors.grey.shade700, fontFamily: 'Inter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _voiceDescriptionController,
                hintText: 'Optional transcript or additional voice notes.',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Inter'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: Color(0xFFB3261E),
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor.withValues(alpha: 0),
              backgroundColor,
              backgroundColor,
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitClaim,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Analyze with AURA AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
