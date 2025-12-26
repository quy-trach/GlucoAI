// lib/features/prediction/presentation/pages/survey_page.dart
import 'package:flutter/material.dart';
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
  int _currentIndex = 0;
  final Map<String, double> _answers = {};
  
  // Biến UI
  double _height = 165;
  double _weight = 60;
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _answers["Age"] = widget.estimatedAgeGroup.toDouble();
  }

  void _nextQuestion() {
    if (surveyQuestions[_currentIndex].type == QuestionType.inputDays) {
      if (_daysController.text.isEmpty) return;
    }

    if (_currentIndex < surveyQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _daysController.clear();
      });
    } else {
      _finishSurvey();
    }
  }

  // ===============================================================
  // LOGIC GỬI DỮ LIỆU & HIỂN THỊ KẾT QUẢ 3 CẤP ĐỘ
  // ===============================================================
  void _finishSurvey() {
    // 1. Tính BMI lần cuối cho chắc
    double bmiValue = _weight / ((_height / 100) * (_height / 100));
    _answers["BMI"] = double.parse(bmiValue.toStringAsFixed(1));

    // 2. Điền dữ liệu thiếu (Chống lỗi 422 - Logic cũ)
    final List<String> requiredKeys = [
      "HighBP", "HighChol", "CholCheck", "BMI", "Smoker", "Stroke",
      "HeartDiseaseorAttack", "PhysActivity", "Fruits", "Veggies",
      "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost", "GenHlth",
      "MentHlth", "PhysHlth", "DiffWalk", "Sex", "Age", "Education", "Income"
    ];

    for (String key in requiredKeys) {
      if (!_answers.containsKey(key)) {
        _answers[key] = 0.0;
      }
    }

    // 3. CHUYỂN SANG TRANG LOADING (Thay vì gọi API trực tiếp ở đây)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingPage(answers: _answers),
      ),
    );
  }

  // ===============================================================
  // UI COMPONENTS (GIỮ NGUYÊN HOẶC TỐI ƯU NHẸ)
  // ===============================================================
  Widget _buildOptionsList(Question question) {
    return Column(
      children: question.options!.map((option) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              option.values.forEach((key, value) => _answers[key] = value);
              _nextQuestion();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.text.replaceAll("{xung_ho}", widget.pronoun),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
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
        _buildSlider("Chiều cao", _height, 100, 220, "cm", (v) => _height = v, Colors.blue),
        const SizedBox(height: 20),
        _buildSlider("Cân nặng", _weight, 30, 150, "kg", (v) => _weight = v, Colors.orange),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _nextQuestion,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, String unit, Function(double) onChanged, Color color) {
    return Column(
      children: [
        Text("$label: ${value.round()} $unit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Slider(
          value: value, min: min, max: max, divisions: (max - min).toInt(),
          activeColor: color,
          label: "${value.round()} $unit",
          onChanged: (val) => setState(() => onChanged(val)),
        ),
      ],
    );
  }

  Widget _buildInputDays(Question question) {
    return Column(
      children: [
        TextField(
          controller: _daysController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Nhập số ngày (0 - 30)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixText: "ngày",
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            double? days = double.tryParse(_daysController.text);
            if (days != null && days >= 0 && days <= 30) {
              _answers["MentHlth"] = days;
              _answers["PhysHlth"] = days;
              _nextQuestion();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = surveyQuestions[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text("Câu hỏi ${_currentIndex + 1}/${surveyQuestions.length}"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.text.replaceAll("{xung_ho}", widget.pronoun),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: question.type == QuestionType.inputBmi
                    ? _buildBMISliders()
                    : question.type == QuestionType.inputDays
                        ? _buildInputDays(question)
                        : _buildOptionsList(question),
              ),
            ),
          ],
        ),
      ),
    );
  }
}