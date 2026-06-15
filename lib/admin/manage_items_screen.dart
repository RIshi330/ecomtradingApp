import 'package:flutter/material.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() =>
      _ManageItemsScreenState();
}

class _ManageItemsScreenState
    extends State<ManageItemsScreen> {

  final List<ItemModel> items = [
    ItemModel(
      title: "Minimalist Watch",
      image:
          "https://images.unsplash.com/photo-1523170335258-f5ed11844a49",
      variants: ["Color", "Size"],
    ),
    ItemModel(
      title: "Performance Runners",
      image:
          "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
      variants: ["Size", "Fabric"],
    ),
    ItemModel(
      title: "Studio Headphones",
      image:
          "https://images.unsplash.com/photo-1505740420928-5e560c06d30e",
      variants: ["Package Type"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Items List",
          style: TextStyle(
            color: Color(0xFF1C1B1B),
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                onPressed: () => Navigator.pop(context),
              )
            : const Icon(
                Icons.menu,
                color: Color(0xff006565),
              ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xff006565)),
            onPressed: () {},
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff006565),
        foregroundColor: Colors.white,
        onPressed: showAddItemSheet,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xff006565),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search catalog...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.sort),
                        label: const Text("Sort"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list),
                        label: const Text("Filter"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onDelete: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (context) {
        return const AddItemSheet();
      },
    );
  }
}

class ItemModel {
  final String title;
  final String image;
  final List<String> variants;

  ItemModel({
    required this.title,
    required this.image,
    required this.variants,
  });
}

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xffD4E6E5),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xff006565),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 6,
                    children: item.variants
                        .map(
                          (e) => Chip(
                            label: Text(e),
                            backgroundColor: const Color(0xffD4E6E5),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() =>
      _AddItemSheetState();
}

class _AddItemSheetState
    extends State<AddItemSheet> {

  final titleController = TextEditingController();

  final Map<String, bool> variants = {
    "Color": false,
    "Size": false,
    "Fabric": false,
    "Material": false,
    "Specification": false,
    "No of items per pack": false,
    "Package Type": false,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom:
              MediaQuery.of(context)
                  .viewInsets
                  .bottom +
              20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Add New Item",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Item Title",
                hintText: "Enter product name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_a_photo,
                    size: 50,
                    color: Color(0xff006565),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Upload Image",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Variants",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ...variants.keys.map(
              (variant) => CheckboxListTile(
                value: variants[variant],
                activeColor: const Color(0xff006565),
                title: Text(
                  variant,
                ),
                onChanged: (value) {
                  setState(() {
                    variants[variant] = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006565),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Add Item",
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
