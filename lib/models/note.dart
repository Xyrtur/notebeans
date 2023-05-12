import 'dart:convert';

class Note {
  int? id;
  String title;
  String content;
  DateTime dateLastEdited;

  Note(this.id, this.title, this.content, this.dateLastEdited);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      // dont need to send id as it autoincrements if added
      'title': utf8.encode(title),
      'content': content,
      'dateLastEdited': epochFromDate(dateLastEdited),
    };
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  // Converting the date time object into int representing seconds passed after midnight 1st Jan, 1970 UTC
  int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  toString() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date_last_edited': epochFromDate(dateLastEdited),
    }.toString();
  }
}
