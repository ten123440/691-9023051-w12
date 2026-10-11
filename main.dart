import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? failure;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (error) {
    failure = error.toString();
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'W12 Firebase Test',
    theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
    home: TestPage(failure: failure),
  ));
}

class TestPage extends StatefulWidget {
  const TestPage({super.key, this.failure});
  final String? failure;
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int count = 0;
  bool busy = false;
  String message = 'กดปุ่มเพื่อบันทึกเหตุการณ์ทดสอบ';

  Future<void> sendEvent() async {
    setState(() => busy = true);
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'w12_test_click',
        parameters: {'click_number': count + 1, 'assignment': 'w12'},
      );
      if (!mounted) return;
      setState(() {
        count++;
        message = 'SDK รับคำสั่งแล้ว • ตรวจการรับข้อมูลใน Firebase Console';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => message = 'บันทึกไม่สำเร็จ: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.failure == null;
    return Scaffold(
      appBar: AppBar(title: const Text('W12 • Flutter × Firebase')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ready ? Icons.cloud_done : Icons.error_outline,
                    size: 80, color: ready ? Colors.deepPurple : Colors.red),
                const SizedBox(height: 20),
                Text(ready ? 'เริ่มต้น Firebase SDK สำเร็จ' : 'เริ่มต้น Firebase ไม่สำเร็จ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                SelectableText(ready
                    ? 'Project: ${Firebase.app().options.projectId}'
                    : widget.failure!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Text('$count', style: Theme.of(context).textTheme.displayLarge),
                const Text('จำนวนครั้งที่เรียกบันทึกเหตุการณ์สำเร็จ'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: ready && !busy ? sendEvent : null,
                  icon: const Icon(Icons.send),
                  label: Text(busy ? 'กำลังบันทึก…' : 'ทดสอบ Analytics'),
                ),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                const Text('Event: w12_test_click\nสถานะในแอปยังไม่ยืนยันว่าเซิร์ฟเวอร์รับข้อมูลแล้ว\nตรวจหลักฐานที่ Analytics Dashboard / DebugView',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
