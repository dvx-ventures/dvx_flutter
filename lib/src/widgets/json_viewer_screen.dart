import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dvx_flutter/src/utils/string_utils.dart';
import 'package:dvx_flutter/src/utils/utils.dart';
import 'package:dvx_flutter/src/widgets/json_widget.dart';

class JsonViewerScreen extends StatelessWidget {
  const JsonViewerScreen({
    required this.map,
    required this.title,
    this.onDelete,
  });

  final Map<String, dynamic> map;
  final String title;
  final VoidCallback? onDelete;

  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> map,
    required String title,
    VoidCallback? onDelete,
  }) async {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return JsonViewerScreen(
            map: map,
            title: title,
            onDelete: onDelete,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  Widget _copyButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        final String jsonStr = StrUtils.toPrettyString(map);
        Clipboard.setData(ClipboardData(text: jsonStr));

        Utils.showCopiedToast(context);
      },
      icon: const Icon(
        Icons.content_copy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (onDelete != null) {
      actions = [
        IconButton(
          iconSize: 18,
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ];
    }

    actions.add(_copyButton(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: JsonViewerWidget(map),
      ),
    );
  }
}
