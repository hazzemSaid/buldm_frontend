import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position?> requestAndGetLocation(BuildContext context) async {
    // Check permission
    var status = await Permission.location.status;
    final localizations = AppLocalizations.of(context)!;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.locationPermissionDenied)),
        );
        return null;
      }
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.locationServicesDisabled)),
      );
      return null;
    }

    // Get location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
