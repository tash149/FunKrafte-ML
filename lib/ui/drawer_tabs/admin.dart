import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funkrafte/ui/common.dart';
import 'package:url_launcher/url_launcher.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('registered').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  int adjIndex = (snapshot.data.documents.length - 1) - index;
                  return AdminUserInfo(
                      id: snapshot.data.documents[adjIndex]['id']);
                  /*return PostWidget(
                      p: Post(ds: snapshot.data.documents[adjIndex]));*/
                });
        });
  }
}

class AdminUserInfo extends StatefulWidget {
  final String id;
  AdminUserInfo({@required this.id});

  @override
  AdminUserInfoState createState() {
    return new AdminUserInfoState();
  }
}

class AdminUserInfoState extends State<AdminUserInfo> {
  String imageUrl;
  String userName = "";
  String email = "";
  bool processed = false;
  BuildContext mContext;

  Future<void> _getData() async {
    var name = await Firestore.instance
        .collection('registered')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['name']);
    var mail = await Firestore.instance
        .collection('registered')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['email']);
    var url = await Firestore.instance
        .collection('registered')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['photoUrl']);
    var proc = await Firestore.instance
        .collection('registered')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['processed']);
    try {
      if (this.mounted)
        setState(() {
          userName = name;
          email = mail;
          imageUrl = url;
          processed = proc;
        });
    } catch (e) {
      print(e);
    }
  }

  void emailUser(
      {String subject = "",
      @required BuildContext context,
      @required String uid}) async {
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

  @override
  Widget build(BuildContext context) {
    mContext = context;
    _getData();

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              imageUrl == null
                  ? CircularProgressIndicator()
                  : CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(imageUrl)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onLongPress: () {
              setState(() {
                processed = !processed;
                Firestore.instance
                    .collection('registered')
                    .document(widget.id)
                    .updateData({'processed': processed});
              });
            },
            child: FloatingActionButton(
              onPressed: () => emailUser(
                  context: context,
                  uid: widget.id,
                  subject: "FunKrafte student signup"),
              child: Icon(Icons.mail),
              backgroundColor: Colors.white,
              foregroundColor: processed ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
