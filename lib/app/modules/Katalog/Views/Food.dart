import 'package:demo_mobile/app/modules/Katalog/Views/detailProduk.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _username = "Loading...";
  String _profileImageUrl = "";
  String _searchQuery = "";
  String _selectedCategory = "All"; // Default: Tampilkan semua kategori
  List<String> _categories = ["All"]; // Untuk menyimpan daftar kategori

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _searchController = TextEditingController();

  bool _isListening = false;
  List<QueryDocumentSnapshot> _catalogData = [];
  List<QueryDocumentSnapshot> _filteredCatalogData = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchCategories();
    _fetchCatalogData();
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

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('products').get(); // Ambil data produk
      Set<String> categories = {"All"}; // Tambahkan kategori default
      for (var doc in snapshot.docs) {
        String category = doc.get('category') ?? "Uncategorized";
        categories.add(category); // Tambahkan kategori dari database
      }
      setState(() {
        _categories = categories.toList(); // Konversi ke list
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _fetchCatalogData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      setState(() {
        _catalogData = snapshot.docs;
        _filteredCatalogData = _catalogData; // Awalnya semua data tampil
      });
    } catch (e) {
      print("Error fetching catalog data: $e");
    }
  }

  void _filterCatalog(String query, String category) {
    setState(() {
      if (query.isEmpty && (category == "All")) {
        // Jika pencarian kosong dan kategori "All", tampilkan semua data
        _filteredCatalogData = _catalogData;
      } else {
        _filteredCatalogData = _catalogData.where((doc) {
          String productName = (doc.get('name') ?? "").toLowerCase();
          String productCategory = (doc.get('category') ?? "Uncategorized");
          bool matchesQuery = productName.contains(query.toLowerCase());
          bool matchesCategory =
              category == "All" || productCategory == category;
          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchQuery = result.recognizedWords.trim();
            _searchController.text = _searchQuery; // Update search bar
            _filterCatalog(_searchQuery, _selectedCategory);
          });
        },
      );
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
        backgroundColor: Colors.orange.shade100,
        title: Row(
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
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              // Navigasi ke halaman keranjang
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterCatalog(value, _selectedCategory);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for a product...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Tampilan kategori dengan dropdown
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _filterCatalog(_searchQuery, _selectedCategory);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: _selectedCategory == category
                                ? Colors.orange
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: _selectedCategory == category
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredCatalogData.isEmpty
                ? Center(child: Text("No products found."))
                : ListView.builder(
                    itemCount: _filteredCatalogData.length,
                    itemBuilder: (context, index) {
                      final product = _filteredCatalogData[index];
                      final productId = product.id; // Ambil ID produk
                      return Card(
                        child: ListTile(
                          leading: Image.network(product['imageUrl']),
                          title: Text(product['name']),
                          subtitle:
                              Text('Starting from \$${product['price']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  productId: productId, // Kirimkan productId
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: Colors.black,
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            backgroundColor: Colors.black,
            label: 'Article',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            backgroundColor: Colors.black,
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: Colors.black,
            label: 'Profile',
          ),
        ],
        currentIndex: 2, // Current page index
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/articles');
              break;
            case 2:
              // Shooping
              break;
            case 3:
              Navigator.pushNamed(context, '/profiles');
              break;
          }
        },
      ),
    );
  }
}
