import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:mpesa_flutter_plugin/payment_enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Mpesa plugin with your consumer key and secret
  await MpesaFlutterPlugin.setConsumerKey("s2u9AHfIk9WBTuf3vLZFw0nmQp3pdJAnSc8AsGtWEC6ywOny");
  await MpesaFlutterPlugin.setConsumerSecret("Z8piKGAEZ27k1lnoisJ4683J6JbXGXerCTxcSkD5wfduc3zxLP35VQtn6TZk2wHA");

  runApp(MaterialApp(
    home: MobilePayment(),
  ));
}


class PaymentCredentialsForm extends StatefulWidget {
  @override
  _PaymentCredentialsFormState createState() => _PaymentCredentialsFormState();
}

class _PaymentCredentialsFormState extends State<PaymentCredentialsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tillNumberController = TextEditingController();
  final TextEditingController _storeNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tillNumberController.text = prefs.getString('tillNumber') ?? '';
    _storeNumberController.text = prefs.getString('storeNumber') ?? '';
  }

  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tillNumber', _tillNumberController.text);
    await prefs.setString('storeNumber', _storeNumberController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credentials saved')));
    Navigator.pop(context); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Payment Credentials'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _tillNumberController,
                decoration: const InputDecoration(labelText: 'Till Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Till Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeNumberController,
                decoration: const InputDecoration(labelText: 'Store Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Store Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveCredentials();
                  }
                },
                child: const Text('Save Credentials'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobilePayment extends StatefulWidget {
  @override
  _MobilePaymentState createState() => _MobilePaymentState();
}

class _MobilePaymentState extends State<MobilePayment> {
  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile Payment"),
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentCredentialsForm()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              width: 600,
              height: 550, // Increased height to accommodate new field
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                image: DecorationImage(
                  image: const AssetImage("lib/assets/PaymentIcon.png"),
                  fit: BoxFit.cover, // This is to ensure the image covers the whole container
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), // 20% opacity
                    BlendMode.dstATop, // This blend mode allows the image to show through the color filter
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "M-Pesa Payment",
                      style: TextStyle(
                        color: Color.fromARGB(58, 205, 50, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        child: TextFormField(
                          controller: totalPriceController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          decoration: InputDecoration(
                            hintText: "Total Price",
                            fillColor: Colors.green,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Text(
                        "Phone No:",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: customerPhoneController,
                          decoration: InputDecoration(
                            hintText: "Enter Phone Number",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 10),
                  const Spacer(),
                  const SizedBox(height: 10),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String tillNumber = prefs.getString('tillNumber') ?? '';
                        String storeNumber = prefs.getString('storeNumber') ?? '';
                        String phoneNumber = customerPhoneController.text;
                        double amount = double.tryParse(totalPriceController.text) ?? 0.0;

                        if (phoneNumber.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid details')));
                          return;
                        }

                        // Debug information
                        print("Till Number: $tillNumber");
                        print("Store Number: $storeNumber");
                        print("Phone Number: $phoneNumber");
                        print("Amount: $amount");

                        try {
                          var response = await MpesaFlutterPlugin.initializeMpesaSTKPush(
                        businessShortCode: "600584", // Default sandbox short code
                        transactionType: TransactionType.CustomerPayBillOnline,
                        amount: amount,
                        partyA: phoneNumber,
                        partyB: tillNumber, // Default sandbox short code
                        callBackURL: Uri.parse("https://mydomain.com/path"),
                        accountReference: "medfast_go",
                        phoneNumber: "600000",
                        transactionDesc: "Payment Description",
                        baseUri: Uri.parse("https://sandbox.safaricom.co.ke"),
                        passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919", // Default sandbox passkey
                      );

                          print("Response: $response");

                          if (response['ResponseCode'] == '0') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentConfirmationScreen(
                                  items: ["Item 1", "Item 2"], // Replace with your actual items
                                  amountPaid: amount,
                                  balance: 0.0,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed')));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text("Submit Payment"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentConfirmationScreen extends StatelessWidget {
  final List<String> items;
  final double amountPaid;
  final double balance;

  PaymentConfirmationScreen({
    required this.items,
    required this.amountPaid,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            for (var item in items) Text(item),
            const SizedBox(height: 20),
            Text('Amount Paid: \$${amountPaid.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Text('Balance: \$${balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
