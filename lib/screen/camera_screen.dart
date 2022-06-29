import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kltn/utils/routes.dart';
import 'package:kltn/widget/home_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }

    cameraController
        .getMaxZoomLevel()
        .then((value) => _maxAvailableZoom = value);

    cameraController
        .getMinZoomLevel()
        .then((value) => _minAvailableZoom = value);

    cameraController
        .getMinExposureOffset()
        .then((value) => _minAvailableExposureOffset = value);

    cameraController
        .getMaxExposureOffset()
        .then((value) => _maxAvailableExposureOffset = value);
  }

  // To store the retrieved files
  List<File> allFileList = [];

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized ? buildBody() : Container(),
    );
  }

  Widget buildBody() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Column(
        children: [
          Flexible(
            flex: 5,
            child: buildCameraRegion(),
          ),
          Flexible(
            flex: 1,
            child: buildToolRegion(),
          ),
        ],
      ),
    );
  }

  Widget buildCameraRegion() {
    return Stack(
      children: [
        buildCamera(),
        buildToolBeforeCamera(),
      ],
    );
  }

  Widget buildCamera() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: CameraPreview(controller!),
    );
  }

  Widget buildToolBeforeCamera() {
    return Container(
      constraints: const BoxConstraints.expand(),
      padding: EdgeInsets.fromLTRB(0, 0, 20.w, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            flex: 9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeButton(),
                buildExposureSlider(),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: buildZoomSlider(),
          ),
        ],
      ),
    );
  }

  Widget buildToolRegion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
            ),
            buildCaptureButton(),
            const SizedBox(
              width: 50,
            ),
          ],
        ),
      ],
    );
  }

  void reload() {
    setState(() {});
  }

  Widget buildZoomSlider() {
    return Align(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Slider(
              value: _currentZoomLevel,
              min: _minAvailableZoom,
              max: _maxAvailableZoom,

              activeColor: Colors.white,
              inactiveColor: Colors.white30,
              onChanged: (value) async {
                setState(() {
                  _currentZoomLevel = value;
                });
                await controller!.setZoomLevel(value);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${_currentZoomLevel.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExposureSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top * 1.5,),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_currentExposureOffset.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              height: 30,
              child: Slider(
                value: _currentExposureOffset,
                min: _minAvailableExposureOffset,
                max: _maxAvailableExposureOffset,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  setState(() {
                    _currentExposureOffset = value;
                  });
                  await controller!.setExposureOffset(value);
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  void changeToConfirmScreen(File image) {
    Navigator.of(context).pushNamed(
        Routes.confirmImage, arguments: image);
  }

  Widget buildCaptureButton() {
    return InkWell(
      onTap: () async {
        XFile? rawImage = await takePicture();
        if (rawImage != null) {
          File file = File(rawImage.path);
          changeToConfirmScreen(file);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.circle, color: Colors.white38, size: 240.h),
          Icon(Icons.circle, color: Colors.white, size: 200.h),
        ],
      ),
    );
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  _getImageGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      changeToConfirmScreen(file);
    }
  }
}
