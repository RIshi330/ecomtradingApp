import 'package:flutter/material.dart';
import '../model/opportunity_model.dart';

Color statusColor(String status) {
  switch (status) {
    case "Active":
      return Colors.green;
    case "Pending":
      return Colors.orange;
    case "Unpublished":
      return Colors.grey;
    default:
      return Colors.blue;
  }
}

class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback? onTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusThemeColor = statusColor(opportunity.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE6E6F0)),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status and Reference
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusThemeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      opportunity.status,
                      style: TextStyle(
                        color: statusThemeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    opportunity.reference,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                opportunity.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),

              // Metadata: Type & Location & Category
              Row(
                children: [
                  const Icon(Icons.work_outline, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    opportunity.type,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    opportunity.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.category_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      opportunity.category,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFE6E6F0), height: 1),
              const SizedBox(height: 8),

              // Footer: Stats & Date
              Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 14, color: Color(0xff006565)),
                  const SizedBox(width: 4),
                  Text(
                    "${opportunity.views}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xff006565)),
                  const SizedBox(width: 4),
                  Text(
                    "${opportunity.responses}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    opportunity.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
