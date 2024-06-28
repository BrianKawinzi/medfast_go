import 'package:flutter/material.dart';
import 'package:medfast_go/pages/bottom_navigation.dart';

class FAQ extends StatelessWidget {
  const FAQ({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const BottomNavigation(),
              ),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: const [
          // Add your list of FAQ items here
          FAQItem(
            question:
                'Is there a way to track completed orders and top sold products in Medfast_Go?',
            answer:
                'Yes, Medfast_Go offers features to track completed orders and identify top-selling products. You can monitor completed orders, analyze sales trends, and identify top-selling products based on various metrics such as sales volume, revenue generated, and customer preferences directly from the apps home screen',
          ),
          FAQItem(
            question:
                'Can I add customers to Medfast_Go and track their purchases?',
            answer:
                'Yes, you can add customers to Medfast_Go and track their purchases for personalized service and marketing purposes. The app allows you to create customer profiles, record their purchase history, and analyze their buying patterns to better serve their needs.',
          ),
          FAQItem(
            question:
                'How can I view my expenses and profit made in Medfast_Go?',
            answer:
                'Medfast_Go provides detailed insights into your pharmacys financial performance, including expenses and profits. You can view your expenses, sales revenue, and profit margins from the Home page of the app',
          ),
          FAQItem(
            question:
                'How can I download stock and sale reports in Medfast_Go?',
            answer:
                'Medfast_Go enables you to generate and download comprehensive stock and sale reports for your pharmacy. Simply navigate to the "Reports" section of the app, select the desired report type (e.g., stock report, sales report), specify the date range if needed, and download the report for your records.',
          ),
          FAQItem(
            question: 'Can I view my sale history in Medfast_Go?',
            answer:
                'Yes, Medfast_Go allows you to view your complete sale history, including details such as products sold, quantities, prices, and transaction dates. You can access your sale history from the "Sales History" section of the app and analyze your sales performance over time.',
          ),
          FAQItem(
            question: 'How do I sell products through Medfast_Go?',
            answer:
                'To sell products through Medfast_Go, navigate to the "Point of Sale" (POS) section of the app and select the products you wish to sell from your inventory. Enter the quantity sold and complete the transaction. The app will automatically update your inventory and sales history.',
          ),
          FAQItem(
            question:
                'Is there a way to track the quantity of products remaining in Medfast_Go?',
            answer:
                'Yes, Medfast_Go provides real-time tracking of the quantity of products remaining in your inventory. You can view the current stock levels for each product in the "Inventory" section of the app and take appropriate inventory management actions based on the available quantities.',
          ),
          FAQItem(
            question:
                'Can I receive notifications for drugs nearing expiry date or already expired in Medfast_Go?',
            answer:
                'Yes, Medfast_Go provides notifications for drugs nearing their expiry date and for drugs that have already expired. You will receive timely alerts to help you manage your inventory effectively and prevent any losses due to expired medications.',
          ),
          FAQItem(
            question:
                'How do I add products to my pharmacy inventory in Medfast_Go?',
            answer:
                'To add products to your pharmacy inventory, simply navigate to the "Products" section in the app and select the option to add a new product. Enter the relevant details such as product name, quantity, expiry date, etc., and submit the information to update your inventory.',
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    required this.question,
    required this.answer,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
