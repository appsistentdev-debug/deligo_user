import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart' as fire_db;
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:deligo/bloc/payment_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/models/address_request.dart';
import 'package:deligo/models/appointment.dart';
import 'package:deligo/models/base_list_response.dart';
import 'package:deligo/models/category.dart' as my_category;
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/create_order_res.dart';
import 'package:deligo/models/delivery_fee.dart';
import 'package:deligo/models/faq.dart';
import 'package:deligo/models/file_upload_response.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/models/order_req.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/models/rating_request.dart';
import 'package:deligo/models/review.dart' as my_review;
import 'package:deligo/models/ride.dart';
import 'package:deligo/models/ride_request.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:deligo/models/support_request.dart';
import 'package:deligo/models/transaction.dart';
import 'package:deligo/models/update_user_request.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/models/user_notification.dart';
import 'package:deligo/models/vehicle_type.dart';
import 'package:deligo/models/vehicle_type_fare.dart';
import 'package:deligo/models/vehicle_type_response.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/models/wallet.dart';
import 'package:deligo/network/map_repository.dart';
import 'package:deligo/network/remote_repository.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/locale_data_layer.dart';

part 'fetcher_state.dart';

class FetcherCubit extends Cubit<FetcherState> {
  final RemoteRepository _repository = RemoteRepository();
  StreamSubscription<fire_db.DatabaseEvent>? _rideStream;
  StreamSubscription<fire_db.DatabaseEvent>? _rideLocationStream;
  StreamSubscription<fire_db.DatabaseEvent>? _ordersStreamSubscription;
  StreamSubscription<fire_db.DatabaseEvent>? _orderStreamSubscription;
  StreamSubscription<fire_db.DatabaseEvent>? _deliveryStreamSubscription;
  StreamSubscription<fire_db.DatabaseEvent>? _appointmentsStreamSubscription;
  StreamSubscription<fire_db.DatabaseEvent>? _appointmentStreamSubscription;
  CancelToken? _cancelToken;

  FetcherCubit() : super(const FetcherInitial());

