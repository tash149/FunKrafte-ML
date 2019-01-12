import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funkrafte/data/app_data.dart';
import 'package:funkrafte/ui/common.dart';
import 'package:url_launcher/url_launcher.dart';

class Post {
  /// Let's just avoid conflicts here :)
  String id = "${Random().nextInt(10000)}_${Random().nextInt(10000)}";
  String imageUrl;
  String caption = "";
  String uid = "";
  String currentUid = UserData().user.uid;
  int likes = 0;
  bool liked = false;
  Map<String, List<dynamic>> comments = new Map();
  Set<String> likedBy = new Set();
  DocumentSnapshot ds;

  Post({this.id, this.imageUrl, this.caption, this.ds, this.uid}) {
    if (ds == null) {
      publishDoc();
    } else
      loadFromDs();
  }

  String randomStringGen() {
    return "${Random().nextInt(10000)}-${Random().nextInt(10000)}";
  }

  void addComment(String comment) {
    List<String> currentComment = new List<String>();
    currentComment.add(currentUid);
    currentComment.add(comment);
    var cKey = new DateTime.now().millisecondsSinceEpoch.toString() +
        randomStringGen();
    comments[cKey] = currentComment;
    serverUpdate();
  }

  void like() {
    if (likedBy == null) likedBy = new HashSet();
    liked = !liked;
    liked
        ? likedBy.add(currentUid)
        // ignore: unnecessary_statements
        : likedBy.contains(currentUid) ? likedBy.remove(currentUid) : '';
    likes = likedBy.length;
    serverUpdate();
  }

  void serverUpdate() {
    Firestore.instance
        .collection('posts')
        .document(id)
        .updateData({'likedBy': likedBy.toList(), 'comments': comments});
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "id": id,
        "imageUrl": imageUrl,
        "caption": caption,
        "likedBy": likedBy.toList(),
        "comments": comments
      };

  Future<void> publishDoc() async {
    DocumentReference ref =
        await Firestore.instance.collection('posts').add(this.toJson());
    id = ref.documentID;
    ref.updateData({'id': id});
    ds = await ref.get();
  }

  Future<void> delete() async {
    Firestore.instance.collection('posts').document(id).delete();
  }

  void emailUser({String subject = "", @required BuildContext context}) async {
    String emailId = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: uid)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['email']);
    if (emailId == null) {
      if (context == null) {
        throw ("Bad context and email in db is null!\nuid: $uid");
      }
      popupMenuBuilder(
          context,
          AlertDialog(
            title: Text("Bad Email ID!"),
            content: Text(
                "This is usually caused due to an issue with the database or if the user in question is using an old version of the app."),
          ),
          dismiss: true);
      return;
    }

    String url = 'mailto:$emailId?subject=$subject';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not perform email intent: $url');
    }
  }

  Future<void> loadFromDs() async {
    uid = ds['uid'];
    id = ds['id'];
    imageUrl = ds['imageUrl'];
    caption = ds['caption'];
    likedBy = new Set.from(ds['likedBy']);
    likes = likedBy == null ? 0 : likedBy.length;
    setLiked();
    if (ds['comments'] == null) {
      comments = new Map();
      serverUpdate();
    } else {
      comments = new Map.from(ds['comments']);
    }
  }

  void setLiked() {
    if (likedBy != null && likedBy.contains(currentUid)) liked = true;
  }
}
