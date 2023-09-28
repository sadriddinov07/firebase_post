import 'dart:io';

import 'package:firebase_post/services/db_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

sealed class StoreService {
  static final storage = FirebaseStorage.instance;

  static Future<String> uploadFile(File file) async {
    final image = storage.ref(Folder.postImages).child("image_${DateTime.now().toIso8601String()}${file.path.substring(file.path.lastIndexOf("."))}" );
    final task = image.putFile(file);
    await task.whenComplete(() {});
    return image.getDownloadURL();
  }
}