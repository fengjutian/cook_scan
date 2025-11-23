# cook_scan

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


- 使用编译期注入的 --dart-define ，不在代码库中硬编码密钥。
- Android 真机运行示例：
- flutter run --dart-define=KIMI_API_KEY=<你的新密钥>
- 构建 APK：
- flutter build apk --dart-define=KIMI_API_KEY=<你的新密钥>
- iOS（需在 macOS）：
- 运行： flutter run --dart-define=KIMI_API_KEY=<你的新密钥>
- 构建： flutter build ios --dart-define=KIMI_API_KEY=<你的新密钥>