import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:funkrafte/data/app_data.dart';
import 'package:funkrafte/data/firebase.dart';
import 'package:path_provider/path_provider.dart';

class CameraWidget extends StatefulWidget {
  final BuildContext pContext;
  CameraWidget({@required this.pContext});

  @override
  _CameraWidgetState createState() {
    return _CameraWidgetState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraWidgetState extends State<CameraWidget> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VoidCallback videoPlayerListener;
  bool imageSnapped = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    onNewCameraSelected(AppData().cameras[1]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    var cameraAR = 1.0;
    try {
      cameraAR = controller.value.aspectRatio;
    } catch (e) {
      print(e);
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: controller == null
          ? Container()
          : Stack(
              children: <Widget>[
                Transform.scale(
                  scale: cameraAR / deviceRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: cameraAR,
                      child: imageSnapped
                          ? Image.file(File(imagePath))
                          : _cameraPreviewWidget(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppData().scaleFactorH * 20.0,
                  left: 0.0,
                  right: 0.0,
                  child: Center(
                    child: imageSnapped
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FloatingActionButton(
                                  heroTag: "main",
                                  onPressed: () {
                                    uploadImageAs(File(imagePath),
                                            UserData().user.uid)
                                        .then(
                                            (value) => updateEmotionDB(value));
                                    Navigator.of(widget.pContext).pop();
                                  },
                                  child: Icon(Icons.check),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppData().scaleFactorW * 10.0)),
                              FloatingActionButton(
                                  heroTag: "discard",
                                  onPressed: () {
                                    setState(() {
                                      imageSnapped = false;
                                      if (imagePath != null)
                                        File(imagePath).deleteSync();
                                      imagePath = null;
                                    });
                                  },
                                  child: Icon(Icons.clear),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white)
                            ],
                          )
                        : FloatingActionButton(
                            heroTag: "main",
                            onPressed: controller != null &&
                                    controller.value.isInitialized
                                ? onTakePictureButtonPressed
                                : null,
                            child: Icon(Icons.camera_alt),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black45),
                  ),
                )
              ],
            ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading camera...',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          imageSnapped = true;
        });
        if (filePath != null) print('Picture saved to $filePath');
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/emotion_data';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    print('Error: ${e.code}\n${e.description}');
  }
}

class EmotionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraWidget(pContext: context),
    );
  }
}
