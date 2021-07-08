import 'dart:io';

import 'package:dvx_flutter/src/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dvx_flutter/src/file_system/server_file.dart';
import 'package:dvx_flutter/src/utils/utils.dart';
import 'package:dvx_flutter/src/widgets/preview_dialog.dart';

import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';

Future<void> showVideoDialog(
  BuildContext context, {
  ServerFile? serverFile,
  String? hostUrl,
  bool showFileOpener = true,
}) {
  return showPreviewDialog(
    backgroundColor: Theme.of(context).primaryColor,
    context: context,
    children: [
      Flexible(
        child: VideoPlayerWidget(
          serverFile: serverFile,
          hostUrl: hostUrl,
          showFileOpener: showFileOpener,
          autoplay: true,
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
    this.showFileOpener = true,
    this.openDialogOnTap = false,
    this.autoplay = false,
    this.onClose,
  });

  final ServerFile? serverFile;
  final String? hostUrl;
  final void Function()? onClose;
  final bool openDialogOnTap;
  final bool showFileOpener;
  final bool autoplay;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController? _controller;

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

    if (_controller != null) {
      _controller!.addListener(() {
        setState(() {});
      });
      _controller!.setLooping(true);
      _controller!.initialize().then((_) => setState(() {}));

      if (widget.autoplay) {
        _controller!.play();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_controller!),
            _PlayPauseOverlay(
              controller: _controller!,
              onClose: widget.onClose,
              showFileOpener: widget.showFileOpener,
              onTap: widget.openDialogOnTap
                  ? () {
                      showVideoDialog(
                        context,
                        hostUrl: widget.hostUrl,
                        serverFile: widget.serverFile,
                        showFileOpener: widget.showFileOpener,
                      );
                    }
                  : null,
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

    return LoadingWidget();
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({
    required this.controller,
    this.onClose,
    this.showFileOpener = true,
    this.onTap,
  });

  final VideoPlayerController controller;
  final void Function()? onClose;
  final void Function()? onTap;
  final bool showFileOpener;

  @override
  Widget build(BuildContext context) {
    final bool hasVideoFile = controller.dataSourceType == DataSourceType.file;

    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
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
            if (onTap != null) {
              onTap!();
            } else {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            }
          },
        ),
        Visibility(
          visible:
              showFileOpener && !controller.value.isPlaying && hasVideoFile,
          child: Positioned(
            bottom: 0,
            top: 0,
            left: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  OpenFile.open(Uri.parse(controller.dataSource).path);
                },
                child: Icon(
                  Utils.isIOS ? Ionicons.ios_open : Ionicons.md_open,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: onClose != null,
          child: Positioned(
            top: 10,
            right: 10,
            child: controller.value.isPlaying
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
