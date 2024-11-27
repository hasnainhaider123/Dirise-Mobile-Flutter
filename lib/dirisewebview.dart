import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DiriseWebView extends StatefulWidget {
  const DiriseWebView({super.key});

  @override
  _DiriseWebViewState createState() => _DiriseWebViewState();
}

class _DiriseWebViewState extends State<DiriseWebView> {
  // Completer to handle the InAppWebViewController
  final Completer<InAppWebViewController> _completer = Completer<InAppWebViewController>();
  late InAppWebViewController _webViewController;
  
  // Your session token
  final String myToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIyMiIsImp0aSI6IjQ1OGU4MWNkNWVlMDU4NmQzYzY3YTIwNTI4NTYzYTlmNDFlM2FhZmJhYTFjMWU5NWIwMDIwYzg1ZDVjMGFiODYzZTQ3NTgyY2M1YWIxMGQ2IiwiaWF0IjoxNzMyNzE3NTAzLjg1NzE1NywibmJmIjoxNzMyNzE3NTAzLjg1NzE1OCwiZXhwIjoxNzY0MjUzNTAzLjg1NTYxNSwic3ViIjoiMzIxIiwic2NvcGVzIjpbXX0.BNO-oPtI26eeAZAw9g4aBh2XeJmGhIzWBpCXhGvldDuIy4TBPHcEDoQ5Eq6wmd6ap4ZwvNx2Sez3vzgFwfftBA0LZlmOYbrMtAnwKEidZBbaAxQ3dxAHwVrNNmn7P2xiWx5P0tjlG8AOa8EXr3TjJ4JFU3meaKiuOfYpUv3GZdLRSP6azK_1Wr4eAKX3Mj6IQuwEMYkKTsqDL4w5-g1IYZVLzuYYjUaqxVXm8NI53fANaiNYjr9HTRBxn9ryUF4bDW7HoYsj846ifDhsxiAyyeIpriLYp30Ggv_DJ_4qXcTclC5reKVvtjuoLkUf1TbwRR81e0U7zig6ZNOx_-SLjm4PkdXwPz6ziOk1UjXyoVP_8og_8X1BKLAJO01J6JAzA8WQMBQguyvLegBYfVuAokZW7qycqehTBrD3RBphhVWqm2FFOV6tKDl8ek6TcI6Hs5ZOtfo6lyK11MEgWLM7H7ZJIaEaNjYEw8s2klMtkC2TAKFcYCgo84qoBs7pGNRJynlV9_30gJQuAza_qlfb8UifRLjy8WWVKWYgk7sFqanlnCd3JOW5DP-qOCr3opkBF89eiQQonlpRiY2Y6ELEl9HXW7gQsIPIoYYxgPuzkzFAhpn8GP8mj8JCiwTioSiPcrRv3ESkck7iZ3kllu2HTVz8cLjsZLnfDL4XRbZxTs0';
  final String webUrl = 'https://old-admin.diriseapp.com/'; // Your URL

  @override
  void initState() {
    super.initState();
    // Initialize the WebView
   // InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Example'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(webUrl),
          headers: {
            'authorization': 'Bearer $myToken', // Pass token via Authorization header
          },
        ),
        onWebViewCreated: (controller) {
          _completer.complete(controller);
          _webViewController = controller;
        },
        onLoadStart: (controller, url) {
          print("Started loading: $url");
        },
        onLoadStop: (controller, url) async {
          print("Finished loading: $url");
        },
        onProgressChanged: (controller, progress) {
          print("Progress: $progress%");
        },
      ),
    );
  }
}
