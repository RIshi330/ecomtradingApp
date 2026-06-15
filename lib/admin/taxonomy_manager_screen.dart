import 'package:flutter/material.dart';

class TaxonomyManagerScreen extends StatefulWidget {
  const TaxonomyManagerScreen({super.key});

  @override
  State<TaxonomyManagerScreen> createState() =>
      _TaxonomyManagerScreenState();
}

class _TaxonomyManagerScreenState
    extends State<TaxonomyManagerScreen> {

  int selectedTab = 0;

  final tabs = [
    "Electronics",
    "Fashion",
    "Services",
    "Furniture"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Taxonomy Manager",
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.account_circle,
              color: Color(0xff006565),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff006565),
        foregroundColor: Colors.white,
        onPressed: showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xff006565),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Marketplaces",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Attributes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (_, index) {

                  final active =
                      selectedTab == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(
                              right: 8),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xffD4E6E5)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                                10),
                        border: Border.all(
                          color: active
                              ? const Color(0xff006565).withAlpha(120)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: active
                              ? const Color(0xff006565)
                              : Colors.grey,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText:
                    "Search Categories",
                prefixIcon:
                    const Icon(Icons.search),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: const [

                Text(
                  "Categories Structure",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Spacer(),

                Text(
                  "12 Total Items",
                ),
              ],
            ),

            const SizedBox(height: 16),

            const CategoryNode(
              title:
                  "Computing & Accessories",
              expanded: true,
            ),

            const SizedBox(height: 10),

            const CategoryNode(
              title: "Mobile Phones",
            ),

            const SizedBox(height: 10),

            const CategoryNode(
              title: "Smart Home",
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: showHierarchyMap,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Colors.grey.shade300,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: const Column(
                  children: [

                    Icon(
                      Icons.account_tree,
                      size: 50,
                      color:
                          Color(0xff006565),
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Need More Depth?",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "View hierarchy visual map",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddCategoryDialog(),
    );
  }

  void showHierarchyMap() {
    showDialog(
      context: context,
      builder: (_) => const HierarchyMapDialog(),
    );
  }
}

class CategoryNode extends StatelessWidget {
  final String title;
  final bool expanded;

  const CategoryNode({
    super.key,
    required this.title,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [

          ListTile(
            leading: const Icon(
              Icons.drag_indicator,
              color: Colors.grey,
            ),

            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const AddCategoryDialog(),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const EditCategoryDialog(),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const DeleteCategoryDialog(),
                    );
                  },
                ),
              ],
            ),
          ),

          if (expanded)
            Padding(
              padding:
                  const EdgeInsets.only(
                      left: 24,
                      right: 16,
                      bottom: 16),
              child: Column(
                children: const [

                  SubCategoryTile(
                    title: "Laptops",
                  ),

                  SizedBox(height: 8),

                  SubCategoryTile(
                    title:
                        "Gaming Laptops",
                  ),

                  SizedBox(height: 8),

                  SubCategoryTile(
                    title: "Ultrabooks",
                  ),

                  SizedBox(height: 8),

                  SubCategoryTile(
                    title: "Components",
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SubCategoryTile extends StatelessWidget {
  final String title;

  const SubCategoryTile({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffD4E6E5),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          const Icon(
            Icons.drag_indicator,
            size: 18,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(title),
          ),

          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 18,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class AddCategoryDialog
    extends StatelessWidget {
  const AddCategoryDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text("Add Category"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Category Name",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Description",
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context),
          child:
              const Text("Create"),
        ),
      ],
    );
  }
}

class EditCategoryDialog
    extends StatelessWidget {

  const EditCategoryDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text("Edit Category"),

      content: TextField(
        controller:
            TextEditingController(
          text:
              "Computing & Accessories",
        ),
      ),

      actions: [

        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context),
          child:
              const Text("Save"),
        ),
      ],
    );
  }
}

class DeleteCategoryDialog
    extends StatelessWidget {

  const DeleteCategoryDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text("Delete Category"),

      content: const Text(
        "This will permanently delete the category and all nested categories.",
      ),

      actions: [

        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red,
          ),
          onPressed: () =>
              Navigator.pop(context),
          child:
              const Text("Delete"),
        ),
      ],
    );
  }
}

class HierarchyMapDialog
    extends StatelessWidget {

  const HierarchyMapDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 500,
        padding:
            const EdgeInsets.all(24),

        child: Column(
          children: [

            Row(
              children: [

                const Text(
                  "Hierarchy Visual Map",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () =>
                      Navigator.pop(
                          context),
                  icon:
                      const Icon(Icons.close),
                ),
              ],
            ),

            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [

                    Icon(
                      Icons.account_tree,
                      size: 100,
                      color:
                          Color(0xff006565),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "Visual hierarchy rendering",
                    ),

                    Text(
                      "simulation...",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
