import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'product_filters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProductManagerApp());
}

class ProductManagerApp extends StatelessWidget {
  const ProductManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Autumn Product Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff8a4f2a)),
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _products = FirebaseFirestore.instance.collection('products');
  final _searchController = TextEditingController();
  final _minimumController = TextEditingController();
  final _maximumController = TextEditingController();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _productStream;
  ProductFilter _filter = const ProductFilter();
  String? _filterError;

  @override
  void initState() {
    super.initState();
    // Keep one listener; typing filters the latest snapshot in memory.
    _productStream = _products.snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minimumController.dispose();
    _maximumController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    try {
      final next = ProductFilter.parse(
        search: _searchController.text,
        minimum: _minimumController.text,
        maximum: _maximumController.text,
      );
      setState(() {
        _filter = next;
        _filterError = null;
      });
    } on FormatException catch (error) {
      setState(() => _filterError = error.message);
    }
  }

  void _resetFilters() {
    _searchController.clear();
    _minimumController.clear();
    _maximumController.clear();
    setState(() {
      _filter = const ProductFilter();
      _filterError = null;
    });
  }

  Future<void> _openEditor([
    QueryDocumentSnapshot<Map<String, dynamic>>? document,
  ]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) =>
          ProductEditor(products: _products, document: document),
    );
  }

  Future<void> _deleteProduct(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final name = document.data()['name'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Delete ${name is String ? name : 'this product'}?\n\n'
          'Document ID: ${document.id}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _products.doc(document.id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted document ${document.id}.')),
      );
    } on FirebaseException catch (error) {
      debugPrint('Product delete failed (${error.code}): ${error.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed (${error.code}). Check connection and permissions.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autumn Product Manager')),
      body: Column(
        children: [
          _FilterPanel(
            searchController: _searchController,
            minimumController: _minimumController,
            maximumController: _maximumController,
            error: _filterError,
            onChanged: _applyFilters,
            onReset: _resetFilters,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _MessageState(
                    icon: Icons.cloud_off,
                    message: 'Products could not load. Check connection and permissions.',
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocuments = snapshot.data!.docs;
                if (allDocuments.isEmpty) {
                  return const _MessageState(
                    icon: Icons.inventory_2_outlined,
                    message: 'No products yet. Add one to begin.',
                  );
                }

                final visibleDocuments = allDocuments.where((document) {
                  final product = ProductRecord.tryParse(
                    id: document.id,
                    data: document.data(),
                  );
                  // Keep malformed cloud records visible instead of hiding them.
                  return product == null || _filter.matches(product);
                }).toList();

                if (_filterError == null && visibleDocuments.isEmpty) {
                  return const _MessageState(
                    icon: Icons.search_off,
                    message: 'No products found.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                  itemCount: visibleDocuments.length,
                  itemBuilder: (context, index) {
                    final document = visibleDocuments[index];
                    final product = ProductRecord.tryParse(
                      id: document.id,
                      data: document.data(),
                    );
                    if (product == null) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber),
                          title: Text('Invalid product ${document.id}'),
                          subtitle: const Text(
                            'Check that name is nonempty and price is a finite, '
                            'nonnegative number.',
                          ),
                        ),
                      );
                    }
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          '\$${product.price.toStringAsFixed(2)}\n'
                          'ID: ${product.id}',
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Edit product',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openEditor(document),
                            ),
                            IconButton(
                              tooltip: 'Delete product',
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteProduct(document),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create product',
        onPressed: _openEditor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.searchController,
    required this.minimumController,
    required this.maximumController,
    required this.error,
    required this.onChanged,
    required this.onReset,
  });

  final TextEditingController searchController;
  final TextEditingController minimumController;
  final TextEditingController maximumController;
  final String? error;
  final VoidCallback onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: 'Search products',
                hintText: 'Case-insensitive name substring',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minimumController,
                    onChanged: (_) => onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Minimum price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: maximumController,
                    onChanged: (_) => onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Maximum price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Reset filters',
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
            if (error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, required this.products, this.document});

  final CollectionReference<Map<String, dynamic>> products;
  final QueryDocumentSnapshot<Map<String, dynamic>>? document;

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  var _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final data = widget.document?.data();
    _name = TextEditingController(
      text: data?['name'] is String ? data!['name'] as String : '',
    );
    _price = TextEditingController(text: data?['price']?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });

    final data = <String, Object>{
      'name': _name.text.trim(),
      'price': double.parse(_price.text.trim()),
    };
    try {
      final document = widget.document;
      if (document == null) {
        await widget.products.add(data);
      } else {
        await widget.products.doc(document.id).update(data);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseException catch (error) {
      debugPrint('Product save failed (${error.code}): ${error.message}');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError =
            'Save failed (${error.code}). Check connection and permissions.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.document == null ? 'Create product' : 'Edit product',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a product name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || !amount.isFinite || amount < 0
                        ? 'Enter a finite price of zero or more'
                        : null;
                  },
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _saveError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (_saving) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Awaiting server acknowledgement. If offline, reconnect. '
                    'This editor stays open until the write succeeds or fails.',
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save'),
                ),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
