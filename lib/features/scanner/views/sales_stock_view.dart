import 'package:flutter/material.dart';

/// Where "Sales stock" lands: items going out to a customer.
///
/// A placeholder for now — the screen exists so the purpose chooser has a real
/// destination, and the flow below it can be built without moving navigation
/// around again.
class SalesStockView extends StatelessWidget {
  const SalesStockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales stocks')),
      body: const Center(child: Text('Sales stock flow goes here.')),
    );
  }
}
