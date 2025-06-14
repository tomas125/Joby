import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  late drive.DriveApi _driveApi;
  
  Future<void> initialize() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": dotenv.env['GOOGLE_PROJECT_ID'],
      "private_key_id": dotenv.env['GOOGLE_PRIVATE_KEY_ID'],
      "private_key": dotenv.env['GOOGLE_PRIVATE_KEY']?.replaceAll('\\n', '\n'),
      "client_email": dotenv.env['GOOGLE_CLIENT_EMAIL'],
      "client_id": dotenv.env['GOOGLE_CLIENT_ID'],
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": dotenv.env['GOOGLE_CLIENT_CERT_URL']
    });

    final client = await clientViaServiceAccount(credentials, _scopes);
    _driveApi = drive.DriveApi(client);
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final file = drive.File()
        ..name = fileName
        ..parents = [dotenv.env['GOOGLE_DRIVE_FOLDER_ID'] ?? ''];

      final response = await _driveApi.files.create(
        file,
        uploadMedia: drive.Media(imageFile.openRead(), imageFile.lengthSync()),
      );

      // Make the file publicly accessible
      await _driveApi.permissions.create(
        drive.Permission(role: 'reader', type: 'anyone'),
        response.id!,
      );

      // Get the public URL
      final fileUrl = 'https://drive.google.com/uc?export=view&id=${response.id}';
      return fileUrl;
    } catch (e) {
      throw Exception('Error uploading image to Google Drive: $e');
    }
  }
} 