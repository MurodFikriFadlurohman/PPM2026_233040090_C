// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import project kamu. Pastikan nama package sesuai dengan pubspec.yaml
// Jika kamu tidak menggunakan class MyApp, kita panggil fungsi main-nya saja
import 'package:pertemuan_01_l4/main.dart' as app;

void main() {
  testWidgets('Uji Navigasi Bottom Bar Latihan 4', (WidgetTester tester) async {
    // 1. Jalankan aplikasi
    app.main();

    // 2. Biarkan aplikasi merender semua komponen (termasuk shadow/animasi)
    await tester.pumpAndSettle();

    // 3. Verifikasi keberadaan ikon-ikon yang kamu pasang di main.dart
    // Cek ikon Home
    expect(find.byIcon(Icons.home_filled), findsOneWidget);

    // Cek ikon Search
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Cek ikon Receipt (Struk)
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);

    // Cek ikon Person (Profil)
    expect(find.byIcon(Icons.person), findsOneWidget);

    // 4. Verifikasi teks utama di tengah layar
    expect(find.text('Latihan 4: Icon & Bottom Bar'), findsOneWidget);

    // 5. Pastikan komponen counter yang lama sudah tidak ada
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
