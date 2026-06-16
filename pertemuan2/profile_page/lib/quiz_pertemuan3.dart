import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel state untuk menyimpan data profil utama
  String _nama = 'Murod Fikri Fadlurohman';
  String _tentang = 'Saya suka belajar hal baru, terutama yang berkaitan dengan teknologi dan pengembangan aplikasi mobile.';
  String _pendidikan = 'Universitas Pasundan — Semester 6';
  String _lokasi = 'Bandung, Jawa Barat';
  Uint8List? _imageBytes;
  String? _judulPengalaman;
  String? _deskripsiPengalaman;
  Uint8List? _gambarPengalaman;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const ListTile(leading: Icon(Icons.home), title: Text('Beranda')),
            const ListTile(leading: Icon(Icons.person), title: Text('Profil')),
            ListTile(
              leading: const Icon(Icons.widgets),
              title: const Text('Widget Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryHome()));
              },
            ),
            // --- TAMBAHKAN MENU UPLOAD PENGALAMAN DI SINI ---
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Pengalaman'),
              onTap: () async {
                Navigator.pop(context); // Tutup drawer terlebih dahulu
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UploadPengalamanPage(
                    judulAwal: _judulPengalaman,
                    deskripsiAwal: _deskripsiPengalaman,
                    gambarAwal: _gambarPengalaman,
                  )),
                );

                // Jika data berhasil disimpan dan dikembalikan
                if (result != null) {
                  setState(() {
                    _judulPengalaman = result['judul'];
                    _deskripsiPengalaman = result['deskripsi'];
                    _gambarPengalaman = result['image'];
                  });
                }
              },
            ),
            // -----------------------------------------------
            const ListTile(leading: Icon(Icons.settings), title: Text('Pengaturan')),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // === HEADER PROFIL ===
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    // Ubah logika backgroundImage menjadi MemoryImage
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!) as ImageProvider
                        : const AssetImage('Asset/avatar.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nama,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mahasiswa Teknik Informatika',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _StatBox(label: 'Post', value: '22')),
                Expanded(child: _StatBox(label: 'Teman', value: '227')),
                Expanded(child: _StatBox(label: 'Like', value: '1.5K')),
              ],
            ),
            const SizedBox(height: 24),

            // === SECTION CARD ===
            _SectionCard(icon: Icons.info_outline, title: 'Tentang Saya', content: _tentang),
            _SectionCard(icon: Icons.school, title: 'Pendidikan', content: _pendidikan),
            _SectionCard(icon: Icons.location_on, title: 'Lokasi', content: _lokasi),
            _SectionCard(icon: Icons.email, title: 'Kontak', content: 'murodadipate@gmail.com\n+62 858-7279-5056'),
            _SectionCard(icon: Icons.star, title: 'Skills', content: 'UI/UX'),

            // --- BONUS: TAMPILKAN CARD PENGALAMAN (JIKA ADA) ---
            if (_judulPengalaman != null && _judulPengalaman!.isNotEmpty) ...[
              const SizedBox(height: 12), // Jarak dengan card sebelumnya
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.work, color: Colors.blue, size: 28),
                          const SizedBox(width: 16),
                          const Text('Pengalaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tampilkan gambar jika ada
                      if (_gambarPengalaman != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _gambarPengalaman!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Tampilkan Judul dan Deskripsi
                      Text(_judulPengalaman!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(_deskripsiPengalaman!, style: const TextStyle(height: 1.4, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
            ],
            // ---------------------------------------------------
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Mengirim data saat ini ke halaman EditProfilePage dan menunggu hasilnya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                namaAwal: _nama,
                tentangAwal: _tentang,
                pendidikanAwal: _pendidikan,
                lokasiAwal: _lokasi,
                gambarAwal: _imageBytes,
              ),
            ),
          );

          // Jika user menekan tombol simpan (result tidak null), perbarui halaman utama
          if (result != null) {
            setState(() {
              _nama = result['nama'];
              _tentang = result['tentang'];
              _pendidikan = result['pendidikan'];
              _lokasi = result['lokasi'];
              _imageBytes = result['image'];
            });
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profil'),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _SectionCard({required this.icon, required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(content, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});
  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Display', Icons.image, Colors.blue),
      ('Input', Icons.edit, Colors.green),
      ('Button', Icons.smart_button, Colors.orange),
      ('Feedback', Icons.notifications, Colors.purple),
      ('Layout', Icons.dashboard, Colors.teal),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Gallery')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (name, icon, color) = categories[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => CategoryPage(name: name))),
            ),
          );
        },
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String name;
  const CategoryPage({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    final body = switch (name) {
      'Display' => const _DisplayDemo(),
      'Input' => const _InputDemo(),
      'Button' => const _ButtonDemo(),
      'Feedback' => const _FeedbackDemo(),
      'Layout' => const _LayoutDemo(),
      _ => const Center(child: Text('?')),
    };
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
    );
  }
}

