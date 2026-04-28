import 'dart:async';
import 'dart:collection';
import 'package:flame/components.dart';
import '../../core/event_bus.dart';
import '../actors/bullet.dart';

class ProjectileManager extends Component with HasGameRef {
  final Queue<Bullet> _p = Queue<Bullet>();
  late final StreamSubscription _s;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < 20; i++) _p.add(Bullet(_r));

    _s = EventBus.instance.on<SpawnProjectileEvent>().listen((e) {
      final b = _p.isEmpty ? Bullet(_r) : _p.removeFirst();
      b.fire(e.p, e.d, e.s);
      gameRef.add(b);
    });
  }

  void _r(Bullet b) => _p.add(b);

  @override
  void onRemove() {
    _s.cancel();
    super.onRemove();
  }
}
