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
import 'package:http/http.dart' as http;

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
    bool _isPopupVisible = false;

    return playerManager.errorInVideo
        ? GestureDetector(
            onTap: () async {
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
                      onPressed: () async {
                        if (_isPopupVisible)
                          return; // Prevent opening another popup if one is already visible
                        _isPopupVisible = true; // Mark popup as visible

                        try {
                          String? url = FlickVideoManager.masterUrl;

                          settingsSheet(
                            context: context,
                            currentQuality: -1,
                            qualities: await fetchQualities(url),
                            currentSpeed:
                                FlickVideoManager.currentSpeed.toDouble(),
                            onQualityChanged: () {
                              onQualityChanged();
                              Navigator.pop(context);
                            },
                            onPlaybackSpeedChanged: (newSpeed) {
                              controlManager.setPlaybackSpeed(newSpeed);
                              FlickVideoManager.currentSpeed = newSpeed;
                              Navigator.pop(context);
                            },
                          );
                        } finally {
                          // Reset the popup visibility flag when the popup is dismissed
                          _isPopupVisible = false;
                        }
                      },
                      icon: const Icon(Icons.settings),
                    ),
                  )),
            ],
          );
  }
}

class StreamQuality {
  StreamQuality(this.qualityLevel, this.url);

  final String qualityLevel;
  final String url;
}

Future<List<StreamQuality>> fetchQualities(String mainM3u8Url) async {
  try {
    final response = await http.get(Uri.parse(mainM3u8Url));
    final lines = response.body.toString().split('\n');
    final qualities = <StreamQuality>[StreamQuality('Auto', mainM3u8Url)];

    final uri = Uri.parse(mainM3u8Url);
    final baseUrl =
        '${uri.scheme}://${uri.host}${uri.path.substring(0, uri.path.lastIndexOf('/'))}';

    for (var i = 0; i < lines.length - 1; i++) {
      final currentLine = lines[i].trim();
      final nextLine = lines[i + 1].trim();

      if (currentLine.startsWith('#EXT-X-STREAM-INF')) {
        if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
          final fullUrl = nextLine.startsWith('http')
              ? nextLine
              : '$baseUrl/${nextLine.startsWith('/') ? nextLine.substring(1) : nextLine}';

          // Extract quality from the path
          final pathParts = fullUrl.split('/');
          final qualityPart = pathParts.firstWhere(
            (part) =>
                part.contains('p') &&
                (part.endsWith('p') || part.contains('p_')),
            orElse: () => '',
          );

          if (qualityPart.isNotEmpty) {
            final qualityString = qualityPart.contains('_')
                ? qualityPart.split('_').first
                : qualityPart;

            qualities.add(StreamQuality(qualityString, fullUrl));
            log('Quality: $qualityString, URL: $fullUrl');
          }
        }
      }
    }

    return qualities;
  } catch (e) {
    rethrow;
  }
}
