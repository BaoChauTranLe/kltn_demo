import 'package:flutter/material.dart';
import 'package:kltn/screen/camera_screen.dart';
import 'package:kltn/screen/confirm_image.dart';
import 'package:kltn/screen/home.dart';

class Routes {
  Routes._();

  //static variables
  static const String home = '/home';
  static const String cameraScreen = '/camera_screen';
  static const String confirmImage = '/confirm_image_screen';

  static final routes = <String, WidgetBuilder>{
    home: (BuildContext context) => HomeScreen(),
    cameraScreen: (BuildContext context) => CameraScreen(),
    confirmImage: (BuildContext context) => ConfirmImageScreen(),
  };
}
