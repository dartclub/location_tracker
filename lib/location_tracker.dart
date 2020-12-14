library location_tracker;

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firestore_api/firestore_api.dart';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
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

  LocationTrackerCubit(
    this._collectionRef, {
    this.updateDistance = 5,
    this.updateBearing = 2,
    this.updateInterval = const Duration(seconds: 2),
  })  : assert(updateBearing >= 0 && updateBearing <= 360),
        super(LocationTrackerHomeState());

  Future<void> _initLocation() async {
    LocationPermission _serviceEnabled = await checkPermission();
    if (_serviceEnabled == LocationPermission.denied) {
      emit(LocationTrackerDeniedState());
    }
    if (_serviceEnabled == LocationPermission.deniedForever) {
      emit(LocationTrackerDeniedForeverState());
    }

    PermissionStatus _status = await location.hasPermission();
    if (_status == PermissionStatus.denied) {
      _status = await location.requestPermission();
    }
    await location.changeSettings(
      distanceFilter: updateDistance,
      interval: updateInterval.inMilliseconds,
    );
  }

  _updateLocation(Point point) async {
    await _currentTracking.collection('points').add(point.toJson());
  }

  start([String id]) async {
    emit(LocationTrackerLoadingState());
    await _initLocation();
    _currentTracking = _collectionRef.document(id);
    var feature = Feature<LineString>(
      id: _currentTracking.documentID,
      properties: {
        "start": DateTime.now(),
      },
      geometry: LineString(),
    );

    await _currentTracking.setData(feature.toJson());

    _locationUpdates = location.onLocationChanged.listen(_onUpdate);
  }

  void _onUpdate(LocationData update) async {
    var point = Point(
      coordinates: Position.named(
        lng: update.longitude,
        lat: update.latitude,
        alt: update.altitude,
      ),
    );
    var heading = update.heading;
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
    emit(LocationTrackerUpdateState(point, heading));
  }

  _assembleLineString() async {
    var snap = await _currentTracking.document;
    Feature<LineString> line = Feature.fromJson(snap.data);
    var pointsSnap = await _currentTracking.collection('points').getDocuments();
    for (var pointSnap in pointsSnap.documents) {
      line.geometry.coordinates.add(Point.fromJson(pointSnap.data).coordinates);
    }
    _currentTracking.update(line.toJson());
  }

  stop() async {
    emit(LocationTrackerLoadingState());
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
