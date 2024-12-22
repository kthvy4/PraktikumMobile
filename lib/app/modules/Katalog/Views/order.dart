import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late Stream<QuerySnapshot> ordersStream;

  @override
  void initState() {
    super.initState();
    ordersStream = FirebaseFirestore.instance.collection('Orders').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];

              // Safely access fields and provide fallback values
              final orderId = order.data().toString().contains('orderId') 
                ? order['orderId'] 
                : 'N/A';
              final status = order.data().toString().contains('status') 
                ? order['status'] 
                : 'Unknown';
              final total = order.data().toString().contains('total') 
                ? order['total'] 
                : 0;

              return ListTile(
                title: Text("Order ID: $orderId"),
                subtitle: Text("Status: $status"),
                trailing: Text("Rp $total"),
              );
            },
          );
        },
      ),
    );
  }
}
