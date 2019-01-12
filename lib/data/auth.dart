import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_data.dart';
import 'firebase.dart';

final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> logoutUser() async {
  await _auth.signOut();
  await _googleSignIn.signOut();
}

Future<bool> isLoggedIn() async {
  bool ret = await _googleSignIn.isSignedIn();
  ret = ret && _auth.currentUser() != null;
  return ret;
}

Future signIn(Function action) async {
  UserData().isAdmin = false;
  GoogleSignInAccount gSI = await _googleSignIn.signIn();
  GoogleSignInAuthentication gSA;
  try {
    gSA = await gSI.authentication;
    _auth
        .signInWithGoogle(idToken: gSA.idToken, accessToken: gSA.accessToken)
        .then((user) {
      action();
      UserData().user = user;
      updateUserDB();
      updateAdmin();
      updateEmotion();
    });
  } catch (e) {}
}

Future<void> updateAdmin() async {
  Firestore.instance
      .collection('users')
      .where('id', isEqualTo: UserData().user.uid)
      .getDocuments()
      .then((result) {
    bool admin = result.documents.elementAt(0)['isAdmin'];
    if (admin == null) admin = false;
    UserData().isAdmin = admin;
  });
}

Future<void> updateEmotion() async {
  Firestore.instance
      .collection('users')
      .where('id', isEqualTo: UserData().user.uid)
      .getDocuments()
      .then((result) {
    String emo = result.documents.elementAt(0)['emotion'];
    if (emo == "NONE")
      UserData().emotion = null;
    else
      UserData().emotion = emo;
  });
}
