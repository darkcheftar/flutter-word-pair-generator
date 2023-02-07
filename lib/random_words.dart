import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class WordPairStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/wordpairs.txt');
  }

  Future<Set<String>> readWordPairs() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return (jsonDecode(contents) as List<dynamic>)
          ?.map((dynamic item) => item as String)
          ?.toSet() as Set<String>;
    } catch (e) {
      // If encountering an error, return 0
      return <String>{};
    }
  }

  Future<File> writeWordPairs(Set<String> wordPairs) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(jsonEncode(wordPairs.toList()));
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key, required this.storage});
  final WordPairStorage storage;

  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _randomWordPairs = <String>[];
  var _savedWordPairs = <String>{};
  @override
  void initState() {
    super.initState();
    widget.storage.readWordPairs().then((value) {
      setState(() {
        _savedWordPairs = value;
      });
    });
  }

  Future<File> _onTap(pair) {
    setState(() {
      if (_savedWordPairs.contains(pair)) {
        _savedWordPairs.remove(pair);
      } else {
        _savedWordPairs.add(pair);
      }
    });
    return widget.storage.writeWordPairs(_savedWordPairs);
  }

  Widget _buildRow(String pair) {
    bool alreadySaved = _savedWordPairs.contains(pair);
    return ListTile(
      title: Text(pair, style: const TextStyle(fontSize: 18)),
      trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null),
      onTap: () => _onTap(pair),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, item) {
        if (item.isOdd) return const Divider();
        final index = item ~/ 2;
        if (index >= _randomWordPairs.length) {
          _randomWordPairs
              .addAll(generateWordPairs().take(10).map((e) => e.asPascalCase));
        }
        return _buildRow(_randomWordPairs[index]);
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      final Iterable<ListTile> tiles = _savedWordPairs.map((String pair) {
        return ListTile(
            title: Text(pair, style: const TextStyle(fontSize: 16.0)));
      });
      final List<Widget> divided =
          ListTile.divideTiles(context: context, tiles: tiles).toList();
      return Scaffold(
          appBar: AppBar(title: const Text('Saved WordPairs')),
          body: ListView(children: divided));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('WordPair Generator'),
          actions: <Widget>[
            IconButton(onPressed: _pushSaved, icon: const Icon(Icons.list))
          ],
        ),
        body: _buildList());
  }
}
