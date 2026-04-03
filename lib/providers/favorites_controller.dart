import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// お気に入り URL（[shared_preferences] に保存）。
class FavoritesController extends ChangeNotifier {
  FavoritesController();

  static const _prefsKey = 'favorite_urls_v1';

  List<String> _urls = [];
  List<String> get urls => List.unmodifiable(_urls);

  bool isFavorite(String url) => _urls.contains(url);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _urls = List<String>.from(p.getStringList(_prefsKey) ?? []);
    notifyListeners();
  }

  Future<void> toggleFavorite(String url) async {
    if (url.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    if (_urls.contains(url)) {
      _urls = _urls.where((e) => e != url).toList();
    } else {
      _urls = [..._urls, url];
    }
    await p.setStringList(_prefsKey, _urls);
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _urls.length) return;
    final p = await SharedPreferences.getInstance();
    _urls = [..._urls]..removeAt(index);
    await p.setStringList(_prefsKey, _urls);
    notifyListeners();
  }
}
