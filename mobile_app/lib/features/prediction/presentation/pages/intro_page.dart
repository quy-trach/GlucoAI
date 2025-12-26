// lib/features/prediction/presentation/pages/intro_page.dart
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'survey_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final TextEditingController _yearController = TextEditingController();

  // Hàm xử lý khi bấm "Bắt đầu"
  void _startSurvey() {
    final String yearText = _yearController.text.trim();
    if (yearText.isEmpty) {
      _showError("Vui lòng nhập năm sinh");
      return;
    }

    final int? birthYear = int.tryParse(yearText);
    final int currentYear = DateTime.now().year;

    if (birthYear == null || birthYear < 1900 || birthYear > currentYear) {
      _showError("Năm sinh không hợp lệ");
      return;
    }

    // 1. TÍNH TUỔI THỰC
    final int age = currentYear - birthYear;

    // 2. TÍNH NHÓM TUỔI (Input cho Model)
    int ageGroup = 1;
    if (age <= 24) {
      ageGroup = 1;
    } else if (age <= 29) {
      ageGroup = 2;
    } else if (age <= 34) {
      ageGroup = 3;
    } else if (age <= 39) {
      ageGroup = 4;
    } else if (age <= 44) {
      ageGroup = 5;
    } else if (age <= 49) {
      ageGroup = 6;
    } else if (age <= 54) {
      ageGroup = 7;
    } else if (age <= 59) {
      ageGroup = 8;
    } else if (age <= 64) {
      ageGroup = 9;
    } else if (age <= 69) {
      ageGroup = 10;
    } else if (age <= 74) {
      ageGroup = 11;
    } else if (age <= 79) {
      ageGroup = 12;
    } else {
      ageGroup = 13;
    }

    // 3. XÁC ĐỊNH XƯNG HÔ
    String pronoun = "Bạn";
    if (age >= 60) {
      pronoun = "Bác";
    } else if (age >= 30) {
      pronoun = "Anh/Chị";
    }

    // 4. CHUYỂN TRANG
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SurveyPage(pronoun: pronoun, estimatedAgeGroup: ageGroup),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. ẢNH MINH HỌA (Giữ nguyên)
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      "assets/images/GlucoAI_Doctor_likebighand.png",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.health_and_safety_outlined,
                          size: 150,
                          color: Colors.blueAccent,
                        );
                      },
                    ),
                  ),

                  // 2. TIÊU ĐỀ
                  Text(
                    "Chào mừng đến với\nGlucoAI",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      // <--- Đổi font ở đây
                      fontSize: 32,
                      fontWeight: FontWeight
                          .w900, 
                      color: Colors.blueAccent,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. CÂU DẪN (Giữ nguyên câu mới)
                  const Text(
                    '"Hãy nhập năm sinh để GlucoAI\nthấu hiểu sức khỏe của bạn."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Ô NHẬP NĂM SINH
                  TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: "Ví dụ: 1990",
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. NÚT BẮT ĐẦU
                  ElevatedButton(
                    onPressed: _startSurvey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), // Radius 12 cho đồng bộ
                      elevation: 5,
                    ),
                    child: const Text(
                      "BẮT ĐẦU KHẢO SÁT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
