import 'package:flutter/material.dart';
import 'dart:async';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'System Update',
      'message': 'Zion OS 2027 v4.0.1 is available',
      'time': 'Just now',
      'icon': Icons.system_update,
      'color': 0xFF00BCD4,
      'read': false,
      'type': 'system',
    },
    {
      'id': '2',
      'title': 'Security Alert',
      'message': 'Unauthorized access attempt blocked',
      'time': '5 min ago',
      'icon': Icons.security,
      'color': 0xFFFF5722,
      'read': false,
      'type': 'security',
    },
    {
      'id': '3',
      'title': 'Network Connected',
      'message': 'Connected to secure network',
      'time': '1 hour ago',
      'icon': Icons.network_wifi,
      'color': 0xFF4CAF50,
      'read': true,
      'type': 'network',
    },
    {
      'id': '4',
      'title': 'Storage Cleaned',
      'message': 'Cleaned 2.5GB of cache files',
      'time': '2 hours ago',
      'icon': Icons.cleaning_services,
      'color': 0xFF00BCD4,
      'read': true,
      'type': 'system',
    },
    {
      'id': '5',
      'title': 'New Tool Available',
      'message': 'Advanced Network Scanner v2.0',
      'time': 'Yesterday',
      'icon': Icons.new_releases,
      'color': 0xFF9C27B0,
      'read': false,
      'type': 'update',
    },
  ];

  String _selectedFilter = 'all';
  bool _isLoading = false;

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'all') return _notifications;
    if (_selectedFilter == 'unread') return _notifications.where((n) => !n['read']).toList();
    return _notifications.where((n) => n['type'] == _selectedFilter).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n['read']).length;

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) _notifications[index]['read'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cleared'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF00BCD4)),
            const SizedBox(width: 8),
            const Text('Notification Center', style: TextStyle(color: Color(0xFF00BCD4))),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 10),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF00BCD4)),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Color(0xFF00BCD4)),
            onPressed: _clearAll,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all', Icons.list),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 'unread', Icons.mark_email_unread),
                const SizedBox(width: 8),
                _buildFilterChip('System', 'system', Icons.computer),
                const SizedBox(width: 8),
                _buildFilterChip('Security', 'security', Icons.security),
                const SizedBox(width: 8),
                _buildFilterChip('Network', 'network', Icons.network_wifi),
                const SizedBox(width: 8),
                _buildFilterChip('Update', 'update', Icons.update),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF00BCD4), height: 1),
          
          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('No notifications', style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isUnread = !notification['read'];
                      
                      return Dismissible(
                        key: Key(notification['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNotification(notification['id']),
                        child: GestureDetector(
                          onTap: () => _markAsRead(notification['id']),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUnread 
                                  ? const Color(0xFF00BCD4).withOpacity(0.1)
                                  : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUnread 
                                    ? const Color(0xFF00BCD4).withOpacity(0.5)
                                    : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(notification['color']).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    notification['icon'],
                                    color: Color(notification['color']),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification['title'],
                                        style: TextStyle(
                                          color: isUnread ? const Color(0xFF00BCD4) : Colors.white,
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['message'],
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['time'],
                                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!notification['read'])
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00BCD4),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
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

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF00BCD4)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF00BCD4))),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: Colors.transparent,
      selectedColor: const Color(0xFF00BCD4),
      checkmarkColor: Colors.white,
    );
  }
}
