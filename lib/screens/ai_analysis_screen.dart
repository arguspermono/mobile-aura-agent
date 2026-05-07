import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/claim_status_model.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
import '../services/firestore_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'final_decision_screen.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key, required this.claimId});

  final String claimId;

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> with TickerProviderStateMixin {
  final _apiService = ApiService();
  final _firestoreService = FirestoreService();

  late final AnimationController _spinController;
  late final AnimationController _blinkController;
  late final AnimationController _shimmerController;

  StreamSubscription<ClaimStatusModel>? _statusSubscription;
  ClaimStatusModel? _latestStatus;
  String? _errorMessage;
  bool _navigated = false;

  final Color primaryColor = const Color(0xFF4648D4);
  final Color secondaryColor = const Color(0xFF006E2A);
  final Color backgroundColor = const Color(0xFFF9F9FF);
  final Color surfaceContainerLow = const Color(0xFFF0F3FF);
  final Color surfaceContainer = const Color(0xFFE7EEFF);
  final Color surfaceContainerHigh = const Color(0xFFDEE8FF);

  static const List<String> _steps = [
    'uploading_evidence',
    'analyzing_evidence',
    'detecting_damage_patterns',
    'calculating_confidence_score',
    'generating_report',
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      final initialStatus = await _apiService.analyzeClaim(widget.claimId);
      if (!mounted) {
        return;
      }
      setState(() {
        _latestStatus = initialStatus;
      });
      _statusSubscription = _firestoreService.watchClaimStatus(widget.claimId).listen(
        (status) {
          if (!mounted) {
            return;
          }
          setState(() {
            _latestStatus = status;
          });
          if (status.isTerminal && !_navigated) {
            _navigated = true;
            if (status.status == 'APPROVED') {
              FcmService.instance.publishClaimUpdate(
                'Refund of Rp100.000 is being processed for claim ${status.claimId}.',
              );
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FinalDecisionScreen(claimId: widget.claimId),
              ),
            );
          }
        },
        onError: (Object error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _errorMessage = error.toString();
          });
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _spinController.dispose();
    _blinkController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latestStatus = _latestStatus;
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: const AuraBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressHeader(latestStatus),
                  const SizedBox(height: 32),
                  _buildCentralAiGraphic(),
                  const SizedBox(height: 32),
                  _buildChecklistCard(latestStatus),
                  const SizedBox(height: 32),
                  _buildLiveStatusTerminal(latestStatus),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    _buildErrorBanner(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: primaryColor),
        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildProgressHeader(ClaimStatusModel? status) {
    final completedSteps = _progressValue(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Real-Time AI Audit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              'STEP 2 OF 3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 1.2,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completedSteps,
            backgroundColor: Colors.grey.shade200,
            color: primaryColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  double _progressValue(ClaimStatusModel? status) {
    if (status == null) {
      return 0.12;
    }
    if (status.currentStep == 'complete') {
      return 1;
    }
    final index = _steps.indexOf(status.currentStep);
    if (index == -1) {
      return 0.12;
    }
    return (index + 1) / (_steps.length + 1);
  }

  Widget _buildCentralAiGraphic() {
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinController.value * 2 * math.pi,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border(
                        top: BorderSide(color: primaryColor, width: 3),
                        right: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 3),
                        bottom: const BorderSide(color: Colors.transparent, width: 3),
                        left: const BorderSide(color: Colors.transparent, width: 3),
                      ),
                    ),
                  ),
                );
              },
            ),
            Icon(Icons.psychology, size: 64, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard(ClaimStatusModel? status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildChecklistRow(step: 'uploading_evidence', label: 'Uploading Evidence', status: status),
          _buildDivider(),
          _buildChecklistRow(step: 'analyzing_evidence', label: 'Analyzing Evidence', status: status),
          _buildDivider(),
          _buildChecklistRow(
            step: 'detecting_damage_patterns',
            label: 'Detecting Damage Patterns',
            status: status,
          ),
          _buildDivider(),
          _buildChecklistRow(
            step: 'calculating_confidence_score',
            label: 'Calculating Confidence Score',
            status: status,
          ),
          _buildDivider(),
          _buildChecklistRow(step: 'generating_report', label: 'Generating Report', status: status),
        ],
      ),
    );
  }

  Widget _buildChecklistRow({
    required String step,
    required String label,
    required ClaimStatusModel? status,
  }) {
    final index = _steps.indexOf(step);
    final currentIndex = status == null ? -1 : _steps.indexOf(status.currentStep);
    final isComplete = status?.currentStep == 'complete' || (currentIndex > index);
    final isActive = status?.currentStep == step;
    final bool isFailed = status?.status == 'ERROR';
    final rowColor = isFailed
        ? const Color(0xFFB3261E)
        : isComplete
            ? secondaryColor
            : isActive
                ? primaryColor
                : Colors.grey.shade500;
    final statusText = isFailed
        ? 'Failed'
        : isComplete
            ? 'Complete'
            : isActive
                ? 'Processing...'
                : 'Pending';
    final icon = isFailed
        ? Icons.error_outline
        : isComplete
            ? Icons.check_circle
            : isActive
                ? Icons.sync
                : Icons.radio_button_unchecked;

    return Opacity(
      opacity: isComplete || isActive ? 1 : 0.65,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: isActive
            ? BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Row(
          children: [
            if (isActive)
              AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_spinController.value * 2 * math.pi,
                    child: Icon(icon, color: rowColor, size: 20),
                  );
                },
              )
            else
              Icon(icon, color: rowColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: rowColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rowColor,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade400.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildLiveStatusTerminal(ClaimStatusModel? status) {
    final terminalLines = _terminalLines(status);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in terminalLines) ...[
            _buildTerminalLine(line, Colors.grey.shade700),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Text(
                '> Current step: ${status?.currentStep ?? 'booting'}',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _blinkController.value,
                    child: Container(width: 6, height: 14, color: primaryColor),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _terminalLines(ClaimStatusModel? status) {
    final lines = <String>[
      '> Firestore realtime stream connected... [OK]',
      '> Claim ID: ${widget.claimId.substring(0, 8)}',
    ];
    if (status == null) {
      lines.add('> Preparing analysis pipeline...');
      return lines;
    }
    switch (status.currentStep) {
      case 'uploading_evidence':
        lines.add('> Upload manifest verified and signed URL stored.');
        break;
      case 'analyzing_evidence':
        lines.add('> Gemini multimodal damage analysis in progress.');
        break;
      case 'detecting_damage_patterns':
        lines.add('> EXIF, timestamp, and device metadata checks running.');
        break;
      case 'calculating_confidence_score':
        lines.add('> BigQuery trust score and weighted confidence calculation running.');
        break;
      case 'generating_report':
        lines.add('> Building explainability report and action payload.');
        break;
      case 'complete':
        lines.add('> Decision ready: ${status.status}. Redirecting to result screen.');
        break;
      case 'failed':
        lines.add('> Pipeline failed. Manual retry required.');
        break;
      default:
        lines.add('> Waiting for background worker...');
    }
    return lines;
  }

  Widget _buildTerminalLine(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: 12,
        color: color,
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
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
}
