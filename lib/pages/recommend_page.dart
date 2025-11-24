import 'package:flutter/material.dart';
import '../services/suggestion_store.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});
  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  @override
  void initState() {
    super.initState();
    SuggestionStore.instance.load();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initTts();
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      if (!_ttsReady) {
        await _initTts();
      }
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('语音不可用：$e')));
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的菜单")),
      body: ValueListenableBuilder<List<SuggestionEntry>>(
        valueListenable: SuggestionStore.instance.suggestions,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: const [Text("暂无已保存的建议")],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final dt = DateTime.fromMillisecondsSinceEpoch(item.ts);
              final timeStr =
                  "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton(
                            onPressed: _ttsReady
                                ? () => _speak(item.text)
                                : null,
                            child: const Text('朗读'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: item.text),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制到剪贴板')),
                              );
                            },
                            child: const Text('复制'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await SuggestionStore.instance.removeAt(index);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已删除')),
                              );
                            },
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(item.text, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
