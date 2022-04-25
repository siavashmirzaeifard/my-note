import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'view/forgot_password_view.dart';
import 'service/auth/firebase_auth_provider.dart';
import 'service/bloc/auth_bloc.dart';
import 'service/bloc/auth_event.dart';
import 'service/bloc/auth_state.dart';
import 'view/new_note_page.dart';
import 'view/login_page.dart';
import 'view/notes_page.dart';
import 'view/register_page.dart';
import 'view/verify_email_page.dart';
import 'helpers/controller/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        "/new-note": (context) => const NewNotePage(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? "Please wait ...",
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesPage();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailPage();
        } else if (state is AuthStateLoggedOut) {
          return const LoginPage();
        } else if (state is AuthStateRegistering) {
          return const RegisterPage();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordPage();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
      },
    );
  }
}
