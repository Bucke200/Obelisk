import 'dart:async';
import 'package:flame/components.dart';

/// Base class for all game events.
abstract class GameEvent {}

/// Fired when the player takes damage.
class PlayerDamageEvent extends GameEvent {
  final int amount;
  PlayerDamageEvent(this.amount);
}

/// Fired when a coin is collected.
class CoinCollectEvent extends GameEvent {
  final int value;
  CoinCollectEvent(this.value);
}

class SpawnProjectileEvent {
  final Vector2 p;
  final Vector2 d;
  final double s;
  SpawnProjectileEvent(this.p, this.d, this.s);
}

class CheckpointReachedEvent extends GameEvent {
  final Vector2 position;
  CheckpointReachedEvent(this.position);
}

/// A simple Event Bus pattern using Dart Streams.
/// Used to decouple game components.
class EventBus {
  // Singleton instance
  static final EventBus _instance = EventBus._internal();
  static EventBus get instance => _instance;

  EventBus._internal();

  final _streamController = StreamController<dynamic>.broadcast();

  /// Fires a new event to all listeners.
  void fire(dynamic event) {
    _streamController.add(event);
  }

  /// Returns a [Stream] of events of type [T].
  Stream<T> on<T>() {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  /// Closes the event bus.
  void dispose() {
    _streamController.close();
  }
}
