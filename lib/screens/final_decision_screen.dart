import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/claim_model.dart';
import '../models/decision_model.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'evidence_collection_screen.dart';

class FinalDecisionScreen extends StatefulWidget {
  const FinalDecisionScreen({super.key, required this.claimId});

  final String claimId;

  @override
  State<FinalDecisionScreen> createState() => _FinalDecisionScreenState();
}

class _FinalDecisionScreenState extends State<FinalDecisionScreen> with TickerProviderStateMixin {
  final _apiService = ApiService();

  late final AnimationController _shimmerController;
  late final AnimationController _ringController;
  late Future<ClaimModel> _claimFuture;

  final Color primaryColor = const Color(0xFF4648D4);
  final Color accentGreen = const Color(0xFF00C853);
  final Color warningColor = const Color(0xFFF59E0B);
  final Color errorColor = const Color(0xFFB3261E);
  final Color backgroundColor = const Color(0xFFF9F9FF);

  @override
  void initState() {
    super.initState();
    _claimFuture = _apiService.getClaim(widget.claimId);
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: const AuraBottomNavBar(currentIndex: 1),
      body: FutureBuilder<ClaimModel>(
        future: _claimFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final claim = snapshot.data!;
          final decision = claim.decisionResult ??
              const DecisionModel(
                confidenceScore: 0,
                decision: 'PENDING',
                visualScore: 0,
                exifScore: 0,
                trustScore: 0,
                aiExplanation: '',
                damageType: '',
                refundValue: 0,
                coverage: '',
              );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProgressIndicator(),
                      const SizedBox(height: 32),
                      _buildConfidenceRingCard(decision),
                      const SizedBox(height: 24),
                      _buildNeuralAnalysisCard(decision),
                      const SizedBox(height: 24),
                      _buildSummaryBentoGrid(claim, decision),
                      const SizedBox(height: 48),
                      _buildCTAButton(claim, decision),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.1),
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
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Step 3 of 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              'CLAIM RESULT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: 1.2,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      (MediaQuery.of(context).size.width - 48) * _shimmerController.value,
                      0,
                    ),
                    child: Container(
                      width: 40,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceRingCard(DecisionModel decision) {
    final color = _decisionColor(decision.decision);
    final confidence = decision.confidenceScore.clamp(0, 1);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: DashedCirclePainter(
                    color: Colors.grey.shade300,
                    strokeWidth: 1.5,
                  ),
                ),
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: ArcPainter(
                        color: color,
                        strokeWidth: 3,
                        progress: confidence * CurvedAnimation(
                          parent: _ringController,
                          curve: Curves.easeOutCubic,
                        ).value,
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(confidence * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      'CONFIDENCE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_decisionIcon(decision.decision), color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  decision.decision,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuralAnalysisCard(DecisionModel decision) {
    final color = _decisionColor(decision.decision);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.memory, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI EXPLANATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  decision.aiExplanation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBentoGrid(ClaimModel claim, DecisionModel decision) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : (constraints.maxWidth - 32) / 3,
              child: _buildBentoCard(
                icon: Icons.broken_image_outlined,
                label: 'DAMAGE TYPE',
                value: decision.damageType,
                valueColor: Colors.black87,
                bgColor: const Color(0xFFF0F3FF),
              ),
            ),
            SizedBox(
              width: isMobile ? double.infinity : (constraints.maxWidth - 32) / 3,
              child: _buildBentoCard(
                icon: Icons.security,
                label: 'COVERAGE',
                value: decision.coverage,
                valueColor: _decisionColor(decision.decision),
                bgColor: const Color(0xFFF0F3FF),
              ),
            ),
            SizedBox(
              width: isMobile ? double.infinity : (constraints.maxWidth - 32) / 3,
              child: _buildRefundCard(decision),
            ),
            SizedBox(
              width: isMobile ? double.infinity : constraints.maxWidth,
              child: _buildBentoCard(
                icon: Icons.receipt_long,
                label: 'CLAIM SUMMARY',
                value: '${claim.claimType} • ${claim.orderId}',
                valueColor: Colors.black87,
                bgColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCard(DecisionModel decision) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDEE8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.payments_outlined, color: primaryColor.withValues(alpha: 0.8), size: 24),
          const SizedBox(height: 16),
          Text(
            'REFUND VALUE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: primaryColor.withValues(alpha: 0.8),
              letterSpacing: 1,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRupiah(decision.refundValue),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(ClaimModel claim, DecisionModel decision) {
    final label = switch (decision.decision) {
      'APPROVED' => 'REQUEST REFUND',
      'REJECTED' => 'RETRY',
      _ => 'WAIT FOR REVIEW',
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [primaryColor, _decisionColor(decision.decision)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {
            if (decision.decision == 'REJECTED') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const EvidenceCollectionScreen()),
                (route) => false,
              );
              return;
            }

            final message = decision.decision == 'APPROVED'
                ? 'Refund of ${_formatRupiah(decision.refundValue)} is being processed.'
                : 'Seller review queue has been notified for claim ${claim.claimId.substring(0, 8)}.';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _decisionColor(String decision) {
    return switch (decision) {
      'APPROVED' => accentGreen,
      'NEEDS_REVIEW' => warningColor,
      'REJECTED' => errorColor,
      _ => primaryColor,
    };
  }

  IconData _decisionIcon(String decision) {
    return switch (decision) {
      'APPROVED' => Icons.verified,
      'NEEDS_REVIEW' => Icons.rule,
      'REJECTED' => Icons.gpp_bad,
      _ => Icons.hourglass_top,
    };
  }

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      final position = digits.length - index;
      buffer.write(digits[index]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString()}';
  }
}

class DashedCirclePainter extends CustomPainter {
  DashedCirclePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        const len = 6.0;
        if (draw) {
          dashedPath.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArcPainter extends CustomPainter {
  ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  final Color color;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
