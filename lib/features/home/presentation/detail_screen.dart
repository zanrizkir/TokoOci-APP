import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokooci_app/config/routes/app_routes.dart';
import 'package:tokooci_app/core/services/api_service.dart';
import 'package:tokooci_app/features/cart/cart_screen.dart';
import 'package:tokooci_app/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:tokooci_app/features/checkout/checkout_screen.dart';
import 'package:tokooci_app/features/home/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: Text('Detail ${product.name}'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Wishlist (dummy)')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Bagikan produk')));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // SCROLLABLE CONTENT
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SECTION
                _buildProductImage(theme),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BRAND
                      Text(
                        (product.brand ?? 'Unknown').toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          letterSpacing: 1,
                          color: theme.hintColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // PRODUCT NAME
                      Text(
                        product.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // RATING & STOCK
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.5',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.stock > 0
                                  ? '${product.stock} tersedia'
                                  : 'Stok habis',
                              style: TextStyle(
                                fontSize: 12,
                                color: product.stock > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // PRICE
                      Text(
                        _formatPrice(product.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CATEGORY
                      if (product.category != null) ...[
                        _SectionTitle(title: 'Kategori'),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category!.name,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // SPECIFICATIONS
                      _SectionTitle(title: 'Spesifikasi'),
                      if (product.specifications != null &&
                          product.specifications!.isNotEmpty)
                        _buildSpecificationsWidget(product.specifications!)
                      else
                        Column(
                          children: [
                            _SpecItem(
                              label: 'Processor',
                              value: 'Tidak tersedia',
                            ),
                            _SpecItem(label: 'RAM', value: 'Tidak tersedia'),
                            _SpecItem(
                              label: 'Storage',
                              value: 'Tidak tersedia',
                            ),
                            _SpecItem(
                              label: 'Graphics',
                              value: 'Tidak tersedia',
                            ),
                            _SpecItem(
                              label: 'Display',
                              value: 'Tidak tersedia',
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // DESCRIPTION
                      _SectionTitle(title: 'Deskripsi'),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'Produk ${product.name} dengan performa yang handal. Cocok untuk berbagai kebutuhan sehari-hari dan produktivitas.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ADDITIONAL INFORMATION
                      _SectionTitle(title: 'Informasi Tambahan'),
                      _InfoItem(
                        icon: Icons.inventory_2_outlined,
                        text: 'Stok: ${product.stock} unit',
                        color: product.stock > 0
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                      _InfoItem(
                        icon: Icons.verified_outlined,
                        text: 'Garansi: 1 tahun resmi',
                        color: Colors.blue[700],
                      ),
                      _InfoItem(
                        icon: Icons.local_shipping_outlined,
                        text: 'Pengiriman: 3-5 hari kerja',
                        color: Colors.orange[700],
                      ),
                      _InfoItem(
                        icon: Icons.rotate_left_outlined,
                        text: 'Pengembalian: 7 hari setelah penerimaan',
                        color: Colors.purple[700],
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FIXED BOTTOM BUTTONS
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomAction(product: product),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    final hasValidImage =
        product.imageUrl != null &&
        product.imageUrl!.isNotEmpty &&
        (product.imageUrl!.startsWith('http://') ||
            product.imageUrl!.startsWith('https://'));

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.primary.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasValidImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getProductEmoji(product.category?.name ?? ''),
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gambar tidak dapat dimuat',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getProductEmoji(product.category?.name ?? ''),
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tidak ada gambar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSpecificationsWidget(String specifications) {
    try {
      final specs = jsonDecode(specifications);
      if (specs is Map<String, dynamic>) {
        return Column(
          children: specs.entries
              .map(
                (entry) => _SpecItem(
                  label: _formatSpecLabel(entry.key),
                  value: entry.value.toString(),
                ),
              )
              .toList(),
        );
      } else {
        return _SpecItem(label: 'Spesifikasi', value: specifications);
      }
    } catch (e) {
      return _SpecItem(label: 'Spesifikasi', value: specifications);
    }
  }

  String _formatSpecLabel(String label) {
    final formatted = label
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();

    return formatted
        .split(' ')
        .map((word) {
          if (word.isNotEmpty) {
            return word[0].toUpperCase() + word.substring(1);
          }
          return word;
        })
        .join(' ');
  }

  String _getProductEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
      case 'ultrabook':
        return '💻';
      case 'gaming':
        return '🎮';
      case 'office':
        return '📊';
      case 'creator':
        return '🎨';
      case 'budget':
        return '💰';
      case 'processor':
        return '⚙️';
      default:
        return '💻';
    }
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

// ==================== BOTTOM ACTION ====================
class _BottomAction extends StatefulWidget {
  final ProductModel product;

  const _BottomAction({required this.product});

  @override
  State<_BottomAction> createState() => __BottomActionState();
}

class __BottomActionState extends State<_BottomAction> {
  final CartRemoteDataSource _cartDataSource = CartRemoteDataSource(
    client: http.Client(),
  );
  bool _isAddingToCart = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _showLoginRequiredDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(
          Icons.shopping_cart_outlined,
          size: 50,
          color: Colors.orange,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login Diperlukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Untuk $action, silakan login terlebih dahulu.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Login Sekarang'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  Future<void> _addToCart(BuildContext context) async {
    final isLoggedIn = await ApiService().isLoggedIn();

    if (!isLoggedIn) {
      _showLoginRequiredDialog(context, 'menambahkan ke keranjang');
      return;
    }

    if (widget.product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk habis'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final response = await _cartDataSource.addToCart(
        token: _token!,
        productId: widget.product.id,
        quantity: 1,
      );

      if (response.success) {
        final snackBar = SnackBar(
          content: Text('${widget.product.name} ditambahkan ke keranjang'),
          action: SnackBarAction(
            label: 'Lihat Keranjang',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
          content: Text('Gagal: ${response.message}'),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error: $e'),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  Future<void> _buyNow(BuildContext context) async {
    final isLoggedIn = await ApiService().isLoggedIn();

    if (!isLoggedIn) {
      _showLoginRequiredDialog(context, 'membeli produk ini');
      return;
    }

    if (widget.product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk habis'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mempersiapkan checkout...'),
          ],
        ),
      ),
    );

    try {
      final cartResponse = await _cartDataSource.addToCart(
        token: _token!,
        productId: widget.product.id,
        quantity: 1,
      );

      if (mounted) Navigator.pop(context);

      if (cartResponse.success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CheckoutScreen(cartData: cartResponse, fromCart: true),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${cartResponse.message}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = widget.product.stock <= 0;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: Container(
        width: screenWidth,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Tambah ke Keranjang
            SizedBox(
              width: (screenWidth - 36) / 2,
              child: OutlinedButton(
                onPressed: isOutOfStock || _isAddingToCart
                    ? null
                    : () => _addToCart(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isOutOfStock
                        ? Colors.grey[300]!
                        : theme.colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isAddingToCart
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 18,
                            color: isOutOfStock
                                ? Colors.grey[400]
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isOutOfStock ? 'Stok Habis' : 'Tambah',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock
                                    ? Colors.grey[400]
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Tombol Beli Sekarang
            SizedBox(
              width: (screenWidth - 36) / 2,
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : () => _buyNow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock
                      ? Colors.grey[400]
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Beli Sekarang',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== COMPONENTS ====================
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;

  const _SpecItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoItem({
    required this.icon,
    required this.text,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
