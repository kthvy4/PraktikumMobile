import 'package:demo_mobile/app/modules/Katalog/Views/keranjang.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pastikan ini mengimpor halaman CartPage Anda
import 'checkout.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  // Constructor menerima productId
  ProductDetailPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final cartCollection = firestore.collection('cart');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart), // Ikon keranjang
            onPressed: () {
              // Navigasi ke halaman keranjang
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('products').doc(productId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error loading product details.'));
          }

          final productData = snapshot.data!;
          final name = productData['name'];
          final details = productData['details'];
          final price = productData['price'].toDouble(); // Pastikan harga dalam tipe double
          final imageUrl = productData['imageUrl'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                const Text('Details', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  details,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // Tambahkan produk ke keranjang
                          await cartCollection.add({
                            'productId': productId,
                            'name': name,
                            'price': price,
                            'imageUrl': imageUrl,
                            'quantity': 1, // Default quantity = 1
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil ditambahkan ke keranjang'),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'Add To Cart',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman Checkout langsung
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                selectedItems: [
                                  {
                                    'name': name,
                                    'price': price,
                                    'quantity': 1, // Default quantity
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'Buy Now',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
