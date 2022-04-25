import 'package:flutter/material.dart';

import '/view/generic_dialog.dart';

Future<bool> showDeleteDialog({required BuildContext context}) {
  return showGenericDialog(
      context: context,
      title: "Delete",
      content: "Are you sure?",
      optionBuilder: () => {"Yes": true, "No": false}).then(
    (value) => value ?? false,
  );
}
