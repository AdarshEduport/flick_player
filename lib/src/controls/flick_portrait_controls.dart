import 'dart:developer';

import 'package:flick_video_player/src/manager/flick_manager.dart';
import 'package:flick_video_player/src/widgets/action_widgets/flick_seek_video_action.dart';
import 'package:flick_video_player/src/widgets/action_widgets/flick_show_control_action.dart';
import 'package:flick_video_player/src/widgets/extras/speed.dart';
import 'package:flick_video_player/src/widgets/flick_current_position.dart';
import 'package:flick_video_player/src/widgets/flick_full_screen_toggle.dart';
import 'package:flick_video_player/src/widgets/flick_play_toggle.dart';
import 'package:flick_video_player/src/widgets/flick_total_duration.dart';
import 'package:flick_video_player/src/widgets/flick_video_buffer.dart';
import 'package:flick_video_player/src/widgets/flick_video_progress_bar.dart';
import 'package:flick_video_player/src/widgets/helpers/flick_auto_hide_child.dart';
import 'package:flick_video_player/src/widgets/helpers/progress_bar/progress_bar_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Default portrait controls.
class FlickPortraitControls extends StatelessWidget {
  final Function() onQualityChanged;

  const FlickPortraitControls({
    super.key,
    this.iconSize = 20,
    this.fontSize = 12,
    this.progressBarSettings,
    required this.onQualityChanged,
  });

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  /// [FlickProgressBarSettings] settings.
  final FlickProgressBarSettings? progressBarSettings;

  @override
  Widget build(BuildContext context) {
    String trim(String data) {
      data =
          data.replaceAll('androidx.media3.exoplayer.ExoPlaybackException', '');
      if (data.length >= 50) {
        return data.substring(0, 50);
      } else {
        return data;
      }
    }

    final controlManager = Provider.of<FlickControlManager>(context);
    final playerManager = Provider.of<FlickVideoManager>(context);

    return playerManager.errorInVideo
        ? GestureDetector(
            onTap: ()async {


              onQualityChanged();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(trim(
                    playerManager.videoPlayerValue!.errorDescription ?? '')),
                SizedBox(
                  height: 10,
                ),
                Icon(Icons.refresh_rounded)
              ],
            ),
          )
        : Stack(
            children: <Widget>[
              Positioned.fill(
                  child: FlickAutoHideChild(
                      child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.black.withOpacity(.6),
              ))),
              const Positioned.fill(
                child: FlickShowControlsAction(
                  child: FlickSeekVideoAction(
                    child: Center(
                      child: FlickVideoBuffer(
                        bufferingChild: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        child: FlickAutoHideChild(
                          showIfVideoNotInitialized: true,
                          child: FlickPlayToggle(
                            size: 55,
                            color: Colors.white,
                            padding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: FlickAutoHideChild(
                  child: Padding(
                    padding: controlManager.isFullscreen
                        ? EdgeInsets.fromLTRB(16, 0, 16, 45)
                        : EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // FlickPlayToggle(
                            //   size: iconSize,
                            // ),
                            // SizedBox(
                            //   width: iconSize / 2,
                            // ),
                            // FlickSoundToggle(
                            //   size: iconSize,
                            // ),
                            // SizedBox(
                            //   width: iconSize / 2,
                            // ),
                            Row(
                              children: <Widget>[
                                FlickCurrentPosition(
                                  fontSize: fontSize,
                                ),
                                FlickAutoHideChild(
                                  child: Text(
                                    ' / ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fontSize),
                                  ),
                                ),
                                FlickTotalDuration(
                                  fontSize: fontSize,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(),
                            ),

                            SizedBox(
                              width: iconSize / 2,
                            ),
                            FlickFullScreenToggle(
                              size: iconSize,
                            ),
                          ],
                        ),
                        FlickVideoProgressBar(
                          flickProgressBarSettings: progressBarSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 6,
                  right: 0,
                  child: FlickAutoHideChild(
                      child: IconButton(
                          onPressed: () {
                            String? url = FlickVideoManager.masterUrl;

                            List<StreamQuality> qualities = [];
                            List<String> qualityValues = [
                              '',
                              '240p',
                              '360p',
                              '480p',
                              '720p'
                            ];
                            if (url.isNotEmpty && url.endsWith('.m3u8')) {
                              for (int quality = 0; quality < 5; quality++) {
                                if (quality == 0) {
                                  qualities.add(StreamQuality(
                                      qualityValues[quality], url));
                                } else {
                                  qualities.add(StreamQuality(
                                      qualityValues[quality],
                                      url.replaceAll('video.m3u8',
                                          '${qualityValues[quality]}/video.m3u8')));
                                }
                              }
                            }

                            settingsSheet(
                              context: context,
                              currentQuality: -1,
                              qualities:
                                  qualityValues.length == qualities.length
                                      ? qualities
                                      : [],
                              currentSpeed:
                                  FlickVideoManager.currentSpeed.toDouble(),
                              onQualityChanged: () {
                                onQualityChanged();
                              },
                              onPlaybackSpeedChanged: (newSpeed) {
                                controlManager.setPlaybackSpeed(newSpeed);
                                FlickVideoManager.currentSpeed = newSpeed;
                              },
                            );
                          },
                          icon: const Icon(Icons.settings)))),
            ],
          );
  }
}

class StreamQuality {
  StreamQuality(this.qualityLevel, this.url);

  final String qualityLevel;
  final String url;
}
