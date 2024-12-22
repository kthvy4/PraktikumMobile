import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingAlamatPage extends StatefulWidget {
  @override
  _SettingAlamatPageState createState() => _SettingAlamatPageState();
}

class _SettingAlamatPageState extends State<SettingAlamatPage> {
  TextEditingController _alamatController = TextEditingController();
  String? _currentLocation;
  String? _savedAlamat;
  double? _latitude; // Variabel untuk lintang
  double? _longitude; // Variabel untuk bujur

  @override
  void initState() {
    super.initState();
    _loadSavedAlamat();
  }

  // Load alamat yang tersimpan di SharedPreferences
  Future<void> _loadSavedAlamat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedAlamat = prefs.getString('alamat') ?? '';
      _alamatController.text = _savedAlamat ?? '';
    });
  }

  // Menyimpan alamat di SharedPreferences dan Firestore
  Future<void> _saveAlamat(String alamat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('alamat', alamat);

    // Simpan ke Firestore
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'user-id';  // Ambil ID pengguna saat ini
    FirebaseFirestore.instance.collection('Profile').doc(userId).update({
      'alamat': alamat,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat berhasil disimpan!')),
      );

      // Perbarui alamat di halaman lain (misalnya profile atau checkout)
      Navigator.pop(context); // Kembali ke halaman sebelumnya setelah berhasil menyimpan
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan alamat: $error')),
      );
    });
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Mengonversi koordinat ke alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      String alamat = "${place.street}, ${place.locality}, ${place.subAdministrativeArea}";

      setState(() {
        _currentLocation = alamat;
        _latitude = position.latitude; // Simpan lintang
        _longitude = position.longitude; // Simpan bujur
        _alamatController.text = alamat; // Isi alamat otomatis di field
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
      );
    }
  }

  // Fungsi untuk membuka Google Maps
  Future<void> _openGoogleMaps() async {
    const googleMapsUrl = "https://www.google.com/maps";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Tidak dapat membuka Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Lokasi'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alamat Kamu:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _savedAlamat ?? 'Belum diatur',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                labelText: 'Masukkan Alamat',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_latitude != null && _longitude != null) ...[
              Text(
                'Koordinat Lokasi:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Latitude: $_latitude',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                'Longitude: $_longitude',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: Icon(Icons.location_on),
                  label: Text('Lokasi Saat Ini'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: Icon(Icons.map),
                  label: Text('Buka Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_alamatController.text.isNotEmpty) {
                  _saveAlamat(_alamatController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alamat tidak boleh kosong!')),
                  );
                }
              },
              child: Text('Simpan Alamat'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
