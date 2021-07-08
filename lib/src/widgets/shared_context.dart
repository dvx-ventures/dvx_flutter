import 'package:flutter/material.dart';

class SharedContext {
  factory SharedContext() {
    return _instance ??= SharedContext._();
  }
  SharedContext._();

  static SharedContext? _instance;
  late BuildContext? _context;

  BuildContext get context {
    // Will crash if null, this should never be null
    return _context!;
  }

  set context(BuildContext context) {
    _context = context;
  }
}

// =======================================================================
// =======================================================================

class SharedContextWidget extends StatelessWidget {
  const SharedContextWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    SharedContext().context = context;
    return child;
  }
}
