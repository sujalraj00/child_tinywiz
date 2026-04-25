import 'package:flutter/material.dart';
import 'package:child_tinywiz/usage_stats_service.dart';
import 'core/di/service_locator.dart';

class UsageStatsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const UsageStatsScreen({Key? key, required this.onBack}) : super(key: key);
  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  List<AppUsageInfo> _usageStats = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadData();
  }

  /// Check permission and load usage data
  Future<void> _checkPermissionAndLoadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final hasPermission = await UsageStatsService.hasUsagePermission();

      if (hasPermission) {
        final stats = await UsageStatsService.getUsageStats();
        setState(() {
          _hasPermission = true;
          _usageStats = stats;
          _isLoading = false;
        });
        // Send usage stats to backend via websocket
        _sendUsageStatsToBackend(stats);
      } else {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  /// Request usage access permission
  Future<void> _requestPermission() async {
    await UsageStatsService.openUsageSettings();

    // Show dialog explaining what to do
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Usage Access'),
        content: const Text(
          'Please find this app in the list and toggle the switch to grant usage access permission. Then return to the app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Recheck permission after user returns
              Future.delayed(const Duration(seconds: 1), () {
                _checkPermissionAndLoadData();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Calculate total usage time across all apps
  int _getTotalUsageTime() {
    return _usageStats.fold(0, (sum, app) => sum + app.totalTimeInForeground);
  }

  /// Send usage stats to backend via websocket
  void _sendUsageStatsToBackend(List<AppUsageInfo> stats) {
    try {
      final socketRepository = ServiceLocator.socketRepository;

      if (socketRepository.isConnected) {
        // Convert AppUsageInfo to Map for transmission
        final usageStatsData = stats.map((app) {
          return {
            'packageName': app.packageName,
            'appName': app.appName,
            'totalTimeInForeground': app.totalTimeInForeground,
            'lastTimeUsed': app.lastTimeUsed,
            'hours': app.hours,
            'minutes': app.minutes,
            'seconds': app.seconds,
            'formattedTime': app.formattedTime,
            'isSocialMedia': app.isSocialMediaApp(),
            'usagePercentage': app.getUsagePercentage(_getTotalUsageTime()),
          };
        }).toList();

        // Calculate summary data
        final totalUsageTime = _getTotalUsageTime();
        final socialMediaCount = stats
            .where((app) => app.isSocialMediaApp())
            .length;

        final summaryData = {
          'totalApps': stats.length,
          'totalUsageTime': totalUsageTime,
          'socialMediaApps': socialMediaCount,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Send usage stats
        socketRepository.sendUsageStats([
          {'summary': summaryData, 'apps': usageStatsData},
        ]);

        print('✅ Usage stats sent to backend: ${stats.length} apps');
      } else {
        print('⚠️ Socket not connected, cannot send usage stats');
      }
    } catch (e) {
      print('❌ Error sending usage stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'App Usage',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF6C63FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: widget.onBack,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
              onPressed: _checkPermissionAndLoadData,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading usage statistics...'),
          ],
        ),
      );
    }
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }
    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }
    if (_usageStats.isEmpty) {
      return _buildEmptyState();
    }
    return _buildUsageStatsList();
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Usage Access Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'To show app usage statistics, this app needs usage access permission. This permission allows us to read how long you\'ve used other apps.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.settings),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _checkPermissionAndLoadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Usage Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'No app usage data found for the last 24 hours. Use some apps and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatsList() {
    final totalUsageTime = _getTotalUsageTime();

    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8A2BE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'Total Apps',
                _usageStats.length.toString(),
                Icons.grid_view_rounded,
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildSummaryItem(
                'Total Time',
                _formatTotalTime(totalUsageTime),
                Icons.timer_rounded,
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildSummaryItem(
                'Social',
                _usageStats
                    .where((app) => app.isSocialMediaApp())
                    .length
                    .toString(),
                Icons.people_alt_rounded,
              ),
            ],
          ),
        ),

        // Apps List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _usageStats.length,
            itemBuilder: (context, index) {
              final app = _usageStats[index];
              final percentage = app.getUsagePercentage(totalUsageTime);

              return _buildUsageCard(app, percentage);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUsageCard(AppUsageInfo app, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: app.isSocialMediaApp()
                    ? Color(0xFFFF9100).withOpacity(0.1)
                    : Color(0xFF00E676).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                app.isSocialMediaApp() ? Icons.people_alt_rounded : Icons.app_shortcut_rounded,
                color: app.isSocialMediaApp() ? Color(0xFFFF9100) : Color(0xFF00C853),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          app.appName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF4A148C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        app.formattedTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: app.isSocialMediaApp()
                              ? Color(0xFFFF9100)
                              : Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        app.isSocialMediaApp()
                            ? Color(0xFFFF9100)
                            : Color(0xFF00E676),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}% of total usage',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTotalTime(int totalTimeMs) {
    final hours = totalTimeMs ~/ (1000 * 60 * 60);
    final minutes = (totalTimeMs % (1000 * 60 * 60)) ~/ (1000 * 60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
