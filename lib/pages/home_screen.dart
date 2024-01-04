import 'package:flutter/material.dart';
import 'package:medfast_go/pages/widgets/navigation_drawer.dart';
import 'package:medfast_go/bargraph/individual_bar.dart';
import 'package:medfast_go/pages/widgets/progress_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //calculate revenue method
  Future<double> calculateTotalRevenue() async {
    double totalRevenue = 0;

    List<double> monthlyAmounts = [
      10000,
      20000,
      15000,
      25000,
      18000,
      22000,
      30500,
      28000,
      35000,
      32000,
      28000,
      40000
    ];

    for (double amount in monthlyAmounts) {
      totalRevenue += amount;
    }

    return totalRevenue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 253, 44),
        elevation: 10.0,
        title: Row(
          children: [


            //chemist name this is an example later on it will be connected so as to change with the specific chemist
            Padding(
              padding: const EdgeInsets.only(right: 13),
              child: Text(
                'Tala Chemist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          //Notification button
          IconButton(
            onPressed: () {
              //Handle notification logic here
            },
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),

          //help button
          IconButton(
            onPressed: () {
              //handle help logic here
            },
            icon: Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: const NavigationDrawerWidget(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //sales tile
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      Text(
                        'Sales Infromation',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      //Progress indicators
                      buildHorizontalProgressIndicators(
                        'Daily Sales',
                        70,
                        Colors.purple,
                        'Monthly Sales',
                        59,
                        Colors.orange,
                      ),

                      buildHorizontalProgressIndicators(
                        'Annual Sales',
                        43,
                        Colors.yellow,
                        'Target Sales',
                        87,
                        Colors.orange,
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //revenue card
              Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total \n Revenue',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),

                          //Calculation of monthly ammounts
                          FutureBuilder<double>(
                              future: calculateTotalRevenue(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    'KSH \n ${snapshot.data!.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              }),

                          DropdownButton<String>(
                            items: <String>[
                              '2022',
                              '2023',
                              '2024',
                              '2025',
                              '2026',
                              '2027'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              //Handle dropdown value change logic
                            },
                            value: '2022',
                          ),
                        ],
                      ),

                      //Bar chart
                      Container(
                        height: 200,
                        child: IndividualBar(
                          x: 1,
                          monthlyAmounts: [
                            10000,
                            20000,
                            15000,
                            25000,
                            18000,
                            22000,
                            30500,
                            28000,
                            35000,
                            32000,
                            28000,
                            40000
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
