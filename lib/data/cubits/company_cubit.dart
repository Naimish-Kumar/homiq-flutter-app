import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/data/model/company.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyFetchProgress extends CompanyState {}

class CompanyFetchSuccess extends CompanyState {
  CompanyFetchSuccess(this.companyData);
  Company companyData;
}

class CompanyFetchFailure extends CompanyState {
  CompanyFetchFailure(this.error);
  final dynamic error;
}

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit() : super(CompanyInitial());

 
  }
