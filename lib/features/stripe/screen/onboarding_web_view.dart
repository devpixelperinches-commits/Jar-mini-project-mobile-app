import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnboardingWebViewScreen extends StatefulWidget {
  final String url;
  const OnboardingWebViewScreen({super.key, required this.url});

  @override
  State<OnboardingWebViewScreen> createState() =>
      _OnboardingWebViewScreenState();
}

class _OnboardingWebViewScreenState extends State<OnboardingWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint("Webview Navigating to --------------: $url");

            // ---- 🔥 React Native equivalent logic ----
            final uri = Uri.parse(url);
            final lastSegment = uri.pathSegments.isNotEmpty
                ? uri.pathSegments.last
                : "";

            debugPrint("Last URL segment ----------------: $lastSegment");

            if (lastSegment == "success") {
              Navigator.pop(context, true); // success
              return NavigationDecision.prevent;
            }
            // ------------------------------------------

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Onboarding")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
