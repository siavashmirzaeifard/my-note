import 'package:flutter/material.dart';

import '/view/generic_dialog.dart';

Future<bool> showLogoutDialog({required BuildContext context}) {
  return showGenericDialog(
    context: context,
    title: "Logout",
    content: "Are you sure?",
    optionBuilder: () => {
      "cancel": false,
      "Logout": true,
    },
  ).then((value) => value ?? false);
}
