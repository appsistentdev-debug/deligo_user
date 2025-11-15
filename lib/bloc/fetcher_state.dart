part of 'fetcher_cubit.dart';

/// APPOINTMENTUPDATE STATES START
class AppointmentUpdateLoading extends FetcherLoading {
  const AppointmentUpdateLoading();
}

class AppointmentUpdateLoaded extends FetcherLoaded {
  final Appointment appointment;
  const AppointmentUpdateLoaded(this.appointment);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppointmentUpdateLoaded && other.appointment == appointment;
  }

  @override
  int get hashCode => appointment.hashCode;
}

class AppointmentUpdateFail extends FetcherFail {
  AppointmentUpdateFail(super.message, super.messageKey);
}

/// APPOINTMENTUPDATE STATES END

/// APPOINTMENTS STATES START
class AppointmentsLoading extends FetcherLoading {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends FetcherLoaded {
  final BaseListResponse<Appointment> appointments;
  const AppointmentsLoaded(this.appointments);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentsLoaded && other.appointments == appointments;
  }

  @override
  int get hashCode => appointments.hashCode;
}

class AppointmentsFail extends FetcherFail {
  AppointmentsFail(super.message, super.messageKey);
}

/// APPOINTMENTS STATES END

/// APPOINTMENTCREATE STATES START
class AppointmentCreateLoading extends FetcherLoading {
  const AppointmentCreateLoading();
}

class AppointmentCreateLoaded extends FetcherLoaded {
  final Appointment appointment;
  final PaymentData paymentData;
  const AppointmentCreateLoaded(this.appointment, this.paymentData);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppointmentCreateLoaded && other.appointment == appointment;
  }

  @override
  int get hashCode => appointment.hashCode;
}

class AppointmentCreateFail extends FetcherFail {
  AppointmentCreateFail(super.message, super.messageKey);
}

/// APPOINTMENTCREATE STATES END

/// PROVIDERREVIEWS STATES START
class ServiceProviderReviewsLoading extends FetcherLoading {
  const ServiceProviderReviewsLoading();
}

class ServiceProviderReviewsLoaded extends FetcherLoaded {
  final BaseListResponse<my_review.Review> reviews;
  const ServiceProviderReviewsLoaded(this.reviews);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceProviderReviewsLoaded && other.reviews == reviews;
  }

  @override
  int get hashCode => reviews.hashCode;
}

class ServiceProviderReviewsFail extends FetcherFail {
  ServiceProviderReviewsFail(super.message, super.messageKey);
}

/// PROVIDERREVIEWS STATES END

///SERVICEPROVIDER STATES START
class ServiceProvidersLoading extends FetcherLoading {
  const ServiceProvidersLoading();
}

class ServiceProvidersLoaded extends FetcherLoaded {
  final BaseListResponse<ServiceProvider> serviceProviders;
  const ServiceProvidersLoaded(this.serviceProviders);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceProvidersLoaded &&
          runtimeType == other.runtimeType &&
          serviceProviders == other.serviceProviders;

  @override
  int get hashCode => serviceProviders.hashCode;
}

class ServiceProvidersFail extends FetcherFail {
  ServiceProvidersFail(super.message, super.messageKey);
}

///SERVICEPROVIDER STATES END

/// ORDERS STATES START
class OrdersLoading extends FetcherLoading {
  const OrdersLoading();
}

class OrdersLoaded extends FetcherLoaded {
  final BaseListResponse<Order> orders;
  const OrdersLoaded(this.orders);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersLoaded &&
          runtimeType == other.runtimeType &&
          orders == other.orders;

  @override
  int get hashCode => orders.hashCode;
}

class OrderUpdateLoaded extends FetcherLoaded {
  final Order order;
  const OrderUpdateLoaded(this.order);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderUpdateLoaded &&
          runtimeType == other.runtimeType &&
          order == other.order;

  @override
  int get hashCode => order.hashCode;
}

class OrdersFail extends FetcherFail {
  OrdersFail(super.message, super.messageKey);
}

/// ORDERS STATES END

/// CREATEORDER STATES START
class CreateOrderLoading extends FetcherLoading {
  const CreateOrderLoading();
}

class CreateOrderLoaded extends FetcherLoaded {
  final CreateOrderRes createOrderRes;
  final PaymentData paymentData;
  const CreateOrderLoaded(this.createOrderRes, this.paymentData);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateOrderLoaded &&
          runtimeType == other.runtimeType &&
          createOrderRes == other.createOrderRes &&
          paymentData == other.paymentData;

  @override
  int get hashCode => createOrderRes.hashCode;
}

