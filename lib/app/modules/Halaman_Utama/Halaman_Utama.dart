import 'dart:io';
import 'package:demo_mobile/app/data/service/service_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> _catImagesFuture;
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String _username = "Loading..."; // Nama pengguna default
  String _profileImageUrl = ""; // URL foto profil default

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Profile')
            .doc(uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            _username = snapshot.get('Nama'); // Gunakan field 'Nama'
            _profileImageUrl = snapshot.get('profileImageUrl'); // Gunakan field 'profileImageUrl'
          });
        } else {
          setState(() {
            _username = "User not found";
            _profileImageUrl = ""; // Jika dokumen tidak ditemukan, kosongkan foto
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _username = "Error fetching data";
         _profileImageUrl = ""; // Jika terjadi error, kosongkan foto
      });
    }
  }

  // List makanan kucing (data awal)
  final List<Map<String, String>> _catFood = [
    {"name": "Whiskas Junior", "price": "36/kg", "image": "https://path-to-image.jpg"},
    {"name": "Snack Cat", "price": "36/kg", "image": "https://path-to-image.jpg"},
    {"name": "Felix Cat", "price": "35/kg", "image": "https://path-to-image.jpg"},
    {"name": "Vitamin Cat", "price": "35/kg", "image": "https://path-to-image.jpg"},
  ];

  // List hasil pencarian
  List<Map<String, String>> _filteredCatFood = [];

  @override
  void initState() {
    super.initState();
    _catImagesFuture = CatApiService().fetchCatImages(limit: 5); // Fetch 5 cat images
    _fetchUserName(); // Ambil nama pengguna saat halaman dimulai
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
            String recognizedText = result.recognizedWords.trim().toLowerCase(); // Normalisasi teks
            print("Recognized Text: $recognizedText"); // Debugging
            _searchQuery = recognizedText;
            _searchController.text = recognizedText; // Update search bar
            _filterResults(recognizedText); // Filter hasil pencarian
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

    void _filterResults(String query) {
    setState(() {
      _filteredCatFood = _catFood
          .where((item) =>
              item["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickImageOrVideo(bool isImage) async {
  try {
    final pickedFile = await (isImage
        ? _picker.pickImage(source: ImageSource.camera)
        : _picker.pickVideo(source: ImageSource.camera));

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      
      if (isImage) {
        // Simpan gambar ke galeri
        final bool? isSaved = await GallerySaver.saveImage(file.path, albumName: 'CatCare');
        if (isSaved == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image.')),
          );
        }
      } else {
        // Simpan video ke galeri
        final bool? isSaved = await GallerySaver.saveVideo(file.path, albumName: 'CatCare');
        if (isSaved == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save video.')),
          );
        }
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CatCare'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications'); // Navigate to notifications page
            },
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
                    ? NetworkImage(_profileImageUrl) // Jika URL foto ada, gunakan
                    : AssetImage('assets/default_avatar.png')
                        as ImageProvider, // Jika tidak ada, gunakan gambar default
                radius: 30,
              ),
              SizedBox(width: 16),
              Text(
                "Welcome, $_username!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterResults(_searchQuery); // Filter hasil saat teks berubah
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
          Text(
            'Welcome in CatCare!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          FutureBuilder<List<String>>(
            future: _catImagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.network(snapshot.data![index]),
                      );
                    },
                  ),
                );
              } else {
                return Center(child: Text('No data found'));
              }
            },
          ),
          SizedBox(height: 16),

          // Recommended cat food section
    // Hasil pencarian
          Text(
            'Recommended',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _filteredCatFood.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredCatFood.length,
                  itemBuilder: (context, index) {
                    final item = _filteredCatFood[index];
                    return _buildRecommendedItem(
                        item["name"]!, item["image"]!, item["price"]!);
                  },
                )
              : Center(child: Text('No results found')), // Jika tidak ada hasil
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'Photo') {
            _pickImageOrVideo(true); // Capture image
          } else if (value == 'Video') {
            _pickImageOrVideo(false); // Capture video
          }
        },
        itemBuilder: (BuildContext context) {
          return {'Photo', 'Video'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
        child: FloatingActionButton(
          child: Icon(Icons.camera),
          onPressed: null,
        ),
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
        currentIndex: 0, // Current page index
        onTap: (index) {
          switch (index) {
            case 0:
              // Home
              break;
            case 1:
              Navigator.pushNamed(context, '/articles');
              break;
            case 2:
              Navigator.pushNamed(context, '/shopping');
              break;
            case 3:
              Navigator.pushNamed(context, '/profiles');
              break;
          }
        },
      ),
    );
  }

  // Function to build each recommended item widget
  Widget _buildRecommendedItem(String title, String imageUrl, String price) {
    return Column(
      children: [
        Image.network(imageUrl, height: 100),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(price),
      ],
    );
  }
}
