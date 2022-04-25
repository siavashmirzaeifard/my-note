import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '/extension/list/filter.dart';
import '/service/auth/auth_exception.dart';

class NoteService {
  Database? _db;

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }
  factory NoteService() => _shared;

  List<DatabaseNote> _notes = [];

  DatabaseUser? _user;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeFetchingAllNotesException();
        }
      });

  Future<DatabaseUser> getOrCreateUser(
      {required String email, bool setAsCurrentUser = true}) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserNotFoundException {
      final user = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    await getNote(id: note.id);
    final updateCount = await db.update(
      "note",
      {
        "text": text,
        "is_synced_with_cloud": 0,
      },
      where: "id = ?",
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((element) => element.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final notes = await db.query("note");
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final note = await db.query(
      "note",
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (note.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final notes = DatabaseNote.fromRow(note.first);
      _notes.removeWhere((element) => element.id == id);
      _notes.add(notes);
      _notesStreamController.add(_notes);
      return notes;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final numberOfDeletedNotes = await db.delete("note");
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletedNotes;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final deletedCount = await db.delete(
      "note",
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final dbUser = await getUser(email: owner.email);
    if (owner != dbUser) {
      throw UserNotFoundException();
    }
    const text = "";
    final noteId = await db.insert(
      "note",
      {
        "user_id": owner.id,
        "text": text,
        "is_synced_with_cloud": 1,
      },
    );
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final result = await db.query(
      "user",
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw UserNotFoundException();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final result = await db.query(
      "user",
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExistException();
    }
    final userId = await db.insert(
      "user",
      {"email": email.toLowerCase()},
    );
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabase();
    final deletedCount = await db.delete(
      "user",
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db == null;
    }
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, "note.db");
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute('''CREATE TABLE IF NOT EXISTS "user"(
        id INTEGER NOT NULL,
        email TEXT NOT NULL UNIQUE,
        PRIMARY KEY(id AUTOINCREMENT)
      );''');

      await db.execute('''CREATE TABLE IF NOT EXISTS "note"(
        id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        text TEXT,
        is_synced_with_cloud INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES "user" (id),
        PRIMARY KEY(id AUTOINCREMENT)
      );''');
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }
}

class DatabaseAlreadyOpenException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class UnableToGetDocumentDirectoryException implements Exception {}

class CouldNotDeleteUserException implements Exception {}

class CouldNotDeleteNoteException implements Exception {}

class CouldNotUpdateNoteException implements Exception {}

class CouldNotFindNoteException implements Exception {}

class UserAlreadyExistException implements Exception {}

class UserShouldBeSetBeforeFetchingAllNotesException implements Exception {}

class DatabaseUser {
  final int id;
  final String email;

  DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map["id"] as int,
        email = map["email"] as String;

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map["id"] as int,
        userId = map["user_id"] as int,
        text = map["text"] as String,
        isSyncedWithCloud = (map["is_synced_with_cloud"] as int) == 1 ? true : false;

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
