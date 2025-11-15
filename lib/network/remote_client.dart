import 'dart:io';

import 'package:deligo/models/appointment.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:deligo/models/address.dart';
import 'package:deligo/models/address_request.dart';
import 'package:deligo/models/auth_request_check_existence.dart';
import 'package:deligo/models/auth_request_login.dart';
import 'package:deligo/models/auth_request_login_social.dart';
import 'package:deligo/models/auth_request_register.dart';
import 'package:deligo/models/auth_response.dart';
import 'package:deligo/models/base_list_response.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/create_order_res.dart';
import 'package:deligo/models/delivery_fee.dart';
import 'package:deligo/models/faq.dart';
import 'package:deligo/models/file_upload_response.dart';
import 'package:deligo/models/notifications_summary.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/models/payment.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/models/payment_response.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/models/rating_request.dart';
import 'package:deligo/models/review.dart';
import 'package:deligo/models/ride.dart';
import 'package:deligo/models/send_to_bank.dart';
import 'package:deligo/models/setting.dart';
import 'package:deligo/models/support_request.dart';
import 'package:deligo/models/transaction.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/models/user_notification.dart';
import 'package:deligo/models/vehicle_type_response.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/models/wallet.dart';

part 'remote_client.g.dart';

@RestApi()
abstract class RemoteClient {
  factory RemoteClient(Dio dio, {String? baseUrl}) = _RemoteClient;

  @POST("api/check-user")
  Future<void> checkUser(@Body() AuthRequestCheckExistence checkUser);

  @POST("api/register")
  Future<AuthResponse> registerUser(
      @Body() AuthRequestRegister authRequestRegister);

  @POST("api/login")
  Future<AuthResponse> login(@Body() AuthRequestLogin loginRequest);

  @POST("api/social/login")
  Future<AuthResponse> socialLogin(
      @Body() AuthRequestLoginSocial socialLoginUser);

  @PUT("api/user")
  Future<UserData> updateUser(@Header("Authorization") String bearerToken,
      @Body() Map<String, dynamic> updateUserRequest);

  @GET("api/user")
  Future<UserData> getUser(@Header("Authorization") String bearerToken);

  @GET("api/settings")
  Future<List<Setting>> getSettings();

  @GET("api/banners?pagination=0")
  Future<List<Category>> getBanners();

  @GET("api/categories?pagination=0")
  Future<List<Category>> getCategories({
    @Query("parent") int? parent,
    @Query("scope") String? scope,
    @Query("meta[vendor_type]") String? vendorType,
    @Query("meta[is_enabled]") String? isEnabled,
    @Query("categories") String? parentCatIdsCommaSeparated,
    @Query("title") String? query,
  });

  @GET("api/provider/profile/ratings/{providerId}")
  Future<BaseListResponse<Review>> getReviewsProvider(
      @Header("Authorization") String? bearerToken,
      @Path("providerId") int providerId,
      @Query("page") int pageNo);

  @POST("api/provider/profile/ratings/{providerId}")
  Future<dynamic> createRatingProvider(
      @Header("Authorization") String? bearerToken,
      @Path("providerId") int providerId,
      @Body() RatingRequest ratingRequest);

  @POST("api/provider/appointments/{providerId}")
  Future<Appointment> createAppointment(
      @Header("Authorization") String? bearerToken,
      @Path("providerId") int providerId,
      @Body() Map<String, dynamic> appointmentCreateRequest);

  @PUT("api/provider/appointments/{appointmentId}")
  Future<Appointment> updateAppointment(
      @Header("Authorization") String? bearerToken,
      @Path("appointmentId") int appointmentId,
      @Body() Map<String, dynamic> appointmentCreateRequest);

  @GET("api/provider/appointments")
  Future<BaseListResponse<Appointment>> getAppointments(
    @Header("Authorization") String? bearerToken, {
    @Query("appointer") required int userId,
    @Query("page") required int pageNo,
    @Query("upcoming") int? upcoming,
    @Query("past") int? past,
  });

  @GET("api/provider/appointments?upcoming=1")
  Future<BaseListResponse<Appointment>> getAppointmentsUpcoming(
      @Header("Authorization") String? bearerToken,
      @Query("appointer") int userId,
      @Query("page") int pageNo);

