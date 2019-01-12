import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const headerHeight = 250.0;

    return new Container(
      height: headerHeight,
      decoration: new BoxDecoration(
        color: Colors.purple,
        boxShadow: <BoxShadow>[
          new BoxShadow(
              spreadRadius: 2.0,
              blurRadius: 4.0,
              offset: new Offset(0.0, 1.0),
              color: Colors.black38),
        ],
      ),
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // linear gradient
          new Container(
            height: headerHeight,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(colors: <Color>[
                //7928D1
                Color(0xFF4A00E0), Color(0xFF8E2DE2)
              ], stops: <double>[
                0.1,
                0.7
              ], begin: Alignment.topRight, end: Alignment.bottomLeft),
            ),
          ),
          // radial gradient
          new Padding(
            padding: new EdgeInsets.only(
                top: topPadding, left: 15.0, right: 15.0, bottom: 20.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, top: 30.0),
                  child: _buildTitle(),
                ),
                new Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: _buildAvatar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: new Text("POSP Updater",
          style: new TextStyle(
            color: Colors.white,
            fontSize: 40.0,
          )),
    );
  }

  /// The avatar consists of the profile image, the users name and location
  Widget _buildAvatar() {
    return new Row(
      children: <Widget>[
        new Padding(padding: const EdgeInsets.only(right: 20.0)),
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(),
          ],
        ),
      ],
    );
  }
}

Future<Null> popupMenuBuilder(BuildContext context, Widget child,
    {bool dismiss = false}) async {
  return showDialog<Null>(
      context: context,
      barrierDismissible: dismiss,
      builder: (BuildContext context) => child);
}
