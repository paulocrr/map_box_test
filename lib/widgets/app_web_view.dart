import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebView extends StatefulWidget {
  final String url;
  const AppWebView({required this.url, super.key});

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late final WebViewController _controller;
  var loadPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadPercentage = progress / 100;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mapas'),
      ),
      body: loadPercentage < 1
          ? Center(
              child: CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 5.0,
                percent: loadPercentage,
                center: Text('${(loadPercentage * 100).toStringAsFixed(0)} %'),
                progressColor: Colors.green,
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
