import 'package:flutter/material.dart';

import '../models/claim_model.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'evidence_collection_screen.dart';
import 'notifications_screen.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  static const String demoUserId = 'demo-user-001';

  final _apiService = ApiService();
  late Future<List<ClaimModel>> _claimsFuture;

  final Color primaryColor = const Color(0xFF4648D4);
  final Color secondaryColor = const Color(0xFF006E2A);
  final Color errorColor = const Color(0xFFB3261E);
  final Color warningColor = const Color(0xFFF59E0B);
  final Color backgroundColor = const Color(0xFFF9F9FF);

  @override
  void initState() {
    super.initState();
    _claimsFuture = _apiService.listClaims(userId: demoUserId);
  }

  Future<void> _refreshClaims() async {
    setState(() {
      _claimsFuture = _apiService.listClaims(userId: demoUserId);
    });
    await _claimsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      bottomNavigationBar: const AuraBottomNavBar(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _refreshClaims,
        child: FutureBuilder<List<ClaimModel>>(
          future: _claimsFuture,
          builder: (context, snapshot) {
            final claims = snapshot.data ?? const <ClaimModel>[];
            return ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 24,
                right: 24,
                bottom: 120,
              ),
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildTotalClaimsCard(claims),
                const SizedBox(height: 32),
                _buildCreateClaimCTA(context),
                const SizedBox(height: 32),
                _buildRecentClaims(snapshot),
                const SizedBox(height: 32),
                _buildAuraTipCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7C4D7), width: 2),
                color: const Color(0xFFE7EEFF),
              ),
              child: Icon(Icons.person, color: primaryColor, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Aura Demo User',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildTotalClaimsCard(List<ClaimModel> claims) {
    final approvedCount = claims.where((claim) => claim.status == 'APPROVED').length;
    final processingCount = claims.where((claim) => claim.status == 'PROCESSING').length;
    final rejectedCount = claims.where((claim) => claim.status == 'REJECTED').length;
    final totalValue = claims.fold<int>(
      0,
      (sum, claim) => sum + (claim.decisionResult?.refundValue ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4DE6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Claims Value',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatRupiah(totalValue),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(claims.length.toString(), 'Total', Colors.white),
              _buildStatItem(approvedCount.toString(), 'Approved', const Color(0xFF4ADE80)),
              _buildStatItem(processingCount.toString(), 'Processing', const Color(0xFFFB923C)),
              _buildStatItem(rejectedCount.toString(), 'Rejected', const Color(0xFFF87171)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateClaimCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EvidenceCollectionScreen()),
        ).then((_) => _refreshClaims());
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 42),
            SizedBox(height: 16),
            Text(
              'Create New Claim',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'AI-assisted filing process',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentClaims(AsyncSnapshot<List<ClaimModel>> snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Claims',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (snapshot.connectionState != ConnectionState.done)
          const Center(child: CircularProgressIndicator())
        else if (snapshot.hasError)
          Text(
            snapshot.error.toString(),
            style: TextStyle(color: errorColor, fontFamily: 'Inter'),
          )
        else if ((snapshot.data ?? const []).isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No claims yet. Start a new submission to test the AI pipeline.',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          )
        else
          ...snapshot.data!.take(4).map(_buildClaimItem),
      ],
    );
  }

  Widget _buildClaimItem(ClaimModel claim) {
    final statusColor = _statusColor(claim.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2_outlined, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim.claimType,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${claim.status} • ${claim.currentStep}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRupiah(claim.decisionResult?.refundValue ?? 0),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuraTipCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AURA AI TIP',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4648D4),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Use filenames or descriptions like "damaged", "ambiguous", or "fake" to demo approve, review, and rejection flows quickly in mock mode.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'APPROVED' => secondaryColor,
      'REJECTED' => errorColor,
      'NEEDS_REVIEW' => warningColor,
      'PROCESSING' => primaryColor,
      _ => Colors.grey.shade600,
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
