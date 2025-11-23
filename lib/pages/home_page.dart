import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Function(File?) onImageCaptured;
  final List<String> labels;
  final VoidCallback onGetSuggestions;

  const HomePage({
    super.key,
    required this.onImageCaptured,
    required this.labels,
    required this.onGetSuggestions,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                '食材识别 & 做饭建议',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),

              // --- 图片展示卡片 ---
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    // 调用你原来的拍照逻辑
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: selectedImage == null
                              ? const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- 食材标签 ---
              if (widget.labels.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.labels
                        .map(
                          (text) => Chip(
                            label: Text(text),
                            backgroundColor: Colors.white.withOpacity(0.8),
                          ),
                        )
                        .toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // --- 获取建议按钮 ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: widget.onGetSuggestions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    elevation: 5,
                  ),
                  child: const Text(
                    '生成做饭建议',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
