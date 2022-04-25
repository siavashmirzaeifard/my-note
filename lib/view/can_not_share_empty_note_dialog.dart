import 'package:flutter/material.dart';

import '/view/generic_dialog.dart';

Future<void> showCanNotShareEmptyDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: "Share",
    content: "Empty note",
    optionBuilder: () => {
      "OK": false,
    },
  );
}
