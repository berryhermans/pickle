import 'package:flutter/material.dart';

import 'app/app_config.dart';
import 'app/pickle_app.dart';

void main() {
  AppConfig.current.validate();
  runApp(const PickleApp());
}
