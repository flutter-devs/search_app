import 'dart:async';

import 'package:search_app/bloc/bloc.dart';
import 'package:search_app/models/userModel.dart';

class UserBloc extends Bloc {
  final userController = StreamController<List<UserModel>>.broadcast();

  @override
  void dispose() {
    userController.close();
  }
}

UserBloc userBloc = UserBloc();
