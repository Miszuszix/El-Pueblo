import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({
    super.key,
    required this.playerNames,
    required this.assignedRoles,
  }) : assert(playerNames.length == assignedRoles.length);

  /// Noms dels jugadors, en ordre.
  final List<String> playerNames;

  /// Rol assignat a cada jugador (mateixa posició que a playerNames).
  final List<String> assignedRoles;

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  int _currentIndex = 0;
  bool _revealed = false;

  bool get _isFirst => _currentIndex == 0;
  bool get _isLast => _currentIndex == widget.playerNames.length - 1;

  void _toggleCard() {
    setState(() {
      _revealed = !_revealed;
    });
  }

  void _previousPlayer() {
    if (_isFirst) return;

    setState(() {
      _currentIndex--;
      _revealed = false; // El rol sempre comença amagat
    });
  }

  void _nextPlayer() {
    if (_isLast) {
      _goToNextScreen();
      return;
    }

    setState(() {
      _currentIndex++;
      _revealed = false; // El rol sempre comença amagat
    });
  }

  // Aquí anirem a la següent pestanya del joc
  void _goToNextScreen() {
    // TODO: Navigator.push(...) cap a la pantalla següent
  }

  @override
  Widget build(BuildContext context) {
    final playerName = widget.playerNames[_currentIndex];
    final role = widget.assignedRoles[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Jugador ${_currentIndex + 1} / ${widget.playerNames.length}'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Nom del jugador a dalt
              Text(
                playerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Botó esquerre + carta + botó dret
              Expanded(
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      iconSize: 36,
                      tooltip: 'Jugador anterior',
                      onPressed: _isFirst ? null : _previousPlayer,
                      icon: const Icon(Icons.arrow_back),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 0.7,
                          child: GestureDetector(
                            onTap: _toggleCard,
                            child: _FlipCard(
                              // La key fa que en canviar de jugador la carta
                              // es reinicii sense animació (no es veu el rol nou).
                              key: ValueKey(_currentIndex),
                              revealed: _revealed,
                              role: role,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton.filled(
                      iconSize: 36,
                      tooltip: _isLast ? 'Començar partida' : 'Jugador següent',
                      onPressed: _nextPlayer,
                      icon: Icon(
                        _isLast ? Icons.play_arrow : Icons.arrow_forward,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Nom del rol: només visible amb la carta girada.
              // Alçada fixa perquè la carta no salti quan apareix/desapareix.
              SizedBox(
                height: 50,
                child: Center(
                  child: _revealed
                      ? Text(
                    role,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carta amb animació de gir. Mostra el revers o el rol segons [revealed].
class _FlipCard extends StatelessWidget {
  const _FlipCard({
    super.key,
    required this.revealed,
    required this.role,
  });

  // TODO: canvia aquests camins quan tinguis les imatges
  // (i recorda declarar-les a pubspec.yaml)
  static const String _backImagePath = 'assets/images/card_back.png';

  final bool revealed;
  final String role;

  String get _frontImagePath =>
      'assets/images/roles/${role.toLowerCase()}.png';

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: revealed ? 1 : 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        final angle = value * math.pi;
        final showFront = angle > math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspectiva
            ..rotateY(angle),
          child: showFront
          // La cara frontal es dibuixa girada 180º perquè no es vegi en mirall
              ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(math.pi),
            child: _CardFace(
              imagePath: _frontImagePath,
              fallbackIcon: Icons.style,
              fallbackText: role,
              fallbackColor: Colors.amber[200]!,
            ),
          )
              : _CardFace(
            imagePath: _backImagePath,
            fallbackIcon: Icons.help_outline,
            fallbackText: '?',
            fallbackColor: Colors.red[800]!,
          ),
        );
      },
    );
  }
}

/// Una cara de la carta. Si la imatge encara no existeix, mostra un marcador.
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.imagePath,
    required this.fallbackIcon,
    required this.fallbackText,
    required this.fallbackColor,
  });

  final String imagePath;
  final IconData fallbackIcon;
  final String fallbackText;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: fallbackColor,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(fallbackIcon, size: 80, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                fallbackText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}