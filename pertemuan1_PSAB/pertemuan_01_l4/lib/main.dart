import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Kita letakkan Bottom Bar di bagian bawah layar menggunakan bottomNavigationBar
        bottomNavigationBar: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Eksperimen: Ganti warna ikon sesuai instruksi
              // Ikon 1: Merah, Ukuran 48
              Icon(
                Icons.home_outlined,
                color: Colors.grey,
                size: 48,
              ),

              // Ikon 2: Hijau, Ukuran 48
              Icon(
                Icons.search,
                color: Colors.grey,
                size: 48,
              ),

              // Ikon 3: Ungu, Ukuran 48
              Icon(
                Icons.receipt_long,
                color: Colors.grey,
                size: 48,
              ),

              // Ikon 4: Warna default, Ukuran 48
              Icon(
                Icons.person,
                color: Colors.grey,
                size: 48,
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text(
            'Latihan 4: Icon & Bottom Bar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}