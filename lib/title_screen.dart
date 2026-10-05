import 'package:el_pueblo/players_names_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'players_names_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: TextStyle(fontSize: 30),
    );
    return MaterialApp(
      home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "EL PUEBLO",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
                onPressed: ()=>Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlayersNamesScreen()
                    )
                ),
              style: style,
              child: Text("START"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: ()=> SystemNavigator.pop(),
                style: style,
                child: Text("EXIT")
            )
          ],
        ),
      ),
      ),
    );
  }
}
