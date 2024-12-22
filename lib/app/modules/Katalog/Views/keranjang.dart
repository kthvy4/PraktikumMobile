import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_mobile/app/modules/Katalog/Views/checkout.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  Future<void> _checkout(BuildContext context, CollectionReference cartCollection) async {
    final orderCollection = FirebaseFirestore.instance.collection('orders');

    try {
      // Ambil semua item dari keranjang
      final cartSnapshot = await cartCollection.get();

      if (cartSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keranjang kosong, tidak ada yang dibeli.')),
        );
        return;
      }

      // Persiapkan data untuk order
      final cartItems = cartSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'productId': data['productId'],
          'name': data['name'],
          'price': data['price'],
          'quantity': data['quantity'],
          'imageUrl': data['imageUrl'],
        };
      }).toList();

      // Hitung total harga
      final totalPrice = cartItems.fold<int>(0, (sum, item) {
        final price = item['price'] as double;
        final quantity = item['quantity'] as int;
        return sum + (price * quantity).toInt();
      });

      // Tambahkan semua item ke koleksi orders
      await orderCollection.add({
        'items': cartItems,
        'totalPrice': totalPrice,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
      });

      // Hapus semua item dari keranjang
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // Navigasikan ke halaman checkout dengan data barang yang dibeli
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            selectedItems: cartItems,
          ),
        ),
      );

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembelian berhasil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat melakukan pembelian: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCollection = FirebaseFirestore.instance.collection('cart');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Keranjang kosong'),
            );
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final data = item.data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(data['imageUrl']),
                title: Text(data['name']),
                subtitle: Text('Harga: Rp ${data['price']} x ${data['quantity']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    cartCollection.doc(item.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _checkout(context, cartCollection),
          child: const Text('Beli Semua'),
        ),
      ),
    );
  }
}
