import 'dart:async';

import 'package:compost_game/food_entity.dart';
import 'package:flame/components.dart';
import 'package:flame/src/gestures/events.dart';

class Food extends SpriteComponent with Draggable {
  static double foodSize = 64;
  static List<FoodEntity> foodNames = [
    FoodEntity('apple_core.png', 'compost'),
    FoodEntity('banana_peel.png', 'compost'),
    FoodEntity('bone.png', 'dog'),
    FoodEntity('cheese.png', 'fridge'),
    FoodEntity('chicken_thigh_half.png', 'dog'),
    FoodEntity('chicken_thigh.png', 'dog'),
    FoodEntity('fish.png', 'fridge'),
    FoodEntity('green_apple.png', 'fridge'),
    FoodEntity('lemon.png', 'fridge'),
    FoodEntity('red_apple.png', 'fridge'),
    FoodEntity('watermelon_peel_big_64_33.png', 'compost'),
    FoodEntity('whole_grilled_chicken.png', 'fridge')
  ];

  Vector2? _dragDeltaPosition;
  Function checkCollision;
  FoodEntity currentFood;
  Food(this.currentFood, this.checkCollision);

  @override
  bool onDragStart(DragStartInfo info) {
    _dragDeltaPosition = info.eventPosition.game - position;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    final dragDeltaPosition = this._dragDeltaPosition;
    if (dragDeltaPosition == null) {
      return false;
    }
    position.setFrom(info.eventPosition.game - dragDeltaPosition);
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    final shouldDestroy = checkCollision(currentFood, position);
    if (shouldDestroy) {
      y = -100;
    }
    _dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel() {
    _dragDeltaPosition = null;
    return false;
  }
}
