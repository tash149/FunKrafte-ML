import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funkrafte/data/app_data.dart';
import 'package:funkrafte/data/post.dart';
import 'package:funkrafte/ui/comments.dart';
import 'package:photo_view/photo_view.dart';

class PostWidget extends StatelessWidget {
  final Post p;

  PostWidget({@required this.p});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserInfoRow(id: p.uid, p: p),
          SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageViewer(url: p.imageUrl)));
                  },
                  child: CachedNetworkImage(
                      imageUrl: p.imageUrl, fit: BoxFit.cover),
                ))
                //child: Image.asset('assets/logo.png', fit: BoxFit.cover))
              ],
            ),
          ),
          PostInfoBar(p),
        ],
      ),
    );
  }
}

class UserInfoRow extends StatefulWidget {
  final String id;
  final Post p;
  UserInfoRow({@required this.id, @required this.p});

  @override
  UserInfoRowState createState() {
    return new UserInfoRowState();
  }
}

class UserInfoRowState extends State<UserInfoRow> {
  String imageUrl;
  String userName = "";
  BuildContext mContext;

  Future<void> _getUserName() async {
    var name = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['name']);
    try {
      if (this.mounted)
        setState(() {
          userName = name;
        });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getUserImageUrl() async {
    var url = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.id)
        .getDocuments()
        .then((result) => result.documents.elementAt(0)['photoUrl']);
    try {
      if (this.mounted)
        setState(() {
          imageUrl = url;
        });
    } catch (e) {
      print(e);
    }
  }

  void _select(int c) {
    if (c == 0) {
      widget.p.emailUser(context: mContext);
    } else if (c == 1) {
      widget.p.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    _getUserImageUrl();
    _getUserName();
    var menu = List<PopupMenuEntry<int>>();
    menu.add(PopupMenuItem<int>(value: 0, child: Text("Email user")));
    menu.add(PopupMenuItem<int>(value: 1, child: Text("Delete post")));
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
                child: Text(
                  userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          UserData().isAdmin
              ? PopupMenuButton<int>(
                  onSelected: _select,
                  itemBuilder: (context) {
                    return menu;
                  },
                )
              : Container()
        ],
      ),
    );
  }
}

class PostInfoBar extends StatefulWidget {
  final Post p;
  PostInfoBar(this.p);

  @override
  PostInfoBarState createState() {
    return new PostInfoBarState();
  }
}

class PostInfoBarState extends State<PostInfoBar> {
  bool like = false;

  @override
  Widget build(BuildContext context) {
    like = widget.p.liked;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => setState(() => widget.p.like()),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 16.0, bottom: 8.0),
                  child: like
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_border),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) => Comments(p: widget.p))),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 16.0, bottom: 8.0),
                  child: Icon(Icons.comment),
                ),
              ),
            ],
          ),
          LikesAndCaption(p: widget.p),
        ],
      ),
    );
  }
}

class LikesAndCaption extends StatefulWidget {
  final Post p;

  LikesAndCaption({this.p});
  @override
  _LikesAndCaptionState createState() => _LikesAndCaptionState();
}

class _LikesAndCaptionState extends State<LikesAndCaption> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(top: 8.0, right: 16.0, left: 16.0, bottom: 8.0),
          child: Text(
            widget.p.likes == 1 ? "1 like" : "${widget.p.likes} likes",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17.5),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.0, right: 16.0, left: 16.0),
          child: Text(widget.p.caption),
        ),
      ],
    );
  }
}

class ImageViewer extends StatefulWidget {
  final String url;
  ImageViewer({this.url});
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
              child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(widget.url),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 2.0)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
