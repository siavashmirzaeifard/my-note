import 'package:flutter/material.dart';

import '/view/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: "Password Reset",
    content: "Password Reset Sent",
    optionBuilder: () => {"ok": null},
  );
}
