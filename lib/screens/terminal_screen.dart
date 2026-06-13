import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  static const platform = MethodChannel('com.zion.os/termux');
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _output = [];
  
  @override
  void initState() {
    super.initState();
    _initTermux();
  }
  
  Future<void> _initTermux() async {
    try {
      final bool initialized = await platform.invokeMethod('initTermux');
      if (initialized) {
        _addOutput('✅ Termux initialized successfully');
        _addOutput('🔥 Zion Terminal v1.0 ready');
        _addOutput('');
        _addOutput('zion@termux:~\\$ ');
      }
    } catch (e) {
      _addOutput('❌ Error: $e');
    }
  }
  
  void _addOutput(String text) {
    setState(() {
      _output.add(text);
    });
    _scrollToBottom();
  }
  
  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;
    
    _addOutput('\\$ $command');
    platform.invokeMethod('executeCommand', {'command': command});
    _inputController.clear();
    
    // أوامر مدمجة للاختبار
    if (command.trim() == 'help') {
      _addOutput('Available commands:');
      _addOutput('  help     - Show this help');
      _addOutput('  clear    - Clear screen');
      _addOutput('  pkg      - Termux package manager');
      _addOutput('  apt      - APT package manager');
    } else if (command.trim() == 'clear') {
      setState(() => _output.clear());
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Zion Terminal', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.green),
            onPressed: () => setState(() => _output.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _output.length,
              itemBuilder: (context, index) {
                return Text(
                  _output[index],
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
          Container(
            height: 50,
            color: Colors.grey[900],
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Text(
                  'zion@termux:~\\$ ',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'أدخل أمر Termux...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onSubmitted: _executeCommand,
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
