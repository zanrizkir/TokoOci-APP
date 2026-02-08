import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tokooci_app/config/routes/app_routes.dart';
import 'package:tokooci_app/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:tokooci_app/features/cart/data/models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  final CartResponse? cartData;
  final bool fromCart;

  const CheckoutScreen({
    super.key,
    this.cartData,
    this.fromCart = true,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  final CartRemoteDataSource _cartDataSource = CartRemoteDataSource(
    client: http.Client(),
  );

  String? _selectedShipping = 'regular';
  String? _selectedPayment = 'transfer';
  bool _isProcessing = false;
  String? _token;
  CartResponse? _cartResponse;

  List<Map<String, dynamic>> _shippingOptions = [
    {'id': 'regular', 'name': 'Reguler (3-5 hari)', 'cost': 15000, 'icon': Icons.local_shipping},
    {'id': 'express', 'name': 'Express (1-2 hari)', 'cost': 30000, 'icon': Icons.directions_car},
    {'id': 'same_day', 'name': 'Same Day', 'cost': 50000, 'icon': Icons.flash_on},
  ];

  List<Map<String, dynamic>> _paymentOptions = [
    {'id': 'transfer', 'name': 'Transfer Bank', 'icon': Icons.account_balance, 'banks': ['BCA', 'Mandiri', 'BNI']},
    {'id': 'cod', 'name': 'Cash on Delivery', 'icon': Icons.money, 'note': 'Bayar saat barang diterima'},
    {'id': 'ewallet', 'name': 'E-Wallet', 'icon': Icons.wallet, 'wallets': ['GoPay', 'OVO', 'Dana']},
  ];

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
    _loadUserProfile();
  }

  Future<void> _loadTokenAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    setState(() {
      _token = token;
    });

    if (widget.fromCart && token != null) {
      await _loadCart();
    }
  }

  Future<void> _loadCart() async {
    if (_token == null) return;

    try {
      final response = await _cartDataSource.getCart(_token!);
      setState(() {
        _cartResponse = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat keranjang: $e')),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    // Load data user dari SharedPreferences atau API
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final phone = prefs.getString('user_phone') ?? '';
    final address = prefs.getString('user_address') ?? '';

    if (mounted) {
      setState(() {
        _nameController.text = name;
        _phoneController.text = phone;
        _addressController.text = address;
      });
    }
  }

  double get _subtotal {
    if (widget.fromCart && _cartResponse != null) {
      return _cartResponse!.data.totalPrice;
    }
    // Jika dari detail produk langsung, perlu data produk
    return 0;
  }

  double get _shippingCost {
    final option = _shippingOptions.firstWhere(
      (opt) => opt['id'] == _selectedShipping,
      orElse: () => _shippingOptions.first,
    );
    return option['cost'].toDouble();
  }

  double get _total => _subtotal + _shippingCost;

  Future<void> _processCheckout() async {
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulasi proses checkout
      await Future.delayed(const Duration(seconds: 2));

      // Simpan data pengiriman
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_phone', _phoneController.text);
      await prefs.setString('user_address', _addressController.text);

      // Jika checkout dari cart, kosongkan cart
      if (widget.fromCart && _cartResponse != null && _cartResponse!.data.items.isNotEmpty) {
        await _cartDataSource.clearCart(_token!);
      }

      // Tampilkan konfirmasi sukses
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Checkout Berhasil!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Order ID: #${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total: ${_formatPrice(_total)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasItems = widget.fromCart
        ? _cartResponse != null && _cartResponse!.data.items.isNotEmpty
        : true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !hasItems
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang Kosong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan produk ke keranjang terlebih dahulu',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // INFORMASI PENGIRIMAN
                          _buildSectionHeader('Informasi Pengiriman'),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildFormField(
                                    controller: _nameController,
                                    label: 'Nama Penerima',
                                    hint: 'Masukkan nama lengkap',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormField(
                                    controller: _phoneController,
                                    label: 'Nomor Telepon',
                                    hint: 'Masukkan nomor telepon',
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nomor telepon tidak boleh kosong';
                                      }
                                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                        return 'Hanya angka yang diperbolehkan';
                                      }
                                      if (value.length < 10) {
                                        return 'Minimal 10 digit';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormField(
                                    controller: _addressController,
                                    label: 'Alamat Lengkap',
                                    hint: 'Masukkan alamat lengkap',
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Alamat tidak boleh kosong';
                                      }
                                      if (value.length < 10) {
                                        return 'Alamat terlalu pendek';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildFormField(
                                          controller: _cityController,
                                          label: 'Kota',
                                          hint: 'Nama kota',
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Kota tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildFormField(
                                          controller: _postalCodeController,
                                          label: 'Kode Pos',
                                          hint: '00000',
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Kode pos tidak boleh kosong';
                                            }
                                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                              return 'Hanya angka yang diperbolehkan';
                                            }
                                            if (value.length != 5) {
                                              return 'Kode pos harus 5 digit';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // METODE PENGIRIMAN
                          _buildSectionHeader('Metode Pengiriman'),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: _shippingOptions.map((option) {
                                  return _buildRadioOption(
                                    value: option['id'],
                                    groupValue: _selectedShipping,
                                    title: option['name'],
                                    subtitle: _formatPrice(option['cost'].toDouble()),
                                    icon: option['icon'],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedShipping = value;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // METODE PEMBAYARAN
                          _buildSectionHeader('Metode Pembayaran'),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: _paymentOptions.map((option) {
                                  return _buildRadioOption(
                                    value: option['id'],
                                    groupValue: _selectedPayment,
                                    title: option['name'],
                                    subtitle: option['note'] ?? '',
                                    icon: option['icon'],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPayment = value;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // RINGKASAN PESANAN
                          _buildSectionHeader('Ringkasan Pesanan'),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildOrderRow('Subtotal', _subtotal),
                                  _buildOrderRow('Biaya Pengiriman', _shippingCost),
                                  const Divider(height: 24),
                                  _buildOrderRow(
                                    'Total Pembayaran',
                                    _total,
                                    isBold: true,
                                    textColor: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Dengan menekan tombol "Bayar Sekarang", Anda menyetujui Syarat & Ketentuan yang berlaku.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // BOTTOM PAYMENT BAR
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          offset: const Offset(0, -6),
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _formatPrice(_total),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _processCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Bayar Sekarang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(String label, double value,
      {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: textColor ?? Colors.grey[700],
            ),
          ),
          Text(
            _formatPrice(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: textColor ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(price);
    } catch (e) {
      final priceStr = price.toStringAsFixed(0);
      final buffer = StringBuffer('Rp ');
      for (int i = 0; i < priceStr.length; i++) {
        if (i > 0 && (priceStr.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(priceStr[i]);
      }
      return buffer.toString();
    }
  }
}