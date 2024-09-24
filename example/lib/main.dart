// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flick_video_player/flick-video-player.dart';

void main() {
  runApp(
    MaterialApp(
      home: SamplePlayer(),
    ),
  );
}

class SamplePlayer extends StatefulWidget {
  SamplePlayer({Key? key}) : super(key: key);

  @override
  _SamplePlayerState createState() => _SamplePlayerState();
}

class _SamplePlayerState extends State<SamplePlayer> {
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      startAt: Duration(seconds: 90),
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(
          "https://d357lqen3ahf81.cloudfront.net/transcoded/3xs3Q4czfzH/video.m3u8",
        ),
        formatHint: VideoFormat.hls,
      ),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FlickVideoPlayer(
                flickVideoWithControls: FlickVideoWithControls(
                  videoFit: BoxFit.fitHeight,
                  controls: FlickPortraitControls(onQualityChanged: () async {
                    final url = FlickVideoManager.url.isEmpty
                        ? FlickVideoManager.masterUrl
                        : FlickVideoManager.url;

                    final position = await flickManager
                        .flickVideoManager?.videoPlayerController?.position;
                    if ((position ?? Duration()).inSeconds != 0) {
                      FlickVideoManager.lastErrorPosition =
                          position ?? Duration();
                    }
                    ;
          

                    flickManager.handleChangeVideo(
                        VideoPlayerController.networkUrl(Uri.parse(url),
                            formatHint: VideoFormat.hls),
                        startAfter:  FlickVideoManager.lastErrorPosition);
                  }),
                ),
                flickManager: flickManager,
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.seven_k))
        ],
      ),
    );
  }
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// void main() => runApp(const VideoApp());

// /// Stateful widget to fetch and then display video content.
// class VideoApp extends StatefulWidget {
//   const VideoApp();

//   @override
//   _VideoAppState createState() => _VideoAppState();
// }

// class _VideoAppState extends State<VideoApp> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.networkUrl(Uri.parse(
//         'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8'))
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});

//         _controller.addListener(() {
//           log('Speed ---->'+_controller.value.playbackSpeed.toString());
//         });
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Demo',
//       home: Scaffold(
//         body: Center(
//           child: _controller.value.isInitialized
//               ? AspectRatio(
//                   aspectRatio: _controller.value.aspectRatio,
//                   child: VideoPlayer(_controller),
//                 )
//               : Container(),
//         ),
//         floatingActionButton: Row(
//           children: [
//             FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   _controller.value.isPlaying
//                       ? _controller.pause()
//                       : _controller.play();
//                 });
//               },
//               child: Icon(
//                 _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//               ),
//             ),
//             FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   _controller.setPlaybackSpeed(.1);
//                 });
//               },
//               child: Icon(
//                 _controller.value.isPlaying
//                     ? Icons.safety_check
//                     : Icons.play_arrow,
//               ),
//             ),
//             FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   _controller.seekTo(Duration(seconds: 30));
//                 });
//               },
//               child: Icon(
//                 _controller.value.isPlaying ? Icons.seven_k : Icons.play_arrow,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
