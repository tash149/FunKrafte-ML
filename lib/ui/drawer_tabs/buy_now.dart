import 'package:flutter/material.dart';
import 'package:funkrafte/data/firebase.dart';

class BuyNow extends StatefulWidget {
  @override
  _BuyNowState createState() => _BuyNowState();
}

class _BuyNowState extends State<BuyNow> {
  bool _isRegistered = false;
  bool _displayResult = false;

  void refresh() {
    setState(() {
      _isRegistered = false;
      _displayResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    isRegistered().then((value) {
      if (this.mounted)
        setState(() {
          _isRegistered = value;
          _displayResult = true;
        });
    });

    return Container(
      margin: MediaQuery.of(context).padding,
      child: Center(
        child: _displayResult
            ? _isRegistered
                ? RegisteredWidget()
                : RegisterNowWidget(cb: refresh)
            : CircularProgressIndicator(),
      ),
    );
  }
}

class RegisteredWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 70.0,
          color: Colors.green,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.5),
        ),
        Text(
          "You are set!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 7.5),
        ),
        Text(
            "You are registered for our classes.\nOur representative will email you shortly 😄",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 17.5))
      ],
    );
  }
}

class RegisterNowWidget extends StatelessWidget {
  final VoidCallback cb;
  RegisterNowWidget({@required this.cb});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Like what you see?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.5),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  registerForProduct().then((value) {
                    cb();
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Row(
                      children: <Widget>[
                        Icon(Icons.check_circle),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 6.0)),
                        Text(
                            "Registered! Our representative will contact you shortly 😄"),
                      ],
                    )));
                  });
                },
                child: Icon(Icons.star),
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              Text(
                "Tap the button to sign-up\nyour child for our classes!",
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 17.5),
              ),
            ],
          ),
        ),
        //RaisedButton(onPressed: () {}, child: Text("Register now!"))
      ],
    );
  }
}
