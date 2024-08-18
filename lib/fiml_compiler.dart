//load a file
import 'dart:io';
import 'package:flutter_markup/flutter_markup.dart';


class DartToFIML{
  static String loadFile(String path){
    final file = File(path);
    return file.readAsStringSync();
  }
}