import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:funkrafte/data/app_data.dart';

import 'data/auth.dart';
import 'ui/buttons.dart';
import 'ui/pages/home.dart';

Future<void> main() async {
  AppData().cameras = await availableCameras();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.red, accentColor: Colors.red),
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/login': (BuildContext context) => new AppWrapper(),
      '/home': (BuildContext context) => new HomeScreen(),
    },
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    pushAndReplace('/login');
  }

  Future<void> pushAndReplace(String routeName) async {
    // Needed for hero animation
    final current = ModalRoute.of(context);
    Navigator.pushNamed(context, routeName);
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.removeRoute(context, current);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;

    // Make our life a bit easier.
    AppData().scaleFactorH = MediaQuery.of(context).size.height / 900;
    AppData().scaleFactorW = MediaQuery.of(context).size.width / 450;
    AppData().scaleFactorA = (MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) /
        (900 * 450);

    return Scaffold(
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: FractionalOffset.topRight,
                    end: FractionalOffset.bottomLeft,
                    tileMode: TileMode.clamp)),
          ),
          new Center(
              child: Hero(
            tag: "logo",
            child: Container(
              height: h / 3.75,
              child: Image.asset(
                'assets/logo.png',
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  @override
  AppWrapperState createState() {
    return new AppWrapperState();
  }
}

class AppWrapperState extends State<AppWrapper> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: null,
      body: new App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    isLoggedIn().then((value) {
      if (value) {
        signIn(() {
          print("Sign in Successful!\nWelcome to FunKrafte!");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              settings: RouteSettings(name: '/home'),
              builder: (context) => HomeScreen()));
        });
      }
    });
    var h = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          child: new Opacity(
            opacity: 0.05,
            child: new Align(
              alignment: Alignment.centerRight,
              child: new Transform.rotate(
                angle: -(22 / 7) / 4.8,
                alignment: Alignment.centerRight,
                child: new ClipPath(
                  //clipper: new BackgroundImageClipper(),
                  child: new Container(
                    padding: const EdgeInsets.only(
                        bottom: 20.0, right: 0.0, left: 60.0),
                    child: new Image(
                        width: h / 2.0,
                        height: h / 2.0,
                        image: AssetImage('assets/logo.png')),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: h / 3.75,
          left: 0.0,
          right: 0.0,
          child: Hero(
              tag: "logo",
              child: Container(
                  height: h / 4.5,
                  child: Image.asset(
                    'assets/logo.png',
                  ))),
        ),
        Positioned(
          top: h / 1.85,
          left: 0.0,
          right: 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GoogleSignInButton(
              onPressed: () {
                print("Sign in Successful!\nWelcome to FunKrafte!");
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
          ),
        )
      ],
    );
  }
}
