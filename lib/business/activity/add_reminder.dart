import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/reminder.dart';
import 'package:medfast_go/pages/widgets/button.dart';
import 'package:medfast_go/utills/dateTime.dart';

class AddReminder extends StatefulWidget {
  final Reminder? reminder;
  final bool isEdit;
  const AddReminder({
    super.key,
    this.reminder,
    required this.isEdit,
  });

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final TextEditingController _reminderTittleController =
      TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _reminderDescriptionController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  // Controller for the date text field
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    widget.isEdit ? initEditReminder() : null;
    super.initState();
  }

  initEditReminder() {
    _reminderDescriptionController.text = widget.reminder!.description;
    _reminderTittleController.text = widget.reminder!.tittle;
    _dateController.text = widget.reminder!.date;
    _timeController.text = widget.reminder!.time;
  }

  Future<void> _addReminder() async {
    final dbHelper = DatabaseHelper();
    Reminder reminder = Reminder(
      tittle: _reminderTittleController.text,
      description: _reminderDescriptionController.text,
      date: _dateController.text,
      time: _timeController.text,
    );
    await dbHelper.insertReminder(reminder);
    Navigator.pop(context);
    _reminderTittleController.clear();
    _reminderDescriptionController.clear();
    _dateController.clear();
    _timeController.clear();
  }

  Future<void> _updateReminder() async {
    final dbHelper = DatabaseHelper();
    Reminder reminder = Reminder(
      id: widget.reminder!.id,
      tittle: _reminderTittleController.text,
      description: _reminderDescriptionController.text,
      date: _dateController.text,
      time: _timeController.text,
    );
    await dbHelper.updateReminder(reminder);
    Navigator.pop(context);
    _reminderTittleController.clear();
    _reminderDescriptionController.clear();
    _dateController.clear();
    _timeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FormField(
                  labelText: 'Enter reminder tittle',
                  hintText: '',
                  field: 'Tittle',
                  controller: _reminderTittleController,
                  icon: const Icon(Icons.abc),
                ),
                const SizedBox(height: 10),
                FormField(
                  labelText: 'Enter reminder description',
                  hintText: '',
                  field: 'Description',
                  controller: _reminderDescriptionController,
                  icon: const Icon(Icons.abc),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date'),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Enter reminder date',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter reminder date';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          // initialDate: DateTime.parse(_dateController.text),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateController.text = ConvertTime()
                                .convertDateTimeToDateMonthYear(pickedDate);
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Time'),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Enter reminder time',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter reminder time';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickeTime = await showTimePicker(
                          context: context,
                          // initialDate: DateTime.parse(_dateController.text),
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickeTime != null) {
                          setState(() {
                            _timeController.text =
                                ConvertTime().convertTimeOfDayToAmPm(pickeTime);
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                !widget.isEdit
                    ? CustomButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _addReminder();
                          }
                        },
                        text: 'ADD REMINDER',
                      )
                    : CustomButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _updateReminder();
                          }
                        },
                        text: 'EDIT REMINDER',
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String field;
  final Icon icon;
  final TextEditingController controller;
  const FormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.field,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.grey),
            hintText: hintText,
            // prefixIcon: icon,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter reminder $field';
            }
            return null;
          },
          onSaved: (value) {},
        ),
      ],
    );
  }
}
