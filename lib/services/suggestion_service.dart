import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionService {
  static const _baseUrl = 'https://api.moonshot.cn/v1/chat/completions';
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
      'temperature': 0.6,
      'messages': [
        {
          'role': 'system',
          'content':
              '你是 Kimi，由 Moonshot AI 提供的人工智能助手，你更擅长中文和英文的对话。你会为用户提供安全、有帮助、准确的回答。',
        },
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
      'temperature': 0.6,
      'messages': [
        {'role': 'system', 'content': '你是 Kimi，由 Moonshot AI 提供的人工智能助手。'},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': '你好'},
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

  static Future<List<String>> detectIngredients({required File image}) async {
    final apiKey = await readKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('未设置 KIMI_API_KEY，请在“我的”页面中配置');
    }
    if (!await image.exists()) {
      throw Exception('图片不存在');
    }

    final bytes = await image.readAsBytes();
    final b64 = base64Encode(bytes);
    final body = {
      'model': _model,
      'temperature': 0.2,
      'messages': [
        {
          'role': 'system',
          'content': '你是食材识别助手。请只返回图片中主要食材名称，使用中文，用逗号分隔，不要解释。',
        },
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': '识别这张图片中的主要食材，结果用中文逗号分隔。'},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$b64'},
            },
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
      throw Exception('Kimi 认证失败(401): ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw Exception('Kimi 接口错误: ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('未识别到食材');
    }
    final content = choices.first['message']?['content'];
    final text = content is String ? content : content.toString();
    final parts = text
        .replaceAll('\n', ' ')
        .split(RegExp(r'[，,、\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final set = <String>{};
    final result = <String>[];
    for (final p in parts) {
      if (set.add(p)) result.add(p);
      if (result.length >= 8) break;
    }
    return result;
  }
}
