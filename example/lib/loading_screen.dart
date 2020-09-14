import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final bool wrapScaffold;

  const LoadingScreen({Key key, this.wrapScaffold = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return wrapScaffold
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
