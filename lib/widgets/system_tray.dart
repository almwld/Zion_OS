import 'package:flutter/material.dart';

class SystemTray extends StatefulWidget {
  const SystemTray({super.key});

  @override
  State<SystemTray> createState() => _SystemTrayState();
}

class _SystemTrayState extends State<SystemTray> {
  String _currentTime = "";
  String _currentDate = "";

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          _currentDate = "${now.day}/${now.month}";
        });
        _updateDateTime();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          const Icon(Icons.network_wifi, size: 16, color: Color(0xFF00BCD4)),
          const SizedBox(width: 12),
          const Icon(Icons.volume_up, size: 16, color: Color(0xFF00BCD4)),
          const SizedBox(width: 12),
          const Icon(Icons.battery_full, size: 16, color: Color(0xFF00BCD4)),
          const SizedBox(width: 15),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFF00BCD4).withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currentTime,
                style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                _currentDate,
                style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
