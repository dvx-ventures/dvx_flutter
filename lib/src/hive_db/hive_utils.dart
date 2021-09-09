import 'dart:io';

import 'package:dvx_flutter/src/hive_db/hive_box.dart';
import 'package:dvx_flutter/src/hive_db/hive_data.dart';
import 'package:dvx_flutter/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class HiveUtils {
  HiveUtils._();

  static Future<void> init() async {
    // store this in the application support on iOS
    // await Hive.initFlutter('hive'); doesn't allow picking location
    if (!Utils.isWeb) {
      if (Utils.isMobile) {
        WidgetsFlutterBinding.ensureInitialized();

        // data directory on android
        Directory appDir = await getApplicationDocumentsDirectory();

        if (Utils.isIOS) {
          appDir = await getLibraryDirectory();
        }

        String path = appDir.path;
        path = p.join(path, 'app_data');
        Hive.init(path);
      } else {
        // a server
        Hive.init('./hive');
      }
    }

    // register adapters
    Hive.registerAdapter<HiveData>(HiveDataAdapter());

    // open prefs box before app runs so it's ready
    if (!HiveBox.prefsBox.isOpen()) {
      await HiveBox.prefsBox.open();
    }
  }
}

// return ValueListenableBuilder(
//   valueListenable: widget.hiveBox.listenable(),
//   builder: (BuildContext context, Box<ScanData> __, Widget _) {
//       return xx;
//   },
// ),

// not sure where I got this
// ValueListenableProvider.value(
//       value : widget.hiveBox.listenable(),
//       child:
