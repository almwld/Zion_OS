import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScannerApp extends StatefulWidget {
  const QRScannerApp({super.key});

  @override
  State<QRScannerApp> createState() => _QRScannerAppState();
}

class _QRScannerAppState extends State<QRScannerApp> {
  final MobileScannerController _scannerController = MobileScannerController();
  String _scannedResult = '';
  String _qrText = '';
  bool _isScanning = true;
  bool _torchOn = false;
  
  // QR Code History
  List<Map<String, dynamic>> _scanHistory = [];
  
  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
  
  void _toggleTorch() {
    setState(() {
      _torchOn = !_torchOn;
      _scannerController.toggleTorch();
    });
  }
  
  void _toggleCamera() {
    setState(() {
      _scannerController.switchCamera();
    });
  }
  
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _scannedResult = code;
          _isScanning = false;
          _scanHistory.insert(0, {
            'code': code,
            'time': DateTime.now().toIso8601String(),
            'type': 'QR Code',
          });
          if (_scanHistory.length > 20) _scanHistory.removeLast();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned: $code'),
            backgroundColor: const Color(0xFF00BCD4),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard'), backgroundColor: Color(0xFF00BCD4)),
                );
              },
            ),
          ),
        );
        break;
      }
    }
  }
  
  void _generateQR() {
    if (_qrText.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Generated QR Code', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: _qrText,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(_qrText, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _newScan() {
    setState(() {
      _scannedResult = '';
      _isScanning = true;
    });
  }
  
  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Scan History', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _scanHistory.isEmpty
                  ? const Center(child: Text('No history', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      itemCount: _scanHistory.length,
                      itemBuilder: (context, index) {
                        final item = _scanHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.qr_code, color: Color(0xFF00BCD4)),
                          title: Text(item['code'], style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(_formatDate(item['time']), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, color: Color(0xFF00BCD4), size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: item['code']));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied'), backgroundColor: Color(0xFF00BCD4)),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _qrText = item['code'];
                              _generateQR();
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR Scanner', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF00BCD4)),
            onPressed: _showHistory,
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Area
          Expanded(
            flex: 2,
            child: _isScanning
                ? Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                      // Scanner Overlay
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00BCD4), width: 2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BCD4).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.all(40),
                      ),
                      // Corner markers
                      Positioned(
                        top: 30,
                        left: 30,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                              left: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                              right: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 30,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                              left: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        right: 30,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                              right: BorderSide(color: const Color(0xFF00BCD4), width: 3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF00BCD4), size: 60),
                          const SizedBox(height: 16),
                          Text(
                            _scannedResult,
                            style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _newScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BCD4),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Scan Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          
          // QR Generator Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text('QR Code Generator', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => setState(() => _qrText = v),
                        decoration: const InputDecoration(
                          hintText: 'Enter text or URL',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _qrText.isNotEmpty ? _generateQR : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: const Text('Generate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.flash_on,
                  label: 'Torch',
                  onTap: _toggleTorch,
                  active: _torchOn,
                ),
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  label: 'Switch',
                  onTap: _toggleCamera,
                  active: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF00BCD4) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: active ? Colors.black : const Color(0xFF00BCD4), size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: active ? const Color(0xFF00BCD4) : Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
  
  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}';
  }
}
