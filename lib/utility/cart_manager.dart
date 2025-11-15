import 'dart:convert';

import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartManager {
  CartManager._privateConstructor() {
    _init();
  }

  static final CartManager _instance = CartManager._privateConstructor();

  factory CartManager() {
    return _instance;
  }

  final String _cartKey = "key_cart";
  SharedPreferences? _sharedPreferences;
  late Cart _cart;

  Future<void> _init() async {
    await _initPrefs();
    _initCart();
  }

  Future<void> _initPrefs() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> _saveCart() async {
    await _initPrefs();
    return _sharedPreferences!.setString(_cartKey, _cart.toJson());
  }

  void _initCart() {
    _cart = _sharedPreferences!.containsKey(_cartKey)
        ? Cart.fromJson(_sharedPreferences!.getString(_cartKey)!)
        : Cart(cartItems: [], extraCharges: [], orderMeta: {});
    double taxes_and_charges = double.tryParse(AppSettings.taxInPercent) ?? 0;
    double delivery_fee = double.tryParse(AppSettings.deliveryFee) ?? 0;
    final currency_icon = AppSettings.currencyIcon;
    final subTotal = cartItemsTotal;

    _cart.removeExtraCharge("delivery_fee");
    _cart.removeExtraCharge("taxes_and_charges");
    if (taxes_and_charges > 0) {
      _cart.addExtraCharge(ExtraCharge(
        extraChargeObject: AppSettings.taxInPercent,
        id: "taxes_and_charges",
        title: "Service Fee",
        isPercent: true,
        price: taxes_and_charges,
        priceToShow: "$currency_icon ${((subTotal * taxes_and_charges) / 100)}",
      ));
    }
    if (delivery_fee > 0) {
      _cart.addExtraCharge(genDeliveryExtraCharge(delivery_fee));
    }
  }

  Future<void> clearCart() async {
    await _initPrefs();
    await _sharedPreferences!.remove(_cartKey);
    _initCart();
  }

  ExtraCharge genDeliveryExtraCharge(double deliveryFee) => ExtraCharge(
        extraChargeObject: deliveryFee,
        id: "delivery_fee",
        title: "Delivery Fee",
        isPercent: false,
        price: deliveryFee,
        priceToShow: "${AppSettings.currencyIcon} $deliveryFee",
      );

  double get cartItemsTotal => _cart.getTotalCartItems();
  double get cartTotal => _cart.getTotalCart();

  List<CartItem> get cartItems => _cart.cartItems;
  List<ExtraCharge> get extraCharges => _cart.extraCharges;
  Map<String, String> get orderMeta => _cart.orderMeta;

  int get cartItemsCount => _cart.cartItems.length;

  double calculateExtraChargePice(ExtraCharge extraCharge) =>
      extraCharge.isPercent
          ? ((cartItemsTotal * extraCharge.price) / 100)
          : extraCharge.price;

  int getCartProductQuantity(int proId) {
    int quantity = 0;
    for (var ci in getCartItemsWithProductId(proId)) {
      quantity += ci.quantity;
    }
    return quantity;
  }

  List<CartItem> getCartItemsWithProductId(int proId) {
    List<CartItem> toReturn = [];
    for (CartItem ci in _cart.cartItems) {
      if (_getProductIdFromCartItemId(ci.id) == proId) {
        toReturn.add(ci);
      }
    }
    return toReturn;
  }

  bool removeCartItemWithProductId(int proId) {
    int index = -1;
    for (int i = 0; i < _cart.cartItems.length; i++) {
      if (_getProductIdFromCartItemId(_cart.cartItems[i].id) == proId) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      _cart.cartItems.removeAt(index);
      _saveCart();
    }
    return index != -1;
  }

  int _getProductIdFromCartItemId(String cartItemId) => int.parse(
      cartItemId.contains("+") ? cartItemId.split("+")[0] : cartItemId);

  bool addOrIncrementCartItem(CartItem ci) {
    int index = _cart.cartItems.indexWhere((element) => element.id == ci.id);
    if (index == -1) {
      _cart.cartItems.add(ci);
    } else {
      ci.setQuantity(_cart.cartItems[index].quantity + 1);
      _cart.cartItems[index] = ci;
    }
    _saveCart();
    return index == -1;
  }

  bool removeOrDecrementCartItem(CartItem ci) {
    int index = _cart.cartItems.indexWhere((element) => element.id == ci.id);
    bool removed = false;
    if (index != -1) {
      if (_cart.cartItems[index].quantity > 1) {
        ci.setQuantity(_cart.cartItems[index].quantity - 1);
        _cart.cartItems[index] = ci;
      } else {
        removed = true;
        _cart.cartItems.removeAt(index);
      }
      _saveCart();
    }
    return removed;
  }

  //custom PRODUCT implementation below
  CartItem genCartItemFromProduct(
      Product product, List<CartItemAddOn>? addOns) {
    String id = "${product.vendor_products?.firstOrNull?.id ?? product.id}";
    double addOnPrice = 0;
    if (addOns?.isNotEmpty ?? false) {
      id += "+";
      for (CartItemAddOn ao in addOns!) {
        id += "${ao.id}_";
        addOnPrice += ao.price;
      }
      id.substring(0, id.lastIndexOf("_"));
    }
    Map<String, dynamic> ciMeta = product.meta ?? {};
    if (product.vendor_products?.firstOrNull?.vendor != null) {
      ciMeta["vendor_id"] = product.vendor_products?.first.vendor!.id;
      ciMeta["vendor_name"] = product.vendor_products?.first.vendor!.name;
      ciMeta["vendor_lat"] =
          "${product.vendor_products?.first.vendor!.latitude}";
      ciMeta["vendor_lng"] =
          "${product.vendor_products?.first.vendor!.longitude}";
    }
    CartItem toReturn = CartItem(
      id: id,
      addOns: addOns ?? [],
      priceAddOn: addOnPrice,
      price:
          (product.sale_price ?? 0) > 0 ? product.sale_price! : product.price,
      title: product.title,
      subtitle: product.categories?.firstOrNull?.title ?? product.detail,
      image: product.imageUrls?.firstOrNull ?? "",
      meta: ciMeta,
      product: product,
    );
    toReturn.setQuantity(1);
    return toReturn;
  }

  //custom IMPLEMENTATION below.

  void setDeliveryFee(double deliveryFee) {
    if (deliveryFee > 0) {
      int deliveryFeeExtraChargeIndex = _cart.extraCharges
          .indexWhere((element) => element.id == "delivery_fee");
      if (deliveryFeeExtraChargeIndex != -1) {
        _cart.extraCharges[deliveryFeeExtraChargeIndex].price = deliveryFee;
        _cart.extraCharges[deliveryFeeExtraChargeIndex].priceToShow =
            "${AppSettings.currencyIcon} $deliveryFee";
      } else {
        _cart.addExtraCharge(genDeliveryExtraCharge(deliveryFee));
      }
    }
  }

  void removeCoupon() {
    _cart.removeExtraCharge("coupon");
    _saveCart();
  }

  //custom COUPON implementation below

  void applyCoupon(Coupon? coupon) {
    _cart.removeExtraCharge("coupon");
    if (coupon != null) {
      _cart.addExtraCharge(ExtraCharge(
        id: "coupon",
        title: coupon.title,
        price: coupon.reward,
        isPercent: coupon.type == "percent",
        priceToShow: "${coupon.reward}%",
        extraChargeObject: coupon,
      ));
      // this.setupOrderRequestBase();
      // this.orderRequest.coupon_code = coupon.code;
    } else {
      // this.setupOrderRequestBase();
      // this.orderRequest.coupon_code = null;
    }
    _saveCart();
  }
}

