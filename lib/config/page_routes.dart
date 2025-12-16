import 'package:deligo/pages/onboarding_page.dart';
import 'package:flutter/material.dart';

import 'package:deligo/pages/add_address_page.dart';
import 'package:deligo/pages/add_money_page.dart';
import 'package:deligo/pages/appointment_info_page.dart';
import 'package:deligo/pages/cart_page.dart';
import 'package:deligo/pages/confirm_package_order_details_page.dart';
import 'package:deligo/pages/coupon_page.dart';
import 'package:deligo/pages/faq_page.dart';
import 'package:deligo/pages/message_page.dart';
import 'package:deligo/pages/order_info_page.dart';
import 'package:deligo/pages/process_payment_page.dart';
import 'package:deligo/pages/products_page.dart';
import 'package:deligo/pages/profile_page.dart';
import 'package:deligo/pages/rate_appointment_page.dart';
import 'package:deligo/pages/rate_order_page.dart';
import 'package:deligo/pages/ride_complete_page.dart';
import 'package:deligo/pages/ride_info_page.dart';
import 'package:deligo/pages/saved_address_page.dart';
import 'package:deligo/pages/search_store_items_page.dart';
import 'package:deligo/pages/select_language_page.dart';
import 'package:deligo/pages/select_services_page.dart';
import 'package:deligo/pages/select_src_dst_page.dart';
import 'package:deligo/pages/service_provider_page.dart';
import 'package:deligo/pages/service_providers_page.dart';
import 'package:deligo/pages/sub_categories_page.dart';
import 'package:deligo/pages/support_page.dart';
import 'package:deligo/pages/tnc_page.dart';
import 'package:deligo/pages/vendors_page.dart';
import 'package:deligo/pages/wallet_page.dart';

class PageRoutes {
  static const String orderInfoPage = 'order_info_page';
  static const String profilePage = 'profile_page';
  static const String languagePage = 'language_page';
  static const String savedAddressPage = 'saved_addresses_page';
  static const String addAddressPage = 'add_new_addresses_page';
  static const String supportPage = 'support_page';
  static const String tncPage = 'tnc_page';
  static const String cartPage = 'cart_page';
  static const String selectSrcDstPage = 'select_src_dst_page';
  static const String couponPage = 'coupon_page';
  static const String rideInfoPage = 'ride_info_page';
  static const String rideCompletePage = 'ride_complete_page';
  static const String messagePage = 'message_page';
  static const String confirmPackageOrderDetailsPage = 'confirm_package_order_details_page';
  static const String subCategoriesPage = 'sub_categories_page';
  static const String vendorsPage = 'vendors_page';
  static const String productsPage = 'products_page';
  static const String processPaymentPage = 'process_payment_page';
  static const String walletPage = 'wallet_page';
  static const String addMoneyPage = 'add_money_page';
  static const String faqPage = 'faq_page';
  static const String selectServicesPage = 'select_services_page';
  static const String rateOrderPage = 'rate_order_page';
  static const String searchStoreItemsPage = 'search_store_items_page';
  static const String serviceProvidersPage = 'service_providers_page';
  static const String serviceProviderPage = 'service_provider_page';
  static const String appointmentInfoPage = 'appointment_info_page';
  static const String rateAppointmentPage = 'rate_appointment_page';
  static const String onboardingPage = 'onboarding_page';

  Map<String, WidgetBuilder> routes() => {
        savedAddressPage: (context) => const SavedAddressPage(),
        addAddressPage: (context) => const AddAddressPage(),
        //addNewAddressesPage: (context) => const AddNewAddressPage(),
        supportPage: (context) => const SupportPage(),
        tncPage: (context) => const TncPage(),
        profilePage: (context) => const ProfilePage(),
        languagePage: (context) => const SelectLanguagePage(),
        cartPage: (context) => const CartPage(),
        selectSrcDstPage: (context) => const SelectSrcDstPage(),
        couponPage: (context) => const CouponPage(),
        rideInfoPage: (context) => const RideInfoPage(),
        rideCompletePage: (context) => const RideCompletePage(),
        messagePage: (context) => const MessagePage(),
        confirmPackageOrderDetailsPage: (context) =>
            const ConfirmPackageOrderDetailsPage(),
        subCategoriesPage: (context) => const SubCategoriesPage(),
        vendorsPage: (context) => const VendorsPage(),
        productsPage: (context) => const ProductsPage(),
        processPaymentPage: (context) => const ProcessPaymentPage(),
        walletPage: (context) => const WalletPage(),
        addMoneyPage: (context) => const AddMoneyPage(),
        orderInfoPage: (context) => const OrderInfoPage(),
        faqPage: (context) => const FaqPage(),
        selectServicesPage: (context) => const SelectServicesPage(),
        rateOrderPage: (context) => const RateOrderPage(),
        searchStoreItemsPage: (context) => const SearchStoreItemsPage(),
        serviceProvidersPage: (context) => const ServiceProvidersPage(),
        serviceProviderPage: (context) => const ServiceProviderPage(),
        appointmentInfoPage: (context) => const AppointmentInfoPage(),
        rateAppointmentPage: (context) => const RateAppointmentPage(),
        onboardingPage: (context) => const OnboardingScreen(),
      };
}
