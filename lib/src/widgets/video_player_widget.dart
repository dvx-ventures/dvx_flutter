import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dvx_flutter/src/file_system/server_file.dart';
import 'package:dvx_flutter/src/utils/utils.dart';
import 'package:dvx_flutter/src/widgets/preview_dialog.dart';

import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';

Future<void> showVideoDialog(BuildContext context,
    {ServerFile? serverFile, String? hostUrl}) {
  return showPreviewDialog(
    backgroundColor: Theme.of(context).primaryColor,
    context: context,
    children: [
      Flexible(
        child: VideoPlayerWidget(
          serverFile: serverFile,
          hostUrl: hostUrl,
          onClose: () {
            Navigator.pop(context);
          },
        ),
      ),
    ],
  );
}

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.serverFile,
    required this.hostUrl,
    this.onClose,
  });

  final ServerFile? serverFile;
  final String? hostUrl;
  final void Function()? onClose;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.serverFile != null) {
      _controller = VideoPlayerController.file(File(widget.serverFile!.path!));
    } else if (widget.hostUrl != null) {
      _controller = VideoPlayerController.network(widget.hostUrl!);
    } else {
      print('you have to set a serverFile or hostUrl in video player.');
    }

    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(true);
    _controller!.initialize().then((_) => setState(() {}));

    // only autoplay on files, not network
    if (widget.serverFile != null) {
      _controller!.play();
    }
  }

  @override
  void dispose() {
    _controller!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_controller!),
            _PlayPauseOverlay(
              controller: _controller,
              onClose: widget.onClose,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(_controller!, allowScrubbing: true),
            ),
          ],
        ),
      );
    }

    return NothingWidget();
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({
    Key? key,
    this.controller,
    this.onClose,
  }) : super(key: key);

  final VideoPlayerController? controller;
  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    final bool hasVideoFile = controller!.dataSourceType == DataSourceType.file;

    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller!.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white54,
                      size: 80.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller!.value.isPlaying
                ? controller!.pause()
                : controller!.play();
          },
        ),
        Positioned(
          bottom: 0,
          top: 0,
          right: 10,
          child: controller!.value.isPlaying || !hasVideoFile
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      OpenFile.open(Uri.parse(controller!.dataSource).path);
                    },
                    child: Icon(
                      Utils.isIOS ? Ionicons.ios_open : Ionicons.md_open,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                ),
        ),
        Visibility(
          visible: onClose != null,
          child: Positioned(
            bottom: 0,
            top: 0,
            left: 10,
            child: controller!.value.isPlaying
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        onClose!();
                      },
                      child: const Icon(
                        Icons.clear,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
