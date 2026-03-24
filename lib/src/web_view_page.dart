import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebViewPage extends StatefulWidget {
  final String version;
  final String route;
  final String appId;

  const WebViewPage({
    super.key,
    required this.version,
    required this.route,
    required this.appId,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final _isLoading = true.obs;
  final _progress = 0.0.obs;
  InAppWebViewController? _webController;
  late final String _url;

  static final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    cacheEnabled: false,
    clearCache: true,
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
    useHybridComposition: false,
    hardwareAcceleration: true,
    useOnLoadResource: true,
    allowFileAccess: true,
    allowContentAccess: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    javaScriptCanOpenWindowsAutomatically: true,
  );

  @override
  void initState() {
    super.initState();
    final encoded = Uri.encodeComponent(jsonEncode({
      "version": widget.version,
      "currentRoute": widget.route,
      "appId": widget.appId,
    }));
    _url = "https://support-user-package.web.app//?appData=$encoded";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            InAppWebView(
              key: UniqueKey(),
              initialUrlRequest: URLRequest(url: WebUri(_url)),
              initialSettings: _settings,
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              onWebViewCreated: (controller) async {
                _webController = controller;
                controller.addJavaScriptHandler(
                  handlerName: 'closeWebView',
                  callback: (args) {
                    if (mounted) Navigator.pop(context);
                  },
                );
                await CookieManager.instance().deleteAllCookies();
                await InAppWebViewController.clearAllCache();
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint('JS Console từ web: ${consoleMessage.message}');
              },
              onLoadStart: (controller, url) {
                _isLoading.value = true;
                _progress.value = 0.0;
              },
              onProgressChanged: (controller, progress) {
                _progress.value = progress / 100;
                if (progress == 100) {
                  _isLoading.value = false;
                }
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
            ),
            Obx(
              () => _isLoading.value
                  ? const ColoredBox(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Đang tải..."),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webController?.stopLoading();
    _webController = null;
    _isLoading.close();
    _progress.close();
    super.dispose();
  }
}
