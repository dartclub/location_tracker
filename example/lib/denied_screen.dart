import 'package:flutter/material.dart';

class DeniedScreen extends StatelessWidget {
  final bool forever;

  const DeniedScreen({Key key, this.forever = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 75, color: Colors.orange),
          Text(
            _buildLabel(),
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  _buildLabel() {
    var label = 'Please enable location services for this app';
    if (forever) {
      label += ' in your device settings';
    }
    return label;
  }
}