  @GET("api/provider/appointments?=1")
  Future<BaseListResponse<Appointment>> getAppointmentsPast(
      @Header("Authorization") String? bearerToken,
      @Query("appointer") int userId,
      @Query("page") int pageNo);

  @GET("api/faq")
  Future<List<Faq>> getFaqs();

  @GET("api/addresses")
  Future<List<Address>> getAddresses(
      @Header("Authorization") String? bearerToken);

  @POST("api/addresses")
  Future<Address> createAddress(@Header("Authorization") String? bearerToken,
      @Body() AddressRequest addressRequest);

  @POST("api/ride/drivers/ratings/{driverId}")
  Future<dynamic> createRatingDriver(
      @Header("Authorization") String? bearerToken,
      @Path("driverId") int driverId,
      @Body() RatingRequest ratingRequest);

  @PUT("api/addresses/{addressId}")
  Future<Address> updateAddress(@Header("Authorization") String? bearerToken,
      @Path("addressId") int addressId, @Body() AddressRequest addressRequest);

  @DELETE("api/addresses/{addressId}")
  Future<void> deleteAddress(@Header("Authorization") String? bearerToken,
      @Path("addressId") int addressId);

  @POST("api/support")
  Future<dynamic> postSupport(@Header("Authorization") String? bearerToken,
      @Body() SupportRequest supportRequest);

  @GET("api/user/notifications")
  Future<BaseListResponse<UserNotification>> getUserNotifications(
      @Header("Authorization") String? bearerToken, @Query("page") int pageNo);

  @GET("api/payment/methods")
  Future<List<PaymentMethod>> paymentMethods();

  @POST("api/user/wallet/payout")
  Future<dynamic> sendToBank(@Header("Authorization") String? bearerToken,
      @Body() SendToBank sendToBank);

  @POST("api/user/wallet/deposit")
  Future<Payment> depositWallet(@Header("Authorization") String? bearerToken,
      @Body() Map<String, String> map);

  @GET("api/payment/wallet/{paymentId}")
  Future<PaymentResponse> payThroughWallet(
      @Header("Authorization") String? bearerToken,
      @Path("paymentId") String paymentId);

  @GET("api/user/wallet/balance")
  Future<Wallet> balanceWallet(@Header("Authorization") String? bearerToken);

  @GET("api/user/wallet/transactions")
  Future<BaseListResponse<Transaction>> transactionsWallet(
      @Header("Authorization") String? bearerToken, @Query("page") int pageNo);

  @GET("api/payment/stripe/{paymentId}")
  Future<PaymentResponse> payThroughStripe(
      @Header("Authorization") String? bearerToken,
      @Path("paymentId") String paymentId,
      @Query("token") String stripeToken);

  @POST("api/user/push-notification")
  Future<void> postNotification(
      @Header("Authorization") String? bearerToken,
      @Body() Map<String, dynamic> notiData,
      @Query("message_title") String? messageTitle,
      @Query("message_body") String? messageBody);

  @GET("api/user/notifications/summary")
  Future<NotificationsSummary> getNotificationsSummary(
      @Header("Authorization") String? bearerToken);

  @POST("api/user/notifications/read")
  Future<dynamic> postNotificationsRead(
      @Header("Authorization") String? bearerToken);

  @DELETE("api/user")
  Future<void> deleteUser(@Header("Authorization") String? bearerToken);

  @GET("api/ride/vehicle-types")
  Future<VehicleTypeResponse> getVehicleTypes(
    @Header("Authorization") String? bearerToken, {
    @Query("latitude_from") String? latitudeFrom,
    @Query("longitude_from") String? longitudeFrom,
    @Query("from_city") String? cityFrom,
    @Query("latitude_to") String? latitudeTo,
    @Query("longitude_to") String? longitudeTo,
    @Query("to_city") String? cityTo,
    @Query("type") String? vehicleType,
  });

  @GET("api/coupons")
  Future<List<Coupon>> getCoupons(@Header("Authorization") String? bearerToken);

  @GET("api/ride/coupons")
  Future<List<Coupon>> getRideCoupons(
      @Header("Authorization") String? bearerToken);

  @GET("api/coupons/check-validity")
  Future<Coupon> checkCouponValidity(
      @Header("Authorization") String? bearerToken,
      @Query("code") String couponCode);

