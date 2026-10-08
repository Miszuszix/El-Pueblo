import 'package:material_ui/material_ui.dart';

class PlayersNamesScreen extends StatefulWidget {
  const PlayersNamesScreen({super.key});

  @override
  State<PlayersNamesScreen> createState() => _PlayersNamesScreenState();
}

class _PlayersNamesScreenState extends State<PlayersNamesScreen> {
  static const int _initialPlayerCount = 5;

  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _initialPlayerCount; i++) {
      _nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    setState(() => _nameControllers.add(TextEditingController()));
  }

  void _removePlayer(int index) {
    final removed = _nameControllers[index];
    setState(() => _nameControllers.removeAt(index));
    // Alliberem el controlador un cop la pantalla s'ha redibuixat
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jugadors')),
      body: ListView.builder(
        // El padding de baix evita que el botó + tapi l'última casella
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _nameControllers.length,
        itemBuilder: (context, index) => _PlayerCard(
          key: ObjectKey(_nameControllers[index]),
          title: 'Player ${index + 1}',
          controller: _nameControllers[index],
          onDelete: () => _removePlayer(index),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        tooltip: 'Afegir jugador',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    super.key,
    required this.title,
    required this.controller,
    required this.onDelete,
  });

  final String title;
  final TextEditingController controller;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar jugador',
                  onPressed: onDelete,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Nom del jugador',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}