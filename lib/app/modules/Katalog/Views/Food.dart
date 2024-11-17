import 'package:demo_mobile/app/modules/notifikasi/notification.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CatFoodPage extends StatefulWidget {
  @override
  _CatFoodPageState createState() => _CatFoodPageState();
}

class _CatFoodPageState extends State<CatFoodPage> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (val) {
        setState(() {
          _searchController.text = val.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pets, color: Colors.orange),
            SizedBox(width: 8),
            Text('wulan'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Navigate to Notification Page
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage()));
              },
            ),
          ],
        ),
        backgroundColor: Colors.orange[50],
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Need a food for your cat?',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                filled: true,
                fillColor: Colors.orange[50],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CategoryButton(label: 'Food'),
              CategoryButton(label: 'Accessories'),
              CategoryButton(label: 'Care'),
              CategoryButton(label: 'Health'),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('cat_foods').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var catFood = snapshot.data!.docs[index];
                    return ListTile(
                      leading: Image.network(catFood['imageUrl'], width: 50, height: 50),
                      title: Text(catFood['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Starting from ${catFood['price']}/KG\n${catFood['description']}'),
                      onTap: () {
                        // Navigate to Detail Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailPage(catFood: catFood)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Article'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;

  CategoryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: Colors.orange[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final QueryDocumentSnapshot catFood;

  DetailPage({required this.catFood});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(catFood['name']),
      ),
      body: Column(
        children: [
          Image.network(catFood['imageUrl']),
          Text(catFood['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(catFood['description']),
          Text('Price: ${catFood['price']}/KG'),
          // Add other details and purchase options here
        ],
      ),
    );
  }
}
