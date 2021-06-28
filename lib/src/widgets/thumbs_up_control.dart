import 'package:flutter/material.dart';
import 'package:dvx_flutter/src/widgets/thumb_widget.dart';

class ThumbsUpControl extends StatefulWidget {
  const ThumbsUpControl({
    required this.value,
    required this.onChanged,
  });

  // or null if not set
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  _ThumbsUpControlState createState() => _ThumbsUpControlState();
}

class _ThumbsUpControlState extends State<ThumbsUpControl> {
  @override
  Widget build(BuildContext context) {
    int? groupValue;
    if (widget.value != null) {
      groupValue = widget.value == true ? 1 : 0;
    } else {
      groupValue = null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            bool? newResult;

            if (groupValue != 1) {
              newResult = true;
            }

            widget.onChanged(newResult);

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 14,
            ),
            child: ThumbWidget(
              selectedIndex: groupValue == 1 ? 2 : 10,
              index: 2,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            bool? newResult;

            if (groupValue != 0) {
              newResult = false;
            }

            widget.onChanged(newResult);

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 14,
            ),
            child: ThumbWidget(
              selectedIndex: groupValue == 0 ? 1 : 10,
              index: 1,
            ),
          ),
        )
      ],
    );
  }
}
