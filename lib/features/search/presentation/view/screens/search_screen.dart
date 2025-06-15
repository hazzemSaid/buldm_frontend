import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: IconButton(
              onPressed: () {
                BlocProvider.of<LocalizationCubit>(context).switchLanguage();
              },
              icon: Icon(Icons.language))),
    );
  }
}
