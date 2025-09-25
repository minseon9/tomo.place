import 'dart:math';

import 'package:location/location.dart';
import 'package:tomo_place/domains/map/core/entities/map_position.dart';

import '../../core/repositories/location_stream_repository.dart';

class LocationStreamRepositoryImpl extends LocationStreamRepository {
  LocationStreamRepositoryImpl();

  final Location _location = Location();

  @override
  void startLocationStreaming() {
    _location.onLocationChanged.listen((locationData) {
      if (isPaused) return;

      if (locationData.latitude != null && locationData.longitude != null) {
        final newLocation = MapPosition(latitude: locationData.latitude!, longitude: locationData.longitude!, heading: locationData.heading!);
        final accuracy = locationData.accuracy ?? 0.0;
        final heading = locationData.heading ?? 0.0;

        if (accuracy > accuracyThreshold) return;

        if (lastPosition != null) {
          final distance = _calculateDistance(lastPosition!, newLocation);
          if (distance < distanceFilter) return;
        }

        lastPosition = newLocation;

        locationController?.add(MapPosition(
          latitude: newLocation.latitude,
          longitude: newLocation.longitude,
          heading: heading,
        ));
        headingController?.add(heading);

        final enhancedData = MapPosition(
          latitude: newLocation.latitude,
          longitude: newLocation.longitude,
          heading: heading,
        );
        enhancedLocationController?.add(enhancedData);
      }
    }, onError: (error) {
      locationController?.addError(error);
      headingController?.addError(error);
      enhancedLocationController?.addError(error);
    });
  }

  double _calculateDistance(MapPosition point1, MapPosition point2) {
    const double earthRadius = 6371000;

    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }
}
