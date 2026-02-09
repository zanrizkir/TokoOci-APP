class AppInputValidators {
  AppInputValidators._();

  /// Validasi teks wajib isi
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validasi email
  static String? email(String? value, {String fieldName = 'Email'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value.trim())) {
      return '$fieldName tidak valid';
    }
    return null;
  }

  /// Validasi password minimal panjang tertentu
  static String? password(
    String? value, {
    String fieldName = 'Password',
    int minLength = 6,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi konfirmasi password
  static String? confirmPassword(
    String? value, {
    required String password,
    String fieldName = 'Konfirmasi password',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value != password) {
      return '$fieldName tidak sama dengan password';
    }
    return null;
  }

  /// Validasi minimal panjang teks (generic)
  static String? minLength(
    String? value, {
    required int length,
    String fieldName = 'Field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.length < length) {
      return '$fieldName minimal $length karakter';
    }
    return null;
  }

  /// Validasi hanya angka
  static String? numeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final numericRegExp = RegExp(r'^[0-9]+$');
    if (!numericRegExp.hasMatch(value.trim())) {
      return '$fieldName hanya boleh berisi angka';
    }
    return null;
  }

  /// Validasi NIK: wajib angka & tepat 16 digit
  static String? nik(String? value, {String fieldName = 'NIK'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName tidak boleh kosong';

    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return '$fieldName harus berupa angka';
    }
    if (v.length != 16) {
      return '$fieldName harus 16 digit';
    }
    return null;
  }

  static String? phoneLocalIdMinOnly(
    String? value, {
    String fieldName = 'No Telepon',
    int minLength = 9,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName tidak boleh kosong';

    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return '$fieldName harus berupa angka';
    }

    if (!v.startsWith('8')) {
      return '$fieldName harus diawali angka 8 (setelah +62).';
    }

    if (v.length < minLength) {
      return '$fieldName minimal $minLength digit (contoh: 812xxxxxxx).';
    }

    return null;
  }

  /// Validasi jumlah pinjaman minimal 1 juta
  static String? minLoanAmount(
    String? value, {
    String fieldName = 'Jumlah pinjaman',
    int min = 1000000,
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName tidak boleh kosong';

    final amount = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (amount < min) {
      return '$fieldName minimal Rp ${_formatRupiah(min)}';
    }
    return null;
  }

  static String _formatRupiah(int value) {
    // format sederhana: 1000000 -> 1.000.000
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buf.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }
}