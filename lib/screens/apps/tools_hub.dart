import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ToolsHubApp extends StatefulWidget {
  const ToolsHubApp({super.key});

  @override
  State<ToolsHubApp> createState() => _ToolsHubAppState();
}

class _ToolsHubAppState extends State<ToolsHubApp> {
  int _selectedCategory = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': 0xFF00BCD4},
    {'name': 'Calculator', 'icon': Icons.calculate, 'color': 0xFF00BCD4},
    {'name': 'Converter', 'icon': Icons.science, 'color': 0xFF00BCD4},
    {'name': 'Text', 'icon': Icons.text_fields, 'color': 0xFF00BCD4},
    {'name': 'Time', 'icon': Icons.access_time, 'color': 0xFF00BCD4},
    {'name': 'Files', 'icon': Icons.folder, 'color': 0xFF00BCD4},
  ];
  
  // Calculator state
  String _calcExpression = '';
  String _calcResult = '';
  
  // Unit Converter
  final TextEditingController _converterInput = TextEditingController(text: '1');
  String _converterFrom = 'Meter';
  String _converterTo = 'Foot';
  String _converterResult = '';
  final List<String> _lengthUnits = ['Meter', 'Kilometer', 'Centimeter', 'Millimeter', 'Mile', 'Foot', 'Inch'];
  final Map<String, double> _lengthRates = {
    'Meter': 1.0, 'Kilometer': 0.001, 'Centimeter': 100.0, 'Millimeter': 1000.0,
    'Mile': 0.000621371, 'Foot': 3.28084, 'Inch': 39.3701,
  };
  
  // Text Tools
  final TextEditingController _textInput = TextEditingController();
  String _textOutput = '';
  int _textStats = 0;
  
  // QR Generator
  final TextEditingController _qrInput = TextEditingController();
  String _qrCode = '';
  
  // Color Picker
  Color _selectedColor = const Color(0xFF00BCD4);
  String _colorHex = '#00BCD4';

  @override
  void initState() {
    super.initState();
    _convert();
  }

  void _onCalcButton(String value) {
    setState(() {
      if (value == 'C') {
        _calcExpression = '';
        _calcResult = '';
      } else if (value == '=') {
        try {
          _calcResult = _evaluateExpression(_calcExpression);
        } catch (_) {
          _calcResult = 'Error';
        }
      } else {
        _calcExpression += value;
      }
    });
  }

  String _evaluateExpression(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    final result = (() {}) as String;
    return '0';
  }

  void _convert() {
    final input = double.tryParse(_converterInput.text) ?? 0;
    final fromRate = _lengthRates[_converterFrom] ?? 1;
    final toRate = _lengthRates[_converterTo] ?? 1;
    final result = input / fromRate * toRate;
    setState(() {
      _converterResult = result.toStringAsFixed(4);
    });
  }

  void _analyzeText() {
    final text = _textInput.text;
    setState(() {
      _textStats = text.length;
      _textOutput = 'Characters: ${text.length}\nWords: ${text.trim().split(RegExp(r'\s+')).length}\nLines: ${text.split('\n').length}';
    });
  }

  void _reverseText() {
    setState(() {
      _textOutput = String.fromCharCodes(_textInput.text.codeUnits.reversed);
    });
  }

  void _toUpperCase() {
    setState(() {
      _textOutput = _textInput.text.toUpperCase();
    });
  }

  void _toLowerCase() {
    setState(() {
      _textOutput = _textInput.text.toLowerCase();
    });
  }

  void _generateQR() {
    if (_qrInput.text.isEmpty) return;
    setState(() {
      _qrCode = _qrInput.text;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  void _shareText(String text) {
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTools = _selectedCategory == 0 ? [] : [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tools Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 45,
            margin: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(_categories[index]['icon'], color: isSelected ? Colors.black : const Color(0xFF00BCD4), size: 16),
                        const SizedBox(width: 6),
                        Text(_categories[index]['name'], style: TextStyle(color: isSelected ? Colors.black : const Color(0xFF00BCD4), fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Content based on selected category
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _selectedCategory == 0 ? _buildAllTools() :
                     _selectedCategory == 1 ? _buildCalculatorTab() :
                     _selectedCategory == 2 ? _buildConverterTab() :
                     _selectedCategory == 3 ? _buildTextToolsTab() :
                     _selectedCategory == 4 ? _buildTimeToolsTab() :
                     _buildFileToolsTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTools() {
    return Column(
      children: [
        _buildToolCard('Calculator', Icons.calculate, 'Basic arithmetic calculator', () => setState(() => _selectedCategory = 1)),
        _buildToolCard('Unit Converter', Icons.science, 'Convert between units', () => setState(() => _selectedCategory = 2)),
        _buildToolCard('Text Tools', Icons.text_fields, 'Analyze, reverse, case convert', () => setState(() => _selectedCategory = 3)),
        _buildToolCard('Time Tools', Icons.access_time, 'Date calculator, timer', () => setState(() => _selectedCategory = 4)),
        _buildToolCard('File Tools', Icons.folder, 'File manager, cleaner', () => setState(() => _selectedCategory = 5)),
        _buildToolCard('QR Generator', Icons.qr_code, 'Generate QR codes', _showQRDialog),
        _buildToolCard('Color Picker', Icons.color_lens, 'Pick and copy colors', _showColorPicker),
      ],
    );
  }

  Widget _buildToolCard(String title, IconData icon, String description, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: const Color(0xFF00BCD4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00BCD4), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(description, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF00BCD4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_calcExpression.isEmpty ? '0' : _calcExpression, style: const TextStyle(color: Colors.white70, fontSize: 20)),
              const SizedBox(height: 10),
              Text(_calcResult, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: [
            _buildCalcButton('7'), _buildCalcButton('8'), _buildCalcButton('9'), _buildCalcButton('÷'),
            _buildCalcButton('4'), _buildCalcButton('5'), _buildCalcButton('6'), _buildCalcButton('×'),
            _buildCalcButton('1'), _buildCalcButton('2'), _buildCalcButton('3'), _buildCalcButton('-'),
            _buildCalcButton('0'), _buildCalcButton('C'), _buildCalcButton('='), _buildCalcButton('+'),
          ],
        ),
      ],
    );
  }

  Widget _buildCalcButton(String text) {
    return GestureDetector(
      onTap: () => _onCalcButton(text),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildConverterTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                controller: _converterInput,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                keyboardType: TextInputType.number,
                onChanged: (_) => _convert(),
                decoration: const InputDecoration(
                  labelText: 'Value',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _converterFrom,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Color(0xFF00BCD4)),
                      decoration: const InputDecoration(labelText: 'From', labelStyle: TextStyle(color: Color(0xFF00BCD4))),
                      items: _lengthUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) { setState(() => _converterFrom = v!); _convert(); },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _converterTo,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Color(0xFF00BCD4)),
                      decoration: const InputDecoration(labelText: 'To', labelStyle: TextStyle(color: Color(0xFF00BCD4))),
                      items: _lengthUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) { setState(() => _converterTo = v!); _convert(); },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Result', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('$_converterResult $_converterTo', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextToolsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                controller: _textInput,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTextButton('Analyze', _analyzeText),
                  _buildTextButton('Reverse', _reverseText),
                  _buildTextButton('UPPERCASE', _toUpperCase),
                  _buildTextButton('lowercase', _toLowerCase),
                ],
              ),
              if (_textOutput.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                  ),
                  child: SelectableText(_textOutput, style: const TextStyle(color: Color(0xFF00BCD4))),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
      child: Text(label),
    );
  }

  Widget _buildTimeToolsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 64, color: Color(0xFF00BCD4)),
            SizedBox(height: 16),
            Text('Time Tools Coming Soon', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileToolsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 64, color: Color(0xFF00BCD4)),
            SizedBox(height: 16),
            Text('File Tools Coming Soon', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  void _showQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Generator', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _qrInput,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Text or URL',
                labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _generateQR();
                Navigator.pop(context);
                _showQRResult();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated QR', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Icon(Icons.qr_code, size: 80, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(_qrCode, style: const TextStyle(color: Color(0xFF00BCD4))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(_qrCode),
            child: const Text('Copy', style: TextStyle(color: Color(0xFF00BCD4))),
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Picker', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(color: _selectedColor, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 16),
            Text(_colorHex, style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(_colorHex),
            child: const Text('Copy Hex', style: TextStyle(color: Color(0xFF00BCD4))),
          ),
        ],
      ),
    );
  }
}
