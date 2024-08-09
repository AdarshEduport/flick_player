import 'package:flick_video_player/src/manager/flick_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Returns a text widget with total duration of the video.
class FlickTotalDuration extends StatelessWidget {
  const FlickTotalDuration({
    Key? key,
    this.fontSize,
    this.color,
  }) : super(key: key);

  final double? fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {

    String formatDuration(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;
  int seconds = duration.inSeconds % 60;

  // Format with leading zeros if necessary
  String formattedHours = hours.toString().padLeft(2, '0');
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');

   String formatedTime="";
   if(hours!=0)formatedTime = "$formattedHours:";

  return '$formatedTime$formattedMinutes:$formattedSeconds';
}
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    Duration? duration = videoManager.videoPlayerValue?.duration;



    String textDuration =
        duration != null ? formatDuration(duration) : '0:00';

    return Text(
      textDuration,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
