import 'package:flutter/material.dart';
import 'package:medfast_go/pages/home_page.dart';

class Support extends StatefulWidget {
  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final _formKey = GlobalKey<FormState>();
  bool showSendButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor:
          Colors.green, // Set the background color of the entire screen

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pharmacy ID Box
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .white, // Set the background color of the text field
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your pharmacy ID';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Pharmacy ID',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                  onTap: () {
                    setState(() {
                      showSendButton = true;
                    });
                  },
                ),
              ),
              SizedBox(height: 16.0), // Spacer

              // Email Box
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .white, // Set the background color of the text field
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                  onTap: () {
                    setState(() {
                      showSendButton = true;
                    });
                  },
                ),
              ),
              SizedBox(height: 16.0), // Spacer

              // Subject Box
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .white, // Set the background color of the text field
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the subject';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Subject',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                  onTap: () {
                    setState(() {
                      showSendButton = true;
                    });
                  },
                ),
              ),
              SizedBox(height: 16.0), // Spacer

              // Large Message Box
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .white, // Set the background color of the text field
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Type message here',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                    onTap: () {
                      setState(() {
                        showSendButton = true;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: showSendButton,
        child: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // If the form is valid, handle the send button click
              // You can implement your send logic here
              print('Send button clicked!');
            }
          },
          child: Icon(Icons.send,
              color: Colors.green), // Change the color of the Send icon
          backgroundColor:
              Colors.white, // Set the background color of the Send button
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
