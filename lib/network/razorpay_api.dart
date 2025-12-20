import 'dart:convert';
import 'package:http/http.dart' as http;

class RazorpayApi {
static const String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, dynamic>> createOrder({
    required int amount,
    required String orderId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/razorpay/create-order"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "order_id": orderId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Razorpay order creation failed");
    }

    return jsonDecode(response.body);
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String paymentId,
    required String signature,
    required String token,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/razorpay/verify-payment"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": paymentId,
        "razorpay_signature": signature,
      }),
    );
  }
}
