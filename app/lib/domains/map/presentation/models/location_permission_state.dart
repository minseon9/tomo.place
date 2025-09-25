import 'package:equatable/equatable.dart';

abstract class LocationPermissionState extends Equatable {
  const LocationPermissionState();
  
  bool get hasLocationPermission => false;
  
  bool get hasPartialPermission => false;
  
  bool get canRequestInApp => false;
  
  String? get message => null;
}

class LocationPermissionInitial extends LocationPermissionState {
  const LocationPermissionInitial();
  @override
  List<Object?> get props => [];
}

class LocationPermissionLoading extends LocationPermissionState {
  const LocationPermissionLoading();
  @override
  List<Object?> get props => [];
}

class LocationPermissionGranted extends LocationPermissionState {
  const LocationPermissionGranted();
  @override
  List<Object?> get props => [];
  
  @override
  bool get hasLocationPermission => true;
}

class LocationPermissionPartial extends LocationPermissionState {
  final String message;
  
  const LocationPermissionPartial({required this.message});
  @override
  List<Object?> get props => [message];
  
  @override
  bool get hasLocationPermission => true;
  @override
  bool get hasPartialPermission => true;
}

class LocationPermissionDenied extends LocationPermissionState {
  final String message;
  
  const LocationPermissionDenied({required this.message});
  @override
  List<Object?> get props => [message];
  
  @override
  bool get canRequestInApp => true;
}

class LocationPermissionPermanentlyDenied extends LocationPermissionState {
  final String message;
  
  const LocationPermissionPermanentlyDenied({required this.message});
  @override
  List<Object?> get props => [message];
  
  @override
  bool get canRequestInApp => false;
}
