import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import '/service/auth/auth_service.dart';
import '/service/cloud/cloud_note.dart';
import '/service/cloud/firebase_cloud_storage.dart';
import '/view/can_not_share_empty_note_dialog.dart';
import '/view/get_argument.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({Key? key}) : super(key: key);

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  // DatabaseNote? _note;
  // late final NoteService _noteService;
  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textController;

  // Future<DatabaseNote> createNewNote(BuildContext context) async {
  Future<CloudNote> createNewNote(BuildContext context) async {
    // final widgetNote = context.getArguments<DatabaseNote>();
    final widgetNote = context.getArguments<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // final email = AuthService.firebase().currentUser!.email;
    final userId = AuthService.firebase().currentUser!.id;
    // final owner = await _noteService.getUser(email: email);
    // final newNote = await _noteService.createNote(owner: owner);
    final newNote = await _noteService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextFieldIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      // _noteService.deleteNote(id: note.id);
      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextFieldIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      // _noteService.updateNote(note: note, text: text);
      _noteService.updateNote(documentId: note.documentId, text: text);
    }
  }

  void _textEditingControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    // await _noteService.updateNote(note: note, text: text);
    await _noteService.updateNote(
      text: text,
      documentId: note.documentId,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textEditingControllerListener);
    _textController.addListener(_textEditingControllerListener);
  }

  @override
  void initState() {
    // _noteService = NoteService();
    _noteService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextFieldIsEmpty();
    _saveNoteIfTextFieldIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
            onPressed: () {
              if (_note == null || _textController.text.isEmpty) {
                showCanNotShareEmptyDialog(context);
              } else {
                Share.share(_textController.text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createNewNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
