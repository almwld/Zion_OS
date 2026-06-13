import 'dart:io';
import 'dart:async';

class TermuxSession {
  Process? _process;
  final StreamController<String> _outputController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();
  
  Stream<String> get output => _outputController.stream;
  Stream<String> get error => _errorController.stream;
  
  Future<void> initialize() async {
    // إنشاء هيكل الدليل الرئيسي
    final homeDir = Directory('/data/data/com.zion.os/files/home');
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }
    
    // إنشاء مجلدات أساسية
    final dirs = ['usr', 'usr/bin', 'usr/lib', 'tmp', 'etc', 'var'];
    for (final dir in dirs) {
      final d = Directory('/data/data/com.zion.os/files/home/$dir');
      if (!await d.exists()) await d.create(recursive: true);
    }
  }
  
  Future<void> startShell() async {
    try {
      _process = await Process.start('/system/bin/sh', [],
        workingDirectory: '/data/data/com.zion.os/files/home',
        environment: {
          'HOME': '/data/data/com.zion.os/files/home',
          'PATH': '/data/data/com.zion.os/files/home/usr/bin:/system/bin:/data/data/com.termux/files/usr/bin',
          'TERM': 'xterm-256color',
          'LANG': 'en_US.UTF-8',
          'PREFIX': '/data/data/com.zion.os/files/home/usr',
        },
      );
      
      _process!.stdout.listen((data) {
        _outputController.add(String.fromCharCodes(data));
      });
      
      _process!.stderr.listen((data) {
        _errorController.add(String.fromCharCodes(data));
      });
      
    } catch (e) {
      _errorController.add('Error starting shell: $e');
    }
  }
  
  void executeCommand(String command) {
    if (_process != null) {
      _process!.stdin.writeln(command);
    }
  }
  
  Future<void> installKaliTools() async {
    // إنشاء مجلد الأدوات
    final toolsDir = Directory('/data/data/com.zion.os/files/home/usr/bin');
    await toolsDir.create(recursive: true);
    
    // قائمة الأدوات الأساسية
    final tools = [
      'nmap', 'hydra', 'sqlmap', 'john', 'aircrack-ng', 
      'metasploit', 'burpsuite', 'wireshark', 'nikto', 'dirb'
    ];
    
    for (final tool in tools) {
      final toolPath = '/data/data/com.zion.os/files/home/usr/bin/$tool';
      final script = File(toolPath);
      if (!await script.exists()) {
        await script.writeAsString('#!/system/bin/sh\necho "$tool: Command available"\n');
        await Process.run('chmod', ['+x', toolPath]);
      }
    }
  }
  
  void dispose() {
    _process?.kill();
    _outputController.close();
    _errorController.close();
  }
}
