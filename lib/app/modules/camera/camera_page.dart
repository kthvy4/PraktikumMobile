import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_mobile/app/modules/connection/controller/connection_controller.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  final storage = GetStorage();
  final connectionController = Get.find<ConnectionController>();
  final ImagePicker _picker = ImagePicker();
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  List<File> capturedFiles = []; // List untuk menyimpan file yang diambil

  @override
  void initState() {
    super.initState();
    initializeCamera();
    handleLoginSync();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras!.isNotEmpty) {
        _cameraController = CameraController(cameras![0], ResolutionPreset.high);
        await _cameraController!.initialize();
        setState(() {});
      } else {
        Get.snackbar("Error", "No camera available", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize camera", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void handleLoginSync() async {
    if (connectionController.isConnected.value) {
      List<String> pendingFiles = storage.read<List<String>>('pendingFiles') ?? [];
      if (pendingFiles.isNotEmpty) {
        for (var filePath in pendingFiles) {
          File file = File(filePath);
          await uploadFileToFirestore(file);
          if (await file.exists()) {
            await file.delete();
          }
        }
        storage.write('pendingFiles', []);
        Get.snackbar("Sync", "Offline files uploaded successfully.", backgroundColor: Colors.green, colorText: Colors.white);
      }
      setState(() {
        capturedFiles.clear();
      });
    }
  }

  Future<void> pickImageOrVideo(BuildContext context, bool isImage) async {
    try {
      final pickedFile = await (isImage
          ? _picker.pickImage(source: ImageSource.camera)
          : _picker.pickVideo(source: ImageSource.camera));

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        setState(() {
          capturedFiles.add(file); // Tambahkan file yang diambil ke list
        });

        await uploadFileToFirestore(file);

        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> uploadFileToFirestore(File file) async {
    try {
      String fileName = file.path.split('/').last;
      Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();

      // Upload data to Firestore
      await FirebaseFirestore.instance.collection('uploads').add({
        'url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove the file from the capturedFiles list after upload
      setState(() {
        capturedFiles.remove(file);
      });

      Get.snackbar("Success", "File uploaded successfully!", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Error", "Failed to upload file. Saving locally.", backgroundColor: Colors.red, colorText: Colors.white);
      saveFileLocally(file);
    }
  }

  void saveFileLocally(File file) {
    List<String> pendingFiles = storage.read<List<String>>('pendingFiles') ?? [];
    pendingFiles.add(file.path);
    storage.write('pendingFiles', pendingFiles);
    Get.snackbar("Offline", "File saved locally.", backgroundColor: Colors.orange, colorText: Colors.white);
  }

  Future<void> captureImage() async {
    await pickImageOrVideo(context, true);
  }

  Future<void> captureVideo() async {
    await pickImageOrVideo(context, false);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text("Camera")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(connectionController.isConnected.value
                ? "Camera Upload (Online)"
                : "Camera Upload (Offline)"),
          ),
          body: Column(
            children: [
              Expanded(
                child: CameraPreview(_cameraController!),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.camera_alt),
                      label: Text("Capture Image"),
                      onPressed: captureImage,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.videocam),
                      label: Text("Capture Video"),
                      onPressed: captureVideo,
                    ),
                  ],
                ),
              ),
              // Menampilkan gambar atau video yang diambil
              Expanded(
                child: ListView.builder(
                  itemCount: capturedFiles.length,
                  itemBuilder: (context, index) {
                    final file = capturedFiles[index];
                    if (file.path.endsWith('.mp4')) {
                      // Jika file adalah video
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: VideoPlayerWidget(file: file),
                      );
                    } else {
                      // Jika file adalah gambar
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(file),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;
  VideoPlayerWidget({required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Gunakan VideoPlayerController.file untuk video lokal
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {}); // Update tampilan setelah video diinisialisasi
        _controller.play(); // Mulai memutar video secara otomatis
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_controller.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        else
          Center(child: CircularProgressIndicator()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: () {
                setState(() {
                  _controller.seekTo(Duration.zero);
                  _controller.pause();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
