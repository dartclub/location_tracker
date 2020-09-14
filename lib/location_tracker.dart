library location_tracker;

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firestore_api/firestore_api.dart';
import 'package:bloc/bloc.dart';
import 'package:location/location.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

class LocationTrackerState extends Equatable {
  @override
  List<Object> get props => [];
}

class LocationTrackerLoadingState extends LocationTrackerState {}

class LocationTrackerFailureState extends LocationTrackerState {}

class LocationTrackerDeniedState extends LocationTrackerState {}

class LocationTrackerDeniedForeverState extends LocationTrackerState {}

class LocationTrackerHomeState extends LocationTrackerState {}

class LocationTrackerUpdateState extends LocationTrackerState {
  final Point point;
  final double heading;

  LocationTrackerUpdateState(this.point, this.heading);
}

class LocationTrackerCubit extends Cubit<LocationTrackerState> {
  final CollectionReference _collectionRef;
  final double updateDistance;
  final double updateBearing;
  final Duration updateInterval;

  StreamSubscription _locationUpdates;
  DocumentReference _currentTracking;
  Location location;

  LocationTrackerCubit(
    this._collectionRef, {
    this.updateDistance = 5,
    this.updateBearing = 2,
    this.updateInterval = const Duration(seconds: 5),
  })  : assert(updateBearing >= 0 && updateBearing <= 360),
        super(LocationTrackerHomeState());

  Future<Location> _initLocation() async {
    location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        emit(LocationTrackerFailureState());
      }
    }

    PermissionStatus _status = await location.hasPermission();
    if (_status == PermissionStatus.denied) {
      _status = await location.requestPermission();
      if (_status == PermissionStatus.denied) {
        emit(LocationTrackerDeniedState());
      }
      if (_status == PermissionStatus.deniedForever) {
        emit(LocationTrackerDeniedForeverState());
      }
    }
    await location.changeSettings(
      distanceFilter: updateDistance,
      interval: updateInterval.inMilliseconds,
    );
    return location;
  }

  _updateLocation(Point point) async {
    await _currentTracking.collection('points').add(point.toJson());
  }

  start([String id]) async {
    emit(LocationTrackerLoadingState());
    var location = await _initLocation();
    _currentTracking = _collectionRef.document(id);
    var feature = Feature<GeometryCollection>(
      id: _currentTracking.documentID,
      properties: {
        "start": DateTime.now(),
      },
      geometry: GeometryCollection(geometries: []),
    );

    await _currentTracking.setData(feature.toJson());

    _locationUpdates =
        location.onLocationChanged.listen((LocationData update) async {
      var point = Point(
        coordinates: Position.named(
          lng: update.longitude,
          lat: update.latitude,
          alt: update.altitude,
        ),
      );
      var heading = update.heading;
      emit(LocationTrackerUpdateState(point, heading));
      if (state is LocationTrackerUpdateState) {
        var dist = distance(point, (state as LocationTrackerUpdateState).point);
        var headingDiff =
            (heading - (state as LocationTrackerUpdateState).heading).abs();
        if (headingDiff > updateBearing && dist > updateDistance) {
          await _updateLocation(point);
        }
      } else {
        await _updateLocation(point);
      }
    });
  }

  stop() async {
    await _currentTracking.update({
      "properties.end": DateTime.now(),
    });
    _currentTracking = null;
    _locationUpdates?.cancel();
    emit(LocationTrackerHomeState());
  }

  @override
  Future<void> close() {
    _locationUpdates?.cancel();
    return super.close();
  }
}