class CreateOrderFail extends FetcherFail {
  CreateOrderFail(super.message, super.messageKey);
}

/// CREATEORDER STATES END

/// RATEORDER STATES START
class RateOrderLoading extends FetcherLoading {
  const RateOrderLoading();
}

class RateOrderLoaded extends FetcherLoaded {
  const RateOrderLoaded();
}

class RateOrderFail extends FetcherFail {
  RateOrderFail(super.message, super.messageKey);
}

/// RATEORDER STATES END

/// COUPONVALIDITY STATES START
class CouponValidityLoading extends FetcherLoading {
  const CouponValidityLoading();
}

class CouponValidityLoaded extends FetcherLoaded {
  final Coupon coupon;
  const CouponValidityLoaded(this.coupon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CouponValidityLoaded &&
          runtimeType == other.runtimeType &&
          coupon == other.coupon;

  @override
  int get hashCode => coupon.hashCode;
}

class CouponValidityFail extends FetcherFail {
  CouponValidityFail(super.message, super.messageKey);
}

/// COUPONVALIDITY STATES END

/// DELIVERYFEE STATES START
class DeliveryFeeLoading extends FetcherLoading {
  const DeliveryFeeLoading();
}

class DeliveryFeeLoaded extends FetcherLoaded {
  final DeliveryFee deliveryFee;
  const DeliveryFeeLoaded(this.deliveryFee);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryFeeLoaded &&
          runtimeType == other.runtimeType &&
          deliveryFee == other.deliveryFee;

  @override
  int get hashCode => deliveryFee.hashCode;
}

class DeliveryFeeFail extends FetcherFail {
  DeliveryFeeFail(super.message, super.messageKey);
}

/// DELIVERYFEE STATES END

/// RIDES STATES START
class RidesLoading extends FetcherLoading {
  const RidesLoading();
}

class RidesLoaded extends FetcherLoaded {
  final BaseListResponse<Ride> rides;
  const RidesLoaded(this.rides);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RidesLoaded &&
          runtimeType == other.runtimeType &&
          rides == other.rides;

  @override
  int get hashCode => rides.hashCode;
}

class RidesFail extends FetcherFail {
  RidesFail(super.message, super.messageKey);
}

/// RIDES STATES END

/// RIDEUPDATE STATES START
class RideUpdateLoading extends FetcherLoading {
  const RideUpdateLoading();
}

class RideUpdateLoaded extends FetcherLoaded {
  final Ride ride;
  const RideUpdateLoaded(this.ride);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideUpdateLoaded &&
          runtimeType == other.runtimeType &&
          ride == other.ride;

  @override
  int get hashCode => ride.hashCode;
}

class LocationUpdateLoaded extends FetcherLoaded {
  final LatLng latLng;
  const LocationUpdateLoaded(this.latLng);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationUpdateLoaded &&
          runtimeType == other.runtimeType &&
          latLng == other.latLng;

  @override
  int get hashCode => latLng.hashCode;
}

class RideUpdateFail extends FetcherFail {
  RideUpdateFail(super.message, super.messageKey);
}

/// RIDEUPDATE STATES END

/// CreateRide STATES START
class CreateRideLoading extends FetcherLoading {
  const CreateRideLoading();
}

class CreateRideLoaded extends FetcherLoaded {
  final Ride ride;

  const CreateRideLoaded(this.ride);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRideLoaded &&
          runtimeType == other.runtimeType &&
          ride == other.ride;

  @override
  int get hashCode => ride.hashCode;
}

class CreateRideFail extends FetcherFail {
  CreateRideFail(super.message, super.messageKey);
}

/// CreateRide STATES END

/// COUPONS STATES START
class CouponsLoading extends FetcherLoading {
  const CouponsLoading();
}

class CouponsLoaded extends FetcherLoaded {
  final List<Coupon> coupons;

  const CouponsLoaded(this.coupons);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CouponsLoaded && listEquals(other.coupons, coupons);
  }

  @override
  int get hashCode => coupons.hashCode;
}

class CouponsFail extends FetcherFail {
  CouponsFail(super.message, super.messageKey);
}

/// COUPONS STATES END

/// VENDORS STATES START
class VendorsLoading extends FetcherLoading {
  const VendorsLoading();
}

class VendorsLoaded extends FetcherLoaded {
  final BaseListResponse<Vendor> vendors;
  final String? sortOrVendorType;
  const VendorsLoaded(this.vendors, this.sortOrVendorType);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorsLoaded &&
          runtimeType == other.runtimeType &&
          vendors == other.vendors &&
          sortOrVendorType == other.sortOrVendorType;

  @override
  int get hashCode => vendors.hashCode ^ sortOrVendorType.hashCode;
}

