import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notebeans/models/note.dart';
import 'package:notebeans/utils/sql_helper.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object> get props => [];
}

class NoteCreate extends NoteEvent {
  final Note note;
  const NoteCreate({required this.note});
}

class NoteEdit extends NoteEvent {
  final Note note;
  const NoteEdit({required this.note});
}

class NoteDelete extends NoteEvent {
  final int id;
  const NoteDelete({required this.id});
}

class FetchNotes extends NoteEvent {
  const FetchNotes();
}

abstract class NoteState {
  const NoteState();

  List<Object> get props => [];
}

class NoteSaved extends NoteState {
  final int id;
  const NoteSaved({required this.id});
}

class NoteDeleted extends NoteState {
  const NoteDeleted();
}

class NotesFetched extends NoteState {
  final List<Note> notesList;
  const NotesFetched({required this.notesList});
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(const NoteInitial()) {
    on<NoteCreate>((event, emit) async {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDatabase();
      int result = await notesDb.insertNote(event.note);
      await notesDb.closeDatabase();
      emit(NoteSaved(id: result));
    });

    on<NoteEdit>((event, emit) async {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDatabase();
      int result = await notesDb.updateNote(event.note);
      await notesDb.closeDatabase();
      emit(NoteSaved(id: result));
    });

    on<NoteDelete>((event, emit) async {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDatabase();
      await notesDb.deleteNote(event.id);
      await notesDb.closeDatabase();
      emit(const NoteDeleted());
    });

    on<FetchNotes>((event, emit) async {
      NotesDatabase notesDb = NotesDatabase();
      await notesDb.initDatabase();
      List<Map> notesList = await notesDb.getAllNotes();
      await notesDb.closeDatabase();
      List<Map<String, dynamic>> notesData =
          List<Map<String, dynamic>>.from(notesList);
      notesData
          .sort((b, a) => (a['dateLastEdited']).compareTo(b['dateLastEdited']));

      List<Note> noteObjectList = [];

      for (int i = 0; i < notesData.length; i++) {
        noteObjectList.add(Note(
            notesData[i]['id'],
            utf8.decode(notesData[i]['title']),
            notesData[i]['content'],
            DateTime.fromMillisecondsSinceEpoch(
                notesData[i]['dateLastEdited'] * 1000)));
      }
      emit(NotesFetched(notesList: noteObjectList));
    });
  }
}
