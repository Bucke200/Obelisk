import 'package:flame/extensions.dart';
import 'package:flame_simple_platformer/core/event_bus.dart';
import 'package:flutter/foundation.dart';

/// Manages the global game state by listening to game events.
class GameManager {
  static final GameManager _instance = GameManager._internal();
  static GameManager get instance => _instance;

  GameManager._internal();

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> lives = ValueNotifier<int>(3);
  Vector2? _respawnPosition;
  Vector2? get respawnPosition => _respawnPosition;

  /// Initializes the manager and sets up event listeners.
  void init() {
    score.value = 0;
    lives.value = 3;
    _respawnPosition = null;

    EventBus.instance.on<PlayerDamageEvent>().listen((event) {
      lives.value -= event.amount;
      if (lives.value < 0) lives.value = 0;
    });

    EventBus.instance.on<CoinCollectEvent>().listen((event) {
      score.value += event.value;
    });

    EventBus.instance.on<CheckpointReachedEvent>().listen((event) {
      _respawnPosition = event.position;
    });
  }

  /// Resets the game state.
  void reset() {
    score.value = 0;
    lives.value = 3;
    _respawnPosition = null;
  }
}
