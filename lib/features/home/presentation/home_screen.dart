import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tokooci_app/config/constants/api_constants.dart';
import 'package:tokooci_app/core/services/api_service.dart';
import 'package:tokooci_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:tokooci_app/features/home/data/models/category_model.dart';
import 'package:tokooci_app/features/home/data/models/product_model.dart';
import 'package:tokooci_app/features/home/presentation/detail_screen.dart';
import 'package:tokooci_app/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:tokooci_app/features/cart/cart_screen.dart';
import 'package:tokooci_app/config/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchC = TextEditingController();
  Timer? _searchTimer;

  // API Services
  final ApiService _apiService = ApiService();
  late HomeRemoteDataSource _dataSource;
  late CartRemoteDataSource _cartDataSource;

  // State variables
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  String _errorMessage = '';
  
  int _cartCount = 0;
  int _selectedCategory = 0;
  int _selectedBanner = 0;
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  
  String? _token;
  bool _isLoggedIn = false;
  String _userName = '';

  // Data from API
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  // All category (for "Semua" option)
  final CategoryModel _allCategory = CategoryModel(
    id: 0,
    name: 'Semua',
    slug: 'all',
    description: 'Semua produk',
    productsCount: 0,
  );

  // Dummy banners
  final _banners = const [
    _BannerItem(
      title: 'Diskon Akhir Tahun',
      subtitle: 'Hingga 30% untuk laptop pilihan',
      cta: 'Lihat Promo',
      icon: Icons.local_offer_rounded,
    ),
    _BannerItem(
      title: 'Gratis Ongkir',
      subtitle: 'Min. belanja Rp 2.000.000',
      cta: 'Cek S&K',
      icon: Icons.local_shipping_rounded,
    ),
    _BannerItem(
      title: '0% Cicilan',
      subtitle: 'Tenor 3–12 bulan (partner tertentu)',
      cta: 'Ajukan Sekarang',
      icon: Icons.credit_card_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dataSource = HomeRemoteDataSource(apiService: _apiService);
    _cartDataSource = CartRemoteDataSource(client: http.Client());
    _loadUserData();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userName = prefs.getString('user_name') ?? '';
    
    setState(() {
      _token = token;
      _isLoggedIn = token != null && token.isNotEmpty;
      _userName = userName;
    });

    if (_isLoggedIn) {
      await _loadCartCount();
    }
  }

  Future<void> _loadCartCount() async {
    if (!_isLoggedIn || _token == null) return;

    try {
      final response = await _cartDataSource.getCart(_token!);
      setState(() {
        _cartCount = response.data.totalItems;
      });
    } catch (e) {
      print('Gagal memuat jumlah cart: $e');
      setState(() {
        _cartCount = 0;
      });
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
    ]);
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _errorMessage = '';
    });

    try {
      final response = await _dataSource.getCategories();
      
      setState(() {
        _categories = [_allCategory, ...response.data];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat kategori: $e';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadProducts({
    int? categoryId,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      setState(() {
        _isLoadingProducts = true;
        _errorMessage = '';
        _currentPage = page;
      });
    }

    try {
      final response = await _dataSource.getProducts(
        categoryId: categoryId == 0 ? null : categoryId,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: 12,
      );
      
      setState(() {
        if (loadMore) {
          _products.addAll(response.data.data);
        } else {
          _products = response.data.data;
        }
        
        _hasMoreProducts = response.data.meta.currentPage < response.data.meta.lastPage;
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _errorMessage = 'Gagal memuat produk: ${e.toString()}';
        _isLoadingProducts = false;
      });
    }
  }

  void _debounceSearch(String query) {
    _searchTimer?.cancel();
    
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadProducts(search: query);
      }
    });
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchC.text.trim().toLowerCase();
    final selectedCategory = _selectedCategory == 0 ? null : _categories[_selectedCategory];
    
    return _products.where((product) {
      final matchesCategory = selectedCategory == null || 
          product.categoryId == selectedCategory.id;
      
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          (product.brand ?? '').toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategory = index;
    });
    
    final categoryId = index == 0 ? null : _categories[index].id;
    _loadProducts(categoryId: categoryId);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        int sortIndex = 0;
        bool onlyPromo = false;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Urutkan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Terlaris'),
                        selected: sortIndex == 0,
                        onSelected: (_) => setModalState(() => sortIndex = 0),
                      ),
                      ChoiceChip(
                        label: const Text('Termurah'),
                        selected: sortIndex == 1,
                        onSelected: (_) => setModalState(() => sortIndex = 1),
                      ),
                      ChoiceChip(
                        label: const Text('Termahal'),
                        selected: sortIndex == 2,
                        onSelected: (_) => setModalState(() => sortIndex = 2),
                      ),
                      ChoiceChip(
                        label: const Text('Rating tertinggi'),
                        selected: sortIndex == 3,
                        onSelected: (_) => setModalState(() => sortIndex = 3),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hanya promo'),
                    subtitle: const Text('Contoh toggle filter (dummy)'),
                    value: onlyPromo,
                    onChanged: (v) => setModalState(() => onlyPromo = v),
                  ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filter diterapkan (dummy)'),
                          ),
                        );
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLoginRequiredDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.lock_outline, size: 50, color: Colors.orange),
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
              'Untuk mengakses $featureName, silakan login terlebih dahulu.',
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

  void _navigateToProfile(BuildContext context) {
    if (_isLoggedIn) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else {
      _showLoginRequiredDialog(context, 'Profil');
    }
  }

  void _navigateToCart(BuildContext context) {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      ).then((_) {
        _loadCartCount();
      });
    } else {
      _showLoginRequiredDialog(context, 'Keranjang');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toko OCI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Dikirim ke Bandung',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // TOMBOL LOGIN / PROFILE BERDASARKAN STATUS LOGIN
          if (!_isLoggedIn)
            // TOMBOL LOGIN (BELUM LOGIN)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            // ICON PROFILE (SUDAH LOGIN)
            IconButton(
              onPressed: () => _navigateToProfile(context),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          
          // CART BADGE (SELALU TAMPIL, TAPI FUNGSI BERBEDA)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _CartBadge(
              count: _cartCount,
              onTap: () => _navigateToCart(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SALAM PENGANTAR JIKA SUDAH LOGIN
          if (_isLoggedIn && _userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.waving_hand_rounded,
                    size: 18,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Halo, $_userName!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (_cartCount > 0)
                    Text(
                      '${_cartCount} item di keranjang',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700], fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[700], size: 16),
                    onPressed: () => setState(() => _errorMessage = ''),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SearchBar(
                    controller: _searchC,
                    onChanged: (value) {
                      setState(() {});
                      _debounceSearch(value);
                    },
                    onFilterTap: _openFilterSheet,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _isLoadingCategories
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _CategoryChips(
                          categories: _categories.map((c) => c.name).toList(),
                          selectedIndex: _selectedCategory,
                          onSelected: _onCategorySelected,
                        ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _PromoBanner(
                      items: _banners,
                      activeIndex: _selectedBanner,
                      onChanged: (i) => setState(() => _selectedBanner = i),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Laptop Populer',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lihat semua (dummy)')),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Lihat semua'),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildProductsGrid(theme, filteredProducts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(ThemeData theme, List<ProductModel> filteredProducts) {
    if (_isLoadingProducts && _products.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (filteredProducts.isEmpty && !_isLoadingProducts) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchC.text.isEmpty
                      ? 'Tidak ada produk ditemukan'
                      : 'Tidak ada produk dengan kata kunci "${_searchC.text}"',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < filteredProducts.length) {
              final product = filteredProducts[index];
              return _ProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ).then((_) {
                    // Refresh cart count ketika kembali dari detail
                    if (_isLoggedIn) {
                      _loadCartCount();
                    }
                  });
                },
                onAddToCart: () async {
                  if (!_isLoggedIn) {
                    _showLoginRequiredDialog(context, 'menambahkan ke keranjang');
                    return;
                  }

                  try {
                    await _cartDataSource.addToCart(
                      token: _token!,
                      productId: product.id,
                      quantity: 1,
                    );
                    await _loadCartCount();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} ditambahkan ke keranjang'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menambahkan: $e')),
                    );
                  }
                },
              );
            } else if (_hasMoreProducts && !_isLoadingProducts) {
              _loadProducts(
                categoryId: _selectedCategory == 0 ? null : _categories[_selectedCategory].id,
                search: _searchC.text.isEmpty ? null : _searchC.text,
                page: _currentPage + 1,
                loadMore: true,
              );
              return const Center(child: CircularProgressIndicator());
            }
            return null;
          },
          childCount: filteredProducts.length + (_hasMoreProducts ? 1 : 0),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3 / 5,
        ),
      ),
    );
  }
}

