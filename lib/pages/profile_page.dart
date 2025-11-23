import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.history),
            title: Text("历史菜谱"),
          ),
          ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text("收藏"),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("设置"),
          ),
        ],
      ),
    );
  }
}
