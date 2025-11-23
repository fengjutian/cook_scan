import 'package:flutter/material.dart';
import 'api_key_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的")),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.history),
            title: Text("历史菜谱"),
          ),
          const ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text("收藏"),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text("配置 Kimi API Key"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApiKeyPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
