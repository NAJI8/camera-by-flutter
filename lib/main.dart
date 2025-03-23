import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool isCameraInitialized = false;

  void _toggleCamera() async {
    if (isCameraInitialized) {
      _controller?.dispose();
      setState(() {
        isCameraInitialized = false;
      });
    } else {
      if (widget.cameras.isNotEmpty) {
        _controller = CameraController(widget.cameras.first, ResolutionPreset.medium);
        _initializeControllerFuture = _controller!.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune caméra disponible")),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (!isCameraInitialized || _controller == null) return;

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo prise: ${image.path}')),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caméra')),
      body: Column(
        children: [
          Expanded(
            child: isCameraInitialized
                ? FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : const Center(child: Text("Appuyez sur le bouton pour activer la caméra")),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _toggleCamera,
                child: Text(isCameraInitialized ? "Désactiver la caméra" : "Activer la caméra"),
              ),
              ElevatedButton(
                onPressed: isCameraInitialized ? _takePicture : null,
                child: const Text("Prendre une photo 📸"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}