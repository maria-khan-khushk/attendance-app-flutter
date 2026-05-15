import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
        ),
        useMaterial3: true,
      ),
      home: const AttendanceScreen(),
    );
  }
}
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreen> {
  final CollectionReference _attendance =
      FirebaseFirestore.instance.collection('attendance');
  final List<String> students = [
    'Maria khan',
    'Sara Khan',
    'Sheza khan',
    'Fatima Noor',
    'Usman Tariq',
    'Ayesha Malik',
    'Hassan Raza',
  ];
  Map<String, bool> presentMap = {};
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    for (var s in students) {
      presentMap[s] = false;
    }
  }
  String get _today => DateTime.now().toString().split(' ')[0];
  int get _presentCount =>
      presentMap.values.where((v) => v == true).length;
void _saveAttendance() async {
  setState(() => _saving = true);
  try {
    await _attendance.doc(_today).set({
      'date': _today,
      'attendance': presentMap,
      'totalStudents': students.length,
      'presentCount': _presentCount,
      'savedAt': FieldValue.serverTimestamp(),
    });
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Attendance saved! ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  } catch (e) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          '🎓 Attendance Manager',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard(' Date', _today, Colors.white),
                _statCard(' Present',
                    '$_presentCount', Colors.greenAccent),
                _statCard(' Absent',
                    '${students.length - _presentCount}',
                    Colors.redAccent),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Students List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                String name = students[index];
                bool isPresent = presentMap[name] ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPresent
                          ? Colors.green.shade300
                          : Colors.red.shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: isPresent
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Text(
                        name[0],
                        style: TextStyle(
                          color: isPresent
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    subtitle: Text(
                      isPresent ? ' Present' : ' Absent',
                      style: TextStyle(
                        color: isPresent
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Switch(
                      value: isPresent,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: (val) {
                        setState(() => presentMap[name] = val);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveAttendance,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _saving ? 'Saving...' : 'Save Attendance to Firebase',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _statCard(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}