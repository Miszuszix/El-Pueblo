import 'package:material_ui/material_ui.dart';

class PlayersNamesScreen extends StatefulWidget {
  const PlayersNamesScreen({super.key});

  @override
  State<PlayersNamesScreen> createState() => _PlayersNamesScreenState();
}

class _PlayersNamesScreenState extends State<PlayersNamesScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text("Back")
              )
            ],
          ),
        ),
      ),
    );
  }
}
