import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final video = RTCVideoRenderer();
  ByteBuffer? capturedImage;

  @override
  void initState() {
    video.initialize().then((_) {
      final mediaConstraints = {
        "audio": false,
        "video": {
          "width": 480,
          "height": 360,
        }
      };

      navigator.mediaDevices.getUserMedia(mediaConstraints).then((stream) {
        setState(() {
          video.srcObject = stream;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 300,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: RTCVideoView(
                    video,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),
            capturedImage != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 300,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Image.memory(capturedImage!.asUint8List()),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () async {
                  if (video.srcObject == null) return;
                  if (video.srcObject!.getVideoTracks().isEmpty) return;

                  final videoTrack = video.srcObject!.getVideoTracks().first;

                  while (true) {
                    capturedImage = await videoTrack.captureFrame();
                    setState(() {});
                  }
                },
                child: const Text('Start Capture Frame'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
