import 'denied_screen.dart';
import 'failure_screen.dart';
import 'loading_screen.dart';
import 'location_screen.dart';
import 'package:firestore_api/firestore_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker/location_tracker.dart';

class HomeScreen extends StatefulWidget {
  final Firestore firestore;

  const HomeScreen({Key key, @required this.firestore}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationTrackerCubit _locationTracker;
  bool _tracking = false;

  @override
  void initState() {
    _locationTracker =
        LocationTrackerCubit(widget.firestore.collection('routes'));
    super.initState();
  }

  @override
  void dispose() {
    _locationTracker?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Location Tracker'),
      ),
      body: BlocConsumer<LocationTrackerCubit, LocationTrackerState>(
          cubit: _locationTracker,
          builder: (BuildContext context, LocationTrackerState state) {
            if (state is LocationTrackerFailureState) {
              return FailureScreen(title: 'Could not enable location services');
            }
            if (state is LocationTrackerDeniedState) {
              return DeniedScreen();
            }
            if (state is LocationTrackerDeniedForeverState) {
              return DeniedScreen(forever: true);
            }
            if (state is LocationTrackerHomeState) {
              return _HomeMessage();
            }
            if (state is LocationTrackerUpdateState) {
              return LocationUpdateScreen(state: state);
            }

            return LoadingScreen();
          },
          listener: (context, state) {
            print(state.runtimeType);
            if (state is LocationTrackerUpdateState && !_tracking) {
              setState(() {
                _tracking = true;
              });
            }
            if (state is LocationTrackerHomeState && _tracking) {
              setState(() {
                _tracking = false;
              });
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  FloatingActionButton _buildFloatingActionButton() =>
      FloatingActionButton.extended(
        onPressed: () {
          if (_tracking) {
            _locationTracker.stop();
          } else {
            _locationTracker.start();
          }
        },
        label: Text(_tracking ? 'Stop' : 'Start'),
        icon: Icon(_tracking ? Icons.stop : Icons.play_arrow),
      );
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    Key key,
  }) : super(key: key);

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
          Icon(Icons.gps_not_fixed, color: Colors.blue, size: 75),
          Text(
            'Start tracking your location',
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
