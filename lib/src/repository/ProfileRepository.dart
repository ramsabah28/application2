import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> setEmailAdress(String email) async {}

  Future<void> setUsername(String username) async {}

  Future<void> setAdress(String adress) async {}

  Future<void> setFavorit(String uuid) async {}
}
