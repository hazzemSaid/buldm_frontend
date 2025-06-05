// lib/cubit/localization_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit() : super(const Locale('en'));

  void switchLanguage() {
    if (state.languageCode == 'en') {
      emit(const Locale('ar', 'EG'));
    } else {
      emit(const Locale('en', 'US'));
    }
  }

  void setLocale(Locale locale) => emit(locale);
}
