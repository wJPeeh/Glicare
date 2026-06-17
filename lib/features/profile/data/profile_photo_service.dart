import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { gallery, camera }

class ProfilePhotoService {
  ProfilePhotoService(this._storage);

  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUpload({
    required String uid,
    required PhotoSource source,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final ref = _storage.ref().child('users/$uid/profile_photo.jpg');
    final file = File(picked.path);
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }

  Future<void> deletePhoto(String uid) async {
    try {
      await _storage.ref().child('users/$uid/profile_photo.jpg').delete();
    } on FirebaseException {
      // already absent — ignore
    }
  }
}
