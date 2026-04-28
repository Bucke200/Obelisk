import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_simple_platformer/core/event_bus.dart';
import 'package:flame_simple_platformer/game/actors/platform.dart';
import 'package:flame_simple_platformer/game/utils/audio_manager.dart';
import 'package:flutter/services.dart';

enum PlayerState { idle, run, jump, fall }

// Represents a player in the game world.
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, KeyboardHandler {
  int _hAxisInput = 0;
  bool _jumpInput = false;
  bool _isOnGround = false;

  double timeSinceLeftGround = 0;
  double jumpBufferTimer = 0;

  final double _gravity = 10 * 60;
  final double _jumpSpeed = 360;
  final double _moveSpeed = 200;

  final Vector2 _up = Vector2(0, -1);
  final Vector2 _down = Vector2(0, 1);
  final Vector2 _velocity = Vector2.zero();
  Vector2 get velocity => _velocity;

  // FIX 1: Define a class-level variable to store the image
  final Image characterImage;

  // FIX 2: Store the passed image into the variable and close the constructor properly
  Player(
    this.characterImage, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  });

  @override
  Future<void> onLoad() async {
    // Explicitly define the source size of a single frame (likely 32x32)
    final spriteSheet = SpriteSheet(
      image: characterImage,
      srcSize: Vector2(32, 32), 
    );

    animations = {
      PlayerState.idle: spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        from: 0,
        to: 1,
      ),
      PlayerState.run: spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        from: 0,
        to: 1,
      ),
      PlayerState.jump: spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        from: 0,
        to: 1,
      ),
      PlayerState.fall: spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        from: 0,
        to: 1,
      ),
    };

    current = PlayerState.idle;

    await add(CircleHitbox());
  }

  @override
  void update(double dt) {
    // Modify components of velocity based on
    // inputs and gravity.
    _velocity.x = _hAxisInput * _moveSpeed;
    _velocity.y += _gravity * dt;

    if (_isOnGround) {
      timeSinceLeftGround = 0;
    } else {
      timeSinceLeftGround += dt;
    }

    if (jumpBufferTimer > 0) {
      jumpBufferTimer -= dt;
    }

    if (_jumpInput) {
      jumpBufferTimer = 0.15;
      _jumpInput = false;
    }

    // Allow jump only if jump input is pressed
    // and player is already on ground.
    if ((_isOnGround || timeSinceLeftGround < 0.1) && jumpBufferTimer > 0) {
      AudioManager.playSfx('Jump_15.wav');
      _velocity.y = -_jumpSpeed;
      _isOnGround = false;
      jumpBufferTimer = 0;
      timeSinceLeftGround = 0;
    }

    // Clamp velocity along y to avoid player tunneling
    // through platforms at very high velocities.
    _velocity.y = _velocity.y.clamp(-_jumpSpeed, 150);

    // delta movement = velocity * time
    position += _velocity * dt;

    if (_isOnGround) {
      if (_hAxisInput != 0) {
        current = PlayerState.run;
      } else {
        current = PlayerState.idle;
      }
    } else {
      if (_velocity.y < 0) {
        current = PlayerState.jump;
      } else {
        current = PlayerState.fall;
      }
    }

    // Flip player if needed.
    if (_hAxisInput < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (_hAxisInput > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.keyA) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0;
    _jumpInput = keysPressed.contains(LogicalKeyboardKey.space);

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyF) {
      EventBus.instance.fire(SpawnProjectileEvent(
        position,
        Vector2(scale.x > 0 ? 1 : -1, 0),
        400,
      ));
    }

    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        if (_up.dot(collisionNormal) > 0.9) {
          // If collision normal is almost upwards,
          // player must be on ground.
          _isOnGround = true;
        } else if (_down.dot(collisionNormal) > 0.9) {
          // If collision normal is almost downwards,
          // player must be hitting the ceiling.
          _velocity.y = 0;
        }

        // Resolve collision by moving player along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  // This method runs an opacity effect on player
  // to make it blink.
  void hit() {
    add(
      OpacityEffect.fadeOut(
        EffectController(alternate: true, duration: 0.1, repeatCount: 5),
      ),
    );
  }

  // Makes the player jump forcefully.
  void jump() {
    _jumpInput = true;
    _isOnGround = true;
  }
}