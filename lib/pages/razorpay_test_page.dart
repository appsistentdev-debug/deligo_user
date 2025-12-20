// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// import '../../network/razorpay_api.dart';
// import '../../utility/razorpay_util.dart';

// class RazorpayTestPage extends StatefulWidget {
//   const RazorpayTestPage({Key? key}) : super(key: key);

//   @override
//   State<RazorpayTestPage> createState() => _RazorpayTestPageState();
// }

// class _RazorpayTestPageState extends State<RazorpayTestPage> {
//   final RazorpayApi razorpayApi = RazorpayApi();
//   late RazorpayUtil razorpayUtil;

//   // 🔹 TEST VALUES
//   final int amount = 10; // ₹10 for testing
//   final String martGoOrderId = "TEST_ORDER_001";
//   final String userToken = "PUT_USER_TOKEN_HERE";

//   @override
//   void initState() {
//     super.initState();

//     razorpayUtil = RazorpayUtil();

//     razorpayUtil.razorpay.on(
//       Razorpay.EVENT_PAYMENT_SUCCESS,
//       _onPaymentSuccess,
//     );

//     razorpayUtil.razorpay.on(
//       Razorpay.EVENT_PAYMENT_ERROR,
//       _onPaymentError,
//     );
//   }

//   Future<void> startPayment() async {
//     try {
//       // 1️⃣ Create order from Laravel
//       final data = await razorpayApi.createOrder(
//         amount: amount,
//         orderId: martGoOrderId,
//         token: userToken,
//       );

//       // 2️⃣ Open Razorpay
//       razorpayUtil.razorpay.open({
//         'key': data['key'],
//         'order_id': data['order_id'],
//         'amount': data['amount'],
//         'currency': 'INR',
//         'name': 'MartGo Test',
//         'description': 'Razorpay Test Payment',
//         'prefill': {
//           'contact': '9999999999',
//           'email': 'test@martgo.in',
//         },
//       });
//     } catch (e) {
//       _showMessage("Error starting payment: $e");
//     }
//   }

//   void _onPaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       await razorpayApi.verifyPayment(
//         razorpayOrderId: response.orderId!,
//         paymentId: response.paymentId!,
//         signature: response.signature!,
//         token: userToken,
//       );

//       _showMessage(" Payment Success & Verified");
//     } catch (e) {
//       _showMessage(" Verification Failed");
//     }
//   }

//   void _onPaymentError(PaymentFailureResponse response) {
//     _showMessage(" Payment Failed");
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }

//   @override
//   void dispose() {
//     razorpayUtil.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Razorpay Test")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: startPayment,
//           child: const Text("Pay ₹10 (Test)"),
//         ),
//       ),
//     );
//   }
// }
