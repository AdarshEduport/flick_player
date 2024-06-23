import 'package:flick_video_player/src/controls/flick_portrait_controls.dart';
import 'package:flick_video_player/src/manager/flick_manager.dart';
import 'package:flutter/material.dart';



class PlayBackSpeedWidget extends StatefulWidget {
  final double? currentSpeed;
  final Function(double newSpeed) onPlaybackSpeedChanged;
  const PlayBackSpeedWidget({
    super.key,
    required this.onPlaybackSpeedChanged,
    this.currentSpeed,
  });

  @override
  State<PlayBackSpeedWidget> createState() => _PlayBackSpeedWidgetState();
}

class _PlayBackSpeedWidgetState extends State<PlayBackSpeedWidget> {
  Map<double, String> playBackSpeeds = {
    0.25: '0.25x',
    .5: '0.5x',
    .75: '0.75x',
    1: 'Normal',
    1.25: '1.25x',
    1.5: '1.5x',
    1.75: '1.75x',
    2: '2x'
  };
  double currentSpeed = 1;

  @override
  void initState() {
    currentSpeed = widget.currentSpeed ?? 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      margin: EdgeInsets.only(
          bottom: 10 + MediaQuery.of(context).padding.bottom,
          left: 16,
          right: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: double.maxFinite,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
          height: 8,
        ),
        shrinkWrap: true,
        itemCount: playBackSpeeds.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            setState(() {
              currentSpeed = playBackSpeeds.keys.toList()[index];
              widget.onPlaybackSpeedChanged(currentSpeed);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Visibility(
                  visible: playBackSpeeds.keys.toList()[index] == currentSpeed,
                  replacement: const SizedBox(
                    width: 28,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(playBackSpeeds.values.toList()[index]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void settingsSheet(
    {required BuildContext context,
    required int currentQuality,
    required double currentSpeed,
    required Function() onQualityChanged,
    required dynamic Function(double) onPlaybackSpeedChanged,
    required List<StreamQuality> qualities}) {
  showModalBottomSheet(
    useSafeArea: true,
    
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      margin: EdgeInsets.only(
          bottom: 10 + MediaQuery.of(context).padding.bottom,
          left: 10,
          right: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: qualities.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: VideoSettingsTile(
                icon: const Icon(
                  Icons.tune,
                  color: Colors.black,
                ),
                title: 'Quality',
                onTap: () {
                  showModalBottomSheet(
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => QualitiesWidget(
                      currentQuality: currentQuality,
                      onQualityChanged: () async {
                        // await player.setRate(newSpeed);

                        onQualityChanged();
                      },
                      qualities: qualities,
                    ),
                  );
                },
              ),
            ),
          ),
          VideoSettingsTile(
            icon: const Icon(
              Icons.slow_motion_video,
              color: Colors.black,
            ),
            title: 'Playback Speed',
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => PlayBackSpeedWidget(
                  currentSpeed: currentSpeed,
                  onPlaybackSpeedChanged: (double newSpeed) async {
                    onPlaybackSpeedChanged(newSpeed);
                  },
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class VideoSettingsTile extends StatelessWidget {
  final void Function() onTap;
  final String title;
  final Icon icon;
  const VideoSettingsTile({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();

        onTap();
      },
      child: Row(
        children: [
          icon,
          const SizedBox(
            width: 8,
          ),
          Text(title),
        ],
      ),
    );
  }
}

class QualitiesWidget extends StatefulWidget {
  final int currentQuality;
  final List<StreamQuality> qualities;
  final Function() onQualityChanged;
  const QualitiesWidget(
      {super.key,
      required this.onQualityChanged,
      required this.currentQuality,
      required this.qualities});

  @override
  State<QualitiesWidget> createState() => _QualitiesWidgetState();
}

class _QualitiesWidgetState extends State<QualitiesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      margin: EdgeInsets.only(
          bottom: 10 + MediaQuery.of(context).padding.bottom,
          left: 16,
          right: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: double.maxFinite,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
          height: 8,
        ),
        shrinkWrap: true,
        itemCount: widget.qualities.length, //media urls + auto
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            setState(() {
              FlickVideoManager.url = widget.qualities[index].url;

              FlickVideoManager.currentQuality = index ;
              widget.onQualityChanged();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Visibility(
                  visible: index == FlickVideoManager.currentQuality,
                  replacement: const SizedBox(
                    width: 28,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(index == 0 ? 'Auto' : '${widget.qualities[index].qualityLevel}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
