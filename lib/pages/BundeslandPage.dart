import 'package:flutter/material.dart';

class BundeslandPage extends StatelessWidget {
  const BundeslandPage({super.key});

  // Liste der Bundesländer
  static const List<String> _bundeslaender = [
    'Baden-Württemberg',
    'Bayern',
    'Berlin',
    'Brandenburg',
    'Bremen',
    'Hamburg',
    'Hessen',
    'Mecklenburg-Vorpommern',
    'Niedersachsen',
    'Nordrhein-Westfalen',
    'Rheinland-Pfalz',
    'Saarland',
    'Sachsen',
    'Sachsen-Anhalt',
    'Schleswig-Holstein',
    'Thüringen'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Bitte wähle dein Bundesland"),
            ListView.builder(
              itemCount: _bundeslaender.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_bundeslaender[index]),
                  onTap: () {
                    // Hier kannst du definieren, was passieren soll, wenn ein Bundesland ausgewählt wird
                    print('Gewähltes Bundesland: ${_bundeslaender[index]}');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
