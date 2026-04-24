import 'package:flutter/material.dart';
import '../../viewmodels/story_time_viewmodel.dart';
import '../../../domain/entities/quiz.dart';
import '../../../core/constants/app_constants.dart';

class QuizScreen extends StatefulWidget {
  final StoryTimeViewModel viewModel;
  final Quiz quiz;

  const QuizScreen({Key? key, required this.viewModel, required this.quiz})
    : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  List<int?> _userAnswers = [];
  bool _showResults = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(widget.quiz.questions.length, null);
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      // If this question was already answered, update the answer immediately
      if (_userAnswers[_currentQuestionIndex] != null) {
        _userAnswers[_currentQuestionIndex] = index;
      }
    });
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex != null) {
      _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex;

      if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
        });
      } else {
        _calculateScore();
        setState(() {
          _showResults = true;
        });
      }
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      });
    }
  }

  void _calculateScore() {
    int correct = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_userAnswers[i] == widget.quiz.questions[i].correctAnswerIndex) {
        correct++;
      }
    }
    setState(() {
      _score = correct;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _userAnswers = List.filled(widget.quiz.questions.length, null);
      _showResults = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultsScreen();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Question
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Answer options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAnswerIndex == index;
                    final isAnswered =
                        _userAnswers[_currentQuestionIndex] != null;
                    final wasSelected =
                        _userAnswers[_currentQuestionIndex] == index;
                    final isCorrect = index == question.correctAnswerIndex;
                    final showFeedback =
                        isAnswered && (wasSelected || isCorrect);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(index),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: showFeedback
                                ? (isCorrect
                                      ? Color(0xFF4CAF50).withOpacity(0.2)
                                      : wasSelected
                                      ? Color(0xFFE91E63).withOpacity(0.2)
                                      : Colors.white)
                                : isSelected
                                ? Color(0xFF2196F3).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: showFeedback
                                  ? (isCorrect
                                        ? Color(0xFF4CAF50)
                                        : wasSelected
                                        ? Color(0xFFE91E63)
                                        : Colors.grey[300]!)
                                  : isSelected
                                  ? Color(0xFF2196F3)
                                  : Colors.grey[300]!,
                              width: (isSelected || showFeedback) ? 3 : 1,
                            ),
                            boxShadow: (isSelected || showFeedback)
                                ? [
                                    BoxShadow(
                                      color:
                                          (showFeedback
                                                  ? (isCorrect
                                                        ? Color(0xFF4CAF50)
                                                        : wasSelected
                                                        ? Color(0xFFE91E63)
                                                        : Color(0xFF2196F3))
                                                  : Color(0xFF2196F3))
                                              .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: showFeedback
                                      ? (isCorrect
                                            ? Color(0xFF4CAF50)
                                            : wasSelected
                                            ? Color(0xFFE91E63)
                                            : Colors.grey[300]!)
                                      : isSelected
                                      ? Color(0xFF2196F3)
                                      : Colors.grey[300],
                                ),
                                child: showFeedback
                                    ? Icon(
                                        isCorrect ? Icons.check : Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : isSelected
                                    ? Icon(
                                        Icons.radio_button_checked,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.grey[600],
                                        size: 16,
                                      ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: (isSelected || showFeedback)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.black87,
                                    fontFamily: AppConstants.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton.icon(
                      onPressed: _previousQuestion,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    SizedBox(),
                  ElevatedButton.icon(
                    onPressed: _selectedAnswerIndex != null
                        ? _nextQuestion
                        : null,
                    icon: Icon(
                      _currentQuestionIndex < widget.quiz.questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                    ),
                    label: Text(
                      _currentQuestionIndex < widget.quiz.questions.length - 1
                          ? 'Next'
                          : 'Finish',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / widget.quiz.questions.length * 100).round();
    final isPerfect = _score == widget.quiz.questions.length;
    final isGood = _score >= widget.quiz.questions.length * 0.7;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPerfect
                    ? Icons.celebration
                    : isGood
                    ? Icons.star
                    : Icons.thumb_up,
                size: 100,
                color: isPerfect ? Colors.amber : Color(0xFF4CAF50),
              ),
              SizedBox(height: 30),
              Text(
                isPerfect
                    ? 'Perfect Score!'
                    : isGood
                    ? 'Great Job!'
                    : 'Good Try!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'You got $_score out of ${widget.quiz.questions.length} correct!',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF4CAF50),
                  fontFamily: AppConstants.fontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'That\'s $percentage%!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _restartQuiz,
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.viewModel.closeQuiz();
                    },
                    icon: Icon(Icons.check),
                    label: Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
