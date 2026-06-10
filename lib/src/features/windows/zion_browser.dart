import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZionBrowser extends StatefulWidget {
  const ZionBrowser({super.key});

  @override
  State<ZionBrowser> createState() => _ZionBrowserState();
}

class _ZionBrowserState extends State<ZionBrowser> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _urlController.text = url;
          },
          onPageFinished: (url) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://www.google.com'));
    _urlController.text = 'https://www.google.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => _controller.goBack(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () => _controller.goForward(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _controller.reload(),
                ),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter URL',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                    onSubmitted: (url) {
                      var finalUrl = url;
                      if (!url.startsWith('http')) {
                        finalUrl = 'https://$url';
                      }
                      _controller.loadRequest(Uri.parse(finalUrl));
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
