import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'final_decision_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _blinkController;
  late AnimationController _shimmerController;

  final Color primaryColor = const Color(0xFF4648D4);
  final Color secondaryColor = const Color(0xFF006E2A);
  final Color backgroundColor = const Color(0xFFF9F9FF);
  final Color surfaceContainerLow = const Color(0xFFF0F3FF);
  final Color surfaceContainer = const Color(0xFFE7EEFF);
  final Color surfaceContainerHigh = const Color(0xFFDEE8FF);

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FinalDecisionScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _blinkController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: const AuraBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressHeader(),
                  const SizedBox(height: 32),
                  _buildCentralAiGraphic(),
                  const SizedBox(height: 32),
                  _buildChecklistCard(),
                  const SizedBox(height: 32),
                  _buildLiveStatusTerminal(),
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: 18,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'AI Analysis',
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
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [primaryColor.withValues(alpha: 0.7), primaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      (MediaQuery.of(context).size.width * 0.4) * _shimmerController.value - 20,
                      0,
                    ),
                    child: Container(
                      width: 20,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.5),
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
            // Bloom glow
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
            // Outer ring
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
            // Inner spinning arc
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
            // Inner arc rotation offset for the blur effect
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: (_spinController.value * 2 * math.pi) + (math.pi / 4),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border(
                        top: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 6),
                        right: const BorderSide(color: Colors.transparent, width: 6),
                        bottom: const BorderSide(color: Colors.transparent, width: 6),
                        left: const BorderSide(color: Colors.transparent, width: 6),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Center icon
            Icon(
              Icons.psychology,
              size: 64,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildChecklistRow(
            icon: Icons.check_circle,
            iconColor: secondaryColor,
            label: 'Uploading Evidence',
            labelColor: Colors.black87,
            status: 'Complete',
            statusColor: secondaryColor,
            isProcessing: false,
          ),
          _buildDivider(),
          _buildChecklistRow(
            icon: Icons.sync,
            iconColor: primaryColor,
            label: 'Analyzing Evidence',
            labelColor: primaryColor,
            labelWeight: FontWeight.bold,
            status: 'Processing...',
            statusColor: primaryColor,
            isProcessing: true,
          ),
          _buildDivider(),
          _buildChecklistRow(
            icon: Icons.radio_button_unchecked,
            iconColor: Colors.grey.shade400,
            label: 'Detecting Damage Patterns',
            labelColor: Colors.grey.shade500,
            status: 'Pending',
            statusColor: Colors.grey.shade500,
            isProcessing: false,
            opacity: 0.6,
          ),
          _buildDivider(),
          _buildChecklistRow(
            icon: Icons.radio_button_unchecked,
            iconColor: Colors.grey.shade400,
            label: 'Calculating Confidence Score',
            labelColor: Colors.grey.shade500,
            status: 'Pending',
            statusColor: Colors.grey.shade500,
            isProcessing: false,
            opacity: 0.6,
          ),
          _buildDivider(),
          _buildChecklistRow(
            icon: Icons.radio_button_unchecked,
            iconColor: Colors.grey.shade400,
            label: 'Generating Report',
            labelColor: Colors.grey.shade500,
            status: 'Pending',
            statusColor: Colors.grey.shade500,
            isProcessing: false,
            opacity: 0.6,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    FontWeight labelWeight = FontWeight.w500,
    required String status,
    required Color statusColor,
    required bool isProcessing,
    double opacity = 1.0,
  }) {
    Widget rowContent = Row(
      children: [
        if (isProcessing)
          AnimatedBuilder(
            animation: _spinController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_spinController.value * 2 * math.pi,
                child: Icon(icon, color: iconColor, size: 20),
              );
            },
          )
        else
          Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: labelWeight,
              color: labelColor,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: isProcessing
            ? BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: rowContent,
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

  Widget _buildLiveStatusTerminal() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTerminalLine('> Scanning image pixels for structural anomalies... [OK]', Colors.grey.shade600),
          const SizedBox(height: 8),
          _buildTerminalLine('> Consulting Firestore realtime listener... [OK]', Colors.grey.shade600),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '> Executing predictive model layers...',
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
                    child: Container(
                      width: 6,
                      height: 14,
                      color: primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
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
}