class VendorsFail extends FetcherFail {
  VendorsFail(super.message, super.messageKey);
}

/// VENDORS STATES END

/// PRODUCTS STATES START
class ProductsLoading extends FetcherLoading {
  final int? categoryId;
  const ProductsLoading([this.categoryId]);
}

class ProductsLoaded extends FetcherLoaded {
  final BaseListResponse<Product> products;
  final int? categoryId;
  const ProductsLoaded(this.products, [this.categoryId]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsLoaded &&
          runtimeType == other.runtimeType &&
          products == other.products &&
          categoryId == other.categoryId;

  @override
  int get hashCode => products.hashCode ^ categoryId.hashCode;
}

class ProductsListLoaded extends FetcherLoaded {
  final List<Product> products;
  final int? categoryId;
  const ProductsListLoaded(this.products, [this.categoryId]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsListLoaded &&
          runtimeType == other.runtimeType &&
          foundation.listEquals(other.products, products) &&
          categoryId == other.categoryId;

  @override
  int get hashCode => products.hashCode ^ categoryId.hashCode;
}

class ProductsFail extends FetcherFail {
  final int? categoryId;
  ProductsFail(super.message, super.messageKey, [this.categoryId]);
}

/// PRODUCTS STATES END

/// VEHICLETYPES STATES START
class VehicleTypeLoading extends FetcherLoading {
  const VehicleTypeLoading();
}

class VehicleTypeLoaded extends FetcherLoaded {
  final List<VehicleType> vehicleTypes;
  const VehicleTypeLoaded(this.vehicleTypes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTypeLoaded &&
          runtimeType == other.runtimeType &&
          vehicleTypes == other.vehicleTypes;

  @override
  int get hashCode => vehicleTypes.hashCode;
}

class VehicleTypeFail extends FetcherFail {
  VehicleTypeFail(super.message, super.messageKey);
}

/// VEHICLETYPES STATES END

/// WALLETTRANSACTIONS STATES START
class WalletTransactionsLoading extends FetcherLoading {
  const WalletTransactionsLoading();
}

class WalletTransactionsLoaded extends FetcherLoaded {
  final BaseListResponse<Transaction> transactions;
  const WalletTransactionsLoaded(this.transactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTransactionsLoaded &&
          runtimeType == other.runtimeType &&
          transactions == other.transactions;

  @override
  int get hashCode => transactions.hashCode;
}

class WalletTransactionsFail extends FetcherFail {
  WalletTransactionsFail(super.message, super.messageKey);
}

/// WALLETTRANSACTIONS STATES END

/// WALLETBALANCE STATES START
class WalletBalanceLoading extends FetcherLoading {
  const WalletBalanceLoading();
}

class WalletBalanceLoaded extends FetcherLoaded {
  final Wallet wallet;
  const WalletBalanceLoaded(this.wallet);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletBalanceLoaded &&
          runtimeType == other.runtimeType &&
          wallet == other.wallet;

  @override
  int get hashCode => wallet.hashCode;
}

class WalletBalanceFail extends FetcherFail {
  WalletBalanceFail(super.message, super.messageKey);
}

/// WALLETBALANCE STATES END

/// RATING STATES START
class RatingLoading extends FetcherLoading {
  const RatingLoading();
}

class RatingLoaded extends FetcherLoaded {
  const RatingLoaded();
}

class RatingFail extends FetcherFail {
  RatingFail(super.message, super.messageKey);
}

/// RATING STATES END

// /// APPOINTMENTUPDATE STATES START
// class AppointmentUpdateLoading extends FetcherLoading {
//   const AppointmentUpdateLoading();
// }

// class AppointmentUpdateLoaded extends FetcherLoaded {
//   final Appointment appointment;
//   const AppointmentUpdateLoaded(this.appointment);

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is AppointmentUpdateLoaded && other.appointment == appointment;
//   }

//   @override
//   int get hashCode => appointment.hashCode;
// }

// class AppointmentUpdateFail extends FetcherFail {
//   AppointmentUpdateFail(String message, String messageKey)
//       : super(message, messageKey);
// }

// /// APPOINTMENTUPDATE STATES END

// /// APPOINTMENTS STATES START
// class AppointmentsLoading extends FetcherLoading {
//   const AppointmentsLoading();
// }

// class AppointmentsLoaded extends FetcherLoaded {
//   final BaseListResponse<Appointment> appointments;
//   const AppointmentsLoaded(this.appointments);

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is AppointmentsLoaded && other.appointments == appointments;
//   }

//   @override
//   int get hashCode => appointments.hashCode;
// }

// class AppointmentsFail extends FetcherFail {
//   AppointmentsFail(String message, String messageKey)
//       : super(message, messageKey);
// }

// /// APPOINTMENTS STATES END

// /// APPOINTMENTCREATE STATES START
// class AppointmentCreateLoading extends FetcherLoading {
//   const AppointmentCreateLoading();
// }

// class AppointmentCreateLoaded extends FetcherLoaded {
//   final Appointment appointment;
//   final PaymentData paymentData;
//   const AppointmentCreateLoaded(this.appointment, this.paymentData);

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is AppointmentCreateLoaded && other.appointment == appointment;
//   }

//   @override
//   int get hashCode => appointment.hashCode;
// }

// class AppointmentCreateFail extends FetcherFail {
//   AppointmentCreateFail(String message, String messageKey)
//       : super(message, messageKey);
// }

// /// APPOINTMENTCREATE STATES END

/// USERNOTIFICATIONS STATES START
class UserNotificationsLoading extends FetcherLoading {
  const UserNotificationsLoading();
}

class UserNotificationsLoaded extends FetcherLoaded {
  final BaseListResponse<UserNotification> notifications;
  const UserNotificationsLoaded(this.notifications);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserNotificationsLoaded &&
        other.notifications == notifications;
  }

