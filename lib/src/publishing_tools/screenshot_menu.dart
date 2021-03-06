import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dvx_flutter/src/widgets/menu_item.dart';

class ScreenshotMenuItem {
  ScreenshotMenuItem({this.title = kNoTextTitle, this.filename = 'no-title'});
  String? title;
  String? filename;

  static const kNoTextTitle = 'No Title';

  String? get displayTitle => title == kNoTextTitle ? '' : title;

  static Future<List<ScreenshotMenuItem>> get items async {
    final List<ScreenshotMenuItem> result = [];

    final String data = await rootBundle.loadString('assets/screenshots.json');

    final Map<String, dynamic> jsonMap =
        json.decode(data) as Map<String, dynamic>;

    final dataList = List<Map>.from(jsonMap['data'] as List);

    // add no title choice
    result.add(ScreenshotMenuItem());
    for (final x in dataList) {
      result.add(ScreenshotMenuItem(
          title: x['title'] as String?, filename: x['filename'] as String?));
    }

    return result;
  }
}

class ScreenshotMenu extends StatefulWidget {
  const ScreenshotMenu({this.onItemSelected, this.selectedItem});

  final void Function(ScreenshotMenuItem)? onItemSelected;
  final ScreenshotMenuItem? selectedItem;

  @override
  _ScreenshotMenuState createState() => _ScreenshotMenuState();
}

class _ScreenshotMenuState extends State<ScreenshotMenu> {
  List<ScreenshotMenuItem> items = [];

  @override
  void initState() {
    super.initState();

    _setup();
  }

  Future<void> _setup() async {
    items = await ScreenshotMenuItem.items;

    setState(() {});
  }

  Widget _menuButton(BuildContext context) {
    final Widget button = SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                widget.selectedItem!.title!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              child: FittedBox(
                fit: BoxFit.fill,
                child: Icon(
                  Icons.arrow_drop_down,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final List<PopupMenuItem<ScreenshotMenuItem>> menuItems = [];

    for (final item in items) {
      menuItems.add(PopupMenuItem<ScreenshotMenuItem>(
        value: item,
        child: MenuItem(
          icon: const Icon(Icons.compare),
          name: item.title,
        ),
      ));
    }

    return PopupMenuButton<ScreenshotMenuItem>(
      itemBuilder: (context) {
        return menuItems;
      },
      onSelected: (selected) {
        widget.onItemSelected!(selected);
      },
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _menuButton(context);
  }
}
