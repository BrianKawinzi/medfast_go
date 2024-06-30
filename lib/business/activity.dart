import 'package:flutter/material.dart';
import 'package:medfast_go/business/activity/add_note_page.dart';
import 'package:medfast_go/business/activity/add_reminder.dart';
import 'package:medfast_go/business/activity/notes_page.dart';
import 'package:medfast_go/business/activity/remaiders_page.dart';

import '../data/DatabaseHelper.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  bool showAllNotes = true;
  @override
  void initState() {
    DatabaseHelper().initializeDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => showAllNotes
                    ? const AddNotePage(
                        isEdit: false,
                      )
                    : const AddReminder(
                        isEdit: false,
                      ),
              ),
            );
          },
          backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showAllNotes = true;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'All Notes',
                            style: TextStyle(
                              fontWeight: showAllNotes
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: showAllNotes
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                          Container(
                            width: 24.0, // Adjust as needed
                            height: 2.0,
                            color: showAllNotes
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showAllNotes = false;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Reminders',
                            style: TextStyle(
                              fontWeight: !showAllNotes
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: !showAllNotes
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                          Container(
                            width: 80.0, // Adjust as needed
                            height: 2.0,
                            color: !showAllNotes
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              showAllNotes ? const NotesPage() : const RemindersPage(),
            ],
          ),
        ),
      );
}