  @override
  int get hashCode => notifications.hashCode;
}

class UserNotificationsFail extends FetcherFail {
  UserNotificationsFail(super.message, super.messageKey);
}

/// USERNOTIFICATIONS STATES END

// /// PROVIDERREVIEWS STATES START
// class ProviderReviewsLoading extends FetcherLoading {
//   const ProviderReviewsLoading();
// }

// class ProviderReviewsLoaded extends FetcherLoaded {
//   final BaseListResponse<Review> reviews;
//   const ProviderReviewsLoaded(this.reviews);

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ProviderReviewsLoaded && other.reviews == reviews;
//   }

//   @override
//   int get hashCode => reviews.hashCode;
// }

// class ProviderReviewsFail extends FetcherFail {
//   ProviderReviewsFail(String message, String messageKey)
//       : super(message, messageKey);
// }

// /// PROVIDERREVIEWS STATES END

// /// PROVIDERSLISTING STATES START
// class ProvidersLoading extends FetcherLoading {
//   const ProvidersLoading();
// }

// class ProvidersLoaded extends FetcherLoaded {
//   final BaseListResponse<Provider> providers;
//   const ProvidersLoaded(this.providers);

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ProvidersLoaded && other.providers == providers;
//   }

//   @override
//   int get hashCode => providers.hashCode;
// }

// class ProvidersFail extends FetcherFail {
//   ProvidersFail(String message, String messageKey) : super(message, messageKey);
// }

// /// PROVIDERSLISTING STATES END

/// BANNERS STATES START
class BannersLoading extends FetcherLoading {
  const BannersLoading();
}

class BannersLoaded extends FetcherLoaded {
  final List<my_category.Category> banners;
  const BannersLoaded(this.banners);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BannersLoaded &&
        foundation.listEquals(other.banners, banners);
  }

  @override
  int get hashCode => banners.hashCode;
}

class BannersFail extends FetcherFail {
  BannersFail(super.message, super.messageKey);
}

/// BANNERS STATES END

/// CATEGORIES STATES START
class CategoriesLoading extends FetcherLoading {
  const CategoriesLoading();
}

class CategoriesLoaded extends FetcherLoaded {
  final List<my_category.Category> categories;
  const CategoriesLoaded(this.categories);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoriesLoaded &&
        foundation.listEquals(other.categories, categories);
  }

  @override
  int get hashCode => categories.hashCode;
}

class CategoriesFail extends FetcherFail {
  CategoriesFail(super.message, super.messageKey);
}

/// CATEGORIES STATES END

/// ADDRESSDELETE STATES START
class AddressDeleteLoading extends FetcherLoading {
  const AddressDeleteLoading();
}

class AddressDeleteLoaded extends FetcherLoaded {
  final int addressId;
  const AddressDeleteLoaded(this.addressId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddressDeleteLoaded && other.addressId == addressId;
  }

