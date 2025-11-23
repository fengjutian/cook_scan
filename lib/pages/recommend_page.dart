import 'package:flutter/material.dart';
import '../services/suggestion_store.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});
  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  @override
  void initState() {
    super.initState();
    SuggestionStore.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("今日推荐")),
      body: ValueListenableBuilder<List<SuggestionEntry>>(
        valueListenable: SuggestionStore.instance.suggestions,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                Text("暂无已保存的建议"),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final dt = DateTime.fromMillisecondsSinceEpoch(item.ts);
              final timeStr = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
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
                        const Icon(Icons.restaurant_menu, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        Text(timeStr, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
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
