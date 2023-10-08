import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraDescription cameraDescription;
  CameraController? controller;

  final CameraLensDirection direction = CameraLensDirection.back;

  Future<void> getCamera(CameraLensDirection dir) async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == dir,
      );
    } else {
      debugPrint("No cameras available with lens direction $dir");
    }
  }

  Future<void> checkCamera() async {
    try {
      await getCamera(direction);

      if (controller == null) {
        controller =
            CameraController(cameraDescription, ResolutionPreset.medium);
        await controller?.initialize(); // Add await here
      }
    } on CameraException catch (e) {
      debugPrint(e.description);
    }
  }

  @override
  void initState() {
    super.initState();
    getCamera(direction).then((_) {
      checkCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: controller?.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (controller != null && controller!.value.isInitialized) {
                return Container(
                  child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: CameraPreview(controller!),
                  ),
                );
              } else {
                return Text("Camera not initialized");
              }
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
