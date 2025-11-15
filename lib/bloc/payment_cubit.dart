import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:deligo/models/send_to_bank.dart';
import 'package:deligo/models/wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/config/app_config.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/models/payment.dart';
import 'package:deligo/models/payment_response.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/network/remote_repository.dart';
import 'package:deligo/models/payment_method.dart' as my_payment_method;

part 'payment_state.dart';

class PaymentStatus {
  final bool isPaid;
  final String paidVia;
  PaymentStatus(this.isPaid, this.paidVia);
}

class PaymentCubit extends Cubit<PaymentState> {
  final List<String> _supportedPaymentGatewaySlugs = [
    "cod",
    "wallet",
    "stripe",
    "payu",
    "paystack"
  ];
  final RemoteRepository _networkRepo = RemoteRepository();
  String? _sUrl, _fUrl, _currentPaymentMethod;
  Payment? _currentPayment;

  PaymentCubit() : super(InitialPaymentState());

  Future<void> initSendToBank(SendToBank sendToBank) async {
    emit(SendToBankLoading());
    try {
      await _networkRepo.sendToBank(sendToBank);
      emit(SendToBankLoaded());
    } catch (e) {
      if (kDebugMode) {
        print("initSendToBank: $e");
      }
      emit(SendToBankFail("Something went wrong", "something_wrong"));
    }
  }

  Future<void> initFetchPaymentMethods(List<String> slugsToIgnore) async {
    emit(LoadingPaymentMethods());
    try {
      List<my_payment_method.PaymentMethod> listPayment =
          await _networkRepo.getPaymentMethod();
      listPayment.removeWhere((element) => (element.enabled == null ||
          element.enabled != 1 ||
          (slugsToIgnore.contains(element.slug))));
      emit(PaymentMethodsLoaded(listPayment));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(PaymentMethodsError("Something went wrong", "something_wrong"));
    }
  }

  Future<void> initWalletDeposit(double amount,
      my_payment_method.PaymentMethod paymentMethod, String? couponCode) async {
    emit(LoadingWalletDeposit());
    VerifyPaymentMethodResponse verifyPaymentMethodResponse =
        await _verifyPaymentMethod(
            paymentMethod: paymentMethod,
            amount: amount,
            paymentMethodslugsToIgnore: ["cod", "wallet"]);
    if (verifyPaymentMethodResponse.paymentSetupError != null) {
      emit(verifyPaymentMethodResponse.paymentSetupError!);
    } else {
      try {
        Payment payment = await _networkRepo.depositWallet(
            "$amount", paymentMethod.slug!, couponCode);
        UserData? userData = await LocalDataLayer().getUserMe();
        emit(WalletDepositLoaded(PaymentData(
          payment: payment,
          payuMeta: PayUMeta(
            name: userData!.name.replaceAll(' ', ''),
            mobile: userData.mobile_number.replaceAll(' ', ''),
            email: userData.email.replaceAll(' ', ''),
            bookingId: "${payment.id}",
            productinfo: "Wallet Recharge",
          ),
        )));
      } catch (e) {
        if (kDebugMode) {
          print("initWalletDeposit: $e");
        }
        emit(WalletDepositError("Something went wrong", "something_wrong"));
      }
    }
  }

