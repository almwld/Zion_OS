import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:riverpod/riverpod.dart';
import '../demon_si.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  final DemonSi _si = DemonSi();
  bool _siAwake = false;

  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      if (command == 'awaken' || command == 'start_ai') {
        if (!_siAwake) { _siAwake = true; _si.awaken(); return '👿 Si الشيطان استيقظ.'; }
        return '👿 Si مستيقظ.';
      }
      if (command == 'berserk') { _si.activateBerserkMode(); return '💀 هياج!'; }
      if (command == 'total_war') { _si.activateTotalWar(); return '🔥 حرب شاملة!'; }
      if (command == 'annihilate') return await _si.annihilate(target ?? 'unknown');
      if (command == 'ddos_hell') return await _si.ddosHell(target ?? 'unknown');
      if (command == 'destroy_network') return await _si.destroyNetwork(target ?? '192.168.1');
      if (command == 'apocalypse') return await _si.apocalypse();
      if (command == 'demon_report') return const JsonEncoder.withIndent('  ').convert(_si.getDemonReport());
      if (command == 'si_sleep') { _siAwake = false; return '😴 Si نام.'; }
      if (command == 'help') return _helpText();

      if (_siAwake) return await _si.executeUserCommand(command, target: target);

      switch (command) {
        case 'ping': return await _ping(target ?? '127.0.0.1');
        case 'port_scan': return await _portScan(target ?? '127.0.0.1');
        case 'system_info': return _systemInfo();
        default: return 'Unknown: $command';
      }
    } catch (e) { return 'Error: $e'; }
  }

  Future<String> _ping(String t) async { try { return (await Process.run('ping', ['-c', '4', t], runInShell: true)).stdout.toString(); } catch (e) { return 'Ping failed: $e'; } }
  Future<String> _portScan(String t) async { final p = [21,22,23,25,53,80,443,8080,8443]; final o = <String>[]; for (final x in p) { try { final s = await Socket.connect(t, x, timeout: const Duration(milliseconds: 500)); o.add('$x (open)'); s.destroy(); } catch (_) {} } return 'Port scan on $t:\n${o.isNotEmpty ? o.join('\n') : "No open ports found"}'; }
  String _systemInfo() => 'OS: ${Platform.operatingSystem}\nCPU: ${Platform.numberOfProcessors} cores';

  String _helpText() => '''
=== DEMON Si ===
awaken      - إيقاظ
berserk     - هياج
total_war   - حرب
annihilate  - تدمير
ddos_hell   - DDoS
apocalypse  - نهاية
help        - مساعدة
===============
''';
}
