import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/note.dart';
import 'package:medfast_go/pages/widgets/button.dart';
import 'package:medfast_go/utills/dateTime.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;
  final bool isEdit;

  const AddNotePage({
    super.key,
    this.note,
    required this.isEdit,
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _noteTittleController = TextEditingController();

  final TextEditingController _noteDescription = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showButton = false;

  @override
  void initState() {
    _noteDescription.addListener(_checkButtonVisibility);
    _noteTittleController.addListener(_checkButtonVisibility);
    widget.isEdit ? initEdit() : null;
    super.initState();
  }

  void _checkButtonVisibility() {
    setState(() {
      _showButton = _noteDescription.text.isNotEmpty &&
          _noteTittleController.text.isNotEmpty;
    });
  }

  initEdit() {
    _noteTittleController.text = widget.note!.tittle;
    _noteDescription.text = widget.note!.description;
  }

  Future<void> _addNote() async {
    final dbHelper = DatabaseHelper();
    Note note = Note(
      tittle: _noteTittleController.text,
      description: _noteDescription.text,
      date: DateTime.now().toIso8601String(),
      time: ConvertTime().convertTimeOfDayToAmPm(TimeOfDay.now()),
    );
    await dbHelper.insertNote(note);
    Navigator.pop(context);
    _noteDescription.clear();
    _noteTittleController.clear();
  }

  Future<void> _updateNote() async {
    final dbHelper = DatabaseHelper();
    Note note = Note(
      id: widget.note!.id,
      tittle: _noteTittleController.text,
      description: _noteDescription.text,
      date: DateTime.now().toIso8601String(),
      time: ConvertTime().convertTimeOfDayToAmPm(TimeOfDay.now()),
    );
    await dbHelper.updateNote(note);
    Navigator.pop(context);
    _noteDescription.clear();
    _noteTittleController.clear();
  }

  @override
  void dispose() {
    _noteDescription.dispose();
    _noteTittleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 205, 50, 1),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _noteTittleController,
                        decoration: const InputDecoration(
                          hintText: 'Tittle',
                          border: InputBorder.none, // Hide border
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _noteDescription,
                        decoration: const InputDecoration(
                          hintText: 'Note something down',
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _showButton
                ? !widget.isEdit
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        alignment: Alignment.bottomCenter,
                        child: CustomButton(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await _addNote();
                            }
                          },
                          text: 'ADD NOTE',
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        alignment: Alignment.bottomCenter,
                        child: CustomButton(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await _updateNote();
                            }
                          },
                          text: 'EDIT NOTE',
                        ),
                      )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
