import 'dart:collection';

import 'package:deligo/bloc/payment_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ProcessPaymentPage extends StatelessWidget {
  const ProcessPaymentPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (BuildContext context) => PaymentCubit(),
        child: ProcessPaymentWidget(
            ModalRoute.of(context)!.settings.arguments as PaymentData),
      );
}

class ProcessPaymentWidget extends StatefulWidget {
  final PaymentData paymentData;
  const ProcessPaymentWidget(this.paymentData, {super.key});
  @override
  ProcessPaymentWidgetState createState() => ProcessPaymentWidgetState();
}

class ProcessPaymentWidgetState extends State<ProcessPaymentWidget> {
  final GlobalKey webViewKey = GlobalKey();
  late PaymentCubit _paymentCubit;
  String? _initialUrlRequest, _sUrl, _fUrl;
  PaymentStatus? _paymentStatus;

  Future<bool> _warnPop() async {
    var value = await ConfirmDialog.showConfirmation(
      context,
      Text(AppLocalization.instance.getLocalizationFor("warn_back_title")),
      Text(AppLocalization.instance.getLocalizationFor("warn_back_message")),
      AppLocalization.instance.getLocalizationFor("no"),
      AppLocalization.instance.getLocalizationFor("yes"),
    );
    return value != null && value == true;
  }

  @override
  void initState() {
    _paymentCubit = BlocProvider.of<PaymentCubit>(context);
    super.initState();
    Future.delayed(const Duration(milliseconds: 100),
        () => _paymentCubit.initProcessPayment(widget.paymentData));
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            bool popSure = await _warnPop();
            if (popSure) {
              _paymentCubit.setPaymentProcessed(false);
            }
          }
        },
        child: BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (kDebugMode) {
              print("PaymentStateIs: $state");
            }
            if (state is ProcessingPaymentState) {
              setState(() {
                _initialUrlRequest = null;
                _sUrl = null;
                _fUrl = null;
              });
            } else if (state is LoadPaymentUrlState) {
              setState(() {
                _initialUrlRequest = state.paymentLink;
                _sUrl = state.sUrl;
                _fUrl = state.fUrl;
              });
            } else if (state is ProcessedPaymentState) {
              _paymentStatus = state.paymentStatus;
              Navigator.pop(context, _paymentStatus);
            }
          },
          child: Scaffold(
            body: _initialUrlRequest != null
                ? SafeArea(
                    child: InAppWebView(
                      key: webViewKey,
                      // contextMenu: contextMenu,
                      initialUrlRequest: URLRequest(
                        url: WebUri.uri(Uri.parse(_initialUrlRequest!)),
                      ),
                      // initialFile: "assets/index.html",
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialSettings: InAppWebViewSettings(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        useHybridComposition: true,
                        allowsInlineMediaPlayback: true,
                      ),
                      pullToRefreshController: null,
                      onWebViewCreated: (controller) {
                        //webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        // setState(() {
                        //   this.url = url.toString();
                        //   urlController.text = this.url;
                        // });
                      },

                      onPermissionRequest:
                          (controller, permissionRequest) async {
                        return PermissionResponse(
                            resources: permissionRequest.resources,
                            action: PermissionResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading: null,
                      onLoadStop: (controller, url) async {
                        if (kDebugMode) {
                          print("loadstop: $url");
                        }
                        if (url.toString() == _sUrl) {
                          _paymentCubit.setPaymentProcessed(true);
                        }
                        if (url.toString() == _fUrl) {
                          _paymentCubit.setPaymentProcessed(false);
                        }
                        // pullToRefreshController.endRefreshing();
                        // setState(() {
                        //   this.url = url.toString();
                        //   urlController.text = this.url;
                        // });
                      },
                      onReceivedError: (controller, request, error) =>
                          _paymentCubit.setPaymentProcessed(false),
                      onProgressChanged: (controller, progress) {
                        // if (progress == 100) {
                        //   pullToRefreshController.endRefreshing();
                        // }
                        // setState(() {
                        //   this.progress = progress / 100;
                        //   urlController.text = this.url;
                        // });
                      },
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {
                        // setState(() {
                        //   this.url = url.toString();
                        //   urlController.text = this.url;
                        // });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        if (kDebugMode) {
                          print(consoleMessage);
                        }
                      },
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      );
}
