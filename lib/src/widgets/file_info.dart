import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dvx_flutter/src/file_system/server_file.dart';
import 'package:dvx_flutter/src/widgets/checkerboard_container.dart';
import 'package:dvx_flutter/src/widgets/video_player_widget.dart';
import 'package:intl/intl.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:dvx_flutter/src/extensions/num_ext.dart';

class FileInfo extends StatefulWidget {
  const FileInfo(
    this.map,
    this.serverFile,
    this.hostUrl,
  );

  final Map<String, dynamic> map;
  final ServerFile serverFile;
  final String? hostUrl;

  @override
  _FileInfoState createState() => _FileInfoState();
}

class _FileInfoState extends State<FileInfo> {
  Uint8List? _pdfImageData;

  @override
  void initState() {
    super.initState();

    _loadPDFImage();
  }

  @override
  void didUpdateWidget(FileInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    _loadPDFImage();
  }

  Future<void> _loadPDFImage() async {
    if (!_onWeb) {
      if (widget.serverFile.isPdf) {
        // open pdf, make image of first page
        final document = await PdfDocument.openFile(widget.serverFile.path!);
        final page = await document.getPage(1);
        final PdfPageImage? pageImage =
            await page.render(width: page.width, height: page.height);

        setState(() {
          _pdfImageData = pageImage!.bytes;
        });
      }
    }
  }

  List<Widget> _buildPreview(BuildContext context) {
    final List<Widget> list = [];
    Widget child;

    if (widget.serverFile.isFile) {
      // svgs crash Image
      if ((widget.serverFile.isImageDrawable || widget.serverFile.isPdf) &&
          !widget.serverFile.isSvg) {
        if (_onWeb) {
          String url = '${widget.hostUrl}?preview=${widget.serverFile.path}';
          url = Uri.encodeFull(url);
          child = Image.network(url);
        } else {
          if (_pdfImageData != null) {
            child = Image.memory(_pdfImageData!);
          } else {
            child = Image.file(File(widget.serverFile.path!));
          }
        }

        list.add(
          Align(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CheckerboardContainer(
                color: widget.serverFile.isPdf ? Colors.white : null,
                constraints:
                    const BoxConstraints(maxHeight: 1000, maxWidth: 1000),
                child: child,
              ),
            ),
          ),
        );
      } else if (widget.serverFile.isVideo) {
        if (_onWeb) {
          String url = '${widget.hostUrl}?preview=${widget.serverFile.path}';
          url = Uri.encodeFull(url);

          list.add(VideoPlayerWidget(serverFile: null, hostUrl: url));
        } else {
          list.add(
              VideoPlayerWidget(serverFile: widget.serverFile, hostUrl: null));
        }
      }
    }

    return list;
  }

  List<Widget> _buildList(BuildContext context) {
    final List<Widget> list = [];

    list.addAll(widget.map.keys.map((key) {
      String valueString = widget.map[key].toString();

      if (key == 'size' ||
          key == 'free space' ||
          key == 'used space' ||
          key == 'total space') {
        final int size = widget.map[key] as int;
        valueString = size.formatBytes(2);
      }

      if (key == 'changed') {
        valueString =
            DateFormat.yMMMEd().add_jms().format(DateTime.parse(valueString));
      }
      if (key == 'modified') {
        valueString =
            DateFormat.yMMMEd().add_jms().format(DateTime.parse(valueString));
      }
      if (key == 'accessed') {
        valueString =
            DateFormat.yMMMEd().add_jms().format(DateTime.parse(valueString));
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '$key:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(valueString),
            ),
          ],
        ),
      );
    }).toList());

    return list;
  }

  bool get _onWeb {
    return widget.hostUrl != null;
  }

  List<Widget> _contents(BuildContext context) {
    final List<Widget> widgets = _buildList(context);

    widgets.addAll(_buildPreview(context));

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const Text(
            'File Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          ..._contents(context),
        ],
      ),
    );
  }
}
