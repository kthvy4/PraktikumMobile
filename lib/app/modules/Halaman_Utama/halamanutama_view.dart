import 'package:demo_mobile/app/modules/camera/camera_page.dart';
import 'package:demo_mobile/app/data/service/service_api.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> _catImagesFuture;
  late Future<List<Map<String, dynamic>>> _recommendedProductsFuture;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _username = "Memuat...";
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _catImagesFuture = CatApiService().fetchCatImages(limit: 5);
    _recommendedProductsFuture = _fetchRecommendedProducts();
    _fetchUserName();
  }

  Future<List<Map<String, dynamic>>> _fetchRecommendedProducts() async {
    // Gantilah dengan logika data Anda
    return [
      {"name": "Whiskas Junior", "price": "36/kg", "image": "https://via.placeholder.com/80"},
      {"name": "Snack Cat", "price": "36/kg", "image": "https://via.placeholder.com/80"},
    ];
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot =
            await _firestore.collection('Profile').doc(user.uid).get();

        if (snapshot.exists) {
          setState(() {
            _username = snapshot.get('Nama') ?? "User";
            _profileImageUrl = snapshot.get('profileImageUrl') ?? "";
          });
        } else {
          setState(() {
            _username = "User not found";
            _profileImageUrl = "";
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _searchQuery = result.recognizedWords;
          _searchController.text = _searchQuery;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CatCare'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            children: [
            CircleAvatar(
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? NetworkImage(_profileImageUrl)
                  : null,
              child: _profileImageUrl.isEmpty
                  ? Icon(Icons.person, color: Colors.orange)
                  : null,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              _username,
              style: TextStyle(color: Colors.black),
            ),
          ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildFutureBuilder<List<String>>(
            future: _catImagesFuture,
            title: "Gambar Kucing",
            itemBuilder: (context, images) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: images.map((url) => _buildImageCard(url)).toList(),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _buildFutureBuilder<List<Map<String, dynamic>>>(
            future: _recommendedProductsFuture,
            title: "Rekomendasi Produk",
            itemBuilder: (context, products) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products.map((product) => _buildProductCard(product)).toList(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CameraPage())),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1: Navigator.pushNamed(context, '/articles'); break;
            case 2: Navigator.pushNamed(context, '/shopping'); break;
            case 3: Navigator.pushNamed(context, '/profiles'); break;
          }
        },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
              backgroundColor: Colors.blue,  // warna untuk item ini
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Artikel',
              backgroundColor: Colors.green,  // warna untuk item ini
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Belanja',
              backgroundColor: Colors.orange,  // warna untuk item ini
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
              backgroundColor: Colors.purple,  // warna untuk item ini
            ),
          ],
          selectedItemColor: Colors.white,  // warna saat item terpilih
          unselectedItemColor: Colors.grey,  // warna saat item tidak terpilih
        )
    );
  }
  Widget _buildFutureBuilder<T>({
    required Future<T> future,
    required String title,
    required Widget Function(BuildContext, T) itemBuilder,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          return itemBuilder(context, snapshot.data as T);
        } else {
          return Center(child: Text("$title tidak tersedia"));
        }
      },
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            Image.network(product['image'], width: 80, height: 80, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text(product['price']),
          ],
        ),
      ),
    );
  }
}