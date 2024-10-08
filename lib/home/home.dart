import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 15))
        ..repeat();
  bool activeConnection = false;
  DateTime xTime = DateTime.now();

  late DateTime currentBackPressTime = xTime;

  // late final WebViewController myWebViewController;
  bool isWebViewLoading = true;
  bool showHome = true;

  @override
  void initState() {
    checkUserConnection();

    // late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }
    //
    // final WebViewController webViewController =
    //     WebViewController.fromPlatformCreationParams(params);

    // myWebViewController
    //   ..loadRequest(Uri.parse('https://mbvt.netlify.app/'))
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(NavigationDelegate(onPageFinished: (url) {
    //     Future.delayed(const Duration(seconds: 3)).then((value) {
    //       setState(() {
    //         isWebViewLoading = false;
    //       });
    //     });
    //   }));

    // myWebViewController = webViewController;

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    var maxWidth = MediaQuery.of(context).size.width;
    var maxHeight = MediaQuery.of(context).size.height;
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return WillPopScope(
      onWillPop: () async {
        if (showHome) {
          DateTime now = DateTime.now();
          if (now.difference(currentBackPressTime) >
              const Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Tap back again to close app.");
            return false;
          }
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
          return true;
        } else {
          setState(() {
            showHome = true;
          });
          return false;
        }
      },
      child: Stack(
        children: [
          // Positioned(
          //   top: statusBarHeight,
          //   child: SizedBox(
          //       height: maxHeight - statusBarHeight,
          //       width: maxWidth,
          //       child: WebViewWidget(controller: myWebViewController)),
          // ),
          Visibility(
              visible: showHome,
              child: Container(
                width: maxWidth,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.indigo, Colors.blue, Colors.cyanAccent],
                    stops: [0.1, 0.4, 0.95],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultTextStyle(
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: Colors.black,
                          fontFamily: 'TiltNeon'),
                      textAlign: TextAlign.center,
                      child: AnimatedTextKit(
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TyperAnimatedText("Virtual Tour Demo App",
                              speed: const Duration(milliseconds: 150)),
                        ],
                      ),
                    ),
                    Visibility(
                        visible: isWebViewLoading,
                        child: Image.asset("assets/loader.gif")),
                    Visibility(
                        visible: !isWebViewLoading,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 2.0, color: Colors.black),
                            ),
                            onPressed: () {
                              setState(() {
                                showHome = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(shortestSide / 100),
                              child: const Text(
                                'Start Virtual Tour',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ))),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          activeConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        activeConnection = false;
        closeApp();
      });
    }
  }

  void closeApp() {
    Fluttertoast.showToast(
        msg: "Please connect to Internet first.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3);
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}
