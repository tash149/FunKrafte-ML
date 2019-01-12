import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  static final UserData _singleton = new UserData._internal();

  FirebaseUser user;
  bool isAdmin = false;
  String emotion;

  factory UserData() {
    return _singleton;
  }

  UserData._internal();
}

class AppData {
  static final AppData _singleton = new AppData._internal();

  List<CameraDescription> cameras;
  double scaleFactorW = 0;
  double scaleFactorH = 0;
  double scaleFactorA = 0;

  factory AppData() {
    return _singleton;
  }
  AppData._internal();
}