  Future<void> initProcessPayment(PaymentData paymentData) async {
    emit(ProcessingPaymentState());
    _currentPaymentMethod = (paymentData.payment.paymentMethod?.slug ?? "");
    _currentPayment = paymentData.payment;
    switch (_currentPaymentMethod) {
      case "cod":
        emit(
            ProcessedPaymentState(PaymentStatus(true, _currentPaymentMethod!)));
        break;
      case "wallet":
        try {
          PaymentResponse paymentResponse =
              await _networkRepo.payThroughWallet(paymentData.payment.id);
          emit(ProcessedPaymentState(
              PaymentStatus(paymentResponse.success, _currentPaymentMethod!)));
        } catch (e) {
          if (kDebugMode) {
            print("processPayment wallet $e");
          }
          emit(ProcessedPaymentState(
              PaymentStatus(false, _currentPaymentMethod!)));
        }
        break;
      case "payu":
        try {
          String? key =
              paymentData.payment.paymentMethod?.getMetaKey("public_key");
          String? salt =
              paymentData.payment.paymentMethod?.getMetaKey("private_key");
          if (key != null && salt != null) {
            String name = paymentData.payuMeta!.name;
            String mobile = paymentData.payuMeta!.mobile;
            String email = paymentData.payuMeta!.email;
            String bookingId = paymentData.payuMeta!.bookingId;
            String productinfo = paymentData.payuMeta!.productinfo;
            String amt = "${paymentData.payment.amount}";
            String checksum =
                "$key|$bookingId|$amt|$productinfo|$name|$email|||||||||||$salt";
            var bytes = utf8.encode(checksum);
            Digest sha512Result = sha512.convert(bytes);
            String encrypttext = sha512Result.toString();
            String furl =
                "${AppConfig.baseUrl}api/payment/payu/${paymentData.payment.id}?result=failed";
            String surl =
                "${AppConfig.baseUrl}api/payment/payu/${paymentData.payment.id}?result=success";

            String url =
                "${AppConfig.baseUrl}assets/vendor/payment/payumoney/payuBiz.html?amt=$amt&name=$name&mobileNo=$mobile&email=$email&bookingId=$bookingId&productinfo=$productinfo&hash=$encrypttext&salt=$salt&key=$key&furl=$furl&surl=$surl";
            _sUrl = surl;
            _fUrl = furl;
            emit(LoadPaymentUrlState(url, surl, furl));
          } else {
            emit(ProcessedPaymentState(
                PaymentStatus(false, _currentPaymentMethod!)));
          }
        } catch (e) {
          if (kDebugMode) {
            print("processPayment payu $e");
          }
          emit(ProcessedPaymentState(
              PaymentStatus(false, _currentPaymentMethod!)));
        }
        break;
      case "stripe":
        String furl =
            "${AppConfig.baseUrl}api/payment/stripe/${paymentData.payment.id}?status=error";
        String surl =
            "${AppConfig.baseUrl}api/payment/stripe/${paymentData.payment.id}?status=success";
        String url =
            "${AppConfig.baseUrl}api/payment/stripe/${paymentData.payment.id}";
        _sUrl = surl;
        _fUrl = furl;
        emit(LoadPaymentUrlState(url, _sUrl!, _fUrl!));
        break;
      case "paystack":
        String url =
            "${AppConfig.baseUrl}api/payment/paystack/${paymentData.payment.id}";
        _sUrl =
            "${AppConfig.baseUrl}api/payment/paystack/callback/${paymentData.payment.id}?result=success";
        _fUrl =
            "${AppConfig.baseUrl}api/payment/paystack/callback/${paymentData.payment.id}?result=error";
        emit(LoadPaymentUrlState(url, _sUrl!, _fUrl!));
        break;
      default:
        if (kDebugMode) {
          print("processPayment unknown payment method");
        }
        emit(ProcessedPaymentState(
            PaymentStatus(false, _currentPaymentMethod!)));
        break;
    }
  }

  Future<void> setPaymentProcessed(bool paid) async {
    emit(ProcessingPaymentState());
    if (!paid) {
      await _networkRepo.postUrl(
          "${AppConfig.baseUrl}api/payment/generic/${_currentPayment?.id}/failed");
    }
    emit(ProcessedPaymentState(PaymentStatus(paid, _currentPaymentMethod!)));
  }

  Future<VerifyPaymentMethodResponse> _verifyPaymentMethod({
    required my_payment_method.PaymentMethod paymentMethod,
    required double amount,
    required List<String> paymentMethodslugsToIgnore,
  }) async {
    if (paymentMethodslugsToIgnore.contains(paymentMethod.slug) ||
        !_supportedPaymentGatewaySlugs.contains(paymentMethod.slug)) {
      return VerifyPaymentMethodResponse(
        paymentSetupError:
            PaymentSetupError("Payment not setup", "payment_setup_not"),
      );
    }
    VerifyPaymentMethodResponse toReturn = VerifyPaymentMethodResponse(
      paymentSetupError: null,
    );
    try {
      switch (paymentMethod.slug) {
        case "wallet":
          try {
            Wallet walletBalance = await _networkRepo.balanceWallet();
            if (amount > walletBalance.balance) {
              toReturn.paymentSetupError = PaymentSetupError(
                  "Insufficient wallet balance", "insufficient_wallet");
            }
          } catch (e) {
            if (kDebugMode) {
              print("paythroughwallet: $e");
            }
            toReturn.paymentSetupError = PaymentSetupError(
                "Insufficient wallet balance", "insufficient_wallet");
          }
          break;
        case "payu":
          try {
            String? key = paymentMethod.getMetaKey("public_key");
            String? salt = paymentMethod.getMetaKey("private_key");
            if (key == null || salt == null) {
              toReturn.paymentSetupError =
                  PaymentSetupError("Payment setup fail", "payment_setup_fail");
            }
          } catch (e) {
            if (kDebugMode) {
              print("PayuPaymentError: $e");
            }
            toReturn.paymentSetupError =
                PaymentSetupError("Payment setup fail", "payment_setup_fail");
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print("verifyPaymentMethod: $e");
      }
      toReturn.paymentSetupError =
          PaymentSetupError("Something went wrong", "something_wrong");
    }
    return toReturn;
  }
}

class VerifyPaymentMethodResponse {
  PaymentSetupError? paymentSetupError;

  VerifyPaymentMethodResponse({required this.paymentSetupError});
}

class PaymentData {
  final Payment payment;
  final PayUMeta? payuMeta;

  PaymentData({
    required this.payment,
    this.payuMeta,
  });

  @override
  String toString() => 'PaymentData(payment: $payment, payuMeta: $payuMeta)';
}

class PayUMeta {
  final String name, mobile, email, bookingId, productinfo;

  PayUMeta(
      {required this.name,
      required this.mobile,
      required this.email,
      required this.bookingId,
      required this.productinfo});
}
