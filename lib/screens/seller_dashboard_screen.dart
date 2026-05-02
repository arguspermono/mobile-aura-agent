import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  List<dynamic> _claims = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchClaims();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchClaims());
  }

  Future<void> _fetchClaims() async {
    try {
      final claims = await ApiService.getAllClaims();
      // Sort by newest first
      claims.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      setState(() {
        _claims = claims;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching claims: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard: $e')),
        );
      }
    }
  }

  Future<void> _overrideClaim(String claimId, String newStatus) async {
    try {
      await ApiService.overrideClaim(claimId, newStatus, "Manual override by Seller");
      _fetchClaims();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error overriding: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'APPROVED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'PENDING_REVIEW': return Colors.orange;
      case 'PROCESSING': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchClaims),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _claims.isEmpty
              ? const Center(child: Text("No claims received yet."))
              : ListView.builder(
                  itemCount: _claims.length,
                  itemBuilder: (context, index) {
                    final claim = _claims[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(claim['status']),
                          child: const Icon(Icons.assignment, color: Colors.white),
                        ),
                        title: Text('Claim ID: ${claim['claim_id'].toString().substring(0, 8)}...'),
                        subtitle: Text('Status: ${claim['status']} | User: ${claim['user_id']}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${claim['description']}'),
                                const Divider(),
                                const Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Confidence Score: ${claim['ai_confidence'] ?? "N/A"}'),
                                Text('Risk Score: ${claim['risk_score'] ?? "N/A"}'),
                                Text('Anomalies: ${(claim['anomalies'] as List?)?.join(", ") ?? "None"}'),
                                Text('Explanation: ${claim['ai_explanation'] ?? "N/A"}'),
                                const Divider(),
                                const Text('System Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Decision: ${claim['decision'] ?? "Pending"}'),
                                Text('Action Taken: ${claim['action_taken'] ?? "None"}'),
                                const SizedBox(height: 16),
                                if (claim['status'] == 'PENDING_REVIEW' || claim['status'] == 'PROCESSING')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () => _overrideClaim(claim['claim_id'], 'APPROVED'),
                                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => _overrideClaim(claim['claim_id'], 'REJECTED'),
                                        child: const Text('Reject', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
