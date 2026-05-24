import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Container(
          // Eksperimen 1: Ubah width ke 300 dan height ke 100
          width: 300, height: 100,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            // Eksperimen 2: BorderRadius 100 membuat sudut sangat bulat (bentuk Kapsul)
            borderRadius: BorderRadius.circular(100),
            // Eksperimen 4: Menambahkan border hitam setebal 4
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                // Eksperimen 3: blurRadius 50 membuat bayangan sangat halus dan luas
                blurRadius: 50,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text('Box',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
        ),
      ),
    ),
  ));
}

