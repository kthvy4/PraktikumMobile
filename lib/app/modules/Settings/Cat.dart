import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CatSoundPage extends StatefulWidget {
  const CatSoundPage({Key? key}) : super(key: key);

  @override
  State<CatSoundPage> createState() => _CatSoundPageState();
}

class _CatSoundPageState extends State<CatSoundPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentSound; // Untuk melacak suara yang sedang diputar
  final List<Map<String, String>> _catSounds = [
    {'name': 'Hungry Cat', 'path': 'sounds/hungry-cat-254850.mp3'},
    {'name': 'Crying Cat', 'path': 'sounds/cat-crying-81035.mp3'},
    {'name': 'Loud Meow', 'path': 'sounds/cat-meow-loud-225307.mp3'},
    {'name': 'Kittens Meowing', 'path': 'sounds/kittens-meowing-90204.mp3'},
    {'name': 'Angry Cat', 'path': 'sounds/angry-cat-hq-sound-effect-240675.mp3'},
  ];

  void _playSound(String path) async {
    if (isPlaying && currentSound == path) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
        currentSound = null;
      });
    } else {
      await _audioPlayer.play(AssetSource(path));
      setState(() {
        isPlaying = true;
        currentSound = path;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suara Kucing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pilih suara kucing untuk diputar:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _catSounds.length,
                itemBuilder: (context, index) {
                  final sound = _catSounds[index];
                  final isSelected = currentSound == sound['path'] && isPlaying;
                  return Card(
                    child: ListTile(
                      title: Text(sound['name']!),
                      trailing: Icon(
                        isSelected ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: isSelected ? Colors.red : Colors.blue,
                      ),
                      onTap: () => _playSound(sound['path']!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
