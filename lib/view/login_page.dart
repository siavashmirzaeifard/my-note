import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/extension/buildcontext/loc.dart';
import '/service/bloc/auth_bloc.dart';
import '/service/bloc/auth_event.dart';
import '/service/auth/auth_exception.dart';
import '/service/bloc/auth_state.dart';
import 'error_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          // final closeDialog = _closeDialogHandle;
          // if (!state.isLoading && closeDialog != null) {
          //   closeDialog();
          //   _closeDialogHandle = null;
          // } else if (state.isLoading && closeDialog == null) {
          //   _closeDialogHandle = showLoadingDialog(
          //     context: context,
          //     text: "Loading...",
          //   );
          // }

          if (state.exception is FirebaseAuthException) {
            await showErrorDialog(context: context, text: state.exception.toString());
          } else if (state.exception is GenericException) {
            await showErrorDialog(context: context, text: state.exception.toString());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.app_title),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _email,
                obscureText: false,
                autocorrect: false,
                autofocus: true,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: "email"),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(hintText: "password"),
              ),
              TextButton(
                onPressed: () {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(AuthEventLogIn(
                        email,
                        password,
                      ));
                },
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text("Register"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventForgotPassword());
                },
                child: const Text("Forget password?"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
