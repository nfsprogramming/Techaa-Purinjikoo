import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrl => AppConfig.current.apiBaseUrl;

  Uri _buildUri(String path) {
    var base = _baseUrl.trim();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    var p = path.trim();
    if (!p.startsWith('/')) p = '/$p';

    if (base.endsWith('/api/v1') && p.startsWith('/api/v1')) {
      p = p.substring('/api/v1'.length);
    }
    return Uri.parse('$base$p');
  }

  Future<Map<String, dynamic>?> get(String path, {String? token}) async {
    final uri = _buildUri(path);
    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        AppLogger.d('API GET $path returned status ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.d('API GET $path network notice: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(String path, {Map<String, dynamic>? body, String? token}) async {
    final uri = _buildUri(path);
    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client
          .post(uri, headers: headers, body: body != null ? json.encode(body) : null)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        AppLogger.d('API POST $path returned status ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.d('API POST $path network notice: $e');
      return null;
    }
  }
}
