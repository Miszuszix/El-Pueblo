import 'package:material_ui/material_ui.dart';

import 'game_logic.dart';
import 'title_screen.dart';

class WinnerScreen extends StatelessWidget {
  const WinnerScreen({
    super.key,
    required this.winner,
    required this.players,
  });

  final GameWinner winner;
  final List<Player> players;

  String get _title {
    switch (winner) {
      case GameWinner.werewolves:
        return 'WEREWOLVES WIN!';
      case GameWinner.villagers:
        return 'VILLAGERS WIN!';
      case GameWinner.lovers:
        return 'THE LOVERS WIN!';
      case GameWinner.nobody:
        return 'NOBODY WINS';
    }
  }

  String get _subtitle {
    switch (winner) {
      case GameWinner.werewolves:
        return 'The werewolves now outnumber the village.';
      case GameWinner.villagers:
        return 'Every werewolf has been eliminated.';
      case GameWinner.lovers:
        return 'The lovers are the last ones standing.';
      case GameWinner.nobody:
        return 'Everyone is dead.';
    }
  }

  IconData get _icon {
    switch (winner) {
      case GameWinner.werewolves:
        return Icons.pets;
      case GameWinner.villagers:
        return Icons.home;
      case GameWinner.lovers:
        return Icons.favorite;
      case GameWinner.nobody:
        return Icons.close;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Icon(_icon, size: 90, color: Colors.amber),

              const SizedBox(height: 16),

              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(3, 4),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),

              const SizedBox(height: 24),

              // Final status of every player
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        player.alive ? Icons.favorite : Icons.close,
                        color: player.alive ? Colors.green[400] : Colors.red[400],
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          decoration:
                              player.alive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      trailing: Text(
                        player.role,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TitleScreen(),
                    ),
                    (route) => false,
                  ),
                  child: const Text(
                    'BACK TO MENU',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
