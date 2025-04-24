import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class MetalRate {
  final String product;
  final String description;
  final String price;

  MetalRate(this.product, this.description, this.price);
}

class GoldSilverRateScreen extends StatefulWidget {
  @override
  _GoldSilverRateScreenState createState() => _GoldSilverRateScreenState();
}

class _GoldSilverRateScreenState extends State<GoldSilverRateScreen> {
  List<MetalRate> goldRates = [];
  List<MetalRate> silverRates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    const url = 'https://www.bajus.org/gold-price';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dom.Document document = parser.parse(response.body);

      final goldRows = document.querySelectorAll('.gold-table tbody tr');
      final silverRows = document.querySelectorAll('.silver-table tbody tr');

      final List<MetalRate> gold = goldRows.map((row) {
        final product = row.querySelector('h6')?.text.trim() ?? '';
        final desc = row.querySelector('td p')?.text.trim() ?? '';
        final price = row.querySelector('.price')?.text.trim() ?? '';
        return MetalRate(product, desc, price);
      }).toList();

      final List<MetalRate> silver = silverRows.map((row) {
        final product = row.querySelector('h6')?.text.trim() ?? '';
        final desc = row.querySelector('td p')?.text.trim() ?? '';
        final price = row.querySelector('.price')?.text.trim() ?? '';
        return MetalRate(product, desc, price);
      }).toList();

      setState(() {
        goldRates = gold;
        silverRates = silver;
        isLoading = false;
      });
    } else {
      print('❌ Failed to fetch data');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gold & Silver Rates")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchRates,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildSectionTitle("Gold Rates"),
            ...goldRates.map((rate) => MetalRateCard(rate: rate)).toList(),
            const SizedBox(height: 20),
            _buildSectionTitle("Silver Rates"),
            ...silverRates.map((rate) => MetalRateCard(rate: rate)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class MetalRateCard extends StatelessWidget {
  final MetalRate rate;

  const MetalRateCard({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rate.product,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (rate.description.isNotEmpty)
              Text(rate.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Price:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(rate.price,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
