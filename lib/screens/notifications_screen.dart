import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'hub_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String demoUserId = 'demo-user-001';

  final _apiService = ApiService();
  final Color primaryColor = const Color(0xFF4648d4);
  final Color primaryContainer = const Color(0xFF6063ee);
  final Color secondaryColor = const Color(0xFF006e2a);
  final Color secondaryContainer = const Color(0xFF5cfd80);
  final Color tertiaryColor = const Color(0xFF595c5e);
  final Color tertiaryContainer = const Color(0xFF727577);
  final Color backgroundColor = const Color(0xFFF9F9FF);

  int _selectedTabIndex = 0;
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _apiService.listNotifications(userId: demoUserId);
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = _apiService.listNotifications(userId: demoUserId);
    });
    await _notificationsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      bottomNavigationBar: const AuraBottomNavBar(currentIndex: 2),
      appBar: AppBar(
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
        actions: [
          IconButton(
            onPressed: _refreshNotifications,
            icon: Icon(Icons.refresh, color: Colors.grey.shade700),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: FutureBuilder<List<NotificationModel>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            final notifications = _filteredNotifications(snapshot.data ?? const []);
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 120.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(snapshot.data?.length ?? 0),
                    const SizedBox(height: 24),
                    _buildSegmentedTabControl(),
                    const SizedBox(height: 32),
                    _buildNotificationList(snapshot, notifications),
                    const SizedBox(height: 32),
                    _buildAILayerCard(snapshot.data ?? const []),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int totalNotifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Backend activity feed for $totalNotifications claim updates.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEFF),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(0, 'All'),
          _buildTabItem(1, 'Approved'),
          _buildTabItem(2, 'Created'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFFFFFBFF) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    AsyncSnapshot<List<NotificationModel>> snapshot,
    List<NotificationModel> notifications,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          snapshot.error.toString(),
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFFB3261E),
          ),
        ),
      );
    }
    if (notifications.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No backend notifications yet. Create a claim to populate this feed.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < notifications.length; index++) ...[
          _buildNotificationCard(
            notification: notifications[index],
            isUnread: index == 0,
          ),
          if (index != notifications.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
    required bool isUnread,
  }) {
    final style = _notificationStyle(notification);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: style.accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: style.accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: style.iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(style.icon, color: style.iconColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _timeAgo(notification.createdAt),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Claim ${notification.claimId.isEmpty ? '-' : notification.claimId.substring(0, min(8, notification.claimId.length))}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: style.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 12),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ] else
                          const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAILayerCard(List<NotificationModel> notifications) {
    final createdCount = notifications.where((item) => item.title.contains('Created')).length;
    final approvedCount = notifications.where((item) => item.title.contains('APPROVED')).length;
    final percentage = notifications.isEmpty ? 0.0 : approvedCount / notifications.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6063EE), Color(0xFF303F9F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6063EE).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.9), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'BACKEND FEED',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Temporary mock notifications',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$createdCount created events and $approvedCount approved events are available for backend testing.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: DonutChartPainter(
                percentage: percentage,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: const Color(0xFF69FF87),
                strokeWidth: 4,
              ),
              child: Center(
                child: Text(
                  '${(percentage * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationModel> _filteredNotifications(List<NotificationModel> notifications) {
    return switch (_selectedTabIndex) {
      1 => notifications.where((item) => item.title.contains('APPROVED')).toList(),
      2 => notifications.where((item) => item.title.contains('Created')).toList(),
      _ => notifications,
    };
  }

  _NotificationStyle _notificationStyle(NotificationModel notification) {
    if (notification.title.contains('APPROVED')) {
      return _NotificationStyle(
        accentColor: secondaryColor,
        iconBgColor: secondaryContainer,
        iconColor: const Color(0xFF00732C),
        icon: Icons.check_circle,
      );
    }
    if (notification.title.contains('REJECTED')) {
      return _NotificationStyle(
        accentColor: const Color(0xFFB3261E),
        iconBgColor: const Color(0xFFFFE8E7),
        iconColor: const Color(0xFFB3261E),
        icon: Icons.gpp_bad,
      );
    }
    if (notification.title.contains('REVIEW')) {
      return _NotificationStyle(
        accentColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFFF1CC),
        iconColor: const Color(0xFF9A6700),
        icon: Icons.rule,
      );
    }
    return _NotificationStyle(
      accentColor: tertiaryContainer,
      iconBgColor: const Color(0xFFE0E3E5),
      iconColor: tertiaryColor,
      icon: Icons.notifications_none,
    );
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.accentColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.icon,
  });

  final Color accentColor;
  final Color iconBgColor;
  final Color iconColor;
  final IconData icon;
}

class DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;

  DonutChartPainter({
    required this.percentage,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
