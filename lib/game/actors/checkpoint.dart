import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_simple_platformer/core/event_bus.dart';
import 'package:flame_simple_platformer/game/actors/player.dart';
import 'package:flame_simple_platformer/game/game.dart';

class Checkpoint extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SimplePlatformer> {
  bool _isActive = false;

  Checkpoint({super.position, super.size}) : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      gameRef.spriteSheet,
      srcPosition: Vector2(9 * 32, 0),
      srcSize: Vector2.all(32),
    );
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (!_isActive && other is Player) {
      _isActive = true;
      sprite = Sprite(
        gameRef.spriteSheet,
        srcPosition: Vector2(10 * 32, 0),
        srcSize: Vector2.all(32),
      );
      EventBus.instance.fire(CheckpointReachedEvent(position.clone()));
    }
  }
}
