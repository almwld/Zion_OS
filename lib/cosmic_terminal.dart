import 'package:flutter/material.dart';
import 'core/services/kali_chroot_service.dart';

class CosmicTerminal extends StatefulWidget {
  const CosmicTerminal({super.key});

  @override
  State<CosmicTerminal> createState() => _CosmicTerminalState();
}

class _CosmicTerminalState extends State<CosmicTerminal> {
  final TextEditingController _cmdCtrl = TextEditingController();
  final List<String> _output = ['Zion Terminal v4.0 - Kali Ready', 'اكتب "help" للمساعدة.'];
  final ScrollController _scrollCtrl = ScrollController();
  bool _kaliAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkKali();
  }

  Future<void> _checkKali() async {
    final available = await KaliChrootService.isKaliAvailable();
    setState(() {
      _kaliAvailable = available;
      if (available) {
        _output.add('✅ Kali Linux متصل وجاهز.');
      } else {
        _output.add('⚠️ Kali Linux غير متصل. الأوامر محلية فقط.');
      }
    });
  }

  Future<void> _execute(String cmd) async {
    setState(() {
      _output.add('> $cmd');
    });

    if (_kaliAvailable && _isKaliCommand(cmd)) {
      try {
        final result = await KaliChrootService.execute(cmd);
        setState(() {
          if (result['success'] == true) {
            _output.add(result['stdout'] ?? '(no output)');
          } else {
            _output.add('Error: ${result['stderr'] ?? "Unknown"}');
          }
        });
      } catch (e) {
        setState(() {
          _output.add('Error connecting to Kali: $e');
        });
      }
    } else {
      _executeLocal(cmd);
    }

    _cmdCtrl.clear();
    _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  bool _isKaliCommand(String cmd) {
    final kaliCommands = ['nmap', 'msfconsole', 'sqlmap', 'hydra', 'john', 'aircrack-ng', 'nikto', 'dirb', 'wpscan', 'tshark', 'tcpdump', 'metasploit', 'msf', 'gobuster', 'ffuf'];
    return kaliCommands.any((k) => cmd.trim().toLowerCase().startsWith(k));
  }

  void _executeLocal(String cmd) {
    switch (cmd.trim().toLowerCase().split(' ').first) {
      case 'help':
        _output.add('ls, pwd, whoami, date, clear, nmap, msfconsole, help');
        if (_kaliAvailable) _output.add('Kali commands: nmap, msfconsole, sqlmap, hydra, john, aircrack-ng, nikto, dirb, wpscan');
        break;
      case 'clear':
        _output.clear();
        break;
      case 'ls':
        _output.add('bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var');
        break;
      case 'pwd':
        _output.add('/home/zion');
        break;
      case 'whoami':
        _output.add('root');
        break;
      case 'date':
        _output.add(DateTime.now().toString());
        break;
      default:
        _output.add('command not found: ${cmd.split(' ').first}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('الطرفية الكونية', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'Cairo')),
            const SizedBox(width: 8),
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _kaliAvailable ? Colors.green : Colors.red)),
          ],
        ),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.close, color: Color(0xFF00FF41)), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _output.length,
              itemBuilder: (context, i) => Text(
                _output[i],
                style: TextStyle(
                  color: _output[i].startsWith('>') ? const Color(0xFF00FF41) : (_output[i].startsWith('Error') ? Colors.red : Colors.white70),
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0A0E0A), border: Border(top: BorderSide(color: Color(0xFF1A3A1A)))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('zion:~# ', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
                Expanded(
                  child: TextField(
                    controller: _cmdCtrl,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    cursorColor: const Color(0xFF00FF41),
                    onSubmitted: _execute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
