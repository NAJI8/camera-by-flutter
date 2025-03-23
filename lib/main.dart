import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

void main() async {
  // Initialiser Flutter avant de démarrer l'application
  WidgetsFlutterBinding.ensureInitialized();

  // Récupérer la liste des caméras disponibles sur le dispositif
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(camera: camera),  // Passer la caméra à l'écran
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    // Initialiser le contrôleur de la caméra avec la caméra et la résolution
    _controller = CameraController(widget.camera, ResolutionPreset.high);

    // Attendre que la caméra soit initialisée
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Libérer les ressources une fois l'écran détruit
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Flutter')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,  // Attendre l'initialisation
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Afficher l'aperçu de la caméra une fois l'initialisation terminée
            return CameraPreview(_controller);  // Affichage du flux vidéo de la caméra
          } else {
            return const Center(child: CircularProgressIndicator());  // Affichage d'un indicateur de progression
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Attendre l'initialisation complète du contrôleur de la caméra
            await _initializeControllerFuture;

            // Prendre une photo
            final image = await _controller.takePicture();

            // Si l'écran est encore actif, naviguer vers l'écran de la photo
            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            // Si une erreur se produit, afficher un message dans la console
            print("Erreur lors de la capture : $e");
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Capturée')),
      body: Center(
        // Affichage de l'image capturée à l'aide de File
        child: Image.file(File(imagePath)),
      ),
    );
  }
}


