import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  StreamSubscription? _connectivitySubscription;
  bool isConnected = false;

  ConnectivityCubit() : super(ConnectivityState(false));

  void monitorInternet() => _connectivitySubscription ??=
          Connectivity().onConnectivityChanged.listen((connectivityResult) {
        isConnected = !(connectivityResult.contains(ConnectivityResult.none));
        emit(ConnectivityState(isConnected));
      });

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
