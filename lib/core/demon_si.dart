import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'sage_si.dart';

class DemonSi extends SageSi {
  bool _berserkMode = false;
  bool _totalWar = false;
  int _totalDestroyed = 0;

  @override
  Future<void> awaken() async {
    await super.awaken();
    _log('👿 وضع الشيطان مُفعّل');
  }

  void activateBerserkMode() {
    _berserkMode = true;
    _log('💀💀💀 وضع الهياج مُفعّل 💀💀💀');
  }

  void activateTotalWar() {
    _totalWar = true;
    _berserkMode = true;
    _log('🔥🔥🔥 الحرب الشاملة مُفعّلة 🔥🔥🔥');
  }

  Future<String> annihilate(String target) async {
    _log('💥 تدمير شامل لـ: $target');
    try {
      await Process.run('ping', ['-c', '1', target], runInShell: true);
    } catch (_) {}
    _totalDestroyed++;
    return '💀 تم تدمير $target بالكامل.';
  }

  Future<String> ddosHell(String target, {int duration = 300}) async {
    _log('🌊 بدء هجوم DDoS جهنمي على: $target');
    return '🔥 تم الهجوم على $target';
  }

  Future<String> destroyNetwork(String subnet) async {
    _log('💣 تدمير الشبكة: $subnet');
    return '🔥 تم تدمير الشبكة $subnet';
  }

  Future<String> apocalypse() async {
    _log('💀💀💀 نهاية العالم 💀💀💀');
    activateTotalWar();
    return '☠️ اكتملت نهاية العالم.';
  }

  Map<String, dynamic> getDemonReport() {
    return {
      'berserk_mode': _berserkMode,
      'total_war': _totalWar,
      'total_destroyed': _totalDestroyed,
    };
  }
}
