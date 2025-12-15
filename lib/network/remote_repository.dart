// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

//import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:deligo/bloc/auth_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/models/address_request.dart';
import 'package:deligo/models/appointment.dart';
import 'package:deligo/models/auth_request_check_existence.dart';
import 'package:deligo/models/auth_request_login.dart';
import 'package:deligo/models/auth_request_register.dart';
import 'package:deligo/models/auth_response.dart';
import 'package:deligo/models/base_list_response.dart';
import 'package:deligo/models/category.dart' as my_category;
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/create_order_res.dart';
import 'package:deligo/models/delivery_fee.dart';
import 'package:deligo/models/faq.dart';
import 'package:deligo/models/file_upload_response.dart';
import 'package:deligo/models/notifications_summary.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/models/order_req.dart';
import 'package:deligo/models/payment.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/models/payment_response.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/models/rating_request.dart';
import 'package:deligo/models/review.dart';
import 'package:deligo/models/ride.dart';
import 'package:deligo/models/ride_request.dart';
import 'package:deligo/models/send_to_bank.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:deligo/models/setting.dart';
import 'package:deligo/models/support_request.dart';
import 'package:deligo/models/transaction.dart' as my_transaction;
import 'package:deligo/models/user_data.dart';
import 'package:deligo/models/user_notification.dart';
import 'package:deligo/models/vehicle_type_response.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/models/wallet.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'remote_client.dart';
import 'request_interceptor.dart';

class RemoteRepository {
  static RemoteRepository? _instance;

  final Dio dio;
  final RemoteClient client;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // final FacebookAuth _facebookAuth = FacebookAuth.instance;
  // final GoogleSignIn _googleSignIn =
  //     GoogleSignIn(scopes: <String>['email', 'profile']);
  String? _verificationId;
  int? _resendToken;

  RemoteRepository._(this.dio, this.client);