//models below

class Cart {
  List<CartItem> cartItems;
  List<ExtraCharge> extraCharges;
  Map<String, String> orderMeta;
  Cart({
    required this.cartItems,
    required this.extraCharges,
    required this.orderMeta,
  });

  Cart copyWith({
    List<CartItem>? cartItems,
    List<ExtraCharge>? extraCharges,
    Map<String, String>? orderMeta,
  }) {
    return Cart(
      cartItems: cartItems ?? this.cartItems,
      extraCharges: extraCharges ?? this.extraCharges,
      orderMeta: orderMeta ?? this.orderMeta,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItems': cartItems.map((x) => x.toMap()).toList(),
      'extraCharges': extraCharges.map((x) => x.toMap()).toList(),
      'orderMeta': orderMeta,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      cartItems: List<CartItem>.from(
          map['cartItems']?.map((x) => CartItem.fromMap(x))),
      extraCharges: List<ExtraCharge>.from(
          map['extraCharges']?.map((x) => ExtraCharge.fromMap(x))),
      orderMeta: Map<String, String>.from(map['orderMeta']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String source) => Cart.fromMap(json.decode(source));

  @override
  String toString() =>
      'Cart(cartItems: $cartItems, extraCharges: $extraCharges, orderMeta: $orderMeta)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cart &&
        listEquals(other.cartItems, cartItems) &&
        listEquals(other.extraCharges, extraCharges) &&
        mapEquals(other.orderMeta, orderMeta);
  }

  @override
  int get hashCode =>
      cartItems.hashCode ^ extraCharges.hashCode ^ orderMeta.hashCode;

  double getTotalCart() {
    double subTotal = getTotalCartItems();

    double taxes_and_charges = 0;
    for (ExtraCharge ec in extraCharges) {
      if (ec.id == "taxes_and_charges") {
        taxes_and_charges =
            ec.isPercent ? ((subTotal * ec.price) / 100) : (ec.price);
        break;
      }
    }

    double delivery_fee = 0;
    for (ExtraCharge ec in extraCharges) {
      if (ec.id == "delivery_fee") {
        delivery_fee = ec.price;
        break;
      }
    }

    double coupon = 0;
    for (ExtraCharge ec in extraCharges) {
      if (ec.id == "coupon") {
        coupon = ec.isPercent ? ((subTotal * ec.price) / 100) : (ec.price);
        break;
      }
    }

    double toReturn = subTotal + taxes_and_charges + delivery_fee - coupon;
    return toReturn;
  }

  double getTotalCartItems() {
    double toReturn = 0;
    for (CartItem ci in cartItems) {
      toReturn += ci.total;
    }
    return toReturn;
  }

  void removeExtraCharge(String extraChargeId) =>
      extraCharges.removeWhere((element) => element.id == extraChargeId);

  void addExtraCharge(ExtraCharge ec) => extraCharges.insert(0, ec);
}

class CartItem {
  String id;
  String title;
  String subtitle;
  String image;
  double price;
  double priceAddOn;
  int quantity;
  double total;
  List<CartItemAddOn> addOns;
  dynamic product;
  dynamic meta; // add new customization "meta"
  CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.price,
    required this.priceAddOn,
    this.quantity = -9999,
    this.total = -9999,
    required this.addOns,
    required this.product,
    required this.meta,
  });

  void setQuantity(int newQuantity) {
    quantity = newQuantity;
    total = (price + priceAddOn) * quantity;
  }

  double getTotal() {
    return total;
  }

  double getTotalBase() {
    double totalBase = price * quantity;
    return totalBase;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'price': price,
      'priceAddOn': priceAddOn,
      'quantity': quantity,
      'total': total,
      'addOns': addOns.map((x) => x.toMap()).toList(),
      'product': product,
      'meta': meta,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      image: map['image'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      priceAddOn: map['priceAddOn']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      total: map['total']?.toDouble() ?? 0.0,
      addOns: List<CartItemAddOn>.from(
          map['addOns']?.map((x) => CartItemAddOn.fromMap(x))),
      product: map['product'],
      meta: map['meta'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItem.fromJson(String source) =>
      CartItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CartItem(id: $id, title: $title, subtitle: $subtitle, image: $image, price: $price, priceAddOn: $priceAddOn, quantity: $quantity, total: $total, addOns: $addOns, product: $product, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItem &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.image == image &&
        other.price == price &&
        other.priceAddOn == priceAddOn &&
        other.quantity == quantity &&
        other.total == total &&
        listEquals(other.addOns, addOns) &&
        other.product == product &&
        other.meta == meta;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        image.hashCode ^
        price.hashCode ^
        priceAddOn.hashCode ^
        quantity.hashCode ^
        total.hashCode ^
        addOns.hashCode ^
        product.hashCode ^
        meta.hashCode;
  }
}

class CartItemAddOn {
  int id;
  String title;
  double price;
  String priceToShow;
  CartItemAddOn({
    required this.id,
    required this.title,
    required this.price,
    required this.priceToShow,
  });

  double getTotalBase(int quantity) {
    double totalBase = price * quantity;
    return totalBase;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'priceToShow': priceToShow,
    };
  }

  factory CartItemAddOn.fromMap(Map<String, dynamic> map) {
    return CartItemAddOn(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      priceToShow: map['priceToShow'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItemAddOn.fromJson(String source) =>
      CartItemAddOn.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CartItemAddOn(id: $id, title: $title, price: $price, priceToShow: $priceToShow)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItemAddOn &&
        other.id == id &&
        other.title == title &&
        other.price == price &&
        other.priceToShow == priceToShow;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ price.hashCode ^ priceToShow.hashCode;
  }
}

class ExtraCharge {
  String id;
  String title;
  double price;
  bool isPercent;
  String priceToShow;
  dynamic extraChargeObject;
  ExtraCharge({
    required this.id,
    required this.title,
    required this.price,
    required this.isPercent,
    required this.priceToShow,
    required this.extraChargeObject,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'isPercent': isPercent,
      'priceToShow': priceToShow,
      'extraChargeObject': extraChargeObject,
    };
  }

  factory ExtraCharge.fromMap(Map<String, dynamic> map) {
    return ExtraCharge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      isPercent: map['isPercent'] ?? false,
      priceToShow: map['priceToShow'] ?? '',
      extraChargeObject: map['extraChargeObject'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExtraCharge.fromJson(String source) =>
      ExtraCharge.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExtraCharge(id: $id, title: $title, price: $price, isPercent: $isPercent, priceToShow: $priceToShow, extraChargeObject: $extraChargeObject)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExtraCharge &&
        other.id == id &&
        other.title == title &&
        other.price == price &&
        other.isPercent == isPercent &&
        other.priceToShow == priceToShow &&
        other.extraChargeObject == extraChargeObject;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        price.hashCode ^
        isPercent.hashCode ^
        priceToShow.hashCode ^
        extraChargeObject.hashCode;
  }
}
