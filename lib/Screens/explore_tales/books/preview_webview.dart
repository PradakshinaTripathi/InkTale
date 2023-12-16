import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends HookWidget {
  WebViewPage({Key? key, required this.url, required this.title})
      : super(key: key);

  final String url;
  final String title;
  late final WebViewController _webViewController;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  _loadHtmlFromAssets(BuildContext context) async {
    Size _size = MediaQuery.of(context).size;
    double _param = 2.56;
    if (Platform.isAndroid) _param = .9;
    String width = (_size.width * _param).floor().toString();
    String height = (_size.height * 2.24).floor().toString();
    String filePath = 'assets/webview.html';
    String fileHtmlContents = await rootBundle.loadString(filePath);
    String replaceVol = fileHtmlContents.replaceAll("replace", url);
    String replacedW = replaceVol.replaceAll('{width}', width);
    String finalHtml = replacedW.replaceAll('{height}', height);

    _webViewController!.loadUrl(Uri.dataFromString(finalHtml,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(true);
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    return Scaffold(
      appBar: AppBar(
        title: isLoading.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text('Loading...', style: TextStyle(fontSize: 15)),
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white)),
            )
          ],
        )
            : FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            title,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InteractiveViewer(
                  child: WebView(
                    onPageFinished: (value) {
                      isLoading.value = !isLoading.value;
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _webViewController = webViewController;
                      _controller.complete(webViewController);
                      _loadHtmlFromAssets(context);
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.zoom_out,
                    size: 32.0,
                    color: Colors.black,
                  ),
                  onPressed: () =>
                      _webViewController!
                          .runJavascriptReturningResult('zoomOut()'),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.zoom_in,
                    size: 32.0,
                    color: Colors.black,
                  ),
                  onPressed: () =>
                      _webViewController!
                          .runJavascriptReturningResult('zoomIn()'),
                )
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconTheme(
          data: const IconThemeData(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.navigate_before),
                onPressed: () =>
                    _webViewController!.runJavascriptReturningResult('previousPage()'),
              ),
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.navigate_next),
                onPressed: () =>
                    _webViewController!.runJavascriptReturningResult('nextPage()'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
