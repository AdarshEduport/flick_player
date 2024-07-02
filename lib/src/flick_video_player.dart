import 'package:flick_video_player/src/controls/flick_video_with_controls.dart';
import 'package:flick_video_player/src/manager/flick_manager.dart';
import 'package:flick_video_player/src/utils/flick_manager_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

class FlickVideoPlayer extends StatefulWidget {
  const FlickVideoPlayer({
    super.key,
    required this.flickManager,
    this.flickVideoWithControls = const FlickVideoWithControls(
        // controls:  FlickPortraitControls(onQualityChanged: () {  },),
        ),
    this.flickVideoWithControlsFullscreen,
    this.systemUIOverlay = SystemUiOverlay.values,
    this.systemUIOverlayFullscreen = const [],
    this.preferredDeviceOrientation = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    this.preferredDeviceOrientationFullscreen = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ],
    this.wakelockEnabled = true,
    this.wakelockEnabledFullscreen = true,
  });

  final FlickManager flickManager;

  /// Widget to render video and controls.
  final Widget flickVideoWithControls;

  /// Widget to render video and controls in full-screen.
  final Widget? flickVideoWithControlsFullscreen;

  /// SystemUIOverlay to show.
  ///
  /// SystemUIOverlay is changed in init.
  final List<SystemUiOverlay> systemUIOverlay;

  /// SystemUIOverlay to show in full-screen.
  final List<SystemUiOverlay> systemUIOverlayFullscreen;

  /// Preferred device orientation.
  ///
  /// Use [preferredDeviceOrientationFullscreen] to manage orientation for full-screen.
  final List<DeviceOrientation> preferredDeviceOrientation;

  /// Preferred device orientation in full-screen.
  final List<DeviceOrientation> preferredDeviceOrientationFullscreen;

  /// Prevents the screen from turning off automatically.
  ///
  /// Use [wakeLockEnabledFullscreen] to manage wakelock for full-screen.
  final bool wakelockEnabled;

  /// Prevents the screen from turning off automatically in full-screen.
  final bool wakelockEnabledFullscreen;

  /// Callback called on keyDown for web, used for keyboard shortcuts.

  @override
  _FlickVideoPlayerState createState() => _FlickVideoPlayerState();
}

class _FlickVideoPlayerState extends State<FlickVideoPlayer>
    with WidgetsBindingObserver {
  late FlickManager flickManager;
  bool _isFullscreen = false;
  TransitionRoute<void>? _route;
  double? _videoWidth;
  double? _videoHeight;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    flickManager = widget.flickManager;
    flickManager.registerContext(context);
    flickManager.flickControlManager!.addListener(listener);
    _setSystemUIOverlays();
    _setPreferredOrientation();

    if (widget.wakelockEnabled) {
      WakelockPlus.enable();
    }

    super.initState();
  }

  @override
  void dispose() {
    flickManager.flickControlManager!.removeListener(listener);
    if (widget.wakelockEnabled) {
      WakelockPlus.disable();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_route != null) {
      flickManager.flickControlManager!.exitFullscreen();
      return true;
    }
    return false;
  }

  // Listener on [FlickControlManager],
  // Pushes the full-screen if [FlickControlManager] is changed to full-screen.
  void listener() async {
    if (flickManager.flickControlManager!.isFullscreen && !_isFullscreen) {
      _switchToFullscreen();
    } else if (_isFullscreen &&
        !flickManager.flickControlManager!.isFullscreen) {
      _exitFullscreen();
    }
  }

  _switchToFullscreen() async {
    if (widget.wakelockEnabledFullscreen) {
      /// Disable previous wakelock setting.
      WakelockPlus.disable();
      WakelockPlus.enable();
    }

    _isFullscreen = true;
    _setPreferredOrientation();
    _setSystemUIOverlays();

    _route = PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;
        return PopScope(
          canPop: _route == null,
          onPopInvoked: (didPop) async {
            if (!didPop) flickManager.flickControlManager!.exitFullscreen();
          },
          child: AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return  Scaffold(
                body: FlickManagerBuilder(
                    flickManager: flickManager,
                    child: widget.flickVideoWithControlsFullscreen ??
                        widget.flickVideoWithControls,
                  ),
              );
              
            },
          ),
        );
      },
    );

    // _overlayEntry = OverlayEntry(builder: (context) {
    //   return Scaffold(
    //     body: FlickManagerBuilder(
    //       flickManager: flickManager,
    //       child: widget.flickVideoWithControlsFullscreen ??
    //           widget.flickVideoWithControls,
    //     ),
    //   );
    // });

    // Overlay.of(context).insert(_overlayEntry!);
    await Navigator.of(context).push(_route!);
  }

  _exitFullscreen() {
    if (widget.wakelockEnabled) {
      /// Disable previous wakelock setting.
      WakelockPlus.disable();
      WakelockPlus.enable();
    }

    _isFullscreen = false;

    _route = null;

    _setPreferredOrientation();
    _setSystemUIOverlays();
    Navigator.of(context).pop();
  }

  _setPreferredOrientation() {
    // when aspect ratio is less than 1 , video will be played in portrait mode and orientation will not be changed.
    var aspectRatio =
        widget.flickManager.flickVideoManager!.videoPlayerValue!.aspectRatio;
    if (_isFullscreen && aspectRatio >= 1) {
      SystemChrome.setPreferredOrientations(
          widget.preferredDeviceOrientationFullscreen);
    } else {
      SystemChrome.setPreferredOrientations(widget.preferredDeviceOrientation);
    }
  }

  _setSystemUIOverlays() {
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: widget.systemUIOverlayFullscreen);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: widget.systemUIOverlay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _videoWidth,
      height: _videoHeight,
      child: FlickManagerBuilder(
        flickManager: flickManager,
        child: widget.flickVideoWithControls,
      ),
    );
  }
}
