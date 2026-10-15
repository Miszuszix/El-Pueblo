import 'dart:math' as math;
import 'role_colors.dart';
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
        centerTitle: true,
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

  final bool revealed;
  final String role;

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
            child: _CardFront(role: role),
          )
              : const _CardBack(),
        );
      },
    );
  }
}

/// Revers de la carta (vermell amb un "?")
class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[900]!, width: 3),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: 80, color: Colors.white),
          SizedBox(height: 12),
          Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cara frontal: color pastel + símbol del rol + nom
class _CardFront extends StatelessWidget {
  const _CardFront({required this.role});

  final String role;


  @override
  Widget build(BuildContext context) {
    final key = role.toLowerCase();
    final background = roleColor(role);
    final border = Color.lerp(background, Colors.black, 0.15)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 3),
      ),
      child: Column(
        children: [
          // Símbol del rol (mateixa carpeta d'icones que la pantalla de rols)
          Expanded(
            child: Image.asset(
              'assets/images/icons/$key.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.style, size: 80, color: Colors.black38),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Nom del rol
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              role,
              style: const TextStyle(
                color: Color(0xFF3A3A3A),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}