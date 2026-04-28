import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_simple_platformer/game/game.dart';

class BackgroundLayer extends ParallaxComponent<SimplePlatformer> {
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('Spritesheet.png'),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
      repeat: ImageRepeat.repeatX,
    );
  }

  void updateVelocity(double playerHorizontalVelocity) {
    parallax?.baseVelocity = Vector2(playerHorizontalVelocity / 10, 0);
  }
}
