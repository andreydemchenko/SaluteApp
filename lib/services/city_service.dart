import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/model/city.dart';

class CityService {
  Future<List<City>> fetchCities() async {
    final String response =
    await rootBundle.loadString('utils/russian_cities.json');
    final data = await json.decode(response) as List;
    return data.map((city) => City.fromJson(city)).toList();
  }
}