import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:instagram_v2/screens/gallery_screen.dart';
import 'package:instagram_v2/screens/preview_photo.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen();

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  List cameras;
  int selectedCameraIndex;

  List<Media> _allUri = [];
  var _dir;
  File _lastImageFile;

  Future<void> _getImagePath() async {
    _dir = await getTemporaryDirectory();
    final List<MediaCollection> collections =
        await MediaGallery.listMediaCollections(
      mediaTypes: [MediaType.image],
    );
    final MediaPage imagePage = await collections[0].getMedias(
      mediaType: MediaType.image,
      take: 500,
    );
    File lastImageFile = await imagePage.items[0].getFile();
    setState(() {
      _lastImageFile = lastImageFile;
    });
  }

  @override
  void initState() {
    super.initState();
    _getImagePath();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _cameraPreviewWidget(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildGalleryIcon(_lastImageFile),
                      _cameraControlWidget(context),
                      _cameraToggleRowWidget(),
                      //Spacer()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return CameraPreview(controller);
  }

  Future<File> _compressAndGetFile(File file, int i) async {
    final targetPath = _dir.absolute.path + "/tempcam$i.jpg";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 40,
      rotate: 0,
    );
    return result;
  }

  _buildGalleryIcon(File file) {
    return Container(
      child: FutureBuilder(
          future: _compressAndGetFile(file, _allUri.length - 1),
          builder: (context, snapshot) {
            return InkWell(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[500]),
                    image: DecorationImage(
                        image: !snapshot.hasData
                            ? AssetImage('assets/images/user_placeholder.jpg')
                            : FileImage(snapshot.data),
                        fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          color: Colors.grey,
                          offset: Offset(2, 2))
                    ],
                  ),
                ),
              ),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => GalleyScreen())),
            );
          }),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _cameraControlWidget(context) {
    return FloatingActionButton(
      child: Icon(
        Icons.camera,
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      onPressed: () {
        _onCapturePressed(context);
      },
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraToggleRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return IconButton(
      onPressed: _onSwitchCamera,
      icon: Icon(
        _getCameraLensIcon(lensDirection),
        color: Colors.white,
        size: 32,
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
    print(errorText);
  }

  void _onCapturePressed(context) async {
    try {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '$dirPath/${timestamp()}.jpg';
      try {
        await controller.takePicture(filePath);
      } on CameraException catch (e) {
        _showCameraException(e);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewPhotoScreen(
                  fileImage: File(filePath),
                )),
      );
    } catch (e) {
      _showCameraException(e);
    }
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _initCameraController(selectedCamera);
  }
}
