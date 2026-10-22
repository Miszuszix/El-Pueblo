import 'package:material_ui/material_ui.dart';

import 'game_logic.dart';
import 'role_colors.dart';
import 'winner_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.playerNames,
    required this.assignedRoles,
  });

  final List<String> playerNames;
  final List<String> assignedRoles;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Game _game = Game(
    names: widget.playerNames,
    roles: widget.assignedRoles,
  );

  // Players marked by the narrator in the current step
  final List<Player> _selected = [];

  // Decisions of the witch whose turn it is (null = not answered yet)
  bool? _witchHeal;
  bool? _witchPoison;

  // Vote ended in a tie (nobody is eliminated)
  bool _noElimination = false;

  // ---------------------------------------------------------------------------
  // State helpers
  // ---------------------------------------------------------------------------

  /// A dead hunter has to choose who he takes with him.
  bool get _hunterStep => _game.pendingHunters.isNotEmpty;

  /// Cupid needs two free players. If fewer are left, the turn is only faked.
  int get _cupidRequired => _game.freeForCupid.length >= 2 ? 2 : 0;

  /// How many players the narrator can mark in the current step.
  int get _maxSelection {
    if (_hunterStep) return 1;

    switch (_game.phase) {
      case GamePhase.cupid:
        return _cupidRequired;
      case GamePhase.wolves:
        return 1;
      case GamePhase.witch:
        return _witchPoison == true ? 1 : 0;
      case GamePhase.seer:
        return 0;
      case GamePhase.day:
        return 0;
      case GamePhase.vote:
        return 1;
    }
  }

  /// Whether [player] can be marked in the current step.
  bool _canSelect(Player player) {
    if (!player.alive) return false;

    // A Cupid cannot choose someone who is already in love
    if (!_hunterStep && _game.phase == GamePhase.cupid && player.isInLove) {
      return false;
    }
    return true;
  }

  /// The bottom button only works when everything has been registered.
  bool get _canAdvance {
    if (_hunterStep) return _selected.length == 1;

    switch (_game.phase) {
      case GamePhase.cupid:
        return _selected.length == _cupidRequired;
      case GamePhase.wolves:
        return _selected.length == 1;
      case GamePhase.witch:
        final witch = _game.currentActor!;
        if (!witch.healUsed && _witchHeal == null) return false;
        if (!witch.poisonUsed) {
          if (_witchPoison == null) return false;
          if (_witchPoison == true && _selected.length != 1) return false;
        }
        return true;
      case GamePhase.seer:
        return true;
      case GamePhase.day:
        return true;
      case GamePhase.vote:
        return _noElimination || _selected.length == 1;
    }
  }

  void _resetStepState() {
    _selected.clear();
    _witchHeal = null;
    _witchPoison = null;
    _noElimination = false;
  }

  void _onPlayerTap(Player player) {
    final max = _maxSelection;
    if (max == 0 || !_canSelect(player)) return;

    setState(() {
      if (_selected.contains(player)) {
        _selected.remove(player);
      } else {
        if (_selected.length >= max) _selected.removeAt(0);
        _selected.add(player);
        _noElimination = false;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Advancing
  // ---------------------------------------------------------------------------

  void _advance() {
    if (!_canAdvance) return;

    // A hunter is shooting (after the night or after a vote)
    if (_hunterStep) {
      final died = _game.hunterShoot(_selected.first);
      _announceDeaths('Hunter shot', died);

      if (_game.pendingHunters.isNotEmpty) {
        // Another hunter still has to shoot
        setState(_resetStepState);
        return;
      }
      _finishStep();
      return;
    }

    switch (_game.phase) {
      case GamePhase.cupid:
        if (_cupidRequired == 2) {
          _game.makeLovers(_selected[0], _selected[1]);
        }
        break;
      case GamePhase.wolves:
        _game.wolfVictim = _selected.first;
        break;
      case GamePhase.witch:
        _game.applyWitch(
          _game.currentActor!,
          heal: _witchHeal == true,
          poisonTarget: _witchPoison == true ? _selected.first : null,
        );
        break;
      case GamePhase.seer:
        break;
      case GamePhase.day:
        break;
      case GamePhase.vote:
        if (!_noElimination) {
          final died = _game.kill(_selected.first);
          _announceDeaths('Eliminated', died);
        }
        if (_game.pendingHunters.isNotEmpty) {
          // The voted player was the hunter: ask who he takes with him
          setState(_resetStepState);
          return;
        }
        break;
    }

    _finishStep();
  }

  /// Checks victory (after deaths) and moves to the next turn / phase.
  void _finishStep() {
    final afterDeaths =
        _game.phase == GamePhase.day || _game.phase == GamePhase.vote;

    if (afterDeaths) {
      final winner = _game.checkWinner();
      if (winner != null) {
        // Remove every game screen from the stack (back goes to the menu)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => WinnerScreen(
              winner: winner,
              players: _game.players,
            ),
          ),
              (route) => route.isFirst,
        );
        return;
      }
    }

    setState(() {
      _game.advance();
      _resetStepState();
    });
  }

  void _announceDeaths(String label, List<Player> died) {
    if (died.isEmpty) return;

    final text = died.map((p) => '${p.name} (${p.role})').join(', ');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label: $text'),
          duration: const Duration(seconds: 6),
        ),
      );
  }

  Future<void> _confirmQuit() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit game?'),
        content: const Text('The current game will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('QUIT'),
          ),
        ],
      ),
    );

    if (quit == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // ---------------------------------------------------------------------------
  // Guide texts
  // ---------------------------------------------------------------------------

  /// "Witch" or, when there are several, "Witch 2/3 (Anna)".
  String _turnLabel(String role) {
    final order = _game.turnOrder;
    if (order.length <= 1) return role;
    return '$role ${_game.turnIndex + 1}/${order.length} '
        '(${_game.currentActor!.name})';
  }

  _Guide _buildGuide() {
    final night = _game.night;
    final firstTurn = _game.turnIndex == 0;

    String? hunterPrompt;
    if (_hunterStep) {
      final hunter = _game.pendingHunters.first;
      hunterPrompt = '${hunter.name} was the Hunter! Ask them: '
          '“Who do you want to take down with you?” '
          'Mark that player above.';
    }

    switch (_game.phase) {
      case GamePhase.cupid:
        final title = 'Night $night — ${_turnLabel('Cupid')}';

        if (_cupidRequired == 0) {
          return _Guide(
            title,
            'There are not enough free players left to make fall in love.\n\n'
                'Wake up Cupid anyway for a few seconds so nobody can tell.',
          );
        }

        if (_selected.length == 2) {
          return _Guide(
            title,
            'Lovers chosen: ${_selected[0].name} and ${_selected[1].name}.\n\n'
                'Put Cupid back to sleep. Now wake up ONLY the two lovers so '
                'they can see each other, then tell them to close their eyes '
                'again.\n\n'
                'From now on, if one of them dies, the other one dies too.',
          );
        }

        final wake = firstTurn
            ? 'Tell everyone to close their eyes.\n\nWake up Cupid'
            : 'Wake up the next Cupid';
        final alreadyInLove = _game.players.any((p) => p.isInLove)
            ? '\n\nPlayers who are already in love (heart) cannot be chosen.'
            : '';
        return _Guide(
          title,
          '$wake and ask: “Cupid, who do you want to make fall in love?”\n\n'
              'When Cupid points at two players, mark them above.'
              '$alreadyInLove',
        );

      case GamePhase.wolves:
        final intro = _game.hasCupidPhase
            ? ''
            : 'Night falls. Tell everyone to close their eyes.\n\n';
        return _Guide(
          'Night $night — Werewolves',
          '${intro}Wake up the werewolves and ask: “Werewolves, who do you '
              'want to kill tonight?”\n\n'
              'They must agree on ONE victim together. Mark that player '
              'above, then put the werewolves back to sleep.',
        );

      case GamePhase.witch:
        final witch = _game.currentActor!;
        final victim = _game.wolfVictim?.name ?? '?';
        final parts = <String>[
          firstTurn ? 'Wake up the witch.' : 'Wake up the next witch.',
        ];

        if (witch.healUsed) {
          parts.add('She has already used her healing potion. Tell her who '
              'the werewolves attacked tonight ($victim), but she cannot '
              'save them.');
        } else {
          parts.add('Show her who the werewolves attacked tonight: $victim. '
              'Ask: “Do you want to save this player?”');
          if (_game.victimHealed) {
            parts.add('Note: another witch already saved this player, but '
                'this witch cannot know that. Treat it as normal; if she '
                'saves them too, her potion is wasted.');
          }
        }

        if (witch.poisonUsed) {
          parts.add('She has already used her poison potion, so she cannot '
              'kill anyone else.');
        } else {
          parts.add('Then ask: “Do you want to kill someone?” '
              'If so, mark that player above.');
        }

        if (witch.healUsed && witch.poisonUsed) {
          parts.add('Both potions are used up. Wake her anyway for a few '
              'seconds so nobody can tell.');
        } else {
          parts.add('Put the witch back to sleep.');
        }

        return _Guide(
          'Night $night — ${_turnLabel('Witch')}',
          parts.join('\n\n'),
        );

      case GamePhase.seer:
        return _Guide(
          'Night $night — ${_turnLabel('Seer')}',
          '${firstTurn ? 'Wake up the seer' : 'Wake up the next seer'} and '
              'ask: “Whose role do you want to know?”\n\n'
              'Show them the role of the player they point at (you can see '
              'every role above). Nothing needs to be recorded.\n\n'
              'Then put the seer back to sleep.',
        );

      case GamePhase.day:
        final deaths = _game.nightDeaths;
        final parts = <String>[
          'Everyone wakes up.',
          deaths.isEmpty
              ? 'Announce that nobody died last night.'
              : 'Announce who died last night and reveal their role: '
              '${deaths.map((p) => '${p.name} (${p.role})').join(', ')}.',
        ];
        parts.add(hunterPrompt ??
            'Let the village discuss. When they are ready, press NEXT to '
                'start the vote.');
        return _Guide('Day $night', parts.join('\n\n'));

      case GamePhase.vote:
        if (hunterPrompt != null) {
          return _Guide('Day $night — Vote', hunterPrompt);
        }
        return _Guide(
          'Day $night — Vote',
          'Ask the village to vote for the player to eliminate. The player '
              'with the most votes dies and their role is revealed.\n\n'
              'Mark that player above. If there is a tie, press '
              '“Nobody (tie)”.',
        );
    }
  }

  List<Widget> _buildControls() {
    if (_hunterStep) return const [];

    switch (_game.phase) {
      case GamePhase.witch:
        final witch = _game.currentActor!;
        final victim = _game.wolfVictim?.name ?? '?';
        return [
          if (!witch.healUsed)
            _YesNoRow(
              label: 'Save $victim?',
              value: _witchHeal,
              onChanged: (v) => setState(() => _witchHeal = v),
            ),
          if (!witch.poisonUsed)
            _YesNoRow(
              label: 'Kill someone?',
              value: _witchPoison,
              onChanged: (v) => setState(() {
                _witchPoison = v;
                if (!v) _selected.clear();
              }),
            ),
          if (_witchPoison == true)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Mark the player to kill above.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ];

      case GamePhase.vote:
        return [
          FilterChip(
            label: const Text('Nobody (tie)'),
            selected: _noElimination,
            onSelected: (value) => setState(() {
              _noElimination = value;
              if (value) _selected.clear();
            }),
          ),
        ];

      default:
        return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final guide = _buildGuide();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmQuit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Players (role icon + name on top)
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        for (final player in _game.players)
                          _PlayerTile(
                            player: player,
                            selected: _selected.contains(player),
                            onTap: () => _onPlayerTap(player),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Phase title + narrator guide
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      Text(
                        guide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        guide.body,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ..._buildControls(),
                    ],
                  ),
                ),
              ),

              // Next button (disabled until everything is registered)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _canAdvance ? _advance : null,
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

class _Guide {
  const _Guide(this.title, this.body);

  final String title;
  final String body;
}

/// A label with a Yes / No selector.
class _YesNoRow extends StatelessWidget {
  const _YesNoRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            emptySelectionAllowed: true,
            segments: const [
              ButtonSegment(value: true, label: Text('Yes')),
              ButtonSegment(value: false, label: Text('No')),
            ],
            selected: value == null ? <bool>{} : {value!},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }
}

/// Player name on top, role icon below (same icons and colors as the cards).
class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final Player player;
  final bool selected;
  final VoidCallback onTap;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    final color = roleColor(player.role);
    final borderColor = selected
        ? Colors.red[700]!
        : Color.lerp(color, Colors.black, 0.15)!;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: player.alive ? 1 : 0.6,
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              // Player name
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: player.alive ? null : TextDecoration.lineThrough,
                ),
              ),

              const SizedBox(height: 4),

              // Role icon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: selected ? 4 : 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/icons/${player.role.toLowerCase()}.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),

                  // Cross over dead players
                  if (!player.alive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                  // Heart over players who are in love
                  if (player.isInLove)
                    const Positioned(
                      right: -6,
                      top: -6,
                      child: Icon(Icons.favorite, color: Colors.pink, size: 22),
                    ),
                ],
              ),

              const SizedBox(height: 2),

              // Role name (useful while some icons are still missing)
              Text(
                player.role,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}