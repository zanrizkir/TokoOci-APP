import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../cart/data/datasources/cart_remote_data_source.dart';
import '../cart/data/models/cart_model.dart';
import '../checkout/checkout_screen.dart';
import '../../config/theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRemoteDataSource _cartDataSource = CartRemoteDataSource(
    client: http.Client(),
  );

  bool _isLoading = true;
  String _errorMessage = '';
  CartResponse? _cartResponse;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndCart();
  }

  Future<void> _loadTokenAndCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Anda belum login. Silakan login terlebih dahulu.';
        _isLoading = false;
      });
      return;
    }

    _token = token;
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _cartDataSource.getCart(_token!);
      setState(() {
        _cartResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat keranjang: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addQuantity(int cartItemId, int currentQuantity) async {
    if (_token == null) return;

    try {
      await _cartDataSource.updateCartItem(
        token: _token!,
        cartItemId: cartItemId,
        quantity: currentQuantity + 1,
      );
      await _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah jumlah: $e')));
    }
  }

  Future<void> _reduceQuantity(int cartItemId, int currentQuantity) async {
    if (_token == null) return;

    try {
      if (currentQuantity > 1) {
        await _cartDataSource.updateCartItem(
          token: _token!,
          cartItemId: cartItemId,
          quantity: currentQuantity - 1,
        );
      } else {
        await _cartDataSource.removeFromCart(
          token: _token!,
          cartItemId: cartItemId,
        );
      }
      await _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengurangi jumlah: $e')));
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    if (_token == null) return;

    try {
      await _cartDataSource.removeFromCart(
        token: _token!,
        cartItemId: cartItemId,
      );
      await _loadCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item dihapus dari keranjang')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus item: $e')));
    }
  }

  Future<void> _clearCart() async {
    if (_token == null) return;

    try {
      await _cartDataSource.clearCart(_token!);
      await _loadCart();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang dikosongkan')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengosongkan keranjang: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Keranjang'),
        actions: [
          if (_cartResponse != null && _cartResponse!.data.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
              tooltip: 'Kosongkan Keranjang',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTokenAndCart,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_cartResponse == null || _cartResponse!.data.items.isEmpty) {
      return const _EmptyCart();
    }

    final items = _cartResponse!.data.items;
    final total = _cartResponse!.data.totalPrice;

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _CartItemTile(
              item: item,
              onAdd: () => _addQuantity(item.id, item.quantity),
              onRemove: () => _reduceQuantity(item.id, item.quantity),
              onDelete: () => _removeItem(item.id),
            );
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _CheckoutBar(
            subtotal: total,
            shipping: total > 1500000 ? 0 : 25000,
            total: total + (total > 1500000 ? 0 : 25000),
            onCheckout: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(
                    cartData: _cartResponse,
                    fromCart: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ================= CART ITEM TILE ================= */

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const _CartItemTile({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
            child:
                item.product.imageUrl != null &&
                    item.product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _getProductEmoji(item.product.category?.name ?? ''),
                            style: const TextStyle(fontSize: 24),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _getProductEmoji(item.product.category?.name ?? ''),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.brand ?? 'Unknown',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${item.product.stock}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: item.product.stock > 0
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.product.price),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onDelete,
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded),
                      onPressed: onRemove,
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProductEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return '💻';
      case 'komputer desktop':
        return '🖥️';
      case 'processor':
        return '⚙️';
      case 'motherboard':
        return '🔌';
      case 'ram':
        return '🧠';
      case 'vga card':
        return '🎮';
      case 'storage':
        return '💾';
      case 'power supply':
        return '🔋';
      case 'monitor':
        return '🖥️';
      default:
        return '🛒';
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

/* ================= CHECKOUT BAR ================= */

class _CheckoutBar extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double total;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RowPrice(label: 'Subtotal', value: _formatPrice(subtotal)),
          _RowPrice(
            label: 'Ongkir',
            value: shipping == 0 ? 'Gratis' : _formatPrice(shipping),
          ),
          const Divider(),
          _RowPrice(label: 'Total', value: _formatPrice(total), bold: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
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

class _RowPrice extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _RowPrice({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= EMPTY CART ================= */

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan produk ke keranjang untuk melihatnya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }
}
