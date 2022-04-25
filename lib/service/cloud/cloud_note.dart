import 'package:flutter/cupertino.dart' show immutable;

import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote(
    this.documentId,
    this.ownerUserId,
    this.text,
  );

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()["user_id"],
        text = snapshot.data()["text"];
}
