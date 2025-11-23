import 'dart:io';
import 'package:flutter/material.dart';
import 'recommend_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import '../services/suggestion_service.dart';
import '../services/suggestion_store.dart';

class NavigationRoot extends StatefulWidget {
  const NavigationRoot({super.key});

  @override
  State<NavigationRoot> createState() => _NavigationRootState();
}

class _NavigationRootState extends State<NavigationRoot> {
  int index = 1; // 默认打开“拍照”
  final PageController controller = PageController(initialPage: 1);
  File? lastImage;
  List<String> labels = const [];

  void onTap(int i) {
    setState(() => index = i);
    controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // --- 底部导航 ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: onTap,
            backgroundColor: Colors.white.withOpacity(0.95),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.recommend_outlined),
                label: "推荐",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_rounded, size: 32),
                label: "拍照",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "我的",
              ),
            ],
          ),
        ),
      ),

      // --- 页面内容 ---
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const RecommendPage(),
          HomePage(
            onImageCaptured: (f) {
              setState(() => lastImage = f);
            },
            labels: labels,
            onGetSuggestions: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                final text = await SuggestionService.getCookSuggestions(
                  image: lastImage,
                  labels: labels,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('做饭建议'),
                      content: SingleChildScrollView(child: Text(text)),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await SuggestionStore.instance.add(text);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已保存到推荐')),
                              );
                            }
                          },
                          child: const Text('保存'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('生成失败：$e')));
                }
              }
            },
          ),
          const ProfilePage(),
        ],
      ),
    );
  }
}
