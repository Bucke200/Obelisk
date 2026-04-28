import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_simple_platformer/game/actors/enemy_base.dart';

class ChaserEnemy extends Enemy {
  final PositionComponent target;
  final double agroRange = 250;

  ChaserEnemy({
    required this.target,
    super.position,
  }) : super(moveSpeed: 120, size: Vector2.all(32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sheet = SpriteSheet(image: game.spriteSheet, srcSize: Vector2.all(32));
    animations = {
      EnemyState.idle: sheet.createAnimation(row: 1, stepTime: 0.1, from: 0, to: 1),
      EnemyState.walk: sheet.createAnimation(row: 1, stepTime: 0.1, from: 0, to: 4),
    };
    current = EnemyState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dist = (target.position - position).length;
    if (dist < agroRange) {
      velocity = (target.position - position).normalized() * moveSpeed;
      position += velocity * dt;
      current = EnemyState.walk;
    } else {
      velocity = Vector2.zero();
      current = EnemyState.idle;
    }
  }
}
