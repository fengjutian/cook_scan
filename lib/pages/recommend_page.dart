import 'package:flutter/material.dart';

class RecommendPage extends StatelessWidget {
  const RecommendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("今日推荐")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard("番茄炒蛋", "简单快手 10 分钟"),
          _buildCard("青椒牛肉", "经典家常 15 分钟"),
          _buildCard("土豆炖鸡", "高蛋白晚餐"),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: Colors.green, size: 34),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}
