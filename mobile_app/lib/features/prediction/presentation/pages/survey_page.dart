import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/questions_data.dart';
import 'loading_page.dart';

class SurveyPage extends StatefulWidget {
  final String pronoun;
  final int estimatedAgeGroup;

  const SurveyPage({
    super.key,
    required this.pronoun,
    required this.estimatedAgeGroup,
  });

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final PageController _pageController = PageController();
  
  int _currentIndex = 0;
  final Map<String, double> _answers = {};
  
  // Màu xanh đặc trưng
  final Color primaryAppColor = Colors.blue.shade700;

  // Quản lý trạng thái chọn và delay
  String? _selectedOptionText; 
  bool _isTransitioning = false; 

  // Biến cho các câu hỏi nhập liệu
  double _height = 165;
  double _weight = 60;
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _answers["Age"] = widget.estimatedAgeGroup.toDouble();
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousQuestion() {
    if (_currentIndex > 0 && !_isTransitioning) {
      setState(() {
        _selectedOptionText = null; 
      });
      _animateToPage(_currentIndex - 1);
    }
  }

  void _handleOptionTap(Option option) {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
      _selectedOptionText = option.text; 
      option.values.forEach((key, value) => _answers[key] = value);
    });

    // Delay 800ms để người dùng kịp nhìn hiệu ứng active xanh chữ trắng
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (_currentIndex < surveyQuestions.length - 1) {
          _animateToPage(_currentIndex + 1);
          setState(() {
            _isTransitioning = false;
            _selectedOptionText = null; 
          });
        } else {
          _finishSurvey();
        }
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < surveyQuestions.length - 1) {
      _animateToPage(_currentIndex + 1);
    } else {
      _finishSurvey();
    }
  }

  void _finishSurvey() {
    double bmiValue = _weight / ((_height / 100) * (_height / 100));
    _answers["BMI"] = double.parse(bmiValue.toStringAsFixed(1));

    // Đảm bảo đủ 21 đặc trưng theo yêu cầu của ông
    final List<String> featureKeys = [
      "HighBP", "HighChol", "CholCheck", "BMI", "Smoker", "Stroke",
      "HeartDiseaseorAttack", "PhysActivity", "Fruits", "Veggies",
      "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost", "GenHlth",
      "MentHlth", "PhysHlth", "DiffWalk", "Sex", "Age", "Education", "Income"
    ];

    for (String key in featureKeys) {
      if (!_answers.containsKey(key)) {
        _answers[key] = 0.0;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingPage(answers: _answers)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Câu ${_currentIndex + 1}/${surveyQuestions.length}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: _currentIndex > 0 
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: primaryAppColor, size: 20),
              onPressed: _previousQuestion,
            ) 
          : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / surveyQuestions.length,
            backgroundColor: Colors.blue.shade50,
            color: primaryAppColor,
            minHeight: 6,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: surveyQuestions.length,
              itemBuilder: (context, index) => _buildQuestionSlide(surveyQuestions[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSlide(Question q) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            q.text.replaceAll("{xung_ho}", widget.pronoun),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildQuestionContent(q),
          const SizedBox(height: 40),
          _buildInlineNavigation(q),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(Question q) {
    if (q.type == QuestionType.singleChoice || q.id == "Sex" || q.id == "Age") {
      return _buildOptionsList(q);
    } else if (q.type == QuestionType.inputBmi) {
      return _buildBMISliders();
    } else if (q.type == QuestionType.inputDays) {
      return _buildInputDaysField();
    }
    return const SizedBox();
  }

  Widget _buildOptionsList(Question q) {
    return Column(
      children: q.options!.map((option) {
        bool isActive = _selectedOptionText == option.text;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: double.infinity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive ? primaryAppColor : Colors.white,
              border: Border.all(
                color: isActive ? primaryAppColor : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isActive 
                ? [BoxShadow(color: primaryAppColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _handleOptionTap(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.text.replaceAll("{xung_ho}", widget.pronoun),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (isActive) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBMISliders() {
    return Column(
      children: [
        _buildSliderLabel("Chiều cao", _height, "cm"),
        Slider(value: _height, min: 100, max: 220, activeColor: primaryAppColor, onChanged: (v) => setState(() => _height = v)),
        const SizedBox(height: 16),
        _buildSliderLabel("Cân nặng", _weight, "kg"),
        Slider(value: _weight, min: 30, max: 150, activeColor: Colors.orange, onChanged: (v) => setState(() => _weight = v)),
      ],
    );
  }

  Widget _buildSliderLabel(String label, double val, String unit) => 
    Text("$label: ${val.round()} $unit", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  Widget _buildInputDaysField() {
    return TextField(
      controller: _daysController,
      keyboardType: TextInputType.number,
      onChanged: (v) {
        double? val = double.tryParse(v);
        if (val != null && val >= 0 && val <= 30) {
          _answers["MentHlth"] = val;
          _answers["PhysHlth"] = val;
        }
      },
      decoration: InputDecoration(
        labelText: "Nhập số ngày (0 - 30)",
        labelStyle: TextStyle(color: primaryAppColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryAppColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInlineNavigation(Question q) {
    return Column(
      children: [
        if (q.type == QuestionType.inputBmi || q.type == QuestionType.inputDays)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTransitioning ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAppColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        const SizedBox(height: 12),
        if (_currentIndex > 0)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isTransitioning ? null : _previousQuestion,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryAppColor,
                side: BorderSide(color: primaryAppColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Quay lại câu trước", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}