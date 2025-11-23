import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
                '食材识别',
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
                    final picker = ImagePicker();
                    final xfile = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1600,
                      imageQuality: 85,
                    );
                    if (xfile != null) {
                      final file = File(xfile.path);
                      setState(() => selectedImage = file);
                      widget.onImageCaptured(file);
                    }
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
                  onPressed: () {
                    if (selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请先拍照或上传图片')),
                      );
                      return;
                    }
                    widget.onGetSuggestions();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 10),
                      Text(
                        '生成做饭建议',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final xfile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1600,
                        imageQuality: 85,
                      );
                      if (xfile == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('未选择图片')));
                        return;
                      }
                      final file = File(xfile.path);
                      setState(() => selectedImage = file);
                      widget.onImageCaptured(file);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('选择失败：$e')));
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('从相册选择'),
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
