import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Product {
  String name;
  double price;
  double gstRate;
  double gstAmount;
  double total;
  double cgst;
  double sgst;

  Product({
    required this.name,
    required this.price,
    required this.gstRate,
    required this.cgst,
    required this.sgst,
    required this.gstAmount,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'gstRate': gstRate,
      'cgst': gstRate / 2,
      'sgst': gstRate / 2,
      'gstAmount': gstAmount,
      'total': total,
    };
  }
}

class gstCalculator extends StatefulWidget {
  const gstCalculator({super.key});

  @override
  gstCalculatorState createState() => gstCalculatorState();
}

class gstCalculatorState extends State<gstCalculator> {
  List<Product> products = [];
  double totalAmount = 0.0;
  double totalGST = 0.0;
  double grandTotal = 0.0;
  double totalCgst = 0.0;
  double totalSgst = 0.0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  double _selectedGSTRate = 18.0;
  

  void _addProduct() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    double price = double.tryParse(_priceController.text) ?? 0.0;
    double gstAmount = price * (_selectedGSTRate / 100);
    double cgst = gstAmount / 2;
    double sgst = gstAmount / 2;
    double total = price + gstAmount;

    setState(() {
      products.add(Product(
        name: _nameController.text,
        price: price,
        gstRate: _selectedGSTRate,
        gstAmount: gstAmount,
        cgst: cgst,
        sgst: sgst,
        total: total,
      ));
      _calculateTotals();
    });

    _nameController.clear();
    _priceController.clear();
  }

  void _calculateTotals() {
    totalAmount = products.fold(0.0, (sum, product) => sum + product.price);
    totalGST = products.fold(0.0, (sum, product) => sum + product.gstAmount);
    totalCgst = products.fold(0.0, (sum, product) => sum + product.cgst);
    totalSgst = products.fold(0.0, (sum, product) => sum + product.sgst);
    grandTotal = products.fold(0.0, (sum, product) => sum + product.total);
  }

  void _removeProduct(int index) {
    setState(() {
      products.removeAt(index);
      _calculateTotals();
    });
  }

  Future<void> _saveInvoiceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('invoice_history') ?? [];
    
    final invoiceData = {
      'date': DateTime.now().toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalGST': totalGST,
      'totalSgst': totalSgst,
      'totalCgst': totalCgst,
      'grandTotal': grandTotal,
    };
    
    history.add(jsonEncode(invoiceData));
    await prefs.setStringList('invoice_history', history);
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('22DIT022 - N-MART'),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Product Name'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Price'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('GST Rate'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('GST Amount'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Total'),
                      ),
                    ],
                  ),
                  ...products.map((product) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(product.name),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${product.price.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${product.gstRate}%'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${product.gstAmount.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${product.total.toStringAsFixed(2)}'),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount:'),
                  pw.Text('${totalAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total CGST:'),
                  pw.Text('${totalCgst.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total SGST:'),
                  pw.Text('${totalSgst.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total GST:'),
                  pw.Text('${totalGST.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total:'),
                  pw.Text('${grandTotal.toStringAsFixed(2)}'),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    
    // Save invoice history after generating PDF
    await _saveInvoiceHistory();
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice saved and PDF generated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('Invoice Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _generatePDF,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select GST Rate:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedGSTRate == 5.0 ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedGSTRate = 5.0;
                      });
                    },
                    child: const Text('5%'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedGSTRate == 12.0 ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedGSTRate = 12.0;
                      });
                    },
                    child: const Text('12%'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedGSTRate == 18.0 ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedGSTRate = 18.0;
                      });
                    },
                    child: const Text('18%'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedGSTRate == 28.0 ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedGSTRate = 28.0;
                      });
                    },
                    child: const Text('28%'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Add Product'),
              ),
              const SizedBox(height: 20),
              if (products.isNotEmpty) ...[
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Price: ₹${product.price.toStringAsFixed(2)}\n'
                          'SGST: ${product.gstRate}% (₹ ${(product.gstAmount/2).toStringAsFixed(2)})\n'
                          'CGST: ${product.gstRate}% (₹ ${(product.gstAmount/2).toStringAsFixed(2)})\n'
                          'GST: ${product.gstRate}% (₹${product.gstAmount.toStringAsFixed(2)})\n'
                          'Total: ₹${product.total.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeProduct(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount:'),
                            Text('₹${totalAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total CGST:'),
                            Text('₹${totalCgst.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total SGST:'),
                            Text('₹${totalSgst.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total GST:'),
                            Text('₹${totalGST.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:'),
                            Text(
                              '₹${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
