import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final String initialCategory;
  final String initialType;
  final Function(String status, String category, String type) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialStatus,
    required this.initialCategory,
    required this.initialType,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedStatus;
  late String selectedCategory;
  late String selectedType;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
    selectedCategory = widget.initialCategory;
    selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Filter Opportunities",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedStatus = "All";
                    selectedCategory = "All";
                    selectedType = "All";
                  });
                },
                child: const Text("Reset All"),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 1: Status
          const Text(
            "Status",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final status in ["All", "Active", "Pending", "Unpublished"])
                ChoiceChip(
                  label: Text(status),
                  selected: selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) selectedStatus = status;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 2: Category
          const Text(
            "Category",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final category in ["All", "Tech & Product", "Non-Profit", "Marketing"])
                ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) selectedCategory = category;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 3: Job Type
          const Text(
            "Job Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final type in ["All", "Full-time", "Hybrid", "Volunteer"])
                ChoiceChip(
                  label: Text(type),
                  selected: selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) selectedType = type;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF474DC5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    widget.onApply(selectedStatus, selectedCategory, selectedType);
                    Navigator.pop(context);
                  },
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
