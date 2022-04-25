import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '/service/bloc/auth_event.dart';
import '/service/bloc/auth_bloc.dart';
import '/service/bloc/auth_state.dart';
import '/view/error_dialog.dart';
import '/view/password_reset_sent_dialog.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(context: context, text: state.exception.toString());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forgot Password"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthEventForgotPassword(email: _controller.text));
                },
                child: const Text("Reset"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
