import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class Catatan {
  final int? id;                 // <- Tetap nullable untuk database Auto Increment
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;
  final String email;            // <--- JANGAN DIAPUS: Properti email yang kamu buat sebelumnya

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
    required this.email,         // <--- JANGAN DIAPUS: Masukkan ke constructor
  });

  // === Dart object → row Map (Untuk Create & Update di DB) ===
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
    'email': email,          // <--- TAMBAHKAN INI: Agar email ikut tersimpan ke database
  };

  // === Row Map → Dart object (Untuk Read dari DB) ===
  static Catatan fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    dibuatPada:
    DateTime.fromMillisecondsSinceEpoch(m['dibuat_pada'] as int),
    email: m['email'] as String? ?? '', // <--- TAMBAHKAN INI: Mengambil data email dari DB
  );

  // Helper untuk Edit — copy dengan beberapa field diganti.
  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
    String? email,               // <--- TAMBAHKAN INI: Opsi parameter untuk edit email
  }) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        dibuatPada: dibuatPada,
        email: email ?? this.email,   // <--- TAMBAHKAN INI: Mempertahankan data email lama/baru
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/form':
            final arg = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(initial: arg as Catatan?),
            );
          case '/detail':
            final c = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: c),
            );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === STATE BARU (MENGGUNAKAN FUTURE) ===
  late Future<List<Catatan>> _futureCatatan;

  // === STATE FILTER KAMU (DIPERTAHANKAN) ===
  String _kategoriTerpilih = 'Semua';
  final List<String> _opsiFilter = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _muatUlang(); // Inisialisasi data saat pertama kali aplikasi dibuka
  }

  // Fungsi untuk memicu pembaruan data dari database
  void _muatUlang() {
    setState(() {
      _futureCatatan = DbHelper.instance.getAll();
    });
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';
  }

  // Menyesuaikan fungsi hapus agar langsung menghapus dari database
  // === LANGKAH 7: FUNGSI DIALOG KONFIRMASI HAPUS ===
  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${c.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Mengembalikan nilai false jika batal
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), // Mengembalikan nilai true jika setuju
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Jika user menekan tombol 'Hapus' (yakin == true)
    if (yakin == true) {
      await DbHelper.instance.delete(c.id!); // Hapus data di SQLite berdasarkan id
      if (!mounted) return;
      _muatUlang(); // Muat ulang data dari database agar layar refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${c.judul}" dihapus')),
      );
    }
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial); // Diubah ke /form
    _muatUlang(); // Memperbarui daftar data dari database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          // Tambahkan tombol refresh di sebelah dropdown filter agar lebih fleksibel
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
          // Dropdown Filter bawaan kode kamu (Tetap Utuh)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _kategoriTerpilih,
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list),
              items: _opsiFilter.map((kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _kategoriTerpilih = val; // Memicu build ulang untuk memfilter data snapshot
                  });
                }
              },
            ),
          )
        ],
      ),

      // === REFACTOR BODY: Menggunakan FutureBuilder ===
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          // 1. Kondisi saat data masih loading
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Kondisi jika terjadi error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Ambil data mentah dari database (jika null, jadikan list kosong)
          final dataMentah = snapshot.data ?? const [];

          // 3. LOGIKA FILTER KAMU (Tetap dipertahankan di sini)
          final List<Catatan> catatanTampil = _kategoriTerpilih == 'Semua'
              ? dataMentah
              : dataMentah.where((c) => c.kategori == _kategoriTerpilih).toList();

          // 4. Kondisi jika catatan kosong setelah difilter
          if (catatanTampil.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          // 5. Tampilan ListView Utama (Menggunakan kode asli milikmu)
          return ListView.builder(
            itemCount: catatanTampil.length,
            itemBuilder: (context, i) {
              final c = catatanTampil[i];
              return ListTile(
                title: Text(c.judul),
                subtitle: Text('${c.kategori} • ${_formatTanggal(c.dibuatPada)}'),
                // === MODIFIKASI TRAILING DI LANGKAH 7 ===
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Agar row tidak memakan space terlalu lebar
                  children: [
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _bukaForm(initial: c), // Mengoper data catatan untuk diedit
                    ),
                    // Tombol Hapus dengan Konfirmasi
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _konfirmasiHapus(c), // Memanggil dialog konfirmasi
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/detail', arguments: c);
                },
              );
            },
          );
        },
      ),

      // Floating Action Button kamu (Disesuaikan agar menyimpan ke DB)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(), // <--- Cukup panggil helper method ini saja!
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial; // <--- Jika null = mode CREATE, jika ada isi = mode EDIT
  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late final TextEditingController _emailCtrl; // <--- Tetap mempertahankan field email kamu

  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  // Helper untuk mengecek apakah sedang dalam mode edit
  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false; // State penanda proses loading saat simpan data

  @override
  void initState() {
    super.initState();
    // Jika mode EDIT, isi form dengan data lama (widget.initial). Jika CREATE, isi string kosong.
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.initial?.email ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose(); // Bersihkan controller email
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true); // Aktifkan loading indicator

    try {
      if (_isEdit) {
        // --- MODE EDIT (Update data ke SQLite) ---
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          email: _emailCtrl.text.trim(),
        );
        await DbHelper.instance.update(updated);
      } else {
        // --- MODE CREATE (Insert data baru ke SQLite) ---
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
          email: _emailCtrl.text.trim(),
        );
        await DbHelper.instance.insert(baru);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
      ));
      Navigator.pop(context); // Kembali ke halaman utama
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false); // Matikan loading jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Judul AppBar berubah dinamis sesuai mode
      appBar: AppBar(title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              enabled: !_menyimpan,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // FIELD EMAIL DENGAN VALIDASI REGEX ASLI MILIKMU (Tetap Aman!)
            TextFormField(
              controller: _emailCtrl,
              enabled: !_menyimpan,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v)) {
                  return 'Format email tidak valid (contoh: nama@email.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: _menyimpan ? null : (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              enabled: !_menyimpan,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),

            // Tombol berubah jadi loading indicator saat proses menyimpan data ke DB
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_menyimpan ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        // TAMBAHKAN KODE ACTIONS DI BAWAH INI
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Menuju halaman form dengan mengoper data catatan saat ini
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context); // Tutup detail biar Home otomatis memuat ulang data ter-update
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(catatan.judul,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text(catatan.kategori)),
            const Divider(height: 32),
            Text(catatan.isi,
                style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}