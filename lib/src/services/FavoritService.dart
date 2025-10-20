import 'package:shared_preferences/shared_preferences.dart';

class FavoritService {
	static Future<bool> addToFavorites(String uuid) async {
		final prefs = await SharedPreferences.getInstance();
		List<String> favs = prefs.getStringList('favorites') ?? [];
		if (!favs.contains(uuid)) {
			favs.add(uuid);
			await prefs.setStringList('favorites', favs);
			return true;
		}
		return false;
	}

	static Future<void> removeFromFavorites(String uuid) async {
		final prefs = await SharedPreferences.getInstance();
		List<String> favs = prefs.getStringList('favorites') ?? [];
		favs.remove(uuid);
		await prefs.setStringList('favorites', favs);
	}
}
