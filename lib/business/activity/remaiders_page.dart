import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/reminder.dart';
import 'package:medfast_go/utills/dateTime.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Reminder> allReminders = [];

  @override
  void initState() {
    super.initState();
    _fetchReminder();
  }

  Future<void> _fetchReminder() async {
    final dbHelper = DatabaseHelper();
    final fetchedReminders = await dbHelper.getReminders();
    setState(() {
      allReminders = fetchedReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchReminder();
    List<Reminder> currentReminders = [];
    List<Reminder> completedReminders = [];

    DateTime now = DateTime.now();

    // Filter reminders based on their dates
    for (var reminder in allReminders) {
      DateTime parsedDate =
          ConvertTime().convertDateMonthYearToDateTime(reminder.date);
      if (parsedDate.isBefore(now)) {
        completedReminders.add(reminder);
      } else {
        currentReminders.add(reminder);
      }
    }
    return allReminders.isEmpty
        ? const Align(
            alignment: Alignment.center,
            child: Text(
              "You haven't set a reminder yet. Please use the button below to create one.",
              textAlign: TextAlign.center,
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentReminders.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Reminders',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: currentReminders.length,
                              itemBuilder: (_, index) {
                                Reminder reminder = currentReminders[index];
                                return ReminderCard(
                                  reminder: reminder,
                                  remove: () {
                                    setState(() {
                                      currentReminders.removeAt(index);
                                    });
                                  },
                                );
                              }),
                          const SizedBox(height: 15),
                        ],
                      )
                    : const SizedBox(),
                completedReminders.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Completed Reminders',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: completedReminders.length,
                              itemBuilder: (_, index) {
                                Reminder reminder = completedReminders[index];
                                return ReminderCard(
                                  reminder: reminder,
                                  remove: () {
                                    setState(() {
                                      completedReminders.removeAt(index);
                                    });
                                  },
                                );
                              }),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          );
  }
}

class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  final Function remove;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.remove,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReminderCardState createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  bool _isCompleted = false;

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
  }

  void _deleteReminder(Reminder reminder) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteReminder(reminder.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggleCompletion,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.reminder.tittle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        widget.remove();
                        _deleteReminder(widget.reminder);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                ],
              ),
              Text(
                widget.reminder.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      thickness: 3,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.reminder.date,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      thickness: 3,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.reminder.time,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(_isCompleted ? Icons.check_circle : Icons.circle),
                    color: _isCompleted ? Colors.green : Colors.grey,
                    onPressed: _toggleCompletion,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