  Future<void> initGetUserMe(bool forceReload) async {
    if (!isClosed) emit(const UserMeLoading());
    if (forceReload) {
      try {
        UserData? freshUser = await _repository.getUser();
        if (freshUser != null) {
          await LocalDataLayer().setUserMe(freshUser);
          if (!isClosed) emit(UserMeLoaded(freshUser));
        } else {
          if (!isClosed) {
            emit(UserMeError("Something went wrong", "something_wrong"));
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("initGetUserMe: $e");
        }
        if (!isClosed) {
          emit(UserMeError(_getErrorMessage(e), "something_wrong"));
        }
      }
    } else {
      UserData? savedUser = await LocalDataLayer().getUserMe();
      if (!isClosed) {
        emit(savedUser != null
            ? UserMeLoaded(savedUser)
            : UserMeError("Unauthenticated", "unauthenticated"));
      }
    }
  }

  Future<void> initUpdateUserMe(String? name, File? imageFile) async {
    if (!isClosed) emit(const UserMeUpdating());
    try {
      FileUploadResponse? fileUploadResponse;
      if (imageFile != null) {
        try {
          fileUploadResponse = await RemoteRepository().uploadFile(imageFile);
        } catch (e) {
          if (kDebugMode) {
            print("RemoteRepository.uploadFile: $e");
          }
        }
      }
      UserData? updatedUser = await _repository.updateUser(
          UpdateUserRequest(name, fileUploadResponse?.url).toJson());
      if (updatedUser != null) {
        await LocalDataLayer().setUserMe(updatedUser);
        if (!isClosed) emit(UserMeLoaded(updatedUser));
      } else {
        if (!isClosed) {
          emit(UserMeError("Something went wrong", "something_wrong"));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("initUpdateUserMe: $e");
      }
      if (!isClosed) emit(UserMeError(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initSupportSubmit(String supportMsg) async {
    if (!isClosed) emit(const SupportLoading());
    try {
      UserData? userData = await LocalDataLayer().getUserMe();
      await _repository.postSupport(
          SupportRequest(userData!.name, userData.email, supportMsg));
      if (!isClosed) emit(const SupportLoaded());
    } catch (e) {
      if (kDebugMode) {
        print("initSupportSubmit: $e");
      }
      if (!isClosed) {
        emit(SupportLoadFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchFaqs() async {
    if (!isClosed) emit(const FaqLoading());
    try {
      List<Faq> faqs = await _repository.getFaqs();
      if (!isClosed) emit(FaqLoaded(faqs));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchFaqs: $e");
      }
      if (!isClosed) emit(FaqLoadFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initFetchBanners() async {
    try {
      if (!isClosed) emit(const BannersLoading());
      List<my_category.Category> bannersSaved =
          await LocalDataLayer().getBanners();
      if (bannersSaved.isNotEmpty) {
        if (!isClosed) {
          emit(BannersLoaded(bannersSaved));
        }
      }
      List<my_category.Category> banners = await _repository.getBanners();
      if (!isClosed) emit(const BannersLoading());
      for (my_category.Category banner in banners) {
        banner.setup();
      }
      if (!isClosed) emit(BannersLoaded(banners));
      await LocalDataLayer().saveBanners(banners);
    } catch (e) {
      if (kDebugMode) {
        print("initFetchBanners: $e");
      }
      if (!isClosed) emit(BannersFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initFetchCategories({
    int? parent,
    String? scope,
    String? vendorType,
    String? isEnabled,
    String? parentCatIdsCommaSeparated,
    String? query,
  }) async {
    if (!isClosed) emit(const CategoriesLoading());
    try {
      List<my_category.Category> categories = await _repository.getCategories(
        parent: parent,
        scope: scope,
        vendorType: vendorType,
        isEnabled: isEnabled,
        parentCatIdsCommaSeparated: parentCatIdsCommaSeparated,
        query: query,
      );
      for (my_category.Category category in categories) {
        category.setup();
      }
      if (!isClosed) emit(CategoriesLoaded(categories));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchCategoriesParent: $e");
      }
      if (!isClosed) {
        emit(CategoriesFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchCategoriesWithScope(String scope) async {
    if (!isClosed) emit(const CategoriesLoading());
    try {
      List<my_category.Category> categoriesSaved =
          await LocalDataLayer().getCategoriesHome();
      if (categoriesSaved.isNotEmpty) {
        for (my_category.Category category in categoriesSaved) {
          category.setup();
        }
        categoriesSaved.removeWhere((element) {
          //for testing purposes
          // if (F.name == Flavor.deligo.name && element.slug == "home-service") {
          //   return false;
          // }
          //for testing purposes
          return !(element.isEnabled ?? false);
        });
        if (!isClosed) emit(CategoriesLoaded(categoriesSaved));
      }
      List<my_category.Category> categories =
          await _repository.getCategories(scope: scope);
      if (categoriesSaved.isNotEmpty) {
        if (!isClosed) emit(const CategoriesLoading());
      }
      await LocalDataLayer().saveCategoriesHome(categories);
      for (my_category.Category category in categories) {
        category.setup();
      }
      categories.removeWhere((element) {
        //for testing purposes
        // if (F.name == Flavor.deligo.name && element.slug == "home-service") {
        //   return false;
        // }
        //for testing purposes
        return !(element.isEnabled ?? false);
      });
      if (!isClosed) emit(CategoriesLoaded(categories));
    } catch (e) {
      if (kDebugMode) {
        print("getCategoriesWithScope: $e");
      }
      if (!isClosed) {
        emit(CategoriesFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchCategoriesWithVendorType(String vendorType) async {
    if (!isClosed) emit(const CategoriesLoading());
    try {
      List<my_category.Category> categories =
          await _repository.initFetchCategoriesWithVendorType(vendorType);
      for (my_category.Category category in categories) {
        category.setup();
      }
      if (!isClosed) emit(CategoriesLoaded(categories));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchCategoriesWithVendorType: $e");
      }
      if (!isClosed) {
        emit(CategoriesFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchCategoriesChild(int parentCatId) async {
    if (!isClosed) emit(const CategoriesLoading());
    try {
      List<my_category.Category> categories = parentCatId == -1
          ? await _repository.getCategoriesAll()
          : await _repository.getCategoriesChild("$parentCatId");
      for (my_category.Category category in categories) {
        category.setup();
      }
      if (!isClosed) emit(CategoriesLoaded(categories));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchCategoriesParent: $e");
      }
      if (!isClosed) {
        emit(CategoriesFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchCategoriesSearch(String query) async {
    if (!isClosed) emit(const CategoriesLoading());
    try {
      List<my_category.Category> categories =
          await _repository.getCategoriesSearch(query);
      for (my_category.Category category in categories) {
        category.setup();
      }
      if (!isClosed) emit(CategoriesLoaded(categories));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchCategoriesSearch: $e");
      }
      if (!isClosed) {
        emit(CategoriesFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchNotifications(int pageNo) async {
    if (!isClosed) emit(const UserNotificationsLoading());
    try {
      BaseListResponse<UserNotification> notifications =
          await _repository.getUserNotifications(pageNo);
      for (UserNotification notification in notifications.data) {
        notification.setup();
      }
      if (!isClosed) emit(UserNotificationsLoaded(notifications));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchProviderReviews: $e");
      }
      if (!isClosed) {
        emit(UserNotificationsFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initCreateRatingDriver(
      int rideId, int driverId, RatingRequest ratingRequest) async {
    if (!isClosed) emit(const RatingLoading());
    try {
      await _repository.createRatingDriver(driverId, ratingRequest);
      await LocalDataLayer()
          .setRatedRide(rideId, (ratingRequest.rating ?? 5).toDouble());
      if (!isClosed) emit(const RatingLoaded());
    } catch (e) {
      if (kDebugMode) {
        print("initCreateRatingDriver: $e");
      }
      if (!isClosed) emit(RatingFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initCreateRatingServiceProvider(
      int appointmentId, int providerId, RatingRequest ratingRequest) async {
    if (!isClosed) emit(const RatingLoading());
    try {
      await _repository.createRatingProvider(providerId, ratingRequest);
      await LocalDataLayer().setAppointmentIdRated(appointmentId);
      if (!isClosed) emit(const RatingLoaded());
    } catch (e) {
      if (kDebugMode) {
        print("createRatingProvider: $e");
      }
      if (!isClosed) emit(RatingFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initFetchAddresses() async {
    if (!isClosed) emit(const AddressesLoading());
    try {
      List<Address> addresses = await _repository.fetchAddresses();
      if (!isClosed) emit(AddressesLoaded(addresses));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchAddresses: $e");
      }
      if (!isClosed) {
        emit(AddressesLoadFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initCreateAddress(AddressRequest addressRequest) async {
    if (!isClosed) emit(const AddressAddLoading());
    try {
      Address address = await _repository.createAddress(addressRequest);
      if (!isClosed) emit(AddressAddLoaded(address));
    } catch (e) {
      if (kDebugMode) {
        print("initCreateAddress: $e");
      }
      if (!isClosed) {
        emit(AddressAddFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initUpdateAddress(
      int addressId, AddressRequest addressRequest) async {
    if (!isClosed) emit(const AddressUpdateLoading());
    try {
      Address address =
          await _repository.updateAddress(addressId, addressRequest);
      if (!isClosed) emit(AddressUpdateLoaded(address));
    } catch (e) {
      if (kDebugMode) {
        print("initUpdateAddress: $e");
      }
      if (!isClosed) {
        emit(AddressUpdateFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initDeleteAddress(int addressId) async {
    if (!isClosed) emit(const AddressDeleteLoading());
    try {
      await _repository.deleteAddress(addressId);
      if (!isClosed) emit(AddressDeleteLoaded(addressId));
    } catch (e) {
      if (kDebugMode) {
        print("initDeleteAddress: $e");
      }
      if (!isClosed) {
        emit(AddressDeleteFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchLatLngAddress(String? tag, LatLng latLng) async {
    if (!isClosed) emit(const ReverseGeocodeLoading());
    try {
      MapRepository mapRepository = MapRepository();
      Placemark placemark = await mapRepository.getPlaceMarkFromLatLng(latLng);
      String address = await mapRepository.getAddress(placemark, true);
      if (!isClosed) {
        emit(ReverseGeocodeLoaded(tag, _getCity(placemark), address, latLng));
      }
    } catch (e) {
      if (kDebugMode) {
        print("initFetchLatLngAddress: $e");
      }
      if (!isClosed) {
        emit(ReverseGeocodeFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchPredictionAddress(
      String? tag, Prediction prediction) async {
    if (!isClosed) emit(const GeocodeLoading());
    try {
      MapRepository mapRepository = MapRepository();
      PlaceDetails placeDetails =
          await mapRepository.getPlaceDetails(prediction.placeId!);
      LatLng latLng = LatLng(placeDetails.geometry!.location.lat,
          placeDetails.geometry!.location.lng);
      String address = "";
      Placemark? placemark;
      try {
        placemark = await mapRepository.getPlaceMarkFromLatLng(latLng);
        address = await mapRepository.getAddress(placemark, true);
      } catch (e) {
        address = placeDetails.formattedAddress ?? "";
        if (kDebugMode) {
          print("getAddress: $e");
        }
      }
      if (!isClosed) {
        emit(GeocodeLoaded(tag, _getCity(placemark), address, latLng));
      }
    } catch (e) {
      if (kDebugMode) {
        print("initFetchPredictionAddress: $e");
      }
      if (!isClosed) emit(GeocodeFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initFetchWalletBalance() async {
    if (!isClosed) emit(const WalletBalanceLoading());
    try {
      Wallet wallet = await _repository.balanceWallet();
      if (!isClosed) emit(WalletBalanceLoaded(wallet));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchWalletBalance: $e");
      }
      if (!isClosed) {
        emit(WalletBalanceFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchWalletTransactions(int pageNo) async {
    if (!isClosed) emit(const WalletTransactionsLoading());
    try {
      BaseListResponse<Transaction> notifications =
          await _repository.transactionsWallet(pageNo);
      for (Transaction wt in notifications.data) {
        wt.setup();
      }
      if (!isClosed) emit(WalletTransactionsLoaded(notifications));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchWalletTransactions: $e");
      }
      if (!isClosed) {
        emit(WalletTransactionsFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchVendors({
    String? text,
    int? catId,
    double? lat,
    double? lng,
    required int pageNum,
    int perPage = 15,
    String? sort,
    String? vendorType,
  }) async {
    if (!isClosed) emit(const VendorsLoading());
    try {
      _cancelToken = CancelToken();
      Address? sa = await LocalDataLayer().getSavedAddress();
      BaseListResponse<Vendor> vendors = await _repository.searchVendors(
        pageNum: pageNum,
        perPage: perPage,
        text: text,
        catId: catId,
        lat: lat ?? sa?.latitude,
        lng: lng ?? sa?.longitude,
        sort: sort,
        vendorType: vendorType,
        cancelToken: _cancelToken,
      );
      for (Vendor r in vendors.data) {
        r.setup();
      }
      if (!isClosed) emit(VendorsLoaded(vendors, sort ?? vendorType));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchVendors: $e");
      }
      bool isCancelled;
      try {
        isCancelled = CancelToken.isCancel(e as DioException);
      } catch (e) {
        if (kDebugMode) {
          print("isCancelled: $e");
        }
        isCancelled = false;
      }
      if (!isCancelled) {
        if (!isClosed) {
          emit(VendorsFail(_getErrorMessage(e), "something_wrong"));
        }
      }
    }
  }

  void initCancelFetchVendors() => _cancelToken?.cancel("Cancelled");

  Future<void> initFetchProducts(
      {String? search,
      int? vendorId,
      int? categoryId,
      required int pageNum,
      int perPage = 15,
      bool pagination = true}) async {
    if (!isClosed) emit(ProductsLoading(categoryId));
    try {
      if (pagination) {
        BaseListResponse<Product> products = await _repository.searchProducts(
          pageNum: pageNum,
          perPage: perPage,
          search: search,
          vendorId: vendorId,
          categoryId: categoryId,
        );
        for (Product r in products.data) {
          r.setup();
        }
        if (!isClosed) emit(ProductsLoaded(products, categoryId));
      } else {
        // List<Product> products = await _repository.searchProductsWoPagination(
        //   pageNum: pageNum,
        //   perPage: perPage,
        //   search: search,
        //   vendorId: vendorId,
        //   categoryId: categoryId,
        // );
        BaseListResponse<Product> productsRes =
            await _repository.searchProducts(
          pageNum: pageNum,
          perPage: perPage,
          search: search,
          vendorId: vendorId,
          categoryId: categoryId,
        );
        List<Product> products = productsRes.data;
        for (Product r in products) {
          r.setup();
        }
        if (!isClosed) emit(ProductsListLoaded(products, categoryId));
      }
    } catch (e) {
      if (kDebugMode) {
        print("initFetchProducts: $e");
      }
      if (!isClosed) {
        emit(ProductsFail(_getErrorMessage(e), "something_wrong", categoryId));
      }
    }
  }

  Future<void> initFetchDeliveryFeeCustom({
    required String sourceLatitude,
    required String sourceLongitude,
    required String destinationLatitude,
    required String destinationLongitude,
  }) async {
    if (!isClosed) emit(const DeliveryFeeLoading());
    try {
      DeliveryFee deliveryFee = await _repository.getDeliveryFeeCustom(
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        sourceLatitude: sourceLatitude,
        sourceLongitude: sourceLongitude,
      );
      if (!isClosed) emit(DeliveryFeeLoaded(deliveryFee));
    } catch (e) {
      if (kDebugMode) {
        print("getDeliveryFeeCustom: $e");
      }
      if (!isClosed) {
        emit(DeliveryFeeFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchDeliveryFee({
    required String vendorId,
    required String sourceLat,
    required String sourceLng,
    required String destLat,
    required String destLng,
    required String orderType,
  }) async {
    if (!isClosed) emit(const DeliveryFeeLoading());
    try {
      DeliveryFee deliveryFee = await _repository.getDeliveryFee(
        vendorId: vendorId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        destLat: destLat,
        destLng: destLng,
        orderType: orderType,
      );
      if (!isClosed) emit(DeliveryFeeLoaded(deliveryFee));
    } catch (e) {
      if (kDebugMode) {
        print("getDeliveryFeeCustom: $e");
      }
      if (!isClosed) {
        emit(DeliveryFeeFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initValidateCoupon(String couponCode) async {
    if (!isClosed) emit(const CouponValidityLoading());
    try {
      Coupon coupon = await _repository.checkCouponValidity(couponCode);
      if (!isClosed) emit(CouponValidityLoaded(coupon));
    } catch (e) {
      if (kDebugMode) {
        print("initValidateCoupon: $e");
      }
      if (!isClosed) {
        emit(CouponValidityFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initCreateOrder(OrderReq orderReq) async {
    if (!isClosed) emit(const CreateOrderLoading());
    try {
      CreateOrderRes createOrderRes = await _repository.createOrder(orderReq);
      if (!isClosed) {
        emit(CreateOrderLoaded(
            createOrderRes,
            PaymentData(
              payment: createOrderRes.payment ?? createOrderRes.order.payment!,
              payuMeta: PayUMeta(
                name: createOrderRes.order.user!.name.replaceAll(' ', ''),
                mobile: createOrderRes.order.user!.mobile_number
                    .replaceAll(' ', ''),
                email: createOrderRes.order.user!.email.replaceAll(' ', ''),
                bookingId: "${createOrderRes.order.id}",
                productinfo: "Order Id#${createOrderRes.order.id}",
              ),
            )));
      }
    } catch (e) {
      if (kDebugMode) {
        print("initCreateOrder: $e");
      }
      if (!isClosed) {
        emit(CreateOrderFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchOrders(int pageNo, {String? vendorType}) async {
    if (!isClosed) emit(const OrdersLoading());
    try {
      BaseListResponse<Order> orders =
          await _repository.getOrders(pageNo, vendorType: vendorType);
      List<my_category.Category> categoriesSaved =
          await LocalDataLayer().getCategoriesHome();
      for (Order r in orders.data) {
        r.setup(categoriesSaved);
      }
      if (!isClosed) emit(OrdersLoaded(orders));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchOrders: $e");
      }
      if (!isClosed) emit(OrdersFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  void initRateOrder(Order order, Map<String, dynamic> ratingRequestVendor,
      Map<String, dynamic> ratingRequestDelivery) async {
    if (!isClosed) emit(const RateOrderLoading());
    try {
      await _repository.postVendorReview(order.vendor_id!, ratingRequestVendor);
      if (order.delivery != null) {
        await _repository.postDeliveryReview(
            order.delivery!.delivery.id, ratingRequestDelivery);
      }
      await LocalDataLayer().setOrderIdRated(order.id);
      if (!isClosed) emit(const RateOrderLoaded());
    } catch (e) {
      if (kDebugMode) {
        print("initRateOrder: $e");
      }
      if (!isClosed) {
        emit(RateOrderFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchVehicleTypes({
    String? latitudeFrom,
    String? longitudeFrom,
    String? cityFrom,
    String? latitudeTo,
    String? longitudeTo,
    String? cityTo,
    String? rideType,
  }) async {
    if (!isClosed) emit(const VehicleTypeLoading());
    try {
      VehicleTypeResponse vehicleTypeResponse =
          await _repository.getVehicleTypes(
        latitudeFrom: latitudeFrom,
        latitudeTo: latitudeTo,
        longitudeFrom: longitudeFrom,
        cityFrom: cityFrom,
        longitudeTo: longitudeTo,
        cityTo: cityTo,
        vehicleType: rideType,
      );
      for (VehicleType vt in vehicleTypeResponse.vehicle_types) {
        vt.setupImageUrl();
        for (VehicleTypeFare vtf in vehicleTypeResponse.fares) {
          if (vtf.vehicle_type_id == vt.id) {
            vt.estimated_fare_subtotal =
                vtf.estimated_fare ?? vtf.estimated_fare_subtotal;
            break;
          }
        }
      }

      if (!isClosed) emit(VehicleTypeLoaded(vehicleTypeResponse.vehicle_types));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchVehicleTypes: $e");
      }
      if (!isClosed) {
        emit(VehicleTypeFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchCoupons() async {
    if (!isClosed) emit(const CouponsLoading());
    try {
      List<Coupon> coupons = await _repository.getCoupons();
      if (!isClosed) emit(CouponsLoaded(coupons));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchCoupons: $e");
      }
      if (!isClosed) emit(CouponsFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initFetchRides(int pageNo) async {
    if (!isClosed) emit(const RidesLoading());
    try {
      //FROM LOCAL FOR TESTING
      // String sampleOrdersString =
      //     await rootBundle.loadString("assets/sample_rides.json");
      // BaseListResponse<Ride> sampleRides = BaseListResponse<Ride>.fromJson(
      //   jsonDecode(sampleOrdersString),
      //   (json) => Ride.fromJson(json as Map<String, dynamic>),
      // );
      // for (Ride r in sampleRides.data) {
      //   r.setup();
      // }
      // if(!isClosed) emit(RidesLoaded(
      //     BaseListResponse<Ride>(sampleRides.data, sampleRides.meta)));
      //LIVE RESPONSE
      BaseListResponse<Ride> rides = await _repository.getRides(pageNo);
      for (Ride r in rides.data) {
        r.setup();
      }
      if (!isClosed) {
        emit(RidesLoaded(BaseListResponse<Ride>(rides.data, rides.meta)));
      }
    } catch (e) {
      if (kDebugMode) {
        print("initFetchRides: $e");
      }
      if (!isClosed) emit(RidesFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initCreateRide(RideRequest rideRequest) async {
    if (!isClosed) emit(const CreateRideLoading());
    try {
      // IF CHECKING FOR ONGOING RIDE FIRST, PASS RIDEREQUEST AS NULL
      // Ride? ride;
      // if (rideRequest == null) {
      //   BaseListResponse<Ride> rides = await _repository.getRides(1, true);
      //   for (Ride ru in rides.data) {
      //     if (ru.isOngoing) {
      //       ride = ru;
      //       break;
      //     }
      //   }
      // } else {
      //   ride = await _repository.createRide(rideRequest);
      // }
      // ride?.setup();
      // if(!isClosed) emit(CreateRideLoaded(ride));

      Ride ride = await _repository.createRide(rideRequest);
      ride.setup();
      if (!isClosed) emit(CreateRideLoaded(ride));
    } catch (e) {
      if (kDebugMode) {
        print("initCreateRide: $e");
      }
      bool is404 = e is DioException && e.response?.statusCode == 404;
      if (!isClosed) {
        emit(CreateRideFail(
            is404 ? "Driver not found at the moment" : _getErrorMessage(e),
            is404 ? "driver_na" : "something_wrong"));
      }
    }
  }

  Future<void> initUpdateRide(int rideId, String status) async {
    if (!isClosed) emit(const RideUpdateLoading());
    try {
      Ride ride = await _repository.updateRide(rideId, status);
      ride.setup();
      if (kDebugMode) {
        print("SELFUPDATE TRIGGERED: ${ride.id}-${ride.status}");
      }
      if (!isClosed) emit(RideUpdateLoaded(ride));
    } catch (e) {
      if (kDebugMode) {
        print("initUpdateRide: $e");
      }
      if (!isClosed) {
        emit(RideUpdateFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initUpdateOrder(int orderId, Map<String, dynamic> body) async {
    if (!isClosed) emit(const OrdersLoading());
    try {
      Order order = await _repository.updateOrder(orderId, body);
      List<my_category.Category> categoriesSaved =
          await LocalDataLayer().getCategoriesHome();
      order.setup(categoriesSaved);
      if (!isClosed) emit(OrderUpdateLoaded(order));
    } catch (e) {
      if (kDebugMode) {
        print("initUpdateOrder: $e");
      }
      if (!isClosed) emit(OrdersFail(_getErrorMessage(e), "something_wrong"));
    }
  }

  Future<void> initFetchServiceProviders({
    int? pageNo,
    int? categoryId,
    int? subCategoryId,
    double? latitude,
    double? longitude,
  }) async {
    if (!isClosed) emit(const ServiceProvidersLoading());
    try {
      Address? sa = await LocalDataLayer().getSavedAddress();
      BaseListResponse<ServiceProvider> serviceProviders =
          await _repository.getServiceProviders(
        pageNo: pageNo,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        latitude: latitude ?? sa?.latitude,
        longitude: longitude ?? sa?.longitude,
      );
      for (ServiceProvider sp in serviceProviders.data) {
        sp.setup();
      }
      if (!isClosed) emit(ServiceProvidersLoaded(serviceProviders));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchServiceProviders: $e");
      }
      if (!isClosed) {
        emit(ServiceProvidersFail(_getErrorMessage(e), "something_wrong"));
      }
    }
  }

  Future<void> initFetchServiceProviderReviews(
      int providerId, int pageNo) async {
    if (!isClosed) emit(const ServiceProviderReviewsLoading());
    try {
      BaseListResponse<my_review.Review> reviews =
          await _repository.getReviewsProvider(providerId, pageNo);
      for (my_review.Review review in reviews.data) {
        review.setup();
      }
      if (!isClosed) emit(ServiceProviderReviewsLoaded(reviews));
    } catch (e) {
      if (kDebugMode) {
        print("initFetchServiceProviderReviews: $e");
      }
      if (!isClosed) {
        emit(ServiceProviderReviewsFail(
            "Something went wrong", "something_wrong"));
      }
    }
  }

  void initUpdateAppointment(
      int appointmentId, Map<String, dynamic> appointmentUpdateRequest) async {
    if (!isClosed) emit(const AppointmentUpdateLoading());
    try {
      Appointment appointment = await _repository.updateAppointment(
          appointmentId, appointmentUpdateRequest);
      if (appointment.user != null && appointment.provider != null) {
        _repository.addFirebaseAppointment(appointment);
        appointment.setup();
        if (!isClosed) emit(AppointmentUpdateLoaded(appointment));
      } else {
        if (!isClosed) {
          emit(
              AppointmentUpdateFail("Something went wrong", "something_wrong"));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("initUpdateAppointment: $e");
      }
      if (!isClosed) {
        emit(AppointmentUpdateFail("Something went wrong", "something_wrong"));
      }
    }
  }

  void initCreateAppointment(
      int providerId, Map<String, dynamic> appointmentCreateRequest) async {
    if (!isClosed) emit(const AppointmentCreateLoading());
    try {
      Appointment appointment = await _repository.createAppointment(
          providerId, appointmentCreateRequest);
      if (appointment.user != null && appointment.provider != null) {
        _repository.addFirebaseAppointment(appointment);
        appointment.setup();
        if (!isClosed) {
          emit(AppointmentCreateLoaded(
            appointment,
            PaymentData(
              payment: appointment.payment!,
              payuMeta: PayUMeta(
                name: appointment.user!.name.replaceAll(' ', ''),
                mobile: appointment.user!.mobile_number.replaceAll(' ', ''),
                email: appointment.user!.email.replaceAll(' ', ''),
                bookingId: "${Random().nextInt(999) + 10}${appointment.id}",
                productinfo: (appointment.provider!.name ?? AppConfig.appName)
                    .replaceAll(' ', ''),
              ),
            ),
          ));
        }
      } else {
        if (!isClosed) {
          emit(
              AppointmentCreateFail("Something went wrong", "something_wrong"));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("initCreateAppointment: $e");
      }
      AppointmentCreateFail errorState =
          AppointmentCreateFail("Something went wrong", "something_wrong");
      try {
        if (e is DioException &&
            (e).response != null &&
            (e).response!.data != null) {
          Map<String, dynamic> errorResponse = (e).response!.data;
          if (errorResponse.containsKey("errors")) {
            if ((errorResponse['errors'] as Map<String, dynamic>)
                .containsKey("time_from")) {
              errorState = AppointmentCreateFail(
                  (errorResponse['errors']['time_from'] as List<dynamic>)
                          .isNotEmpty
                      ? (errorResponse['errors']['time_from']
                          as List<dynamic>)[0]
                      : "Something went wrong",
                  "err_slot_time_from");
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      if (!isClosed) emit(errorState);
    }
  }

  Future<void> initFetchAppointments(int pageNo, bool? isUpcoming) async {
    if (!isClosed) emit(const AppointmentsLoading());
    try {
      UserData? userData = await LocalDataLayer().getUserMe();
      BaseListResponse<Appointment> appointments =
          await _repository.getAppointments(userData!.id, pageNo, isUpcoming);
      appointments.data.removeWhere(
          (element) => element.user == null || element.provider == null);
      for (Appointment appointment in appointments.data) {
        appointment.setup();
      }
      if (!isClosed) emit(AppointmentsLoaded(appointments));
      initRegisterAppointmentsUpdates();
      // return Future.delayed(Duration(seconds: 10), () async {
      //   String sampleAppointmentsString =
      //       await rootBundle.loadString("assets/sample_appointments.json");
      //   BaseListResponse<Appointment> sampleAppointments =
      //       BaseListResponse<Appointment>.fromJson(
      //     jsonDecode(sampleAppointmentsString),
      //     (json) => Appointment.fromJson(json as Map<String, dynamic>),
      //   );
      //   for (Appointment appointment in sampleAppointments.data)
      //     appointment.setup();
      //   emit(AppointmentsLoaded(sampleAppointments));
      //   return;
      // });
    } catch (e) {
      if (kDebugMode) {
        print("initFetchAppointments: $e");
      }
      if (!isClosed) {
        emit(AppointmentsFail("Something went wrong", "something_wrong"));
      }
    }
  }

  Future<void> registerRideUpdates(Ride ride) =>
      LocalDataLayer().getUserMe().then((UserData? userData) {
        _rideStream ??= fire_db.FirebaseDatabase.instance
            .ref()
            .child("fire_app/users/${userData!.id}/rides/${ride.id}")
            .onValue
            .listen((fire_db.DatabaseEvent event) =>
                _handleFireOnValueRideEvent(event));
        _rideLocationStream ??= fire_db.FirebaseDatabase.instance
            .ref()
            .child("fire_app/drivers/${ride.driver?.id}/location")
            .onValue
            .listen((fire_db.DatabaseEvent event) =>
                _handleFireOnValueLocationEvent(event));
      });

  void _handleFireOnValueRideEvent(fire_db.DatabaseEvent event) {
    if (event.snapshot.value != null) {
      try {
        if (!isClosed) emit(const RideUpdateLoading());
        Map resultMap = event.snapshot.value as Map;
        Ride newRide = Ride.fromJson(jsonDecode(jsonEncode(resultMap)));
        newRide.setup();
        if (kDebugMode) {
          print("FIREBASE TRIGGERED: ${newRide.id}-${newRide.status}");
        }
        if (!isClosed) emit(RideUpdateLoaded(newRide));
      } catch (e) {
        if (kDebugMode) {
          print("handleFireOnValueRideEvent: $e");
        }
      }
    }
  }

  void _handleFireOnValueLocationEvent(fire_db.DatabaseEvent event) {
    if (event.snapshot.value != null) {
      try {
        if (!isClosed) emit(const RideUpdateLoading());
        Map resultMap = event.snapshot.value as Map;
        if (!isClosed) {
          emit(LocationUpdateLoaded(LatLng(
              double.parse("${resultMap["current_latitude"]}"),
              double.parse("${resultMap["current_longitude"]}"))));
        }
      } catch (e) {
        if (kDebugMode) {
          print("handleFireOnValueLocationEvent: $e");
        }
      }
    }
  }

  String? _getCity(Placemark? placemark) {
    String? toReturn;
    if (placemark?.isoCountryCode == "AL") {
      if ((placemark?.name?.toLowerCase() ?? "").contains("airport")) {
        toReturn = "Airport";
      } else {
        toReturn = placemark?.locality;
      }
    } else {
      toReturn = placemark?.locality;
    }
    if (kDebugMode) {
      print("CITY-$toReturn");
    }
    return toReturn;
  }

  String _getErrorMessage(Object e) {
    try {
      DioException de = (e as DioException);
      return (de.response?.statusCode ?? -1) > 499
          ? "Something went wrong"
          : de.response!.data["message"];
    } catch (e) {
      if (kDebugMode) {
        print("getErrorMessage: $e");
      }
      return "Something went wrong";
    }
  }

  void initRegisterOrderUpdates(int orderId) =>
      LocalDataLayer().getUserMe().then((UserData? userData) =>
          _orderStreamSubscription ??= fire_db.FirebaseDatabase.instance
              .ref()
              .child("users/${userData!.id}/orders/$orderId/data")
              .onValue
              .listen((fire_db.DatabaseEvent event) =>
                  _handleFireChangedOrdersEvent(event)));

  void initRegisterOrdersUpdates() =>
      LocalDataLayer().getUserMe().then((UserData? userData) =>
          _ordersStreamSubscription ??= fire_db.FirebaseDatabase.instance
              .ref()
              .child("users/${userData!.id}/orders")
              .onChildChanged
              .listen((fire_db.DatabaseEvent event) =>
                  _handleFireChangedOrdersEvent(event)));

  void initRegisterDeliveryUpdates(int deliveryId) =>
      _deliveryStreamSubscription ??= fire_db.FirebaseDatabase.instance
          .ref()
          .child("fire_app/drivers/$deliveryId/location")
          .onValue
          .listen((fire_db.DatabaseEvent event) =>
              _handleFireOnValueLocationEvent(event));

  void initRegisterAppointmentsUpdates() =>
      LocalDataLayer().getUserMe().then((UserData? userData) =>
          _appointmentsStreamSubscription ??= fire_db.FirebaseDatabase.instance
              .ref(Constants.refUpdates)
              .child("appointment/${Constants.roleUser}_${userData!.id}")
              .onChildChanged
              .listen((fire_db.DatabaseEvent event) =>
                  _handleFireChangedAppointmentsEvent(event)));

  void initRegisterAppointmentUpdates(int appointmentId) =>
      LocalDataLayer().getUserMe().then((UserData? userData) =>
          _appointmentStreamSubscription ??= fire_db.FirebaseDatabase.instance
              .ref(Constants.refUpdates)
              .child("appointment/${Constants.roleUser}_${userData!.id}")
              .child("$appointmentId")
              .onValue
              .listen((fire_db.DatabaseEvent event) =>
                  _handleFireChangedAppointmentsEvent(event)));

  void _handleFireChangedAppointmentsEvent(fire_db.DatabaseEvent event) async {
    if (event.snapshot.value != null) {
      try {
        Map resultMap = event.snapshot.value as Map;
        Appointment updateAppointment =
            Appointment.fromJson(jsonDecode(jsonEncode(resultMap)));
        if (!isClosed) emit(const AppointmentUpdateLoading());
        updateAppointment.setup();
        if (!isClosed) emit(AppointmentUpdateLoaded(updateAppointment));
      } catch (e) {
        if (kDebugMode) {
          print("requestMapCastError: $e");
        }
      }
    }
  }

  void _handleFireChangedOrdersEvent(fire_db.DatabaseEvent event) async {
    if (event.snapshot.value != null) {
      try {
        if (!isClosed) emit(OrdersLoading());
        Map requestMap = event.snapshot.value as Map;
        Order orderUpdated = Order.fromJson(jsonDecode(jsonEncode(
            requestMap.containsKey("data") ? requestMap["data"] : requestMap)));
        List<my_category.Category> categoriesSaved =
            await LocalDataLayer().getCategoriesHome();
        orderUpdated.setup(categoriesSaved);
        if (!isClosed) emit(OrderUpdateLoaded(orderUpdated));
      } catch (e) {
        if (kDebugMode) {
          print("requestMapCastError: $e");
        }
      }
    }
  }

  Future<void> initUnRegisterOrderUpdates() async {
    await _orderStreamSubscription?.cancel();
    _orderStreamSubscription = null;
  }

  Future<void> initUnRegisterOrdersUpdates() async {
    await _ordersStreamSubscription?.cancel();
    _ordersStreamSubscription = null;
  }

  Future<void> initUnRegisterDeliveryUpdates() async {
    await _deliveryStreamSubscription?.cancel();
    _deliveryStreamSubscription = null;
  }

  Future<void> initUnRegisterAppointmentsUpdates() async {
    await _appointmentsStreamSubscription?.cancel();
    _appointmentsStreamSubscription = null;
  }

  Future<void> initUnRegisterAppointmentUpdates() async {
    await _appointmentStreamSubscription?.cancel();
    _appointmentStreamSubscription = null;
  }

  Future<void> initUnRegisterRideUpdates() async {
    await _rideStream?.cancel();
    _rideStream = null;
    await _rideLocationStream?.cancel();
    _rideLocationStream = null;
  }
}
