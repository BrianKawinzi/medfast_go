import 'package:flutter/material.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/note.dart';
import 'package:medfast_go/utills/dateTime.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];

  @override
  void initState() {
    _fetchNote();
    super.initState();
  }

  Future<void> _fetchNote() async {
    final dbHelper = DatabaseHelper();
    final fetchedReminders = await dbHelper.getNotes();
    setState(() {
      notes = fetchedReminders;
    });
  }

  void _deleteNote(Note note) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteNote(note.id!);
  }

  @override
  Widget build(BuildContext context) {
    _fetchNote();
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(notes[index].toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteNote(notes[index]);
            setState(() {
              notes.removeAt(index);
            });
            // ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text("Item ${index + 1} deleted")));
          },
          child: Card(
            child: ListTile(
              title: Text(
                notes[index].tittle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notes[index].description,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${notes[index].time} , ${ConvertTime().convertFromIso8601String(notes[index].date)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              // trailing: IconButton(
              //   icon: const Icon(Icons.edit),
              //   onPressed: () {
              //     // Add edit functionality here
              //     ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text("Edit item ${index + 1}")));
              //   },
              // ),
            ),
          ),
        );
      },
    );
  }
}
