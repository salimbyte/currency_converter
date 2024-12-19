import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../providers/currency_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double _amount = 1.0;
  double _convertedAmount = 0.0;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  void _fetchExchangeRates() async {
    try {
      final provider = Provider.of<CurrencyProvider>(context, listen: false);
      await provider.fetchExchangeRates(_baseCurrency);
    } on SocketException {
      _showToast('No internet connection. Please check your network.');
      setState(() {
        _convertedAmount = 0.0;
      });
    } catch (e) {
      _showToast('Error: ${e.toString()}');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _convertCurrency() {
    final provider = Provider.of<CurrencyProvider>(context, listen: false);
    if (provider.exchangeRates.isNotEmpty) {
      final rate = provider.exchangeRates[_targetCurrency];
      if (rate != null) {
        setState(() {
          _convertedAmount = _amount * (rate is int ? rate.toDouble() : rate);
        });
      } else {
        _showToast('Invalid target currency');
      }
    } else {
      _showToast('Exchange rates not available');
    }
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _baseCurrency;
      _baseCurrency = _targetCurrency;
      _targetCurrency = temp;
      _fetchExchangeRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter amount'),
              onChanged: (value) {
                _amount = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _baseCurrency,
                  items: provider.exchangeRates.keys.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _baseCurrency = value!;
                      _fetchExchangeRates();
                    });
                  },
                ),
                GestureDetector(
                  onTap: _swapCurrencies,
                  child: const Icon(Icons.swap_horiz, size: 32),
                ),
                DropdownButton<String>(
                  value: _targetCurrency,
                  items: provider.exchangeRates.keys.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _targetCurrency = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 20),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.errorMessage.isNotEmpty)
              Column(
                children: [
                  Text(
                    provider.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _fetchExchangeRates,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              )
            else
              Text(
                'Converted Amount: $_convertedAmount $_targetCurrency',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            // Footer with your name and registration number
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Buhari Kasim\nRegistration: U2/22/CSC/0787',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
