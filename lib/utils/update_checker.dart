import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class UpdateChecker {
  // Playstore app url
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.joby.loby';
  
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Get current app version
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      
      // Configure Remote Config
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Set default values
      await remoteConfig.setDefaults({
        'latest_version': currentVersion,
        'force_update': false,
      });
      
      // Get latest values
      await remoteConfig.fetchAndActivate();
      
      final String latestVersion = remoteConfig.getString('latest_version');
      final bool forceUpdate = remoteConfig.getBool('force_update');
      
      // Compare versions
      if (_isVersionNewer(currentVersion, latestVersion)) {
        // Show update dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpdateDialog(context, forceUpdate);
        });
      }
    } catch (e) {
      print('Error checking updates: $e');
      // Don't show error to user, just log it
    }
  }
  
  static bool _isVersionNewer(String currentVersion, String latestVersion) {
    try {
      // Validate version strings
      if (!_isValidVersion(currentVersion) || !_isValidVersion(latestVersion)) {
        print('Invalid version format: current=$currentVersion, latest=$latestVersion');
        return false;
      }

      List<int> current = currentVersion.split('.').map(int.parse).toList();
      List<int> latest = latestVersion.split('.').map(int.parse).toList();
      
      for (int i = 0; i < latest.length; i++) {
        if (i >= current.length) return true;
        if (latest[i] > current[i]) return true;
        if (latest[i] < current[i]) return false;
      }
      
      return false;
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }

  static bool _isValidVersion(String version) {
    // Version should be in format x.y.z where x, y, z are numbers
    final RegExp versionRegex = RegExp(r'^\d+(\.\d+)*$');
    return versionRegex.hasMatch(version);
  }
  
  static void _showUpdateDialog(BuildContext context, bool forceUpdate) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => !forceUpdate,
          child: AlertDialog(
            title: const Text('Nueva versión disponible'),
            content: const Text(
              'Hay una nueva versión de JOBY disponible. Por favor actualiza para disfrutar de las nuevas funcionalidades y mejoras.'
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  child: const Text('Más tarde'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              TextButton(
                child: const Text('Actualizar ahora'),
                onPressed: () {
                  _launchPlayStore();
                  if (!forceUpdate) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  static Future<void> _launchPlayStore() async {
    final Uri url = Uri.parse(playStoreUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $url');
    }
  }
} 