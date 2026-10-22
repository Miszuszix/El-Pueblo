/// Role names used across the whole game.
class Roles {
  static const String witch = 'Witch';
  static const String werewolf = 'Werewolf';
  static const String cupid = 'Cupid';
  static const String hunter = 'Hunter';
  static const String seer = 'Seer';
  static const String villager = 'Villager';
}

enum GamePhase { cupid, wolves, witch, seer, day, vote }

enum GameWinner { werewolves, villagers, lovers, nobody }

class Player {
  Player({required this.name, required this.role});

  final String name;
  final String role;
  bool alive = true;

  /// The player this one is in love with (set by a Cupid).
  Player? lover;

  /// Witch potions: every witch has her own, usable once per game.
  bool healUsed = false;
  bool poisonUsed = false;

  bool get isWerewolf => role == Roles.werewolf;
  bool get isInLove => lover != null;
}

/// Pure game logic (no UI). The screen only calls these methods.
class Game {
  Game({required List<String> names, required List<String> roles})
      : players = [
    for (var i = 0; i < names.length; i++)
      Player(name: names[i], role: roles[i]),
  ],
        phase =
        roles.contains(Roles.cupid) ? GamePhase.cupid : GamePhase.wolves {
    _enterPhase(phase);
  }

  final List<Player> players;
  GamePhase phase;

  /// Current night / day number (Night 1 -> Day 1 -> Night 2 -> ...).
  int night = 1;

  /// Players that act one after another in the current phase
  /// (several Cupids, several Witches, several Seers). Werewolves act
  /// together, so their phase has no turns.
  List<Player> turnOrder = [];
  int turnIndex = 0;

  // Things registered during the current night.
  Player? wolfVictim;
  bool _victimHealed = false;
  final List<Player> _poisonTargets = [];

  /// Players who died at dawn (announced during the day phase).
  List<Player> nightDeaths = [];

  /// Dead hunters who still have to choose who they take with them.
  final List<Player> pendingHunters = [];

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  Player? get currentActor => turnOrder.isEmpty ? null : turnOrder[turnIndex];

  List<Player> get alivePlayers => players.where((p) => p.alive).toList();

  /// Alive players who are not in love yet (the ones a Cupid can choose).
  List<Player> get freeForCupid =>
      players.where((p) => p.alive && !p.isInLove).toList();

  bool hasAlive(String role) =>
      players.any((p) => p.alive && p.role == role);

  /// Whether tonight starts with the Cupid phase (first night only).
  bool get hasCupidPhase =>
      night == 1 && players.any((p) => p.role == Roles.cupid);

  /// True when some witch already saved tonight's victim.
  bool get victimHealed => _victimHealed;

  // ---------------------------------------------------------------------------
  // Registering things
  // ---------------------------------------------------------------------------

  void makeLovers(Player a, Player b) {
    a.lover = b;
    b.lover = a;
  }

  /// Registers one witch's decisions. Nothing dies until dawn, so a second
  /// witch can poison the same player (both potions are spent) or save a
  /// victim that another witch already saved.
  void applyWitch(Player witch, {required bool heal, Player? poisonTarget}) {
    if (heal) {
      witch.healUsed = true;
      _victimHealed = true;
    }
    if (poisonTarget != null) {
      witch.poisonUsed = true;
      _poisonTargets.add(poisonTarget);
    }
  }

  /// Kills [target] (and his/her lover). Returns everybody who just died.
  /// Dead hunters are queued so they can take someone with them.
  List<Player> kill(Player target) {
    final died = <Player>[];

    void die(Player p) {
      if (!p.alive) return;
      p.alive = false;
      died.add(p);
      if (p.role == Roles.hunter) pendingHunters.add(p);
      final partner = p.lover;
      if (partner != null) die(partner);
    }

    die(target);

    // Nobody left to shoot at
    if (players.every((p) => !p.alive)) pendingHunters.clear();

    return died;
  }

  /// The first pending hunter shoots [target].
  List<Player> hunterShoot(Player target) {
    if (pendingHunters.isNotEmpty) pendingHunters.removeAt(0);
    return kill(target);
  }

  // ---------------------------------------------------------------------------
  // Phase flow
  // ---------------------------------------------------------------------------

  /// Moves to the next turn or phase, skipping roles that are no longer alive.
  void advance() {
    // Another player with the same role still has to play this phase
    if (_roleOf(phase) != null && turnIndex + 1 < turnOrder.length) {
      turnIndex++;
      return;
    }

    switch (phase) {
      case GamePhase.cupid:
        _enterPhase(GamePhase.wolves);
        break;
      case GamePhase.wolves:
        _enterNightPhase(GamePhase.witch);
        break;
      case GamePhase.witch:
        _enterNightPhase(GamePhase.seer);
        break;
      case GamePhase.seer:
        _startDay();
        break;
      case GamePhase.day:
        _enterPhase(GamePhase.vote);
        break;
      case GamePhase.vote:
        _startNight();
        break;
    }
  }

  /// The role that acts in [p] one player at a time (null = no turns).
  String? _roleOf(GamePhase p) {
    switch (p) {
      case GamePhase.cupid:
        return Roles.cupid;
      case GamePhase.witch:
        return Roles.witch;
      case GamePhase.seer:
        return Roles.seer;
      default:
        return null;
    }
  }

  void _enterPhase(GamePhase p) {
    phase = p;
    turnIndex = 0;

    final role = _roleOf(p);
    turnOrder = role == null
        ? []
        : players.where((x) => x.alive && x.role == role).toList();
  }

  /// Enters [target] if somebody alive has that role, otherwise skips ahead.
  void _enterNightPhase(GamePhase target) {
    if (target == GamePhase.witch) {
      if (hasAlive(Roles.witch)) {
        _enterPhase(GamePhase.witch);
        return;
      }
      target = GamePhase.seer;
    }

    if (target == GamePhase.seer && hasAlive(Roles.seer)) {
      _enterPhase(GamePhase.seer);
      return;
    }

    _startDay();
  }

  void _startDay() {
    // Night deaths are applied at dawn
    nightDeaths = [];

    final victim = wolfVictim;
    if (victim != null && !_victimHealed) {
      nightDeaths.addAll(kill(victim));
    }
    for (final poisoned in _poisonTargets) {
      nightDeaths.addAll(kill(poisoned));
    }

    _enterPhase(GamePhase.day);
  }

  void _startNight() {
    night++;
    wolfVictim = null;
    _victimHealed = false;
    _poisonTargets.clear();
    nightDeaths = [];
    _enterPhase(GamePhase.wolves);
  }

  // ---------------------------------------------------------------------------
  // Victory conditions
  // ---------------------------------------------------------------------------

  GameWinner? checkWinner() {
    final alive = alivePlayers;
    if (alive.isEmpty) return GameWinner.nobody;

    // Lovers from opposite teams win if they are the last two alive
    if (alive.length == 2) {
      final a = alive[0];
      final b = alive[1];
      if (a.lover == b && a.isWerewolf != b.isWerewolf) {
        return GameWinner.lovers;
      }
    }

    final wolves = alive.where((p) => p.isWerewolf).length;
    final others = alive.length - wolves;

    if (wolves == 0) return GameWinner.villagers;
    if (wolves >= others) return GameWinner.werewolves;
    return null;
  }
}