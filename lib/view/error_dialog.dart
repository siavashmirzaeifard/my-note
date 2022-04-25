import 'package:flutter/material.dart';

import '/view/generic_dialog.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String text,
}) {
  return showGenericDialog<void>(
    context: context,
    title: "Error",
    content: text,
    optionBuilder: () => {
      "Ok": null,
    },
  );
}
