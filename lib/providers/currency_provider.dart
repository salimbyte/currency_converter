import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class CurrencyProvider extends ChangeNotifier {
  Map<String, double> _exchangeRates = {};
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, double> get exchangeRates => _exchangeRates;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchExchangeRates(String baseCurrency) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Convert the 'rates' values to double explicitly
        _exchangeRates = Map<String, double>.fromIterable(
          data['rates'].keys,
          value: (key) => (data['rates'][key] is int)
              ? (data['rates'][key] as int).toDouble()
              : data['rates'][key].toDouble(),
        );
      } else {
        _errorMessage = 'Failed to fetch exchange rates.';
      }
    } on SocketException {
      _errorMessage = 'No internet connection. Please check your network.';
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
