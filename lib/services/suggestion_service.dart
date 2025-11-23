import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionService {
  static const _baseUrl = 'https://api.moonshot.ai/v1/chat/completions';
  static const _model = 'moonshot-v1-128k-vision-preview';

  static Future<String> getCookSuggestions({
    File? image,
    List<String> labels = const [],
  }) async {
    final apiKey = await readKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('未设置 KIMI_API_KEY，请在“我的”页面中配置');
    }

    final contents = <Map<String, dynamic>>[];
    final labelText = labels.isEmpty ? '未识别到具体食材' : labels.join('、');
    contents.add({
      'type': 'text',
      'text': '食材：$labelText。请基于这些食材给出 3 道适合的家常菜，并提供每道菜的简要步骤与所需调料，用中文输出。',
    });

    if (image != null && await image.exists()) {
      final bytes = await image.readAsBytes();
      final b64 = base64Encode(bytes);
      contents.add({
        'type': 'image_url',
        'image_url': {'url': 'data:image/jpeg;base64,$b64'},
      });
    }

    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': '你是一名会做中餐的烹饪助手，会根据用户提供的食材生成合理的菜谱建议。'},
        {'role': 'user', 'content': contents},
      ],
    };

    final resp = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 401) {
      throw Exception('Kimi 认证失败(401): ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw Exception('Kimi 接口错误: ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('无可用建议');
    }
    final content = choices.first['message']?['content'];
    return content is String ? content : content.toString();
  }

  static Future<void> validateKey() async {
    final apiKey = await readKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('未设置 KIMI_API_KEY');
    }
    final body = {
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'ping'},
          ],
        },
      ],
    };
    final resp = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode == 401) {
      throw Exception('认证失败(401): ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw Exception('接口错误: ${resp.statusCode}: ${resp.body}');
    }
  }

  static Future<String?> readKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('kimi_api_key');
    if (stored != null && stored.isNotEmpty) return stored;
    const envKey = String.fromEnvironment('KIMI_API_KEY');
    return envKey.isEmpty ? null : envKey;
  }

  static Future<void> saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kimi_api_key', key.trim());
  }
}
