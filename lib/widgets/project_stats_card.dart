import 'package:flutter/material.dart';

class ProjectStatsCard extends StatelessWidget {
  final String treesPlanted;
  final String amountRaised;
  final String volunteers;

  const ProjectStatsCard({
    super.key,
    this.treesPlanted = "12.5k",
    this.amountRaised = "₹45L",
    this.volunteers = "150+",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffe5f7f7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Project Impact",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _impactItem(
                  treesPlanted,
                  "Trees Planted",
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _impactItem(
                  amountRaised,
                  "Raised",
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _impactItem(
                  volunteers,
                  "Volunteers",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF006565),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
