import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_mobile/app/modules/Katalog/Views/order.dart';
import 'package:demo_mobile/app/modules/Settings/alamat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Ganti dengan path yang sesuai

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  CheckoutPage({required this.selectedItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedAddress = "Loading...";
  String selectedPaymentMethod = "OVO";
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAddressFromFirestore();
  }

  Future<void> _getAddressFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Profile')
            .doc(userId)
            .get();

        setState(() {
          selectedAddress = snapshot.exists
              ? snapshot['alamat'] ?? "Alamat tidak tersedia"
              : "Dokumen tidak ditemukan";
        });
      } else {
        setState(() {
          selectedAddress = "Pengguna tidak terautentikasi";
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Gagal memuat alamat";
      });
      print("Error loading address: $e");
    }
  }

  double calculateSubtotal() {
    return widget.selectedItems.fold(0.0, (sum, item) {
      double price = item['price'] as double;
      int quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
  }

  double calculateTotal(double subtotal) {
    const double deliveryFee = 2.0;
    return subtotal + deliveryFee;
  }

  void proceedToCheckout() async {
    double subtotal = calculateSubtotal();
    double total = calculateTotal(subtotal);

    bool isPinVerified = await _verifyPinDialog();

    if (isPinVerified) {
      try {
        // Simpan data checkout ke Firestore
        await _saveCheckoutToFirestore(total);

        // Navigasi ke halaman "My Orders"
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Checkout failed: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid PIN")),
      );
    }
  }

  Future<void> _saveCheckoutToFirestore(double total) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;

    // Generate a unique order ID
    String orderId = FirebaseFirestore.instance.collection('Orders').doc().id;

    // Save order data with orderId
    await FirebaseFirestore.instance.collection('Orders').add({
      'userId': userId,
      'orderId': orderId, // Add order ID to the order data
      'items': widget.selectedItems,
      'address': selectedAddress,
      'paymentMethod': selectedPaymentMethod,
      'total': total,
      'status': 'Pending', // Status default
      'timestamp': Timestamp.now(),
    });
  } else {
    throw Exception("User is not authenticated");
  }
}

  Future<bool> _verifyPinDialog() async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Enter Payment PIN"),
              content: TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Enter PIN"),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    bool isValid = pinController.text == "135246";
                    Navigator.of(context).pop(isValid);
                  },
                  child: Text("Submit"),
                ),
              ],
            );
          },
        ) ??
        false;
  }
  void selectPaymentMethod() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text("OVO"),
              onTap: () => _updatePaymentMethod("OVO"),
            ),
            ListTile(
              title: Text("Gopay"),
              onTap: () => _updatePaymentMethod("Gopay"),
            ),
            ListTile(
              title: Text("Spay"),
              onTap: () => _updatePaymentMethod("Spay"),
            ),
          ],
        );
      },
    );
  }

  void _updatePaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    double subtotal = calculateSubtotal();
    double total = calculateTotal(subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressAndPaymentSection(),
              SizedBox(height: 16),
              ...widget.selectedItems.map((item) => _buildOrderItem(item)),
              Divider(),
              _buildSummary(subtotal, total),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: proceedToCheckout,
                child: Text("Proceed To Checkout"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressAndPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(selectedAddress),
            ),
            TextButton(onPressed: _navigateToAddressSettings, child: Text("Edit"))
          ],
        ),
        Divider(),
        Text("Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedPaymentMethod),
            TextButton(onPressed: selectPaymentMethod, child: Text("Edit"))
          ],
        ),
      ],
    );
  }

Widget _buildOrderItem(Map<String, dynamic> item) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        // Gambar item
        if (item['image'] != null)
          Image.network(
            item['image'],
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          )
        else
          Icon(Icons.image_not_supported, size: 50), // Placeholder jika gambar tidak ada
        
        SizedBox(width: 8),
        
        // Detail item
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Quantity: ${item['quantity']}"),
          ],
        ),
        
        Spacer(),
        
        // Harga item
        Text("Rp ${item['price'] * item['quantity']}"),
      ],
    ),
  );
}

  Widget _buildSummary(double subtotal, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Subtotal"),
            Text("Rp ${subtotal.toStringAsFixed(2)}"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Delivery"),
            Text("Rp 2.00"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Rp ${total.toStringAsFixed(2)}"),
          ],
        ),
      ],
    );
  }

  Future<void> _navigateToAddressSettings() async {
    String? newAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingAlamatPage()),
    );

    if (newAddress != null && newAddress.isNotEmpty) {
      setState(() {
        selectedAddress = newAddress;
      });
      await _updateAddressInFirestore(newAddress);
    }
  }

  Future<void> _updateAddressInFirestore(String newAddress) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(userId)
            .update({'alamat': newAddress});
      }
    } catch (e) {
      print("Error updating address: $e");
    }
  }
}
