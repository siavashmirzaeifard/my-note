import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize implements AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn implements AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventRegister implements AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventForgotPassword implements AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventShouldRegister implements AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventSendEmailVerification implements AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogOut implements AuthEvent {
  const AuthEventLogOut();
}
