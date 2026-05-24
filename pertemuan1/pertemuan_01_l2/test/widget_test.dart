import 'package:flutter_test/flutter_test.dart';
// Ganti 'pertemuan_01_l2' dengan nama project yang ada di pubspec.yaml kamu
import 'package:pertemuan_01_l2/main.dart' as app;

void main() {
  testWidgets('Uji tampilan Box', (WidgetTester tester) async {
    // 1. Memanggil fungsi main() secara langsung dari file main.dart
    app.main();

    // 2. Memberikan waktu bagi Flutter untuk membangun frame aplikasi
    await tester.pumpAndSettle();

    // 3. Verifikasi apakah teks 'Box' muncul di layar
    expect(find.text('Box'), findsOneWidget);

    // 4. Memastikan tidak ada teks angka '0' karena aplikasi kita bukan counter
    expect(find.text('0'), findsNothing);
  });
}