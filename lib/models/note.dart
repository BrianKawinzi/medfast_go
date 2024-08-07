class Note {
  int? id;
  String tittle;
  String description;
  String time;
  String date;

  Note({
    this.id,
    required this.tittle,
    required this.description,
    required this.time,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    var map = {
      'tittle': tittle,
      'description': description,
      'time': time,
      'date': date,
    };

    if (id != null) {
      map['id'] = id.toString();
    }

    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      tittle: map['tittle'] as String,
      description: map['description'] as String,
      time: map['time'] as String,
      date: map['date'] as String,
    );
  }
}
