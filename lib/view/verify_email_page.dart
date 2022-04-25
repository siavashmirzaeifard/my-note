import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '/service/bloc/auth_bloc.dart';
import '/service/bloc/auth_event.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
            },
            child: const Text("Verify"),
          ),
          TextButton(
            onPressed: () async {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }
}
