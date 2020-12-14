import 'package:flutter/material.dart';
import 'package:location_tracker/location_tracker.dart';

class LocationUpdateScreen extends StatelessWidget {
  final LocationTrackerUpdateState state;

  const LocationUpdateScreen({Key key, @required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.gps_fixed, color: Colors.blue, size: 75),
          Divider(),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Latitude',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    state.point.coordinates.lat.toStringAsFixed(5),
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Longitude',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    state.point.coordinates.lng.toStringAsFixed(5),
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.landscape,
                size: 75,
                color: Colors.blueGrey[300],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Altitude',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    state.point.coordinates.alt.toStringAsFixed(5),
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          /*
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 8),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Transform.rotate(
              angle: state.heading ?? 0,
              child: Icon(Icons.navigation, size: 75),
            ),
          ),*/
        ],
      ),
    );
  }
}
