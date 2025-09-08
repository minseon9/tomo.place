import 'package:equatable/equatable.dart';

import '../../../../shared/exception_handler/models/exception_interface.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  final bool isNavigateHome;

  const AuthSuccess(this.isNavigateHome);

  @override
  List<Object?> get props => [isNavigateHome];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.error});

  final ExceptionInterface error;

  @override
  List<Object?> get props => [error];
}
