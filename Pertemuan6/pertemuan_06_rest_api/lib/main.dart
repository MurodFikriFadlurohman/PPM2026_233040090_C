import 'package:flutter/material.dart';
import 'api_client.dart'; // Menggunakan ApiClient, bukan db_helper

void main() {
  // Tidak lagi mewajibkan WidgetsFlutterBinding.ensureInitialized() untuk REST API
  runApp(const MyApp());
}

// === LANGKAH 3: MODEL CATATAN BARU ===
class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'dibuat_pada': dibuatPada.toUtc().toIso8601String(),
  };

  static Catatan fromJson(Map<String, dynamic> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    dibuatPada: DateTime.parse(m['dibuat_pada'] as String),
  );

  Catatan copyWith({String? judul, String? isi, String? kategori}) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        dibuatPada: dibuatPada,
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
  late Future<List<Catatan>> _futureCatatan;

  String _kategoriTerpilih = 'Semua';
  final List<String> _opsiFilter = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = ApiClient.instance.getAll(); // Mengambil data dari REST API
    });
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';
  }

  // === LANGKAH 7: DELETE KE API ===
  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${c.judul}" akan dihapus permanen dari server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      try {
        await ApiClient.instance.delete(c.id!); // Menggunakan ApiClient
        if (!mounted) return;
        _muatUlang();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${c.judul}" dihapus')),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.message}')),
        );
      }
    }
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial);
    _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
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
                    _kategoriTerpilih = val;
                  });
                }
              },
            ),
          )
        ],
      ),
      // === LANGKAH 5: FUTURE BUILDER DENGAN API EXCEPTION ===
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final e = snapshot.error;
            final pesan = e is ApiException ? e.message : 'Terjadi kesalahan: $e';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text(pesan, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
                ],
              ),
            );
          }

          final dataMentah = snapshot.data ?? const [];
          final List<Catatan> catatanTampil = _kategoriTerpilih == 'Semua'
              ? dataMentah
              : dataMentah.where((c) => c.kategori == _kategoriTerpilih).toList();

          if (catatanTampil.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: catatanTampil.length,
            itemBuilder: (context, i) {
              final c = catatanTampil[i];
              return ListTile(
                title: Text(c.judul),
                subtitle: Text('${c.kategori} • ${_formatTanggal(c.dibuatPada)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _bukaForm(initial: c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _konfirmasiHapus(c),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;
  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;

  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  // === LANGKAH 6: SIMPAN/UPDATE KE API ===
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);

    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await ApiClient.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await ApiClient.instance.insert(baru);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
      ));
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context);
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