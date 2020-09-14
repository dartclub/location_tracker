import 'package:flutter/material.dart';

class FailureScreen extends StatelessWidget {
  final String title;
  final bool wrapScaffold;

  const FailureScreen(
      {Key key, @required this.title, this.wrapScaffold = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return wrapScaffold
        ? Scaffold(body: _buildMessage(context))
        : _buildMessage(context);
  }

  Widget _buildMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_sharp, size: 75, color: Colors.red),
          Text(
            title ?? 'Error',
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
