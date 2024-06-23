

import 'package:flick_video_player/src/manager/flick_manager.dart';
import 'package:flick_video_player/src/widgets/action_widgets/flick_seek_video_action.dart';
import 'package:flick_video_player/src/widgets/action_widgets/flick_show_control_action.dart';
import 'package:flick_video_player/src/widgets/flick_current_position.dart';
import 'package:flick_video_player/src/widgets/flick_full_screen_toggle.dart';
import 'package:flick_video_player/src/widgets/flick_play_toggle.dart';
import 'package:flick_video_player/src/widgets/flick_total_duration.dart';
import 'package:flick_video_player/src/widgets/flick_video_progress_bar.dart';
import 'package:flick_video_player/src/widgets/helpers/flick_auto_hide_child.dart';
import 'package:flick_video_player/src/widgets/helpers/progress_bar/progress_bar_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CustomOrientationControls extends StatelessWidget {
  const CustomOrientationControls({
    Key? key,
    this.iconSize = 20,
    this.fontSize = 12,
  }) : super(key: key);
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  flickVideoManager.errorInVideo?Center(child: Text('somothing went wrong ${flickVideoManager.videoPlayerValue?.errorDescription}')):
                  flickVideoManager.isBuffering
                      ? Center(child: CircularProgressIndicator())
                      : Center(child: FlickPlayToggle()),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickFullScreenToggle(
                        size: iconSize,
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 5,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: Colors.red,
                      handleColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
