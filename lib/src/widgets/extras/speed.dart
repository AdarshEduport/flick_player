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
      width: double.maxFinite,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                      visible:
                          playBackSpeeds.keys.toList()[index] == currentSpeed,
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
    required String masterUrl}) 
     {
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
            visible: masterUrl.startsWith('http'),
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
                      masterUrl: masterUrl,
                      currentQuality: currentQuality,
                      onQualityChanged: () async {
                        // await player.setRate(newSpeed);
                        onQualityChanged();
                      },
                 
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
  final String masterUrl;
  final Function() onQualityChanged;
  const QualitiesWidget(
      {super.key,
      required this.onQualityChanged,
      required this.currentQuality,
      required this.masterUrl});

  @override
  State<QualitiesWidget> createState() => _QualitiesWidgetState();
}

bool isLoading = true;
List<StreamQuality> qualities = [];

class _QualitiesWidgetState extends State<QualitiesWidget> {
  @override
  void initState() {
    // TODO: implement initState
    _fetchQualities();
    super.initState();
  }

  _fetchQualities() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final newQualities = await StreamQuality.fetchQualities(widget.masterUrl);
      qualities.clear();
      qualities.addAll(newQualities);
      isLoading = false;
      setState(() {});
    });
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
      width: double.maxFinite,
      height: isLoading?250:null,
      child:isLoading ? Center(child: CircularProgressIndicator(),):ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(
          height: 8,
        ),
        shrinkWrap: true,
        itemCount: qualities.length, //media urls + auto
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            setState(() {
              FlickVideoManager.url = qualities[index].url;

              FlickVideoManager.currentQuality = index;
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
                Text(qualities[index].qualityLevel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
