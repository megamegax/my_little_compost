import 'dart:async';
import 'dart:math';
import 'dart:ui' hide TextStyle;

import 'package:compost_game/food.dart';
import 'package:compost_game/food_entity.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/painting.dart';

class CompostGame extends FlameGame with HasDraggables {
  List<SpriteComponent> foods = [];
  SpriteComponent background = SpriteComponent();
  SpriteComponent window = SpriteComponent();
  SpriteAnimationComponent dog = SpriteAnimationComponent();
  SpriteAnimationComponent fridge = SpriteAnimationComponent();
  SpriteAnimationComponent compost = SpriteAnimationComponent();
  final style = TextStyle(color: BasicPalette.white.color);
  final regular = TextPaint(
      style: const TextStyle(
    fontSize: 48.0,
  ));
  final dogSize = Vector2(165, 192);
  final fridgeSize = Vector2(160, 186);
  final compostSize = Vector2(110, 123);
  TextComponent text = TextComponent();
  int score = 0;

  @override
  FutureOr<void> onLoad() async {
    text = TextComponent(text: 'Score: $score', textRenderer: regular)
      ..anchor = Anchor.topCenter
      ..x = size[0] / 2 // size is a property from game
      ..y = 32.0;
    double maxSide = min(size.x, size.y);
    camera.viewport = FixedResolutionViewport(Vector2.all(maxSide));

    FlameAudio.bgm.initialize();
    _loadCharacters();
    _loadRoom();

    await Future.delayed(const Duration(seconds: 1));
    _loadFood();

    add(text);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var food in foods) {
      if (food.y == size[1]) {
        food.y = -100;
      } else {
        food.y += 1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('megaman.mp3');
    }
  }

  void _loadRoom() async {
    final screenWidth = size[0];
    final screenHeight = size[1];
    add(background
      ..sprite = await loadSprite('walls.png')
      ..x = 0
      ..y = 0
      ..size = Vector2(screenWidth, screenHeight));
    add(window
      ..sprite = await loadSprite('window.png')
      ..x = 250
      ..y = 150
      ..size = Vector2(200, 200));
  }

  void _loadCharacters() async {
    final screenWidth = size[0];
    final screenHeight = size[1];
    dog = SpriteAnimationComponent.fromFrameData(
        await images.load('dog_big.png'),
        SpriteAnimationData.sequenced(
            amount: 9, stepTime: 0.05, textureSize: dogSize))
      ..x = screenWidth * 0.1
      ..y = screenHeight - 250
      ..size = dogSize;

    fridge = SpriteAnimationComponent.fromFrameData(
        await images.load('fridge_big_trimmed.png'),
        SpriteAnimationData.sequenced(
            amount: 11, stepTime: 0.08, textureSize: fridgeSize))
      ..x = screenWidth * 0.4
      ..y = screenHeight - 250
      ..size = fridgeSize;
    compost = SpriteAnimationComponent.fromFrameData(
        await images.load('compost_big_trimmed.png'),
        SpriteAnimationData.sequenced(
            amount: 8, stepTime: 0.08, textureSize: compostSize))
      ..x = screenWidth * 0.75
      ..y = screenHeight - 150
      ..size = compostSize;

    add(dog);
    add(fridge);
    add(compost);
  }

  void _loadFood() async {
    for (var i = 0; i < 10; i++) {
      final foodEntity =
          Food.foodNames[Random().nextInt(Food.foodNames.length - 1)];
      final food = Food(foodEntity, (FoodEntity currentFood, Vector2 position) {
        if (currentFood.target == 'dog') {
          if (position.x >= dog.x &&
              position.x + Food.foodSize <= dog.x + dog.width &&
              position.y <= dog.y + dog.height &&
              position.y >= dog.y) {
            increaseScore();
            return true;
          }
        }
        if (currentFood.target == 'compost') {
          if (position.x >= compost.x &&
              position.x + Food.foodSize <= compost.x + compost.width &&
              position.y <= compost.y + compost.height &&
              position.y >= compost.y) {
            increaseScore();
            return true;
          }
        }
        if (currentFood.target == 'fridge') {
          if (position.x >= fridge.x &&
              position.x + Food.foodSize <= fridge.x + fridge.width &&
              position.y <= fridge.y + fridge.height &&
              position.y >= fridge.y) {
            increaseScore();
            return true;
          }
        }
        return false;
      });
      food
        ..sprite = await loadSprite(foodEntity.name)
        ..x =
            Random().nextInt(size[0].toInt() - Food.foodSize.toInt()).toDouble()
        ..y = -Random().nextInt(size[1].toInt()).toDouble()
        ..size = Vector2(Food.foodSize, Food.foodSize);
      add(food);
      foods.add(food);
    }
    return;
  }

  void increaseScore() {
    score++;
    text.text = 'Score: $score';
  }
}
