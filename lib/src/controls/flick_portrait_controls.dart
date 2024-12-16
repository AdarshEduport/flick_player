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
    final response = await http.get(Uri.parse(mainM3u8Url)).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode != 200) {
      throw Exception('Failed to load m3u8: ${response.statusCode}');
    }

    final lines = response.body.toString().split('\n');
    final qualities = <StreamQuality>[StreamQuality('Auto', mainM3u8Url)];

    final uri = Uri.parse(mainM3u8Url);
    final baseUrl = _getBaseUrl(uri);

    for (var i = 0; i < lines.length - 1; i++) {
      final currentLine = lines[i].trim();
      final nextLine = lines[i + 1].trim();

      if (currentLine.startsWith('#EXT-X-STREAM-INF')) {
        if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
          final streamUrl = _buildFullUrl(nextLine, baseUrl);
          final quality = _parseQualityLevel(currentLine, streamUrl);

          if (quality != null) {
            qualities.add(quality);
            log('Found quality: ${quality.qualityLevel}, URL: ${quality.url}');
          }
        }
      }
    }

    // Sort qualities (excluding Auto which should stay first)
    if (qualities.length > 1) {
      final autoQuality = qualities.removeAt(0);
      qualities.sort((a, b) {
        final heightA =
            int.tryParse(a.qualityLevel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final heightB =
            int.tryParse(b.qualityLevel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return heightB.compareTo(heightA);
      });
      qualities.insert(0, autoQuality);
    }

    return qualities;
  } catch (e, stackTrace) {
    log('Error fetching qualities', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Parses quality level from stream information
StreamQuality? _parseQualityLevel(String streamInfo, String streamUrl) {
  final attributes = _parseStreamAttributes(streamInfo);
  String? qualityLevel;

  // Try to get quality from RESOLUTION
  if (attributes.containsKey('RESOLUTION')) {
    final resolution = attributes['RESOLUTION']!;
    if (resolution.contains('x')) {
      final height = int.tryParse(resolution.split('x')[1]);
      if (height != null) {
        qualityLevel = '${height}p';
      }
    }
  }

  // Try to get quality from URL path
  if (qualityLevel == null) {
    final pathParts = streamUrl.split('/');
    for (final part in pathParts) {
      if (part.contains('p') && (part.endsWith('p') || part.contains('p_'))) {
        qualityLevel = part.contains('_') ? part.split('_').first : part;
        break;
      }
    }
  }

  // Use bandwidth as fallback
  if (qualityLevel == null && attributes.containsKey('BANDWIDTH')) {
    final bandwidth = int.tryParse(attributes['BANDWIDTH']!);
    if (bandwidth != null) {
      final mbps = (bandwidth / 1000000).toStringAsFixed(1);
      qualityLevel = '${mbps}MB/s';
    }
  }

  return qualityLevel != null ? StreamQuality(qualityLevel, streamUrl) : null;
}

/// Parses stream attributes from the STREAM-INF tag
Map<String, String> _parseStreamAttributes(String line) {
  final attributes = <String, String>{};
  final pattern = RegExp(r'([A-Z-]+)=(?:"([^"]*)"|([^,]*))');
  final matches = pattern.allMatches(line);

  for (final match in matches) {
    final key = match.group(1);
    final value = match.group(2) ?? match.group(3);
    if (key != null && value != null) {
      attributes[key] = value;
    }
  }

  return attributes;
}

/// Builds full URL from a potentially relative path
String _buildFullUrl(String path, String baseUrl) {
  if (path.startsWith('http')) {
    return path;
  }
  return '$baseUrl/${path.startsWith('/') ? path.substring(1) : path}';
}

/// Gets base URL from main M3U8 URL
String _getBaseUrl(Uri uri) {
  final path = uri.path;
  final lastSlash = path.lastIndexOf('/');
  final basePath = lastSlash != -1 ? path.substring(0, lastSlash) : path;
  return '${uri.scheme}://${uri.host}$basePath';
}
