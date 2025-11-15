import 'package:ecommerce/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/views/cart_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedIndex = 0;
  int currentNavIndex = 0;
  Set<Product> favoriteProducts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dutaro E-Commerce App"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              final count = cart.totalItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: currentNavIndex == 0 ? _buildHome() : _buildFavorites(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNavIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Our Products", style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _categoryButton("All Products", 0),
            _categoryButton("Jackets", 1),
            _categoryButton("Sneakers", 2),
          ],
        ),
        const SizedBox(height: 15),
        Expanded(child: _buildProductGrid()),
      ],
    );
  }

  Widget _buildProductGrid() {
    List<Product> displayProducts;

    if (selectedIndex == 0) {
      displayProducts = products;
    } else if (selectedIndex == 1) {
      displayProducts = products.where((product) => product.category == 'Jackets').toList();
    } else {
      displayProducts = products.where((product) => product.category == 'Sneakers').toList();
    }

    return GridView.builder(
      itemCount: displayProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _categoryButton(String title, int index) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedIndex = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedIndex == index ? Colors.red : Colors.grey[200],
        foregroundColor: selectedIndex == index ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(title),
    );
  }

  Widget _buildFavorites() {
    if (favoriteProducts.isEmpty) {
      return const Center(
        child: Text("No favorite products yet."),
      );
    }

    return GridView.builder(
      itemCount: favoriteProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final product = favoriteProducts.elementAt(index);
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorited = favoriteProducts.contains(product);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    if (isFavorited) {
                      favoriteProducts.remove(product);
                    } else {
                      favoriteProducts.add(product);
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: Image.asset(
                product.image,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            ),
            Text(product.status, style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            ),
            Text("\$${product.price}", style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.status.toLowerCase().contains('out of stock')
                      ? Colors.grey
                      : Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: product.status.toLowerCase().contains('out of stock')
                    ? null
                    : () {
                        context.read<CartProvider>().addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} added to cart')),
                        );
                      },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}