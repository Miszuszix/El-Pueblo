import 'package:el_pueblo/players_names_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: Colors.red[800],
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      minimumSize: const Size(220, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "EL PUEBLO",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w900,
                fontSize: 55,
                letterSpacing: 5,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(3, 4),
                    blurRadius: 5,
                  )
                ],
              ),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlayersNamesScreen(),
                ),
              ),
              style: style,
              child: const Text("START"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(),
              style: style,
              child: const Text("EXIT"),
            )
          ],
        ),
      ),
    );
  }
}