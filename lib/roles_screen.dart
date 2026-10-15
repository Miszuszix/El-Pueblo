import 'package:material_ui/material_ui.dart';
import 'player_roles.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key, required this.playerNames});

  final List<String> playerNames;

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final List<String> _roles = [
    'Witch',
    'Werewolf',
    'Cupid',
    'Hunter',
    'Seer',
  ];

  final List<int> _quantities = [0, 0, 0, 0, 0];

  void _increaseRole(int index) {
    setState(() {
      _quantities[index]++;
    });
  }

  void _decreaseRole(int index) {
    if (_quantities[index] > 0) {
      setState(() {
        _quantities[index]--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Roles'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _roles.length,

        itemBuilder: (context, index) {
          return _RoleCard(
            roleName: _roles[index],
            quantity: _quantities[index],
            onAdd: () => _increaseRole(index),
            onRemove: () => _decreaseRole(index),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _goToReveal();
        },
        label: const Text('NEXT'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }

  //Funcio per passar a revelar rols
  void _goToReveal() {
    final players = widget.playerNames.length;
    final total = _quantities.fold<int>(0, (a, b) => a + b);

    if (total > players) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has triat $total rols però només hi ha $players jugadors'),
        ),
      );
      return;
    }

    final deck = <String>[];
    for (var i = 0; i < _roles.length; i++) {
      for (var j = 0; j < _quantities[i]; j++) {
        deck.add(_roles[i]);
      }
    }
    while (deck.length < players) {
      deck.add('Villager'); // Els que no tenen rol especial són vilatans
    }
    deck.shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoleRevealScreen(
          playerNames: widget.playerNames,
          assignedRoles: deck,
        ),
      ),
    );
  }


}


class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.roleName,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final String roleName;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [

            // Hueco reservado para la imagen del rol.
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/icons/${roleName.toLowerCase()}.png',
                  fit: BoxFit.cover,
                  // Si la imagen no existe, se ve el icono gris de antes
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    roleName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      // Botón -
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.remove),
                      ),

                      // Cantidad
                      Container(
                        width: 40,
                        alignment: Alignment.center,

                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Botón +
                      IconButton(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}