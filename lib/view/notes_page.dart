import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/extension/buildcontext/loc.dart';

import '/service/bloc/auth_bloc.dart';
import '/service/bloc/auth_event.dart';
import '/service/cloud/cloud_note.dart';
import '/service/cloud/firebase_cloud_storage.dart';
import '/view/notes_list.dart';
import '/service/auth/auth_service.dart';
import 'logout_dialog.dart';

enum MenuAction { logout }

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // late final NoteService _noteService;
  late final FirebaseCloudStorage _noteService;
  // String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // _noteService = NoteService();
    _noteService = FirebaseCloudStorage();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _noteService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _noteService.allNotes(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final noteCount = snapshot.data ?? 0;
              final text = context.loc.notes_title(noteCount);
              return Text(text);
            } else {
              return const Text("");
            }
          },
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context: context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
              }
            },
            itemBuilder: (context) {
              return const [PopupMenuItem(value: MenuAction.logout, child: Text("Logout"))];
            },
          )
        ],
      ),
      body: // FutureBuilder(
          //   future: _noteService.getOrCreateUser(email: userEmail),
          //   builder: (BuildContext context, AsyncSnapshot snapshot) {
          //     switch (snapshot.connectionState) {
          //       case ConnectionState.done:
          //         return StreamBuilder(
          //           stream: _noteService.allNotes,
          //           builder: (BuildContext context, AsyncSnapshot snapshot) {
          //             switch (snapshot.connectionState) {
          //               case ConnectionState.waiting:
          //               case ConnectionState.active:
          //                 if (snapshot.hasData) {
          //                   final allNotes = snapshot.data as List<DatabaseNote>;
          //                   return NotesListView(
          //                     onDeleteNote: (DatabaseNote note) async {
          //                       await _noteService.deleteNote(id: note.id);
          //                     },
          //                     notes: allNotes,
          //                     onNoteTap: (note) {
          //                       Navigator.of(context).pushNamed("/new-note", arguments: note);
          //                     },
          //                   );
          //                 } else {
          //                   return const CircularProgressIndicator();
          //                 }
          //               default:
          //                 return const CircularProgressIndicator();
          //             }
          //           },
          //         );
          //       default:
          //         return const CircularProgressIndicator();
          //     }
          //   },
          // ),
          StreamBuilder(
        // stream: _noteService.allNotes,
        stream: _noteService.allNotes(ownerUserId: userId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                // final allNotes = snapshot.data as List<DatabaseNote>;
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  onDeleteNote: (note) async {
                    // await _noteService.deleteNote(id: note.id);
                    await _noteService.deleteNote(documentId: note.documentId);
                  },
                  notes: allNotes,
                  onNoteTap: (note) {
                    Navigator.of(context).pushNamed("/new-note", arguments: note);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed("/new-note"),
        child: const Icon(Icons.add),
      ),
    );
  }
}
