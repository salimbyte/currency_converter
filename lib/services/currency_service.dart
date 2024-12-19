import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String apiKey = '6a29be30d9bff24a893edeee'; // Replace with your API key
  final String baseUrl = 'http://open.er-api.com/v6/latest';

  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(Uri.parse('$baseUrl/$baseCurrency'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['rates'];
    } else {
      throw Exception('Failed to fetch exchange rates');
    }
  }
}
