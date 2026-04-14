import 'package:flutter_bloc/flutter_bloc.dart';


abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountProgress extends DeleteAccountState {}

class DeleteAccountFailure extends DeleteAccountState {
  DeleteAccountFailure(this.errorMessage);
  final String errorMessage;
}

class AccountDeleted extends DeleteAccountState {
  AccountDeleted({required this.successMessage});
  final String successMessage;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial());

  Future<void> deleteUserAccount() async {
    emit(DeleteAccountProgress());
    // Stub
    emit(AccountDeleted(successMessage: 'Account deleted successfully'));
  }
}
