import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mlkit/mlkit.dart';
import 'dart:async';
import 'package:async/async.dart';
//import 'package:flutt_cam/flapp/server.py'
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _file;
  upload(File imageFile) async {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse("http://127.0.0.1:5000/");
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value){
      print(value);
    });
  }
  List<VisionFace> _face = <VisionFace>[];

  VisionFaceDetectorOptions options = new VisionFaceDetectorOptions(
      modeType: VisionFaceDetectorMode.Accurate,
      landmarkType: VisionFaceDetectorLandmark.All,
      classificationType: VisionFaceDetectorClassification.All,
      minFaceSize: 0.15,
      isTrackingEnabled: true);

  FirebaseVisionFaceDetector detector = FirebaseVisionFaceDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple[400],
        accentColor: Colors.deepPurpleAccent[200],
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Face Detection Firebase'),
        ),
        body: showBody(_file),
      ),
    );
  }

  Widget showBody(File file) {
    return new Container(
        child: new Stack(
          children: <Widget>[
            _buildImage(),
            _showDetails(_face),

            Align(
              alignment: Alignment(-0.9, 0.9),
              child: new FloatingActionButton(
                onPressed: () async{
                  var file = await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                  //var result = await platform.invokeMethod('pickImage', stringImageSource);
                  var face =
                  await detector.detectFromBinary(_file?.readAsBytesSync(), options);
                  setState(() {
                    if (face.isEmpty) {
                      print('No face detected');
                    } else {
                      _face = face;
                    }
                  });
                },
                child: new Icon(Icons.tag_faces),
              ),
            ),
            Align(
              alignment: Alignment(0.9,0.9),
              child: new FloatingActionButton(
                onPressed: () async{
                  var file = await ImagePicker.pickImage(source: ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                  var face =
                  await detector.detectFromBinary(_file?.readAsBytesSync(), options);
                  setState(() {
                    if (face.isEmpty) {
                      print('No face detected');
                    } else {
                      _face = face;
                    }
                  });
                },
                child: new Icon(Icons.camera_alt),
              ),
            ),
            Align(
              alignment: Alignment(0.0,0.9),
              child: new RaisedButton(
                elevation: 7.0,
                child: Text('Upload'),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  final StorageReference firebaseStorageRef =
                  FirebaseStorage.instance.ref().child('myimage.jpg');
                  final StorageUploadTask task =
                  firebaseStorageRef.putFile(_file);
                },
              )
            )
          ],
        )
    );
  }

  Widget _buildImage() {
    return new SizedBox(
      height: 500.0,
      child: new Center(
        child: _file == null
            ? new Text('')
            : new FutureBuilder<Size>(
          future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
          builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
            if (snapshot.hasData) {
              return Container(
                  foregroundDecoration:
                  TextDetectDecoration(_face, snapshot.data),
                  child: Image.file(_file, fit: BoxFit.fitWidth));
            } else {
              return new Text('Please wait...');
            }
          },
        ),
      ),
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionFace> _texts;
  TextDetectDecoration(List<VisionFace> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _TextDetectPainter(_texts, _originalImageSize);
  }
}

Future _getImageSize(Image image) {
  Completer<Size> completer = new Completer<Size>();
  image.image.resolve(new ImageConfiguration()).addListener(
          (ImageInfo info, bool _) => completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble())));
  return completer.future;
}

Widget _showDetails(List<VisionFace> faceList) {
  if (faceList == null || faceList.length == 0) {
    return new Text('', textAlign: TextAlign.center);
  }
  return new Container(
    child: new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: faceList.length,
      itemBuilder: (context, i) {
        checkData(faceList);
        return _buildRow(
          faceList[0].smilingProbability,
        );
      },
    ),
  );
}

//For checking and printing diferent variables from Firebase
void checkData(List<VisionFace> faceList) {
  final double uncomputedProb = -1.0;
  final int uncompProb = -1;

  for (int i = 0; i < faceList.length; i++) {
    Rect bounds = faceList[i].rect;
    print('Rectangle : $bounds');

    if (faceList[i].smilingProbability != uncomputedProb) {
      double smileProb = faceList[i].smilingProbability;
      print('Smile Prob : $smileProb');
    }

    if (faceList[i].trackingID != uncompProb) {
      int tID = faceList[i].trackingID;
      print('Tracking ID : $tID');
    }
  }
}


Widget _buildRow(
    double smileProb,
    ) {
  return ListTile(
    title: new Text(
      "\nSmileProb : $smileProb",
    ),
    dense: true,
  );
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionFace> _faceLabels;
  final Size _originalImageSize;
  _TextDetectPainter(faceLabels, originalImageSize)
      : _faceLabels = faceLabels,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var faceLabel in _faceLabels) {
      final _rect = Rect.fromLTRB(
          offset.dx + faceLabel.rect.left / _widthRatio,
          offset.dy + faceLabel.rect.top / _heightRatio,
          offset.dx + faceLabel.rect.right / _widthRatio,
          offset.dy + faceLabel.rect.bottom / _heightRatio);

      canvas.drawRect(_rect, paint);
    }
  }
}
