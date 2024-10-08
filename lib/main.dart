import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrant Quiz App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.purpleAccent, // Vibrant background color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> _questions = [
    Question('Flutter is developed by Google?', true),
    Question('Dart is a programming language?', true),
    Question('Widgets are a core part of Flutter?', true),
    Question('Flutter is only for iOS development?', false),
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showIcon = false;
  IconData? _feedbackIcon;
  Timer? _timer;
  int _timeLeft = 5;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 5;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timer?.cancel();
          _nextQuestion();
        }
      });
    });
  }

  void _checkAnswer(bool userAnswer) {
    if (userAnswer == _questions[_currentQuestionIndex].answer) {
      setState(() {
        _score++;
        _feedbackIcon = Icons.check_circle;
        _showIcon = true;
      });
    } else {
      setState(() {
        _feedbackIcon = Icons.cancel;
        _showIcon = true;
      });
    }
    _timer?.cancel();
    Future.delayed(Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showIcon = false;
        _startTimer();
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Quiz Finished!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your score is $_score out of ${_questions.length}.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            GlitterEffect(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetQuiz();
            },
            child: Text('Restart', style: TextStyle(color: Colors.purpleAccent)),
          )
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _showIcon = false;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent, // Set the vibrant background color
      appBar: AppBar(
        title: Text('Vibrant Quiz App'),
        backgroundColor: Colors.black, // Set AppBar to black for contrast
      ),
      body: Stack(
        children: [
          FallingStars(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  _questions[_currentQuestionIndex].questionText,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Time Left: $_timeLeft seconds',
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _checkAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Black button background
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'True',
                    style: TextStyle(fontSize: 18, color: Colors.white), // White text for buttons
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _checkAnswer(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Black button background
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'False',
                    style: TextStyle(fontSize: 18, color: Colors.white), // White text for buttons
                  ),
                ),
                SizedBox(height: 20),
                if (_showIcon)
                  Icon(
                    _feedbackIcon,
                    color: _feedbackIcon == Icons.check_circle ? Colors.green : Colors.red,
                    size: 60,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class Question {
  final String questionText;
  final bool answer;

  Question(this.questionText, this.answer);
}

class FallingStars extends StatefulWidget {
  @override
  _FallingStarsState createState() => _FallingStarsState();
}

class _FallingStarsState extends State<FallingStars> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Widget> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();
    stars = List.generate(50, (index) => _createStar());
  }

  Widget _createStar() {
    final random = Random();
    return Positioned(
      left: random.nextDouble() * 400,  // Adjust this value to your screen width
      top: -random.nextDouble() * 600, // Start above the screen
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _controller.value * 600), // Fall distance
            child: Icon(
              Icons.star,
              color: Colors.primaries[random.nextInt(Colors.primaries.length)],
              size: 20 + random.nextInt(20).toDouble(), // Random size
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: stars,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class GlitterEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(seconds: 1),
        child: Icon(
          Icons.star,
          color: Colors.amber,
          size: 50,
        ),
      ),
    );
  }
}
