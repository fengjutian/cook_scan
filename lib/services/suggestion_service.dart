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
      'text':
          '你是一名智能烹饪助手。已识别食材：$labelText。请基于可用食材生成 3 道易做的家常菜。每道菜输出：\n1）菜名\n2）适合人数\n3）预计用时\n4）难度（1-5）\n5）所需食材及用量\n6）调料\n7）步骤（编号、简洁、可执行，5-8 步）\n8）关键技巧\n9）注意事项\n规则：优先使用提供食材，必要时可补充常见配料；尽量控制整体用时不超过 30 分钟；避免稀有食材；用中文、条理清晰、分段输出。',
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
        {'role': 'system', 'content': '你是智能烹饪助手，负责生成安全、准确、可执行的中文家常菜建议。'},
        {'role': 'user', 'content': contents},
      ],
    };

    http.Response resp;
    try {
      resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('网络错误：$e');
    }

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
    http.Response resp;
    try {
      resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('网络错误：$e');
    }
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
          'content':
              '你是食材识别助手。只返回图片中的主要食材通用名称，排除餐具、器皿、品牌词与背景物体。仅输出一个中文逗号分隔的字符串，不要任何解释或附加标点。',
        },
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': '识别图片中的主要食材，仅返回中文逗号分隔的食材名称。'},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$b64'},
            },
          ],
        },
      ],
    };

    http.Response resp;
    try {
      resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('网络错误：$e');
    }

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
