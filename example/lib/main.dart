// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

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
  final url='https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8';
  final url1 ='https://d357lqen3ahf81.cloudfront.net/transcoded/7ZgAq4yZ8Cz/video.m3u8';
  final url2 ='https://d357lqen3ahf81.cloudfront.net/transcoded/6FNnH2Mcznp/video.m3u8';
  final url3 ='https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8';
  final url4 ="https://assets-dev.eduport.app/hls/19fc6ea4-e7ff-47e1-b210-18ea8ac61e15/master.m3u8";

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      startAt: Duration(seconds: 400),
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(
          url1,
        ),
        //https://d357lqen3ahf81.cloudfront.net/transcoded/BYQBKK3tKhH/video.m3u8 (240p_h264/video.m3u8)
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
                  controls: FlickPortraitControls(
                      progressBarSettings: FlickProgressBarSettings(
                          handleColor: Colors.red,
                          handleRadius: 8.5,
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 4)),
                      onQualityChanged: () async {
                        final url = FlickVideoManager.url.isEmpty
                            ? FlickVideoManager.masterUrl
                            : FlickVideoManager.url;

                        final position = await flickManager
                            .flickVideoManager?.videoPlayerController?.position;
                        if ((position ?? Duration()).inSeconds != 0) {
                          FlickVideoManager.lastErrorPosition =
                              position ?? Duration();
                        }

                        flickManager.handleChangeVideo(
                            VideoPlayerController.networkUrl(Uri.parse(url),
                                formatHint: VideoFormat.hls),
                            startAfter: FlickVideoManager.lastErrorPosition);
                      }),
                ),
                flickManager: flickManager,
              ),
            ),
          ),
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
