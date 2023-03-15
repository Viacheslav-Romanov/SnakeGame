import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

class _SnakeGameState extends State<SnakeGame> {
  // Constants
  static const int numRows = 20;
  static const int numCols = 20;
  static const double cellSize = 20.0;

  // Game state variables
  List<Point<int>> snake = [];
  Point<int> food = Point(0, 0);
  Direction direction = Direction.right;
  int score = 0;

  // Initialize the game state
  void initState() {
    super.initState();
    reset();
  }

  // Reset the game state
  void reset() {
    setState(() {
      snake = [Point(numCols ~/ 2, numRows ~/ 2)];
      food = Point(Random().nextInt(numCols), Random().nextInt(numRows));
      direction = Direction.right;
      score = 0;
    });
  }

  // Handle user input
  void onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyLabel) {
        case 'Arrow Up':
          if (direction != Direction.down) {
            direction = Direction.up;
          }
          break;
        case 'Arrow Down':
          if (direction != Direction.up) {
            direction = Direction.down;
          }
          break;
        case 'Arrow Left':
          if (direction != Direction.right) {
            direction = Direction.left;
          }
          break;
        case 'Arrow Right':
          if (direction != Direction.left) {
            direction = Direction.right;
          }
          break;
      }
      moveSnake();
    }
  }

  // Move the snake
  void moveSnake() {
    setState(() {
      Point<int> head = snake.first;
      switch (direction) {
        case Direction.up:
          head = Point(head.x, head.y - 1);
          break;
        case Direction.down:
          head = Point(head.x, head.y + 1);
          break;
        case Direction.left:
          head = Point(head.x - 1, head.y);
          break;
        case Direction.right:
          head = Point(head.x + 1, head.y);
          break;
      }
      snake.insert(0, head);
      if (head == food) {
        // The snake ate the food, increase the score and place new food
        score += 10;
        food = Point(Random().nextInt(numCols), Random().nextInt(numRows));
      } else {
        // The snake didn't eat the food, remove the tail
        snake.removeLast();
      }

      // Check for game over conditions
      if (head.x < 0 || head.x >= numCols || head.y < 0 || head.y >= numRows) {
        // The snake collided with the game board boundaries
        reset();
        return;
      }
      for (int i = 1; i < snake.length; i++) {
        if (head == snake[i]) {
          // The snake collided with its own body
          reset();
          return;
        }
      }
    });
  }

  // Build the game board
  Widget buildBoard() {
    List<Widget> rows = [];
    for (int i = 0; i < numRows; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < numCols; j++) {
        bool isSnake = false;
        if (snake.any((point) => point.x == j && point.y == i)) {
          isSnake = true;
        }
        cells.add(Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: isSnake
                ? Colors.green
                : (food.x == j && food.y == i ? Colors.red : Colors.grey),
            border: Border.all(color: Colors.black),
          ),
        ));
      }
      rows.add(Row(
        children: cells,
      ));
    }
    return Container(
      width: numCols * cellSize,
      height: numRows * cellSize,
      child: Column(
        children: rows,
      ),
    );
  }

  // Build the game UI
  @override
  Widget build(BuildContext context) {
    final _focusNode = FocusNode();
    FocusScope.of(context).requestFocus(_focusNode);
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: onKeyEvent,
        child: Column(
          children: <Widget>[
            Expanded(child: buildBoard()),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Score: $score'),
            ),
          ],
        ),
      ),
    );
  }
}
