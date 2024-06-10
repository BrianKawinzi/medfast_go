import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

class MpesaPayment {
  int businessShortCode;
  String password;
  String timestamp;
  String transactionType;
  double amount;
  int partyA;
  int partyB;
  int phoneNumber;
  String callbackUrl;
  String accountReference;
  String transactionDesc;

  MpesaPayment({
    required this.businessShortCode,
    required this.password,
    required this.timestamp,
    required this.transactionType,
    required this.amount,
    required this.partyA,
    required this.partyB,
    required this.phoneNumber,
    required this.callbackUrl,
    required this.accountReference,
    required this.transactionDesc,
  });

  Map<String, dynamic> toJson() {
    return {
      'BusinessShortCode': businessShortCode,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': transactionType,
      'Amount': amount,
      'PartyA': partyA,
      'PartyB': partyB,
      'PhoneNumber': phoneNumber,
      'CallBackURL': callbackUrl,
      'AccountReference': accountReference,
      'TransactionDesc': transactionDesc,
    };

  }
}