  factory RemoteRepository() {
    if (_instance == null) {
      Dio dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
      ));
      dio.interceptors.add(RequestInterceptor());
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
      // dio.interceptors.add(RetryInterceptor(
      //   dio: dio,
      //   logPrint: print,
      //   retries: 1,
      //   retryDelays: const [Duration(seconds: 1)],
      //   retryEvaluator: (error, attempt) =>
      //       error.type == DioExceptionType.badResponse ||
      //       error.response?.statusCode == 400,
      // ));
      RemoteClient client = RemoteClient(
        dio,
        baseUrl: AppConfig.baseUrl,
      );
      _instance = RemoteRepository._(dio, client);
    }
    return _instance!;
  }

  /// AUTH STUFF START
  Future<void> logout() async {
    await LocalDataLayer().clearPrefs();
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("firebaseAuth.signOut: $e");
      }
    }
    // try {
    //   await _googleSignIn.signOut();
    // } catch (e) {
    //   if (kDebugMode) {
    //     print("googleSignIn.signOut: $e");
    //   }
    // }
    // try {
    //   await _facebookAuth.logOut();
    // } catch (e) {
    //   if (kDebugMode) {
    //     print("facebookLogin.logOut: $e");
    //   }
    // }
  }

  Future<bool> isRegistered(String number) async {
    try {
      await client.checkUser(AuthRequestCheckExistence(number));
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("isRegistered: $e");
      }
      return false;
    }
  }

  Future<AuthResponse> registerUser(AuthRequestRegister registerUser) {
    return client.registerUser(registerUser);
  }

  Future<AuthResponse> signInWithPhoneNumber(String fireToken) {
    return client.login(AuthRequestLogin(fireToken));
  }

  Future<void> otpSend(
      String phoneNumberFull, VerificationCallbacks verificationCallback) {
    _resendToken = -1;
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumberFull,
      verificationCompleted: (PhoneAuthCredential credential) {
        if (Platform.isAndroid) {
          verificationCallback.onCodeVerifying();
          _fireSignIn(credential, verificationCallback);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print("FirebaseAuthException: $e");
          print("FirebaseAuthException_message: ${e.message}");
          print("FirebaseAuthException_code: ${e.code}");
          print("FirebaseAuthException_phoneNumber: ${e.phoneNumber}");
        }
        verificationCallback.onCodeSendError(_resendToken != -1);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        verificationCallback.onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> otpVerify(
          String otp, VerificationCallbacks verificationCallback) =>
      _fireSignIn(
          PhoneAuthProvider.credential(
              verificationId: _verificationId!, smsCode: otp),
          verificationCallback);

  Future<void> _fireSignIn(AuthCredential credential,
      VerificationCallbacks verificationCallback) async {
    try {
      await _firebaseAuth.signInWithCredential(credential);
      try {
        var user = _firebaseAuth.currentUser;
        if (user == null) {
          verificationCallback.onCodeVerificationError("something_wrong");
          return;
        }
        var idToken = await user.getIdToken();

        final loggedInResponse = await signInWithPhoneNumber(idToken!);
        verificationCallback.onCodeVerified(loggedInResponse);
      } catch (e) {
        if (kDebugMode) {
          print("signInWithCredential: $e");
        }
        String errorToReturn = "something_wrong";
        if (e is DioException) {
          // signout of social accounts.
          try {
            logout();
          } catch (le) {
            if (kDebugMode) {
              print(le);
            }
          }
          try {
            final resp = (e).response;
            if (resp != null && resp.data != null) {
              final data = resp.data;
              Map<String, dynamic>? errorResponse;
              if (data is Map<String, dynamic>) {
                errorResponse = data;
              } else if (data is String) {
                try {
                  final parsed = jsonDecode(data);
                  if (parsed is Map<String, dynamic>) errorResponse = parsed;
                } catch (_) {
                  // ignore parse errors
                }
              }
              if (errorResponse != null && errorResponse.containsKey("message")) {
                final errorMessage = (errorResponse["message"] ?? "").toString();
                if (kDebugMode) {
                  print("errorMessage: $errorMessage");
                }
                if (errorMessage.toLowerCase().contains("role")) {
                  errorToReturn = "role_exists";
                }
              }
            }
          } catch (pe) {
            if (kDebugMode) print(pe);
          }
        }
        verificationCallback.onCodeVerificationError(errorToReturn);
      }
    } catch (e) {
      if (kDebugMode) {
        print("signInWithCredential - ${e.runtimeType}: $e");
      }
      verificationCallback.onCodeVerificationError("unable_otp_verification");
    }
  }

  // Future<AuthResponseSocial> signInWithGoogle() async {
  //   GoogleSignInAccount? googleUser;
  //   try {
  //     googleUser = await _googleSignIn.signIn();
  //     //if (googleUser == null) return AuthResponseSocial(null, null, null, null);
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;
  //     AuthResponse authResponse = await client.socialLogin(
  //         AuthRequestLoginSocial("google", googleAuth.idToken!,
  //             Platform.isAndroid ? "android" : "ios"));
  //     return AuthResponseSocial(null, null, null, authResponse);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("signInWithGoogle");
  //       print(e);
  //     }
  //     String? userName, userEmail, userImageUrl;

  //     try {
  //       if (e is DioException) {
  //         Response<dynamic>? response = (e).response;
  //         if (response == null) {
  //           return AuthResponseSocial(null, null, null, null);
  //         }
  //         if (response.statusCode == 404 && response.data != null) {
  //           Map<String, dynamic> errorResponse = response.data;
  //           if (errorResponse.containsKey("message")) {
  //             if (errorResponse.containsKey("name")) {
  //               userName = errorResponse["name"];
  //             } else if (googleUser != null && googleUser.displayName != null) {
  //               userName = googleUser.displayName;
  //             }

  //             if (errorResponse.containsKey("email")) {
  //               userEmail = errorResponse["email"];
  //             } else if (googleUser != null) {
  //               userEmail = googleUser.email;
  //             }

  //             if (errorResponse.containsKey("image_url")) {
  //               userImageUrl = errorResponse["image_url"];
  //             } else if (googleUser != null && googleUser.photoUrl != null) {
  //               userImageUrl = googleUser.photoUrl;
  //             }
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print("DioError");
  //         print(e);
  //       }
  //     }

  //     try {
  //       logout();
  //     } catch (le) {
  //       if (kDebugMode) {
  //         print(le);
  //       }
  //     }

  //     return AuthResponseSocial(userName, userEmail, userImageUrl, null);
  //   }
  // }

  // Future<AuthResponseSocial> signInWithApple(
  //     AuthorizationCredentialAppleID credentialAppleId) async {
  //   try {
  //     if (kDebugMode) {
  //       print("credentialAppleId: $credentialAppleId");
  //       print("credentialAppleId.givenName: ${credentialAppleId.givenName}");
  //       print("credentialAppleId.familyName: ${credentialAppleId.familyName}");
  //     }
  //     final credential = OAuthProvider('apple.com').credential(
  //       idToken: credentialAppleId.identityToken,
  //       accessToken: credentialAppleId.authorizationCode,
  //     );
  //     UserCredential userCredential =
  //         await _firebaseAuth.signInWithCredential(credential);
  //     if (kDebugMode) {
  //       print(userCredential);
  //     }

  //     var user = _firebaseAuth.currentUser;
  //     String token = "";
  //     if (user != null) token = (await user.getIdToken())!;
  //     if (token.isNotEmpty) {
  //       AuthResponse authResponse = await client.socialLogin(
  //           AuthRequestLoginSocial(
  //               "apple", token, Platform.isAndroid ? "android" : "ios"));
  //       return AuthResponseSocial(null, null, null, authResponse);
  //     } else {
  //       return AuthResponseSocial(null, null, null, null);
  //     }
  //   } catch (e) {
  //     String? userName, userEmail, userImageUrl;

  //     try {
  //       if (e is DioException) {
  //         Response<dynamic>? response = (e).response;
  //         if (response == null) {
  //           return AuthResponseSocial(null, null, null, null);
  //         }
  //         if (response.statusCode == 404 && response.data != null) {
  //           Map<String, dynamic> errorResponse = response.data;
  //           if (errorResponse.containsKey("message")) {
  //             if (errorResponse.containsKey("name")) {
  //               userName = errorResponse["name"];
  //             } else if (credentialAppleId.givenName != null) {
  //               userName = credentialAppleId.givenName!;
  //             }

  //             if (errorResponse.containsKey("email")) {
  //               userEmail = errorResponse["email"];
  //             } else if (credentialAppleId.email != null) {
  //               userEmail = credentialAppleId.email!;
  //             }

  //             if (errorResponse.containsKey("image_url")) {
  //               userImageUrl = errorResponse["image_url"];
  //             }
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print(e);
  //       }
  //     }

  //     try {
  //       logout();
  //     } catch (le) {
  //       if (kDebugMode) {
  //         print(le);
  //       }
  //     }

  //     return AuthResponseSocial(userName, userEmail, userImageUrl, null);
  //   }
  // }

  // Future<AuthResponseSocial> signInWithFacebook() async {
  //   AccessToken? accessToken;
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       accessToken = result.accessToken;
  //       if (accessToken == null) {
  //         return AuthResponseSocial(null, null, null, null);
  //       }
  //       AuthResponse authResponse = await client.socialLogin(
  //           AuthRequestLoginSocial("facebook", accessToken.token,
  //               Platform.isAndroid ? "android" : "ios"));
  //       return AuthResponseSocial(null, null, null, authResponse);
  //     } else {
  //       return AuthResponseSocial(null, null, null, null);
  //     }
  //   } catch (e) {
  //     String? userName, userEmail, userImageUrl;

  //     try {
  //       if (e is DioException) {
  //         Map<String, dynamic>? facebookUserData;
  //         if (accessToken != null) {
  //           facebookUserData = await _facebookAuth.getUserData();
  //         }
  //         Response<dynamic>? response = (e).response;
  //         if (response == null) {
  //           return AuthResponseSocial(null, null, null, null);
  //         }
  //         if (response.statusCode == 404 && response.data != null) {
  //           Map<String, dynamic> errorResponse = response.data;
  //           if (errorResponse.containsKey("message")) {
  //             if (errorResponse.containsKey("name")) {
  //               userName = errorResponse["name"];
  //             } else if (facebookUserData != null) {
  //               userName = facebookUserData["name"];
  //             }

  //             if (errorResponse.containsKey("email")) {
  //               userEmail = errorResponse["email"];
  //             } else if (facebookUserData != null) {
  //               userEmail = facebookUserData["email"];
  //             }

  //             if (errorResponse.containsKey("image_url")) {
  //               userImageUrl = errorResponse["image_url"];
  //             } else if (facebookUserData != null) {
  //               userImageUrl = facebookUserData["picture"]["data"]["url"];
  //             }
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print(e);
  //       }
  //     }

  //     try {
  //       logout();
  //     } catch (le) {
  //       if (kDebugMode) {
  //         print(le);
  //       }
  //     }

  //     return AuthResponseSocial(userName, userEmail, userImageUrl, null);
  //   }
  // }

  /// AUTH STUFF END

  Future<void> postUrl(String url) => dio.post(url, data: {});

  Future<void> getUrl(String url) => dio.get(url);

  Future<List<Faq>> getFaqs() => client.getFaqs();

  Future<List<my_category.Category>> getBanners() => client.getBanners();

  Future<List<my_category.Category>> getCategories({
    int? parent,
    String? scope,
    String? vendorType,
    String? isEnabled,
    String? parentCatIdsCommaSeparated,
    String? query,
  }) =>
      client.getCategories(
        parent: parent,
        scope: scope,
        vendorType: vendorType,
        isEnabled: isEnabled,
        parentCatIdsCommaSeparated: parentCatIdsCommaSeparated,
        query: query,
      );

  Future<List<my_category.Category>> initFetchCategoriesWithVendorType(
          String vendorType) =>
      client.getCategories(
        vendorType: vendorType,
        parent: 1,
        scope: Constants.scopeEcommerce,
      );

  Future<List<my_category.Category>> getCategoriesAll() =>
      client.getCategories();

  Future<List<my_category.Category>> getCategoriesChild(
          String parentCatIdsCommaSeparated) =>
      client.getCategories(
          parentCatIdsCommaSeparated: parentCatIdsCommaSeparated);

  Future<List<my_category.Category>> getCategoriesSearch(String query) =>
      client.getCategories(query: query);

  Future<List<PaymentMethod>> getPaymentMethod() => client.paymentMethods();

  Future<List<Setting>> fetchSettings() => client.getSettings();

  Future<UserData?> updateUser(Map<String, dynamic> updateRequest) async {
    updateRequest.removeWhere((key, value) => value == null);
    String? token = await LocalDataLayer().getAuthenticationToken();
    if (token == null || updateRequest.isEmpty) return null;
    return client.updateUser(token, updateRequest);
  }

  Future<UserData?> getUser() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    if (token == null) return null;
    return client.getUser(token);
  }

  Future<void> sendToBank(SendToBank sendToBank) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.sendToBank(token, sendToBank);
  }

  Future<Payment> depositWallet(
      String amount, String paymentMethodSlug, String? couponCode) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    var req = {"amount": amount, "payment_method_slug": paymentMethodSlug};
    if (couponCode != null) req["coupon_code"] = couponCode;
    return client.depositWallet(token, req);
  }

  Future<PaymentResponse> payThroughStripe(
      int paymentId, String stripeToken) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.payThroughStripe(token, paymentId.toString(), stripeToken);
  }

  Future<PaymentResponse> payThroughWallet(int paymentId) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.payThroughWallet(token, paymentId.toString());
  }

  Future<Wallet> balanceWallet() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.balanceWallet(token);
  }

  Future<BaseListResponse<my_transaction.Transaction>> transactionsWallet(
      int pageNo) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.transactionsWallet(token, pageNo);
  }

  Future<BaseListResponse<Review>> getReviewsProvider(
      int proId, int pageNo) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getReviewsProvider(token, proId, pageNo);
  }

  Future<Appointment> createAppointment(
      int providerId, Map<String, dynamic> appointmentCreateRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.createAppointment(
        token, providerId, appointmentCreateRequest);
  }

  Future<Appointment> updateAppointment(
      int appointmentId, Map<String, dynamic> appointmentCreateRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.updateAppointment(
        token, appointmentId, appointmentCreateRequest);
  }

  Future<BaseListResponse<Appointment>> getAppointments(
      int userId, int pageNo, bool? isUpcoming) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return isUpcoming != null
        ? client.getAppointments(
            token,
            userId: userId,
            pageNo: pageNo,
            upcoming: isUpcoming ? 1 : null,
            past: isUpcoming ? null : 1,
          )
        : client.getAppointments(
            token,
            userId: userId,
            pageNo: pageNo,
          );
  }

  void addFirebaseAppointment(Appointment appointment) {
    DatabaseReference updatesRef = FirebaseDatabase.instance
        .ref()
        .child(Constants.refUpdates)
        .child("appointment");
    DatabaseReference providerApRef = updatesRef
        .child("${Constants.roleProvider}_${appointment.provider!.id}")
        .child("${appointment.id}");
    DatabaseReference customerApRef = updatesRef
        .child("${Constants.roleUser}_${appointment.user!.id}")
        .child("${appointment.id}");
    Map<String, dynamic> appointmentRequest =
        jsonDecode(jsonEncode(appointment));
    providerApRef.set(appointmentRequest);
    customerApRef.set(appointmentRequest);
  }

  Future<BaseListResponse<UserNotification>> getUserNotifications(
      int pageNo) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getUserNotifications(token, pageNo);
  }

  Future<List<Address>> fetchAddresses() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getAddresses(token);
  }

  Future<dynamic> createRatingDriver(
      int driverId, RatingRequest ratingRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.createRatingDriver(token, driverId, ratingRequest);
  }

  Future<dynamic> createRatingProvider(
      int providerId, RatingRequest ratingRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.createRatingProvider(token, providerId, ratingRequest);
  }

  Future<Address> createAddress(AddressRequest addressRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.createAddress(token, addressRequest);
  }

  Future<Address> updateAddress(
      int addressId, AddressRequest addressRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.updateAddress(token, addressId, addressRequest);
  }

  Future<void> deleteAddress(int addressId) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.deleteAddress(token, addressId);
  }

  Future<dynamic> postSupport(SupportRequest supportRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.postSupport(token, supportRequest);
  }

  Future<void> postNotification(
      {required String roleTo,
      required String userIdTo,
      String? title,
      String? body}) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.postNotification(
        token, {"role": roleTo, "user_id": userIdTo}, title, body);
  }

  Future<NotificationsSummary> fetchNotificationsSummary() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getNotificationsSummary(token);
  }

  Future<dynamic> postNotificationsRead() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.postNotificationsRead(token);
  }

  Future<void> deleteUser() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    await client.deleteUser(token);
  }

  Future<BaseListResponse<Vendor>> searchVendors({
    String? text,
    int? catId,
    double? lat,
    double? lng,
    int? pageNum,
    int perPage = 15,
    String? sort,
    String? vendorType,
    CancelToken? cancelToken,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.searchVendors(
      token,
      text: text,
      catId: catId,
      lat: lat,
      lng: lng,
      pageNum: pageNum,
      perPage: perPage,
      sort: sort,
      vendorType: vendorType,
      cancelToken: cancelToken,
    );
  }

  Future<BaseListResponse<Product>> searchProducts({
    String? search,
    int? vendorId,
    int? categoryId,
    int? pageNum,
    int perPage = 15,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.searchProducts(
      token,
      search: search,
      vendorId: vendorId,
      categoryId: categoryId,
      pageNum: pageNum,
      perPage: perPage,
    );
  }

  Future<List<Product>> searchProductsWoPagination({
    String? search,
    int? vendorId,
    int? categoryId,
    int? pageNum,
    int perPage = 15,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.searchProductsWoPagination(
      token,
      search: search,
      vendorId: vendorId,
      categoryId: categoryId,
      pageNum: pageNum,
      perPage: perPage,
    );
  }

  Future<DeliveryFee> getDeliveryFeeCustom({
    required String sourceLatitude,
    required String sourceLongitude,
    required String destinationLatitude,
    required String destinationLongitude,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getDeliveryFeeCustom(
      token,
      sourceLatitude: sourceLatitude,
      sourceLongitude: sourceLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
    );
  }

  Future<DeliveryFee> getDeliveryFee({
    required String vendorId,
    required String sourceLat,
    required String sourceLng,
    required String destLat,
    required String destLng,
    required String orderType,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getDeliveryFee(
      token,
      vendorId: vendorId,
      sourceLat: sourceLat,
      sourceLng: sourceLng,
      destLat: destLat,
      destLng: destLng,
      orderType: orderType,
    );
  }

  Future<CreateOrderRes> createOrder(OrderReq orderReq) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    Map<String, dynamic> orderReqMap = orderReq.toJson();
    orderReqMap.removeWhere((key, value) => value == null);
    return client.createOrder(token, orderReqMap);
  }

  Future<BaseListResponse<Order>> getOrders(int pageNo,
      {String? vendorType}) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getOrders(token, pageNum: pageNo, vendorType: vendorType);
  }

  Future<void> postVendorReview(
      int vendorId, Map<String, dynamic> ratingRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.postVendorReview(token, vendorId, ratingRequest);
  }

  Future<void> postDeliveryReview(
      int deliveryId, Map<String, dynamic> ratingRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.postDeliveryReview(token, deliveryId, ratingRequest);
  }

  Future<BaseListResponse<ServiceProvider>> getServiceProviders({
    int? pageNo,
    int? categoryId,
    int? subCategoryId,
    double? latitude,
    double? longitude,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getServiceProviders(
      token,
      pageNo: pageNo,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<VehicleTypeResponse> getVehicleTypes({
    String? latitudeFrom,
    String? longitudeFrom,
    String? cityFrom,
    String? latitudeTo,
    String? longitudeTo,
    String? cityTo,
    String? vehicleType,
  }) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getVehicleTypes(
      token,
      latitudeFrom: latitudeFrom,
      latitudeTo: latitudeTo,
      longitudeFrom: longitudeFrom,
      cityFrom: cityFrom,
      longitudeTo: longitudeTo,
      cityTo: cityTo,
      vehicleType: vehicleType,
    );
  }

  Future<Coupon> checkCouponValidity(String code) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.checkCouponValidity(token, code);
  }

  Future<List<Coupon>> getCoupons() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getCoupons(token);
  }

  Future<List<Coupon>> getRideCoupons() async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getRideCoupons(token);
  }

  Future<Ride> createRide(RideRequest rideRequest) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    Map<String, dynamic> rideReqMap = rideRequest.toJson();
    rideReqMap.removeWhere((key, value) => value == null);
    return client.createRide(token, rideReqMap);
  }

  Future<BaseListResponse<Ride>> getRides(int pageNo) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.getRides(token, pageNo);
  }

  Future<Ride> updateRide(int rideId, String status) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.updateRide(token, rideId, {"status": status});
  }

  Future<Order> updateOrder(int orderId, Map<String, dynamic> body) async {
    String? token = await LocalDataLayer().getAuthenticationToken();
    return client.updateOrder(token, orderId, body);
  }

  Future<FileUploadResponse> uploadFile(File file) =>
      client.uploadFile(file: file);
}
