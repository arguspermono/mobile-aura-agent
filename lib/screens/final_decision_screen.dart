import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class FinalDecisionScreen extends StatefulWidget {
  const FinalDecisionScreen({super.key});

  @override
  State<FinalDecisionScreen> createState() => _FinalDecisionScreenState();
}

class _FinalDecisionScreenState extends State<FinalDecisionScreen> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _ringController;

  final Color primaryColor = const Color(0xFF4648D4);
  final Color accentGreen = const Color(0xFF00C853);
  final Color secondaryGreen = const Color(0xFF006E2A);
  final Color backgroundColor = const Color(0xFFF9F9FF);

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
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
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  _buildConfidenceRingCard(),
                  const SizedBox(height: 24),
                  _buildNeuralAnalysisCard(),
                  const SizedBox(height: 24),
                  _buildSummaryBentoGrid(),
                  const SizedBox(height: 48),
                  _buildCTAButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
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
            title: const Text(
              'AURA AI',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1.2,
                fontFamily: 'Inter',
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    radius: 16,
                    child: const Icon(Icons.person, color: Colors.grey, size: 20),
                  ),
                ),
              ),
            ],
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
              'FINAL DECISION',
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
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
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

  Widget _buildConfidenceRingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient glow blob
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentGreen.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withValues(alpha: 0.15),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Dashed track
                CustomPaint(
                  size: const Size(200, 200),
                  painter: DashedCirclePainter(
                    color: Colors.grey.shade300,
                    strokeWidth: 1.5,
                  ),
                ),
                // Foreground arc
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: ArcPainter(
                        color: accentGreen,
                        strokeWidth: 3.0,
                        progress: 0.94 * CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic).value,
                      ),
                    );
                  },
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '94',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Inter',
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
          // Pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: accentGreen.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: accentGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'APPROVED',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: accentGreen,
                    letterSpacing: 2.0,
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

  Widget _buildNeuralAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -24,
            top: -24,
            bottom: -24,
            child: Container(
              width: 4,
              color: primaryColor,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.memory, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEURAL ANALYSIS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our neural network detected visible structural fractures consistent with shipping impact.',
                      style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildSummaryBentoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : (constraints.maxWidth - 32) / 3,
              child: _buildBentoCard(
                icon: Icons.broken_image_outlined,
                label: 'DAMAGE TYPE',
                value: 'Fracture',
                valueColor: Colors.black87,
                bgColor: const Color(0xFFF0F3FF),
              ),
            ),
            SizedBox(
              width: isMobile ? double.infinity : (constraints.maxWidth - 32) / 3,
              child: _buildBentoCard(
                icon: Icons.security,
                label: 'COVERAGE',
                value: 'Full',
                valueColor: accentGreen,
                bgColor: const Color(0xFFF0F3FF),
              ),
            ),
            SizedBox(
              width: isMobile ? double.infinity : (constraints.maxWidth - 32) / 3,
              child: _buildRefundCard(),
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
              letterSpacing: 1.0,
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

  Widget _buildRefundCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDEE8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Column(
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
                  letterSpacing: 1.0,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$124.50',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  fontFamily: 'Inter',
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [primaryColor, accentGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REQUEST REFUND',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path dashedPath = _createDashedPath(path, 4, 8);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double gapLength) {
    final Path path = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashLength : gapLength;
        if (draw) {
          path.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;

  ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 2.0); // Slight glow

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
