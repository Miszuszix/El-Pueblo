import 'package:material_ui/material_ui.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

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
          // Aquí posteriormente iremos a la siguiente pantalla.
        },
        label: const Text('NEXT'),
        icon: const Icon(Icons.arrow_forward),
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

              child: const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
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