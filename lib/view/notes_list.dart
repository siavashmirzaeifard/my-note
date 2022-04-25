import 'package:flutter/material.dart';

import '/service/cloud/cloud_note.dart';
import 'delete_dialog.dart';

// typedef NoteCallback = void Function(DatabaseNote note);
typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final NoteCallback onDeleteNote;
  final NoteCallback onNoteTap;
  // final List<DatabaseNote> notes;
  final Iterable<CloudNote> notes;

  const NotesListView({
    Key? key,
    required this.onDeleteNote,
    required this.notes,
    required this.onNoteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            // onNoteTap(notes[index]);
            onNoteTap(notes.elementAt(index));
          },
          title: Text(
            // notes[index].text,
            notes.elementAt(index).text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDeleteNote = await showDeleteDialog(context: context);
              if (shouldDeleteNote) {
                // onDeleteNote(notes[index]);
                onDeleteNote(notes.elementAt(index));
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
