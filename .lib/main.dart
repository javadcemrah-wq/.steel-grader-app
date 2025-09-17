import 'package:flutter/material.dart';

void main() {
  runApp(const SteelGraderApp());
}

class SteelGraderApp extends StatelessWidget {
  const SteelGraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'گریدبندی ورق فولادی',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GraderHomePage(),
    );
  }
}

class Defect {
  String name;
  double severity;
  String description;

  Defect({
    required this.name,
    this.severity = 0,
    this.description = '',
  });
}

class GraderHomePage extends StatefulWidget {
  const GraderHomePage({super.key});

  @override
  State<GraderHomePage> createState() => _GraderHomePageState();
}

class _GraderHomePageState extends State<GraderHomePage> {
  final List<Defect> defects = [
    Defect(name: 'شوره'),
    Defect(name: 'زنگ‌زدگی'),
    Defect(name: 'لکه سیاهی'),
    Defect(name: 'شکستگی عرضی'),
    Defect(name: 'بار اضافه'),
    Defect(name: 'کدری'),
    Defect(name: 'کرماتی'),
    Defect(name: 'خط و خش'),
    Defect(name: 'ریزش'),
    Defect(name: 'روغن‌مردگی'),
    Defect(name: 'لبه خراب'),
  ];

  String? result;

  // قوانین گریدبندی برای هر خرابی
  String calculateDefectGrade(Defect defect) {
    final n = defect.name.toLowerCase();

    // لکه سیاهی
    if (n.contains('لکه') && n.contains('سیاهی')) {
      final s = defect.severity;
      if (s < 5) return '1';
      if (s < 15) return '2';
      if (s < 30) return '3';
      return '4';
    }

    // شکستگی عرضی (متنی)
    if (n.contains('شکستگی') && n.contains('عرضی')) {
      final desc = defect.description.toLowerCase();
      if (desc.contains('سایه روشن') && desc.contains('حس نمی')) return '1';
      if (desc.contains('کمی') && desc.contains('حس می')) return '2';
      if (desc.contains('کامل') && desc.contains('حس می')) return '3';
      if (desc.contains('چند')) return '4';
      return '1';
    }

    // بار اضافه
    if (n.contains('بار اضافه')) {
      final s = defect.severity;
      if (s < 5) return '1';
      if (s < 10) return '2';
      if (s < 20) return '3';
      return '4';
    }

    // کدری و کرماتی
    if (n.contains('کدری') || n.contains('کرماتی')) {
      final s = defect.severity;
      if (s < 5) return '1';
      if (s < 15) return '2';
      if (s < 40) return '3';
      return '4';
    }

    // شوره و زنگ‌زدگی
    if (n.contains('شوره') || n.contains('زنگ')) {
      final s = defect.severity;
      if (s < 10) return 'A';
      if (s < 25) return 'B';
      if (s < 40) return 'C';
      return 'D';
    }

    // خط و خش / ریزشی / روغن‌مردگی / لبه خراب (قانون عمومی شدت)
    if (n.contains('خط') ||
        n.contains('خش') ||
        n.contains('ریزش') ||
        n.contains('روغن') ||
        n.contains('لبه')) {
      final s = defect.severity;
      if (s < 10) return 'A';
      if (s < 30) return 'B';
      if (s < 50) return 'C';
      return 'D';
    }

    return '-';
  }

  // محاسبه گرید کلی (بدترین خرابی = گرید نهایی)
  void calculateResult() {
    setState(() {
      int worst = 1; // بهترین حالت
      for (var d in defects) {
        String g = calculateDefectGrade(d);

        // نگاشت گرید به عدد
        int val;
        switch (g) {
          case 'A':
            val = 1;
            break;
          case 'B':
            val = 2;
            break;
          case 'C':
            val = 3;
            break;
          case 'D':
            val = 4;
            break;
          case '1':
            val = 1;
            break;
          case '2':
            val = 2;
            break;
          case '3':
            val = 3;
            break;
          case '4':
            val = 4;
            break;
          default:
            val = 1;
        }

        if (val > worst) worst = val;
      }

      // تبدیل عدد بدترین گرید به متن نهایی
      String finalGrade;
      switch (worst) {
        case 1:
          finalGrade = "A / 1 (خیلی خوب)";
          break;
        case 2:
          finalGrade = "B / 2 (قابل قبول)";
          break;
        case 3:
          finalGrade = "C / 3 (ضعیف)";
          break;
        case 4:
          finalGrade = "D / 4 (خیلی ضعیف)";
          break;
        default:
          finalGrade = "-";
      }

      result = "گرید کلی ورق: $finalGrade";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گریدبندی ورق فولادی'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...defects.map((defect) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(defect.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (defect.name == 'شکستگی عرضی')
                      TextField(
                        decoration: const InputDecoration(
                            labelText: 'توضیح (مثلاً: کامل زیر دست حس میشود)'),
                        onChanged: (val) {
                          setState(() => defect.description = val);
                        },
                      ),
                    if (defect.name != 'شکستگی عرضی') ...[
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: "${defect.severity.toInt()}%",
                        value: defect.severity,
                        onChanged: (val) {
                          setState(() => defect.severity = val);
                        },
                      ),
                      Text("شدت: ${defect.severity.toInt()}%"),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: calculateResult,
            child: const Text('محاسبه گرید کلی'),
          ),
          const SizedBox(height: 20),
          if (result != null)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(result!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            )
        ],
      ),
    );
  }
}
