import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StreambertWebPlayerPage extends StatefulWidget {
  const StreambertWebPlayerPage({
    super.key,
    required this.url,
    required this.title,
    required this.sourceLabel,
  });

  final Uri url;
  final String title;
  final String sourceLabel;

  @override
  State<StreambertWebPlayerPage> createState() =>
      _StreambertWebPlayerPageState();
}

class _StreambertWebPlayerPageState extends State<StreambertWebPlayerPage> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              widget.sourceLabel,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: () => _controller.reload(),
            icon: const Icon(LucideIcons.refreshCw),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
