import 'package:flutter/material.dart';

void main() {
  runApp(
     MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello Flutter!',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2196F3),
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hallo namaku Murod Fikri F',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 50), // Jarak sebelum masuk ke latihan Row

              // IMPLEMENTASI LATIHAN 3: ROW & COLUMN
              Container(
                color: Colors.grey[200], // Background agar area Row terlihat
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Row(
                  // EKSPERIMEN:
                  // .start, .center, .end, .spaceBetween, .spaceAround, .spaceEvenly
                  mainAxisAlignment: MainAxisAlignment.center,

                  // BONUS: ganti ke .start, .end, atau .stretch
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Icon(Icons.star, size: 40, color: Colors.red),
                    Icon(Icons.star, size: 40, color: Colors.green),
                    Icon(Icons.star, size: 40, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}