import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_simple_platformer/core/event_bus.dart';
import 'package:flame_simple_platformer/game/actors/enemy_base.dart';

class ShooterEnemy extends Enemy {
  final PositionComponent target;
  final double range = 300;

  ShooterEnemy({
    required this.target,
    super.position,
  }) : super(moveSpeed: 0, size: Vector2.all(32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sheet = SpriteSheet(image: game.spriteSheet, srcSize: Vector2.all(32));
    animations = {
      EnemyState.idle: sheet.createAnimation(row: 2, stepTime: 0.1, from: 0, to: 1),
    };
    current = EnemyState.idle;

    add(TimerComponent(
      period: 2.0,
      repeat: true,
      onTick: _shoot,
    ));
  }

  void _shoot() {
    final dist = (target.position - position).length;
    if (dist < range) {
      EventBus.instance.fire(SpawnProjectileEvent(
        position,
        Vector2((target.x - x) > 0 ? 1 : -1, 0),
        300,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((target.x - x) > 0 && scale.x < 0) flipHorizontallyAroundCenter();
    if ((target.x - x) < 0 && scale.x > 0) flipHorizontallyAroundCenter();
  }
}
