// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Pastikan nama package ini sesuai dengan nama projectmu
import 'package:pertemuan_01_l1/main.dart' as app;

void main() {
  testWidgets('Cek tampilan teks Hello Flutter', (WidgetTester tester) async {
    // 1. Jalankan fungsi main() dari aplikasi
    app.main();
    await tester.pump(); // Memberi waktu aplikasi untuk render

    // 2. Cek apakah teks 'Hello Flutter!' ada di layar
    expect(find.text('Hello Flutter!'), findsOneWidget);

    // 3. Cek apakah teks deskripsi juga ada
    expect(find.text('Ini teks biasa dengan ukuran kecil'), findsOneWidget);

    // 4. Pastikan TIDAK ADA teks yang salah (contoh: angka 0 dari boilerplate lama)
    expect(find.text('0'), findsNothing);
  });
}