// ============================
// Widgets (SAMA DENGAN SEBELUMNYA)
// ============================

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari laptop, brand, spesifikasi...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return ChoiceChip(
            label: Text(categories[i]),
            selected: selected,
            onSelected: (_) => onSelected(i),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      )
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.items,
    required this.activeIndex,
    required this.onChanged,
  });

  final List<_BannerItem> items;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            onPageChanged: onChanged,
            itemCount: items.length,
            itemBuilder: (context, i) {
              final b = items[i];
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.95),
                      theme.colorScheme.tertiary.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(
                                0.9,
                              ),
                            ),
                          ),
                          const Spacer(),
                          FilledButton.tonal(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('CTA: ${b.cta} (dummy)'),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.onPrimary
                                  .withOpacity(0.18),
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: Text(b.cta),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        b.icon,
                        color: theme.colorScheme.onPrimary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final isActive = i == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 18 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.disabledColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
                ),
                child: _buildProductImage(),
              ),
              const SizedBox(height: 10),

              // Brand
              Text(
                (product.brand ?? 'Unknown').toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.hintColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),

              // Product name
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),

              // Short description
              Text(
                product.description.length > 50
                    ? '${product.description.substring(0, 50)}...'
                    : product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const Spacer(),

              // Rating and stock info
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '4.5',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${product.stock} tersedia',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price
              Text(
                _formatPrice(product.price),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final hasValidImage = product.imageUrl != null && 
                         product.imageUrl!.isNotEmpty && 
                         (product.imageUrl!.startsWith('http://') || 
                          product.imageUrl!.startsWith('https://'));

    if (hasValidImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          product.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                _getProductEmoji(product.category?.name ?? ''),
                style: const TextStyle(fontSize: 40),
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
      );
    } else {
      return Center(
        child: Text(
          _getProductEmoji(product.category?.name ?? ''),
          style: const TextStyle(fontSize: 40),
        ),
      );
    }
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

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.shopping_cart_outlined),
          ),
          if (count > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================
// Models + helpers
// ============================

class _BannerItem {
  final String title;
  final String subtitle;
  final String cta;
  final IconData icon;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.icon,
  });
}