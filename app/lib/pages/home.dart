import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:kassa/utils/db.dart';

class Product {
  final String name;
  final int price;

  Product(this.name, this.price);
}

class CartItem {
  final Product product;
  final String code;

  CartItem(this.product, this.code);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<CartItem> cart = [];
  bool isScanning = false;

  void openScanner() {
    setState(() {
      isScanning = true;
    });
  }

  int get total => cart.fold(0, (sum, item) => sum + item.product.price);

  void onDetectBarcode(String code) async {
    final product = await DB.getProduct(code);

    if (product != null) {
      final item = Product(product['name'], product['price']);

      setState(() {
        cart.add(CartItem(item, code));
      });
    } else {
      openAddProductDialog(code);
    }

    setState(() {
      isScanning = false;
    });
  }

  void openAddProductDialog(String code) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Добавление нового товара в базу'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Штрих-код: $code"),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Название"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Цена"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final price = int.tryParse(priceController.text) ?? 0;

                await DB.insertProduct(code, name, price);

                if (mounted && name.isNotEmpty && price > 0) {
                  setState(() {
                    cart.add(CartItem(Product(name, price), code));
                  });

                  Navigator.pop(context);
                }
              },
              child: Text("Сохранить"),
            ),
          ],
        );
      },
    );
  }

  void openEditProductDialog(String code, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Редактировать товар"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Штрих-код: $code"),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Название"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Цена"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final price = int.tryParse(priceController.text) ?? 0;

                await DB.updateProduct(code, name, price);

                if (mounted && name.isNotEmpty && price > 0) {
                  setState(() {
                    final index = cart.indexWhere((item) => item.code == code);
                    if (index != -1) {
                      cart[index] = CartItem(Product(name, price), code);
                    }
                  });

                  Navigator.pop(context);
                }
              },
              child: Text("Сохранить"),
            ),
          ],
        );
      },
    );
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isScanning) {
      return Scaffold(
        appBar: AppBar(title: const Text("Сканирование")),
        body: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.first.rawValue;

            if (barcode != null) {
              onDetectBarcode(barcode);
            }
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Касса")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item.product.name),
                  trailing: Text("${item.product.price} ₸"),
                  onLongPress: () {
                    openEditProductDialog(item.code, item.product);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Итого: $total ₸",
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: openScanner,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: clearCart,
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
