import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Center(
          widthFactor: 2.0,
          heightFactor: 2.0,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )),
    );
  }
}
