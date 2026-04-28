import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class Bullet extends SpriteComponent with HasGameRef {
  final void Function(Bullet) onD;
  Vector2 _v = Vector2.zero();
  double _l = 2.0;
  double _t = 0.0;
  bool _a = false;

  Bullet(this.onD) : super(size: Vector2(8, 8));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    add(RectangleHitbox());
  }

  void fire(Vector2 p, Vector2 d, double s) {
    position.setFrom(p);
    _v = d.normalized() * s;
    _a = true;
    _t = 0.0;
  }

  @override
  void update(double dt) {
    if (!_a) return;
    super.update(dt);
    position += _v * dt;
    _t += dt;
    if (_t >= _l) {
      _a = false;
      removeFromParent();
      onD(this);
    }
  }
}