  @override
  int get hashCode => addressId.hashCode;
}

class AddressDeleteFail extends FetcherFail {
  AddressDeleteFail(super.message, super.messageKey);
}

/// ADDRESSDELETE STATES END

/// ADDRESSUPDATE STATES START
class AddressUpdateLoading extends FetcherLoading {
  const AddressUpdateLoading();
}

class AddressUpdateLoaded extends FetcherLoaded {
  final Address address;
  const AddressUpdateLoaded(this.address);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddressUpdateLoaded && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;
}

class AddressUpdateFail extends FetcherFail {
  AddressUpdateFail(super.message, super.messageKey);
}

/// ADDRESSUPDATE STATES END

/// ADDRESSADD STATES START
class AddressAddLoading extends FetcherLoading {
  const AddressAddLoading();
}

class AddressAddLoaded extends FetcherLoaded {
  final Address address;
  const AddressAddLoaded(this.address);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddressAddLoaded && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;
}

class AddressAddFail extends FetcherFail {
  AddressAddFail(super.message, super.messageKey);
}

/// ADDRESSADD STATES END

/// GEOCODING STATES START
class GeocodeLoading extends FetcherLoading {
  const GeocodeLoading();
}

class GeocodeLoaded extends FetcherLoaded {
  final String? tag;
  final String? city;
  final String address;
  final LatLng latLng;
  const GeocodeLoaded(this.tag, this.city, this.address, this.latLng);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeocodeLoaded &&
        other.city == city &&
        other.tag == tag &&
        other.address == address &&
        other.latLng == latLng;
  }

  @override
  int get hashCode => address.hashCode ^ latLng.hashCode;
}

class GeocodeFail extends FetcherFail {
  GeocodeFail(super.message, super.messageKey);
}

/// GEOCODING STATES END

/// REVERSEGEOCODING STATES START
class ReverseGeocodeLoading extends FetcherLoading {
  const ReverseGeocodeLoading();
}

class ReverseGeocodeLoaded extends FetcherLoaded {
  final String? tag;
  final String? city;
  final String address;
  final LatLng latLng;
  const ReverseGeocodeLoaded(this.tag, this.city, this.address, this.latLng);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReverseGeocodeLoaded &&
        other.tag == tag &&
        other.city == city &&
        other.address == address &&
        other.latLng == latLng;
  }

  @override
  int get hashCode => address.hashCode ^ latLng.hashCode;
}

class ReverseGeocodeFail extends FetcherFail {
  ReverseGeocodeFail(super.message, super.messageKey);
}

/// REVERSEGEOCODING STATES END

/// ADDRESS STATES START
class AddressesLoading extends FetcherLoading {
  const AddressesLoading();
}

class AddressesLoaded extends FetcherLoaded {
  final List<Address> addresses;
  const AddressesLoaded(this.addresses);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressesLoaded &&
        foundation.listEquals(other.addresses, addresses);
  }

  @override
  int get hashCode => addresses.hashCode;
}

class AddressesLoadFail extends FetcherFail {
  AddressesLoadFail(super.message, super.messageKey);
}

/// ADDRESS STATES END

/// FAQ STATES START
class FaqLoading extends FetcherLoading {
  const FaqLoading();
}

class FaqLoaded extends FetcherLoaded {
  final List<Faq> faqs;
  const FaqLoaded(this.faqs);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaqLoaded && foundation.listEquals(other.faqs, faqs);
  }

  @override
  int get hashCode => faqs.hashCode;
}

class FaqLoadFail extends FetcherFail {
  FaqLoadFail(super.message, super.messageKey);
}

/// FAQ STATES END

/// SUPPORT STATES START
class SupportLoading extends FetcherLoading {
  const SupportLoading();
}

class SupportLoaded extends FetcherLoaded {
  const SupportLoaded();
}

class SupportLoadFail extends FetcherFail {
  SupportLoadFail(super.message, super.messageKey);
}

/// SUPPORT STATES END

/// USERME STATES START
class UserMeLoading extends FetcherLoading {
  const UserMeLoading();
}

class UserMeUpdating extends FetcherLoading {
  const UserMeUpdating();
}

class UserMeLoaded extends FetcherLoaded {
  final UserData userMe;

  UserMeLoaded(this.userMe) {
    userMe.setup();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMeLoaded &&
          runtimeType == other.runtimeType &&
          userMe == other.userMe;

  @override
  int get hashCode => userMe.hashCode;
}

class UserMeError extends FetcherFail {
  UserMeError(super.message, super.messageKey);
}

/// USERME STATES END

/// BASE STATES START
abstract class FetcherState {
  const FetcherState();
}

class FetcherInitial extends FetcherState {
  const FetcherInitial();
}

class FetcherLoading extends FetcherState {
  const FetcherLoading();
}

class FetcherLoaded extends FetcherState {
  const FetcherLoaded();
}

class FetcherFail extends FetcherState {
  final String message, messageKey;

  const FetcherFail(this.message, this.messageKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetcherFail &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          messageKey == other.messageKey;

  @override
  int get hashCode => message.hashCode ^ messageKey.hashCode;
}
/// BASE STATES END