  @POST("api/ride/rides")
  Future<Ride> createRide(@Header("Authorization") String? bearerToken,
      @Body() Map<String, dynamic> map);

  @GET("api/ride/rides")
  Future<BaseListResponse<Ride>> getRides(
    @Header("Authorization") String? bearerToken,
    @Query("page") int pageNo,
  );

  @PUT("api/ride/rides/{rideId}")
  Future<Ride> updateRide(
    @Header("Authorization") String? bearerToken,
    @Path("rideId") int rideId,
    @Body() Map<String, dynamic> updateRideRequest,
  );

  @GET("api/vendors/list")
  Future<BaseListResponse<Vendor>> searchVendors(
    @Header("Authorization") String? bearerToken, {
    @Query("search") String? text,
    @Query("category") int? catId,
    @Query("lat") double? lat,
    @Query("long") double? lng,
    @Query("page") int? pageNum,
    @Query("per_page") int perPage = 15,
    @Query("sort") String? sort,
    @Query("meta[vendor_type]") String? vendorType,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET("api/products")
  Future<BaseListResponse<Product>> searchProducts(
    @Header("Authorization") String? bearerToken, {
    @Query("search") String? search,
    @Query("vendor") int? vendorId,
    @Query("category") int? categoryId,
    @Query("page") int? pageNum,
    @Query("per_page") int perPage = 15,
  });

  @GET("api/products?pagination=0")
  Future<List<Product>> searchProductsWoPagination(
    @Header("Authorization") String? bearerToken, {
    @Query("search") String? search,
    @Query("vendor") int? vendorId,
    @Query("category") int? categoryId,
    @Query("page") int? pageNum,
    @Query("per_page") int perPage = 15,
  });

  @GET("api/orders/calculate-delivery-fee?order_type=CUSTOM")
  Future<DeliveryFee> getDeliveryFeeCustom(
    @Header("Authorization") String? bearerToken, {
    @Query("source_lat") required String sourceLatitude,
    @Query("source_lng") required String sourceLongitude,
    @Query("dest_lat") required String destinationLatitude,
    @Query("dest_lng") required String destinationLongitude,
  });

  @GET("api/orders/calculate-delivery-fee")
  Future<DeliveryFee> getDeliveryFee(
    @Header("Authorization") String? bearerToken, {
    @Query("vendor_id") required String vendorId,
    @Query("source_lat") required String sourceLat,
    @Query("source_lng") required String sourceLng,
    @Query("dest_lat") required String destLat,
    @Query("dest_lng") required String destLng,
    @Query("order_type") required String orderType,
  });

  @GET("api/orders")
  Future<BaseListResponse<Order>> getOrders(
    @Header("Authorization") String? bearerToken, {
    @Query("page") int? pageNum,
    @Query("active") int? active,
    @Query("past") int? past,
    @Query("meta[category_slug]") String? vendorType,
  });

  @POST("api/orders")
  Future<CreateOrderRes> createOrder(
      @Header("Authorization") String? bearerToken,
      @Body() Map<String, dynamic> map);

  @POST("api/vendors/ratings/{vendorId}")
  Future<void> postVendorReview(
    @Header("Authorization") String? bearerToken,
    @Path("vendorId") int vendorId,
    @Body() Map<String, dynamic> rateRequest,
  );

  @POST("api/delivery/ratings/{deliveryId}")
  Future<void> postDeliveryReview(
    @Header("Authorization") String? bearerToken,
    @Path("deliveryId") int deliveryId,
    @Body() Map<String, dynamic> rateRequest,
  );

  @GET("api/provider/profile/list")
  Future<BaseListResponse<ServiceProvider>> getServiceProviders(
    @Header("Authorization") String? bearerToken, {
    @Query("page") int? pageNo,
    @Query("category") int? categoryId,
    @Query("subcategory") int? subCategoryId,
    @Query("lat") double? latitude,
    @Query("long") double? longitude,
  });

  @PUT("api/orders/{orderId}")
  Future<Order> updateOrder(@Header("Authorization") String? bearerToken,
      @Path("orderId") int orderId, @Body() Map<String, dynamic> map);

  @POST("api/file-upload")
  @MultiPart()
  Future<FileUploadResponse> uploadFile({@Part() File? file});
}
