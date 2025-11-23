import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionEntry {
  final String text;
  final int ts;
  SuggestionEntry({required this.text, required this.ts});
  Map<String, dynamic> toJson() => {'text': text, 'ts': ts};
  static SuggestionEntry fromJson(Map<String, dynamic> j) => SuggestionEntry(text: j['text'] as String, ts: j['ts'] as int);
}

class SuggestionStore {
  static final SuggestionStore instance = SuggestionStore._();
  SuggestionStore._();
  final ValueNotifier<List<SuggestionEntry>> suggestions = ValueNotifier<List<SuggestionEntry>>(<SuggestionEntry>[]);
  static const _key = 'saved_suggestions';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      suggestions.value = <SuggestionEntry>[];
      return;
    }
    final list = (jsonDecode(raw) as List).cast<Map>().map((e) => SuggestionEntry.fromJson(e.cast<String, dynamic>())).toList();
    list.sort((a, b) => b.ts.compareTo(a.ts));
    suggestions.value = list;
  }

  Future<void> add(String text) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final current = List<SuggestionEntry>.from(suggestions.value);
    current.insert(0, SuggestionEntry(text: text, ts: now));
    suggestions.value = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(current.map((e) => e.toJson()).toList()));
  }
}
