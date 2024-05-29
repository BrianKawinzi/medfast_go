import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medfast_go/models/M_PesaPayment.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Credentials saved')));
    Navigator.pop(context); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Payment Credentials'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _tillNumberController,
                decoration: InputDecoration(labelText: 'Till Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Till Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeNumberController,
                decoration: InputDecoration(labelText: 'Store Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Store Number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveCredentials();
                  }
                },
                child: Text('Save Credentials'),
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
  double cashPaid = 0.0;
  double totalPrice = 0.0; // You should set this based on your total price logic

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
            icon: const Icon(Icons.edit),
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
              margin: const EdgeInsets.only(top: 0.0 * 38.1, bottom: 0.0 * 38.1),
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
                    mainAxisAlignment: MainAxisAlignment.center, // Center the row contents
                    children: [
                      Container(
                        width: 200, // Adjust this width as needed
                        child: TextFormField(
                          controller: TextEditingController(
                              text: "Ksh. ${totalPrice.toString()}"), // Display "Ksh." followed by total price
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32, // Make text bold
                          ), // Center align the text
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: "Total Price",
                            fillColor: Colors.green,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          readOnly: true, // Make the field read-only since it's for display purposes
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Space between fields
                  Row(
                    children: [
                      const Text(
                        "M-Pesa Code:",
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
                            hintText: "",
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
                  const SizedBox(height: 10), // Space for clarity
                  PaymentInfoDisplay(
                      customerName: "",
                      amountPaid: "Ksh. "), // After payment
                  const Spacer(),
                  const SizedBox(height: 10), // Space for clarity
                  // Cash Paid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Cash Paid: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Make label text bold
                          fontSize: 16, // You can adjust the font size as needed
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2, // Increase the thickness of the line
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "$cashPaid",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, // Make value text bold
                                fontSize: 16, // You can adjust the font size as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Adjust the height for spacing
                  // Balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Balance: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Make label text bold
                          fontSize: 16, // You can adjust the font size as needed
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2, // Increase the thickness of the line
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${cashPaid - totalPrice}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, // Make value text bold
                                fontSize: 16, // You can adjust the font size as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Spacer(),
                  // Complete and Send Receipt Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        String phoneNumber = customerPhoneController.text;
                        if (phoneNumber.isEmpty) {
                          // Show some error message
                          return;
                        }
                        MpesaPayment mpesaPayment = MpesaPayment();
                        await mpesaPayment.lipaNaMpesa(
                          phoneNumber: phoneNumber,
                          amount: totalPrice,
                          accountReference: "Account Reference",
                          transactionDescription: "Payment Description",
                          callbackUrl: "https://yourcallbackurl.com/callback", businessShortCode: '',
                        );
                      },
                      child: const Text("Complete and Send Receipt"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0), // 2 cm space (assuming 1 cm = 10 pixels)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentInfoDisplay extends StatelessWidget {
  final String customerName; // Placeholder for customer name
  final String amountPaid; // Placeholder for amount paid

  PaymentInfoDisplay({this.customerName = "-", this.amountPaid = "-"});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Different width and height for an oval
      height: 120,
      alignment: Alignment.center, // Center the text inside the container
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(60)), // Rounded corners
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        " $customerName, \n\n  $amountPaid",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
