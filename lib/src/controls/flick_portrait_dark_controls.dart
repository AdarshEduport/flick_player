// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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

/// Default portrait controls.
class FlickPortraitControls extends StatelessWidget {
  final Function() onQualityChanged;
  final Function(double speed) onSpeedChanged;
  final void Function(String errorDescription)? onErrorRefresh;
  const FlickPortraitControls({
    Key? key,
    required this.onQualityChanged,
    this.onErrorRefresh,
    this.iconSize = 20,
    this.fontSize = 12,
    this.progressBarSettings,
     required this.onSpeedChanged,
  }) : super(key: key);

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
              if (onErrorRefresh != null) {
                onErrorRefresh!(
                    playerManager.videoPlayerValue!.errorDescription ?? '');
              }

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
                           masterUrl: url,
                            currentSpeed:
                                FlickVideoManager.currentSpeed.toDouble(),
                            onQualityChanged: () {
                              onQualityChanged();
                            
                                 Navigator.pop(context);
                             
                            },
                            onPlaybackSpeedChanged: (newSpeed) {
                              onSpeedChanged(newSpeed);
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

  static Future<List<StreamQuality>> fetchQualities(String mainM3u8Url) async {
    final qualities = <StreamQuality>[];
    try {
      int getPixels(String resolution) {
      return int.parse(resolution.replaceAll('p', ''));
    }
      final response = await http.get(Uri.parse(mainM3u8Url));

      final playList = await HlsPlaylistParser.create()
          .parseString(Uri.parse(mainM3u8Url), response.body.toString());
      playList as HlsMasterPlaylist;

      for (final variant in playList.variants) {
        final height = variant.format.height ?? 0;
        final width = variant.format.width ?? 0;
        final quality = height>width?width:height;
        if(quality!=0){
           qualities.add(StreamQuality('$quality'+'p', variant.url.toString()));
        }
        
      }

        qualities.sort((a, b) =>getPixels(a.qualityLevel).compareTo(getPixels(b.qualityLevel)));
        qualities.insert(0, StreamQuality('Auto', mainM3u8Url));
      return qualities;
    } catch (e) {
      qualities.insert(0, StreamQuality('Auto', mainM3u8Url));
      return qualities;

    }
  }
}



// Future<List<StreamQuality>> fetchQualities(String mainM3u8Url) async {
//   try {
//     final response = await http.get(Uri.parse(mainM3u8Url));
//     final lines = response.body.toString().split('\n');
//     final qualities = <StreamQuality>[StreamQuality('Auto', mainM3u8Url)];

//     final uri = Uri.parse(mainM3u8Url);
//     final baseUrl =
//         '${uri.scheme}://${uri.host}${uri.path.substring(0, uri.path.lastIndexOf('/'))}';

//     for (var i = 0; i < lines.length - 1; i++) {
//       final currentLine = lines[i].trim();
//       final nextLine = lines[i + 1].trim();

//       if (currentLine.startsWith('#EXT-X-STREAM-INF')) {
//         if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
//           final fullUrl = nextLine.startsWith('http')
//               ? nextLine
//               : '$baseUrl/${nextLine.startsWith('/') ? nextLine.substring(1) : nextLine}';

//           // Extract resolution from STREAM-INF line
//           final resolutionMatch =
//               RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(currentLine);
//           if (resolutionMatch != null) {
//             final height = resolutionMatch.group(1);
//             if (height != null) {
//               final qualityString = '${height}p';
//               qualities.add(StreamQuality(qualityString, fullUrl));
//               log('Quality: $qualityString, URL: $fullUrl');
//               continue;
//             }
//           }

//           // Fallback: Extract quality from the path if RESOLUTION tag is not present
//           final pathParts = fullUrl.split('/');
//           for (final part in pathParts) {
//             final qualityMatch = RegExp(r'(\d+)p').firstMatch(part);
//             if (qualityMatch != null) {
//               final qualityString = qualityMatch.group(0);
//               if (qualityString != null) {
//                 qualities.add(StreamQuality(qualityString, fullUrl));
//                 log('Quality: $qualityString, URL: $fullUrl');
//                 break;
//               }
//             }
//           }
//         }
//       }
//     }

//     // Sort qualities in descending order (highest quality first)
//     qualities.sort((a, b) {
//       if (a.qualityLevel == 'Auto') return -1;
//       if (b.qualityLevel == 'Auto') return 1;
//       final aHeight = int.tryParse(a.qualityLevel.replaceAll('p', '')) ?? 0;
//       final bHeight = int.tryParse(b.qualityLevel.replaceAll('p', '')) ?? 0;
//       return bHeight.compareTo(aHeight);
//     });

//     return qualities;
//   } catch (e) {
//     rethrow;
//   }
// }
