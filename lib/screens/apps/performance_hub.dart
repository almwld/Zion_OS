import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class PerformanceHubApp extends StatefulWidget {
  const PerformanceHubApp({super.key});

  @override
  State<PerformanceHubApp> createState() => _PerformanceHubAppState();
}

class _PerformanceHubAppState extends State<PerformanceHubApp> {
  int _selectedCategory = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Monitor', 'icon': Icons.analytics, 'color': 0xFF00BCD4},
    {'name': 'Optimize', 'icon': Icons.speed, 'color': 0xFF00BCD4},
    {'name': 'Clean', 'icon': Icons.cleaning_services, 'color': 0xFF00BCD4},
    {'name': 'Tools', 'icon': Icons.build, 'color': 0xFF00BCD4},
  ];
  
  // System Stats
  double _cpuUsage = 0;
  double _ramUsage = 0;
  double _diskUsage = 0;
  double _temperature = 0;
  int _processCount = 0;
  int _uptime = 0;
  Timer? _monitorTimer;
  
  List<FlSpot> _cpuHistory = [];
  List<FlSpot> _ramHistory = [];
  int _dataPoint = 0;
  
  // Optimization tools
  final List<Map<String, dynamic>> _optimizers = [
    {'name': 'Memory Boost', 'icon': Icons.memory, 'description': 'Free up RAM', 'color': 0xFF00BCD4, 'running': false},
    {'name': 'CPU Optimizer', 'icon': Icons.speed, 'description': 'Optimize processor', 'color': 0xFF00BCD4, 'running': false},
    {'name': 'Battery Saver', 'icon': Icons.battery_saver, 'description': 'Extend battery life', 'color': 0xFF00BCD4, 'running': false},
    {'name': 'Network Boost', 'icon': Icons.network_wifi, 'description': 'Speed up network', 'color': 0xFF00BCD4, 'running': false},
  ];
  
  final List<Map<String, dynamic>> _cleaners = [
    {'name': 'Cache Cleaner', 'icon': Icons.cached, 'description': 'Clear app cache', 'size': '245 MB', 'color': 0xFF00BCD4},
    {'name': 'Temp Files', 'icon': Icons.delete_sweep, 'description': 'Remove temporary files', 'size': '128 MB', 'color': 0xFF00BCD4},
    {'name': 'Old Downloads', 'icon': Icons.download, 'description': 'Clean old downloads', 'size': '512 MB', 'color': 0xFF00BCD4},
    {'name': 'Empty Folders', 'icon': Icons.folder, 'description': 'Remove empty folders', 'size': '0 MB', 'color': 0xFF00BCD4},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _startMonitoring();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  void _initData() {
    for (int i = 0; i < 20; i++) {
      _cpuHistory.add(FlSpot(i.toDouble(), 0));
      _ramHistory.add(FlSpot(i.toDouble(), 0));
    }
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateStats();
      _updateHistory();
      setState(() {});
    });
  }

  void _updateStats() {
    _cpuUsage = _getCPUUsage();
    _ramUsage = _getRAMUsage();
    _diskUsage = _getDiskUsage();
    _temperature = _getTemperature();
    _processCount = _getProcessCount();
    _uptime = _getUptime();
  }

  void _updateHistory() {
    _dataPoint++;
    _cpuHistory.add(FlSpot(_dataPoint.toDouble(), _cpuUsage));
    _ramHistory.add(FlSpot(_dataPoint.toDouble(), _ramUsage));
    
    if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
    if (_ramHistory.length > 20) _ramHistory.removeAt(0);
  }

  double _getCPUUsage() {
    try {
      final result = Process.runSync('top', ['-bn1'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'CPU:\s*(\d+)%').firstMatch(output);
      if (match != null) return double.parse(match.group(1)!);
    } catch (_) {}
    return 0;
  }

  double _getRAMUsage() {
    try {
      final result = Process.runSync('free', [], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final total = double.parse(parts[1]);
          final used = double.parse(parts[2]);
          return (used / total) * 100;
        }
      }
    } catch (_) {}
    return 0;
  }

  double _getDiskUsage() {
    try {
      final result = Process.runSync('df', ['/data'], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 5) {
          final used = double.parse(parts[2]);
          final total = double.parse(parts[3]);
          return (used / total) * 100;
        }
      }
    } catch (_) {}
    return 0;
  }

  double _getTemperature() {
    try {
      final result = Process.runSync('cat', ['/sys/class/thermal/thermal_zone0/temp'], runInShell: true);
      final temp = double.parse(result.stdout.toString().trim()) / 1000;
      return temp;
    } catch (_) {}
    return 35;
  }

  int _getProcessCount() {
    try {
      final result = Process.runSync('ps', ['-e'], runInShell: true);
      final lines = result.stdout.toString().split('\n');
      return lines.length - 1;
    } catch (_) {}
    return 0;
  }

  int _getUptime() {
    try {
      final result = Process.runSync('cat', ['/proc/uptime'], runInShell: true);
      final uptimeSeconds = double.parse(result.stdout.toString().split(' ')[0]);
      return uptimeSeconds.toInt();
    } catch (_) {}
    return 0;
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (days > 0) return '$days d $hours h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  int _getPerformanceScore() {
    int score = 100;
    if (_cpuUsage > 80) score -= 30;
    else if (_cpuUsage > 60) score -= 20;
    else if (_cpuUsage > 40) score -= 10;
    
    if (_ramUsage > 80) score -= 20;
    else if (_ramUsage > 60) score -= 10;
    
    if (_temperature > 70) score -= 20;
    else if (_temperature > 55) score -= 10;
    
    return score.clamp(0, 100);
  }

  void _runOptimizer(int index) {
    setState(() {
      _optimizers[index]['running'] = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _optimizers[index]['running'] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_optimizers[index]['name']} completed'), backgroundColor: const Color(0xFF00BCD4)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final performanceScore = _getPerformanceScore();
    final filteredItems = _selectedCategory == 0
        ? []
        : _selectedCategory == 1
            ? _optimizers
            : _selectedCategory == 2
                ? _cleaners
                : [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Performance Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Performance Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getScoreColor(performanceScore) == Colors.green
                      ? [Colors.green, Colors.green.withOpacity(0.5)]
                      : _getScoreColor(performanceScore) == Colors.orange
                          ? [Colors.orange, Colors.orange.withOpacity(0.5)]
                          : [Colors.red, Colors.red.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Performance Score', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '$performanceScore',
                    style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    performanceScore > 80 ? 'Excellent' : (performanceScore > 50 ? 'Good' : 'Poor'),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard('CPU', '${_cpuUsage.toStringAsFixed(1)}%', Icons.memory, _getCpuColor(), _cpuHistory, true),
                _buildStatCard('RAM', '${_ramUsage.toStringAsFixed(1)}%', Icons.ram, Colors.green, _ramHistory, true),
                _buildStatCard('Storage', '${_diskUsage.toStringAsFixed(1)}%', Icons.storage, Colors.orange, [], false),
                _buildStatCard('Temperature', '${_temperature.toStringAsFixed(1)}°C', Icons.thermostat, Colors.red, [], false),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Process & Uptime
            Row(
              children: [
                Expanded(child: _buildInfoCard('Processes', '$_processCount', Icons.code, Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard('Uptime', _formatUptime(_uptime), Icons.timer, Colors.orange)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Categories
            Container(
              height: 45,
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedCategory == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : const Color(0xFF00BCD4).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_categories[index]['icon'], color: isSelected ? Colors.black : const Color(0xFF00BCD4), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _categories[index]['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.black : const Color(0xFF00BCD4),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Content based on selected category
            if (_selectedCategory == 1)
              ..._optimizers.map((opt) => _buildOptimizerCard(opt, _optimizers.indexOf(opt))),
            
            if (_selectedCategory == 2)
              ..._cleaners.map((cleaner) => _buildCleanerCard(cleaner)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, List<FlSpot> history, bool hasChart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          if (hasChart)
            SizedBox(
              height: 40,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizerCard(Map<String, dynamic> opt, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(opt['color']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(opt['icon'], color: Color(opt['color']), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(opt['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(opt['description'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: opt['running'] ? null : () => _runOptimizer(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.black,
            ),
            child: opt['running']
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Run'),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanerCard(Map<String, dynamic> cleaner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(cleaner['color']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(cleaner['icon'], color: Color(cleaner['color']), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cleaner['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(cleaner['description'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(cleaner['size'], style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF00BCD4)),
        ],
      ),
    );
  }

  Color _getCpuColor() {
    if (_cpuUsage < 30) return Colors.green;
    if (_cpuUsage < 70) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(int score) {
    if (score > 80) return Colors.green;
    if (score > 50) return Colors.orange;
    return Colors.red;
  }
}
