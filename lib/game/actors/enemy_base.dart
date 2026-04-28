import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_simple_platformer/game/game.dart';

enum EnemyState { idle, walk, hit }

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with CollisionCallbacks, HasGameReference<SimplePlatformer> {
  final double moveSpeed;
  Vector2 velocity = Vector2.zero();

  Enemy({
    required this.moveSpeed,
    super.position,
    super.size,
    super.anchor = Anchor.center,
  });

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (velocity.x != 0) {
      if (velocity.x > 0 && scale.x < 0) flipHorizontallyAroundCenter();
      if (velocity.x < 0 && scale.x > 0) flipHorizontallyAroundCenter();
    }
  }
}
