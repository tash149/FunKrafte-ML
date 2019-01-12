import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'app_data.dart';

Future<void> updateUserDB() async {
  if (UserData().user != null) {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: UserData().user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0 ||
        documents.elementAt(0).data['email'] == null ||
        documents.elementAt(0).data['isAdmin'] == null) {
      // Update data to server if new user
      Firestore.instance
          .collection('users')
          .document(UserData().user.uid)
          .setData({
        'name': UserData().user.displayName,
        'photoUrl': UserData().user.photoUrl,
        'id': UserData().user.uid,
        'email': UserData().user.email,
        'isAdmin': UserData().isAdmin,
        'emotion': "NONE"
      });
    }
  }
}

Future<void> updateEmotionDB(String emotionImURL) async {
  if (emotionImURL != null) {
    final QuerySnapshot result = await Firestore.instance
        .collection('emotion')
        .where('id', isEqualTo: UserData().user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      Firestore.instance
          .collection('emotion')
          .document(UserData().user.uid)
          .setData({
        'uid': UserData().user.uid,
        'photoUrl': emotionImURL,
      });
    }
  }
}

Future<void> registerForProduct() async {
  bool _isRegistered = await isRegistered();
  if (!_isRegistered) {
    Firestore.instance
        .collection('registered')
        .document(UserData().user.uid)
        .setData({
      'name': UserData().user.displayName,
      'photoUrl': UserData().user.photoUrl,
      'id': UserData().user.uid,
      'email': UserData().user.email,
      'processed': false,
    });
  }
}

Future<bool> isRegistered() async {
  final QuerySnapshot result = await Firestore.instance
      .collection('registered')
      .where('id', isEqualTo: UserData().user.uid)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  return documents.length != 0;
}

Future<String> uploadImage(File imageFile) async {
  String _fileName =
      "${new Random().nextInt(10000)}_${new Random().nextInt(10000)}_${new Random().nextInt(10000)}.jpg";
  StorageReference ref =
      FirebaseStorage.instance.ref().child("${UserData().user.uid}/$_fileName");
  StorageUploadTask uploadTask = ref.putFile(imageFile);
  return await (await uploadTask.onComplete).ref.getDownloadURL();
}

Future<String> uploadImageAs(File imageFile, String name) async {
  String _fileName = name;
  StorageReference ref =
      FirebaseStorage.instance.ref().child("${UserData().user.uid}/$_fileName");
  StorageUploadTask uploadTask = ref.putFile(imageFile);
  return await (await uploadTask.onComplete).ref.getDownloadURL();
}

Future<File> getImage() async {
  print("Called getImage");
  return await ImagePicker.pickImage(source: ImageSource.gallery);
}

void createPost() {}
