import 'package:flutter/material.dart';

class SharedContext {
  factory SharedContext() {
    return _instance ??= SharedContext._();
  }
  SharedContext._();

  static SharedContext? _instance;

  // must set this and get this
  BuildContext? context;
}

class SharedContextWidget extends StatelessWidget {
  const SharedContextWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    SharedContext().context = context;
    return child;
  }
}
