class LocationPermissionResult {
  final bool hasLocationPermission;
  final bool hasPartialPermission;
  final bool canRequestInApp;
  final String? message;
  
  const LocationPermissionResult({
    required this.hasLocationPermission,
    required this.hasPartialPermission,
    required this.canRequestInApp,
    this.message,
  });
}
