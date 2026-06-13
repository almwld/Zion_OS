import 'dart:io';

class KaliToolsManager {
  static final KaliToolsManager _instance = KaliToolsManager._internal();
  factory KaliToolsManager() => _instance;
  KaliToolsManager._internal();
  
  List<Map<String, dynamic>> _tools = [];
  
  Future<void> loadTools() async {
    // تحميل الأدوات من الملف الموجود
    final toolsFile = File('/data/data/com.termux/files/home/downloads/kali-armhf/kali_tools_list.txt');
    if (await toolsFile.exists()) {
      final content = await toolsFile.readAsString();
      final lines = content.split('\n');
      
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          _tools.add({
            'name': line.trim(),
            'installed': false,
            'icon': _getIconForTool(line.trim()),
            'description': 'Tool for security testing',
          });
        }
      }
    }
    
    // إذا لم يكن الملف موجوداً، أضف أدوات افتراضية
    if (_tools.isEmpty) {
      _tools = [
        {'name': 'nmap', 'installed': false, 'icon': Icons.network_wifi, 'description': 'Network discovery'},
        {'name': 'hydra', 'installed': false, 'icon': Icons.vpn_key, 'description': 'Password cracker'},
        {'name': 'sqlmap', 'installed': false, 'icon': Icons.storage, 'description': 'SQL injection'},
        {'name': 'john', 'installed': false, 'icon': Icons.lock, 'description': 'Password cracker'},
        {'name': 'aircrack-ng', 'installed': false, 'icon': Icons.wifi, 'description': 'WiFi security'},
        {'name': 'metasploit', 'installed': false, 'icon': Icons.security, 'description': 'Exploit framework'},
        {'name': 'burpsuite', 'installed': false, 'icon': Icons.public, 'description': 'Web security'},
        {'name': 'wireshark', 'installed': false, 'icon': Icons.analytics, 'description': 'Packet analyzer'},
        {'name': 'nikto', 'installed': false, 'icon': Icons.bug_report, 'description': 'Web scanner'},
        {'name': 'dirb', 'installed': false, 'icon': Icons.folder, 'description': 'Directory brute force'},
      ];
    }
  }
  
  List<Map<String, dynamic>> get tools => _tools;
  
  Future<void> installTool(String toolName) async {
    final index = _tools.indexWhere((t) => t['name'] == toolName);
    if (index != -1) {
      _tools[index]['installed'] = true;
      // محاكاة التثبيت
      await Future.delayed(Duration(seconds: 1));
    }
  }
  
  Future<void> uninstallTool(String toolName) async {
    final index = _tools.indexWhere((t) => t['name'] == toolName);
    if (index != -1) {
      _tools[index]['installed'] = false;
      await Future.delayed(Duration(seconds: 1));
    }
  }
  
  Future<String> executeTool(String toolName, String args) async {
    try {
      final result = await Process.run(toolName, args.split(' '), 
        workingDirectory: '/data/data/com.zion.os/files/home',
        runInShell: true,
      );
      return result.stdout.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  IconData _getIconForTool(String name) {
    if (name.contains('nmap')) return Icons.network_wifi;
    if (name.contains('hydra')) return Icons.vpn_key;
    if (name.contains('sql')) return Icons.storage;
    if (name.contains('aircrack')) return Icons.wifi;
    if (name.contains('metasploit')) return Icons.security;
    return Icons.build;
  }
}