class _DisplayDemo extends StatelessWidget {
  const _DisplayDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card', style: TextStyle(fontWeight: FontWeight.bold)),
        const Card(
          child: ListTile(
            leading: Icon(Icons.album),
            title: Text('Judul Item'),
            subtitle: Text('Sub-judul'),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Chip', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: const [
            Chip(label: Text('Flutter')),
            Chip(label: Text('Dart')),
            Chip(label: Text('Mobile')),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Divider', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(thickness: 2),
        const SizedBox(height: 16),
        const Text('CircleAvatar & Icon',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: const [
          CircleAvatar(child: Text('A')),
          SizedBox(width: 12),
          CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check)),
          SizedBox(width: 12),
          Icon(Icons.star, color: Colors.amber, size: 40),
        ]),
      ],
    );
  }
}

class _InputDemo extends StatefulWidget {
  const _InputDemo();
  @override
  State<_InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<_InputDemo> {
  bool _checked = false;
  bool _switched = true;
  double _slider = 0.5;
  String? _dropdown = 'Apel';
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TextField'),
        const SizedBox(height: 4),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nama',
            hintText: 'Ketik nama Anda',
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Checkbox'),
          value: _checked,
          onChanged: (v) => setState(() => _checked = v ?? false),
        ),
        SwitchListTile(
          title: const Text('Switch'),
          value: _switched,
          onChanged: (v) => setState(() => _switched = v),
        ),
        const Text('Slider'),
        Slider(value: _slider, onChanged: (v) => setState(() => _slider = v)),
        const SizedBox(height: 8),
        const Text('Dropdown'),
        DropdownButton<String>(
          value: _dropdown,
          items: ['Apel', 'Jeruk', 'Mangga']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _dropdown = v),
        ),
      ],
    );
  }
}

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
        const SizedBox(height: 8),
        FilledButton(onPressed: () {}, child: const Text('Filled')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
        const SizedBox(height: 8),
        TextButton(onPressed: () {}, child: const Text('Text Button')),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send),
          label: const Text('Dengan Icon'),
        ),
        const SizedBox(height: 8),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite, color: Colors.red),
        ),
      ],
    );
  }
}

