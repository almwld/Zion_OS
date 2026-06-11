import 'package:flutter/material.dart';
import 'dart:io';

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  List<Map<String, dynamic>> _processes = [];
  List<Map<String, dynamic>> _filteredProcesses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'cpu';
  bool _sortAscending = false;
  int _selectedTab = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadProcesses();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadProcesses();
    });
  }

  Future<void> _loadProcesses() async {
    try {
      final result = await Process.run('ps', ['-e', '-o', 'pid,ppid,user,%cpu,%mem,cmd'], runInShell: true);
      final lines = result.stdout.toString().split('\n');
      
      final List<Map<String, dynamic>> processes = [];
      for (var i = 1; i < lines.length && i < 50; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 6) {
          processes.add({
            'pid': parts[0],
            'ppid': parts[1],
            'user': parts[2],
            'cpu': double.tryParse(parts[3]) ?? 0,
            'mem': double.tryParse(parts[4]) ?? 0,
            'name': parts.sublist(5).join(' ').split('/').last,
            'fullName': parts.sublist(5).join(' '),
          });
        }
      }
      
      setState(() {
        _processes = processes;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(_processes);
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p['pid'].toString().contains(_searchQuery)
      ).toList();
    }
    
    if (_selectedTab == 1) {
      filtered = filtered.where((p) => p['cpu'] > 10).toList();
    } else if (_selectedTab == 2) {
      filtered = filtered.where((p) => p['mem'] > 20).toList();
    }
    
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'cpu':
          comparison = a['cpu'].compareTo(b['cpu']);
          break;
        case 'mem':
          comparison = a['mem'].compareTo(b['mem']);
          break;
        case 'name':
          comparison = a['name'].compareTo(b['name']);
          break;
        default:
          comparison = a['cpu'].compareTo(b['cpu']);
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {
      _filteredProcesses = filtered;
    });
  }

  Future<void> _killProcess(String pid, String name) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Process', style: TextStyle(color: Color(0xFF00BCD4))),
        content: Text('Kill process $name (PID: $pid)?', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kill', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await Process.run('kill', ['-9', pid], runInShell: true);
        _loadProcesses();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Process $name terminated'), backgroundColor: const Color(0xFF00BCD4)),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to terminate process'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCpu = _processes.fold<double>(0, (sum, p) => sum + p['cpu']);
    final totalMem = _processes.fold<double>(0, (sum, p) => sum + p['mem']);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Task Manager', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: _loadProcesses,
          ),
        ],
        bottom: TabBar(
          onTap: (index) => setState(() {
            _selectedTab = index;
            _applyFilters();
          }),
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'All'),
            Tab(icon: Icon(Icons.warning), text: 'High CPU'),
            Tab(icon: Icon(Icons.memory), text: 'High RAM'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Processes', _processes.length.toString()),
                _buildStatItem('Total CPU', '${totalCpu.toStringAsFixed(1)}%'),
                _buildStatItem('Total RAM', '${totalMem.toStringAsFixed(1)}%'),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                hintText: 'Search by name or PID...',
                hintStyle: const TextStyle(color: Colors.white38),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF00BCD4)),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('Sort by:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(width: 8),
                _buildSortChip('CPU', 'cpu'),
                _buildSortChip('RAM', 'mem'),
                _buildSortChip('Name', 'name'),
                const Spacer(),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, color: const Color(0xFF00BCD4), size: 18),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Process List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))
                : _filteredProcesses.isEmpty
                    ? const Center(child: Text('No processes found', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: _filteredProcesses.length,
                        itemBuilder: (context, index) {
                          final process = _filteredProcesses[index];
                          final cpuColor = process['cpu'] > 50 ? Colors.red : 
                                          process['cpu'] > 25 ? Colors.orange : Colors.green;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.code, color: Color(0xFF00BCD4), size: 20),
                              ),
                              title: Text(
                                process['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'PID: ${process['pid']} | User: ${process['user']}',
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cpuColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${process['cpu'].toStringAsFixed(1)}%',
                                      style: TextStyle(color: cpuColor, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00BCD4).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${process['mem'].toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 10),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.stop, color: Colors.red, size: 18),
                                    onPressed: () => _killProcess(process['pid'], process['name']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4).withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.white54,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
