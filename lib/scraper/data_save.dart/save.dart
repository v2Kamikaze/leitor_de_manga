import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Save {
  List<dynamic> data = [];
  static final Save _instance = Save._internal();
  factory Save() => _instance;
  Save._internal();


  Future<File> _getFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return await File("${dir.path}/mangas.json").create(recursive: true);
  }

  Future<void> readFile() async {
    final File file = await _getFile();
    String fileContent = await file.readAsString();
    if(fileContent.isNotEmpty) {
      data = json.decode(fileContent);
    }
  }

  Future<void> add(String title, Map info) async {
    final File file =  await _getFile();
    if(title == null && info == null){
      file.writeAsString(json.encode(data));
      return;
    }
    if(!contains(data, title)){
      data.add({title: info});
      file.writeAsString(json.encode(data));
    }
  }

  bool contains(List list, String key) {
    for(var v in list) {
      if(v[key] != null)
        return true;
    }
    return false;
  }
}