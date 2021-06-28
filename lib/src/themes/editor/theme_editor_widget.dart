import 'dart:convert';
import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_shared/src/dialogs/widget_dialog.dart';
import 'package:flutter_shared/src/google_fonts/google_fonts_screen.dart';
import 'package:flutter_shared/src/themes/editor/theme_color_editor_screen.dart';
import 'package:flutter_shared/src/themes/editor/theme_set.dart';
import 'package:flutter_shared/src/themes/editor/theme_set_button.dart';
import 'package:flutter_shared/src/themes/editor/theme_set_manager.dart';
import 'package:flutter_shared/src/utils/utils.dart';
import 'package:flutter_shared/src/widgets/list_row.dart';
import 'package:flutter_shared/src/widgets/theme_button.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:flutter_shared/src/extensions/string_ext.dart';

class ThemeEditorWidget extends StatefulWidget {
  @override
  _ThemeEditorWidgetState createState() => _ThemeEditorWidgetState();
}

class _ThemeEditorWidgetState extends State<ThemeEditorWidget> {
  void _showQRCodeDialog(BuildContext context) {
    final String jsonStr = json.encode(ThemeSetManager().currentTheme!.toMap());

    // here on purpose so we can easily grab the json if we want
    print(jsonStr);

    final List<Widget> children = [
      BarcodeWidget(
        height: 300,
        width: 300,
        backgroundColor: Colors.white,
        barcode: Barcode.qrCode(),
        padding: const EdgeInsets.all(10),
        data: jsonStr,
      ),
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () async {
          final image = img.Image(320, 320);
          img.fill(image, img.getColor(255, 255, 255));

          drawBarcode(image, Barcode.qrCode(), jsonStr,
              width: 300, height: 300, x: 10, y: 10);

          final Directory directory = await getTemporaryDirectory();

          final String path = p.join(directory.path, 'shareTheme.png');

          File(path).writeAsBytesSync(img.encodePng(image));

          await ShareExtend.share(path, 'image');
        },
      )
    ];

    showWidgetDialog(
        context: context,
        title: 'Scan the QRcode import the current theme.',
        children: children);
  }

  @override
  Widget build(BuildContext context) {
    final String fontName = ThemeSetManager()
        .googleFont
        .replaceFirst('TextTheme', '')
        .fromCamelCase();

    final ThemeSet? theme = ThemeSetManager().currentTheme;

    const colorFields = ThemeSetColor.values;

    return Column(
      children: [
        ThemeSetButton(
          themeSets: ThemeSetManager.themeSets,
          onItemSelected: (newTheme) {
            ThemeSetManager().currentTheme = newTheme;
          },
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: colorFields.length,
            itemBuilder: (context, index) {
              return ListRow(
                title: theme!.nameForField(colorFields[index]),
                leading: Container(
                  height: 40,
                  width: 40,
                  color: theme.colorForField(colorFields[index]),
                ),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => ThemeColorEditorScreen(
                          themeSet: theme, field: colorFields[index]),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 4),
          ),
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          value: ThemeSetManager().lightBackground!,
          onChanged: (bool newValue) {
            ThemeSetManager().lightBackground = newValue;
          },
          title: const Text('Light Background'),
        ),
        SwitchListTile(
          value: ThemeSetManager().integratedAppBar!,
          onChanged: (bool newValue) {
            ThemeSetManager().integratedAppBar = newValue;
          },
          title: const Text('Integrated app bar'),
        ),
        ListTile(
          trailing: ThemeButton(
            title: 'Change Font',
            onPressed: () {
              Navigator.of(context).push<void>(MaterialPageRoute(
                builder: (context) {
                  return GoogleFontsScreen();
                },
              ));
            },
          ),
          title: Text(
            fontName,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // scanning only on mobile
            if (Utils.isMobile)
              ThemeButton(
                onPressed: () async {
                  final String barcodeScanRes =
                      await FlutterBarcodeScanner.scanBarcode(
                          '#ff6666', 'Cancel', true, ScanMode.DEFAULT);

                  // "-1" gets returned on cancel or back
                  // we only want json back in this case
                  if (Utils.isNotEmpty(barcodeScanRes) &&
                      barcodeScanRes.firstChar == '{') {
                    final ThemeSet newTheme = ThemeSet.fromMap(
                        json.decode(barcodeScanRes) as Map<String, dynamic>);

                    ThemeSetManager.saveTheme(newTheme, scanned: true);
                  }
                },
                title: 'Scan Theme',
                icon: const Icon(FontAwesome.qrcode),
              ),
            ThemeButton(
              onPressed: () async {
                _showQRCodeDialog(context);
              },
              title: 'Share Theme',
              icon: const Icon(Icons.share),
            ),
          ],
        ),
      ],
    );
  }
}

class ThemeColorData {
  const ThemeColorData({
    this.name,
    this.color,
  });

  final String? name;
  final Color? color;
}