class _FeedbackDemo extends StatelessWidget {
  const _FeedbackDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halo dari SnackBar!')),
            );
          },
          child: const Text('Tampilkan SnackBar'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Yakin ingin lanjut?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Tampilkan Dialog'),
        ),
        const SizedBox(height: 16),
        const Text('Progress Indicator:'),
        const SizedBox(height: 8),
        const LinearProgressIndicator(value: 0.6),
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _LayoutDemo extends StatelessWidget {
  const _LayoutDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stack — widget bertumpuk'),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Stack(
            children: [
              Container(width: double.infinity, color: Colors.blue.shade100),
              Positioned(
                top: 12, left: 12,
                child: Container(width: 50, height: 50, color: Colors.red),
              ),
              const Positioned(
                bottom: 12, right: 12,
                child: Icon(Icons.star, size: 40, color: Colors.amber),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Wrap — auto-pindah baris saat penuh'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: List.generate(8, (i) => Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade100,
            child: Text('Item \${i + 1}'),
          )),
        ),
        const SizedBox(height: 16),
        const Text('GridView (count: 3)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8, crossAxisSpacing: 8,
            children: List.generate(6, (i) => Container(
              color: Colors.purple.shade100,
              alignment: Alignment.center,
              child: Text('\${i + 1}'),
            )),
          ),
        ),
      ],
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String namaAwal;
  final String tentangAwal;
  final String pendidikanAwal;
  final String lokasiAwal;
  //final File? gambarAwal;
  final Uint8List? gambarAwal;

  const EditProfilePage({
    super.key,
    required this.namaAwal,
    required this.tentangAwal,
    required this.pendidikanAwal,
    required this.lokasiAwal,
    this.gambarAwal,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _namaController;
  late TextEditingController _tentangController;
  late TextEditingController _pendidikanController;
  late TextEditingController _lokasiController;
  //File? _imageFile;
  Uint8List? _imageBytes;

  final Color primaryPurple = const Color(0xFF5B5B98);

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaAwal);
    _tentangController = TextEditingController(text: widget.tentangAwal);
    _pendidikanController = TextEditingController(text: widget.pendidikanAwal);
    _lokasiController = TextEditingController(text: widget.lokasiAwal);
    //_imageFile = widget.gambarAwal; // Menerima file gambar lama jika ada
    _imageBytes = widget.gambarAwal;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tentangController.dispose();
    _pendidikanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Baca file sebagai Bytes agar aman dijalankan di Web (Chrome)
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _simpanData() {
    // Mengembalikan Map berisi data terupdate ke halaman utama
    Navigator.pop(context, {
      'nama': _namaController.text,
      'tentang': _tentangController.text,
      'pendidikan': _pendidikanController.text,
      'lokasi': _lokasiController.text,
      'image': _imageBytes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black87, fontSize: 18)),
        actions: [
          TextButton.icon(
            onPressed: _simpanData,
            icon: const Icon(Icons.check, color: Colors.grey, size: 18),
            label: const Text('Simpan', style: TextStyle(color: Colors.grey, fontSize: 14)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === BAGIAN FOTO PROFIL (SEALUR DENGAN WIREFRAME KUIS) ===
            Center(
              child: Column(
                children: [
                  Text('Foto Profil', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        // Ubah FileImage menjadi MemoryImage
                        backgroundImage: _imageBytes != null
                            ? MemoryImage(_imageBytes!) as ImageProvider
                            : const AssetImage('Asset/avatar.png'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined, color: Colors.grey, size: 18),
                    label: const Text('Ganti Foto dari Galeri', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 16),

            // === FORM INPUT ===
            Text('Informasi Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryPurple)),
            const SizedBox(height: 16),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tentangController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio / Tentang',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.info_outline),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pendidikanController,
              decoration: InputDecoration(
                labelText: 'Pendidikan',
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lokasiController,
              decoration: InputDecoration(
                labelText: 'Lokasi',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 32),

            // === TOMBOL SIMPAN UTAMA ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _simpanData,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadPengalamanPage extends StatefulWidget {
  final String? judulAwal;
  final String? deskripsiAwal;
  final Uint8List? gambarAwal;

  const UploadPengalamanPage({
    super.key,
    this.judulAwal,
    this.deskripsiAwal,
    this.gambarAwal,
  });

  @override
  State<UploadPengalamanPage> createState() => _UploadPengalamanPageState();
}

class _UploadPengalamanPageState extends State<UploadPengalamanPage> {
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  Uint8List? _imageBytes;

  final Color primaryPurple = const Color(0xFF5B5B98);

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.judulAwal ?? '');
    _deskripsiController = TextEditingController(text: widget.deskripsiAwal ?? '');
    _imageBytes = widget.gambarAwal;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _simpanData() {
    // Mengembalikan data pengalaman ke halaman utama
    Navigator.pop(context, {
      'judul': _judulController.text,
      'deskripsi': _deskripsiController.text,
      'image': _imageBytes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Upload Pengalaman', style: TextStyle(color: Colors.black87, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Pengalaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryPurple)),
            const SizedBox(height: 16),
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // Area untuk memilih gambar pengalaman
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid), // Ubah dash menjadi solid
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('Ketuk untuk pilih gambar', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _simpanData,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengalaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}