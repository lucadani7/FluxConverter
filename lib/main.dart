import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    dev.log('File .env loaded successfully!', name: 'FluxConverter.Init');
  } catch (e) {
    dev.log('File .env is invalid or is missing!', error: e, name: 'FluxConverter.Init', level: 1000);
  }
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: FluxConverter()));
}

class FluxConverter extends StatefulWidget {
  const FluxConverter({super.key});

  @override
  State<StatefulWidget> createState() => FluxConverterState();
}

class FluxConverterState extends State<FluxConverter> {
  double inputAmount = 0;
  double result = 0;
  String fromCurrency = 'EUR';
  String toCurrency = 'RON';
  bool isLoading = false;
  final List<String> currencies = ['USD', 'EUR', 'RON', 'GBP', 'CHF', 'JPY', 'CAD'];
  String get apiKey => dotenv.env['API_KEY'] ?? '';

  void swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      if (inputAmount > 0) {
        convertCurrency();
      }
    });
  }

  Future<void> convertCurrency() async {
    if (inputAmount <= 0) {
      return;
    }
    if (apiKey.isEmpty) {
      dev.log('API_KEY is empty! Check.env file!', name: 'FluxConverter.API', level: 900);
      return;
    }
    setState(() => isLoading = true);
    final url = Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/pair/$fromCurrency/$toCurrency/$inputAmount');

    try {
      dev.log('API Request to: ${url.host}', name: 'FluxConverter.Network');
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Status code: ${response.statusCode}');
      } else {
        final data = json.decode(response.body);
        setState(() {
          result = (data['conversion_result'] as num).toDouble();
          isLoading = false;
        });
        dev.log('Conversion was successful: $result $toCurrency', name: 'FluxConverter.Success');
      }
    } catch (e, stackTrace) {
      dev.log('Conversion error', error: e, stackTrace: stackTrace, name: 'FluxConverter.Error');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error. Check the Internet or the API key.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'FluxConverter',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text('Real-time Exchange Rates', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildExchangeCard(),
                      const SizedBox(height: 30),
                      _buildConvertButton(),
                      const SizedBox(height: 40),
                      if (result > 0) _buildResultDisplay(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown(fromCurrency, (val) => setState(() => fromCurrency = val!)),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 32, color: Colors.blue),
                onPressed: swapCurrencies,
              ),
              _buildDropdown(toCurrency, (val) => setState(() => toCurrency = val!)),
            ],
          ),
          const Divider(height: 40),
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Amount to convert',
              prefixIcon: const Icon(Icons.wallet),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onChanged: (value) => inputAmount = double.tryParse(value) ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: isLoading ? null : convertCurrency,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('CONVERT NOW',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Column(
      children: [
        Text('Total Amount:', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          '${result.toStringAsFixed(2)} $toCurrency',
          style: TextStyle(color: Colors.blue.shade900, fontSize: 38, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}