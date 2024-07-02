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
  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      startAt: Duration(seconds: 90),
      videoPlayerController: VideoPlayerController.networkUrl(
       Uri.parse("https://d357lqen3ahf81.cloudfront.net/transcoded/9ud5sfEqgec/video.m3u8") ,
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
              aspectRatio: 16/9,
              child: FlickVideoPlayer(
                flickVideoWithControls: FlickVideoWithControls(
                  videoFit: BoxFit.fitHeight,
                  controls: FlickPortraitControls(onQualityChanged: () {
                    flickManager.handleChangeVideo(VideoPlayerController.networkUrl(
                        Uri.parse(FlickVideoManager.url)));
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
