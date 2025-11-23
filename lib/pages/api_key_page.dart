import 'package:flutter/material.dart';
import '../services/suggestion_service.dart';

class ApiKeyPage extends StatefulWidget {
  const ApiKeyPage({super.key});

  @override
  State<ApiKeyPage> createState() => _ApiKeyPageState();
}

class _ApiKeyPageState extends State<ApiKeyPage> {
  final TextEditingController controller = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // 读取已保存的密钥
    // 为避免引入额外依赖，复用 service 的读取逻辑
    // 直接调用保存接口后再读取会更统一，这里仅加载显示
    final key = await _readCurrentKey();
    if (mounted) controller.text = key ?? '';
  }

  Future<String?> _readCurrentKey() async {
    return await SuggestionService.readKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置 Kimi API Key')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请输入 Kimi 的 API Key（仅保存在本机）：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'sk-...（不会上传到服务器）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '注意：密钥将保存在本机的偏好设置中，请勿共享。若密钥泄露请前往控制台撤销并更换。',
              style: TextStyle(fontSize: 12),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final key = controller.text.trim();
                        if (key.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入有效的 API Key')),
                          );
                          return;
                        }
                        setState(() => saving = true);
                        try {
                          await SuggestionService.saveKey(key);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已保存')),
                            );
                            Navigator.of(context).pop();
                          }
                        } finally {
                          if (mounted) setState(() => saving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(saving ? '保存中...' : '保存'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  try {
                    await SuggestionService.validateKey();
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('密钥有效')));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('密钥校验失败：$e')));
                  }
                },
                child: const Text('测试密钥'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
