import 'package:medfast_go/pages/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';

class Support extends StatefulWidget {
  const Support({super.key});

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
        title: const Text('Support'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: NavigationDrawerWidget(),
      ),
      backgroundColor: Colors.green, // Set the background c
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  decoration: const InputDecoration(
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
              const SizedBox(height: 16.0), // Spacer

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
                  decoration: const InputDecoration(
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
              const SizedBox(height: 16.0), // Spacer

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
                    decoration: const InputDecoration(
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
          }, // Change the color of the Send icon
          backgroundColor: Colors.white,
          child: const Icon(Icons.send,
              color:
                  Colors.green), // Set the background color of the Send button
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
