import 'package:demo_mobile/app/modules/Katalog/Views/order.dart';
import 'package:demo_mobile/app/modules/Katalog/Views/uploadProduk.dart';
import 'package:demo_mobile/app/modules/Settings/Cat.dart';
import 'package:demo_mobile/app/modules/Settings/alamat.dart';
import 'package:demo_mobile/app/modules/Settings/generalsetting.dart'; // Import halaman My Order
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Suara Kucing'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CatSoundPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Google Maps'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingAlamatPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Upload Produk'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadProductPage(),
                ),
              );
            },
          ),
          // Menambahkan My Order menu
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Order'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOrdersPage(), // Ganti dengan halaman My Order yang sesuai
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
