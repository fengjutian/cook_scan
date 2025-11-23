import 'dart:io';
import 'package:flutter/material.dart';
import 'recommend_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import '../services/suggestion_service.dart';
import '../services/suggestion_store.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _autoDetectIngredients(File f) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('正在识别食材...')));
      }
      final result = await SuggestionService.detectIngredients(image: f);
      if (!mounted) return;
      setState(() => labels = result);
      if (result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('识别到：${result.join('、')}')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('未识别到食材')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('识别失败：$e')));
    }
  }

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
            selectedIconTheme: const IconThemeData(size: 28),
            unselectedIconTheme: const IconThemeData(size: 28),
            selectedLabelStyle: const TextStyle(fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.recommend_outlined),
                label: "菜单",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_rounded),
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
              if (f != null) {
                _autoDetectIngredients(f);
              }
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
                          onPressed: () => _speak(text),
                          child: const Text('朗读'),
                        ),
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
