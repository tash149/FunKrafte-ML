import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../data/auth.dart';

class GoogleSignInButton extends StatelessWidget {
  final Function onPressed;
  GoogleSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppData().scaleFactorA * 20.0),
      child: MaterialButton(
        onPressed: () => signIn(onPressed),
        color: Colors.white,
        elevation: 0.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "assets/glogo.png",
              height: AppData().scaleFactorH * 25.0,
              width: AppData().scaleFactorW * 25.0,
            ),
            SizedBox(
              width: AppData().scaleFactorW * 20.0,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: AppData().scaleFactorH * 15.0),
              child: Text(
                "Sign in with Google",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                    fontSize: AppData().scaleFactorH * 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadImageButton extends StatelessWidget {
  final Function onPressed;
  UploadImageButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppData().scaleFactorA * 20.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: Theme.of(context).accentColor,
        elevation: 0.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.image, color: Colors.white),
            SizedBox(
              width: AppData().scaleFactorW * 20.0,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: AppData().scaleFactorH * 15.0),
              child: Text(
                "Select Image",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: AppData().scaleFactorH * 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
