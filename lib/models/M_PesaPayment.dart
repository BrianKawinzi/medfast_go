import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

class MpesaPayment {
  MpesaPayment() {
    // Initialize the Mpesa plugin with your consumer key and secret
    MpesaFlutterPlugin.setConsumerKey("s2u9AHfIk9WBTuf3vLZFw0nmQp3pdJAnSc8AsGtWEC6ywOny");
    MpesaFlutterPlugin.setConsumerSecret("Z8piKGAEZ27k1lnoisJ4683J6JbXGXerCTxcSkD5wfduc3zxLP35VQtn6TZk2wHA");
  }

  Future<void> lipaNaMpesa({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDescription,
    required String callbackUrl,
    required String businessShortCode,
  }) async {
    try {
      var response = await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: businessShortCode,
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: amount,
        partyA: phoneNumber,
        partyB: businessShortCode,
        callBackURL: Uri.parse(callbackUrl),
        accountReference: accountReference,
        phoneNumber: phoneNumber,
        transactionDesc: transactionDescription,
        baseUri: Uri.parse("https://sandbox.safaricom.co.ke/"),
        passKey: "mAB1M54uGcy136Gti2W9ikHAw0qZ",
      );

      print("Mpesa response: $response");
    } catch (e) {
      print("Mpesa payment failed: $e");
    }
  }
}
