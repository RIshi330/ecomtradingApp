import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/index.dart';

class MyEventsScreen extends StatefulWidget {
  final bool isEmbedded;
  const MyEventsScreen({super.key, this.isEmbedded = false});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _myEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchMyEvents();
  }

  Future<void> _fetchMyEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'get_vendor_events',
      }, endpoint: 'new_apis/event_vendor_api.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> rawList = response['data'];
        setState(() {
          _myEvents = List<Map<String, dynamic>>.from(rawList.map((item) => Map<String, dynamic>.from(item)));
        });
      } else {
        setState(() {
          _myEvents = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching vendor events: $e");
      _showSnackBar("Failed to load events: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String eventId, String variantId, String newStatus) async {
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'Status change',
        'id': eventId,
        'v_id': variantId,
        'status': newStatus,
      }, endpoint: 'new_apis/event_vendor_api.php');

      if (response['success'] == true) {
        _showSnackBar("Status updated successfully");
        _fetchMyEvents();
      } else {
        _showSnackBar(response['message'] ?? "Failed to update status");
      }
    } catch (e) {
      _showSnackBar("Error updating status: $e");
    }
  }

  Future<void> _updateLabel(String eventId, String variantId, String newLabel) async {
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'Label change',
        'id': eventId,
        'v_id': variantId,
        'status': newLabel,
      }, endpoint: 'new_apis/event_vendor_api.php');

      if (response['success'] == true) {
        _showSnackBar("Label updated successfully");
        _fetchMyEvents();
      } else {
        _showSnackBar(response['message'] ?? "Failed to update label");
      }
    } catch (e) {
      _showSnackBar("Error updating label: $e");
    }
  }

  Future<void> _deleteEventVariant(String eventId, String variantId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event variant? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = Database();
      final response = await db.getData({
        'action': 'delete event variants',
        'pid': eventId,
        'v_id': variantId,
      }, endpoint: 'new_apis/event_vendor_api.php');

      if (response['success'] == true) {
        _showSnackBar("Event deleted successfully");
        _fetchMyEvents();
      } else {
        _showSnackBar(response['message'] ?? "Failed to delete event");
      }
    } catch (e) {
      _showSnackBar("Error deleting event: $e");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.primary),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1':
        return Colors.green; // Active
      case '0':
        return Colors.orange; // Unpublish
      case '-1':
        return Colors.grey; // Draft
      case '2':
        return AppTheme.error; // Suspended
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case '1':
        return 'Active';
      case '0':
        return 'Unpublished';
      case '-1':
        return 'Draft';
      case '2':
        return 'Suspended';
      default:
        return 'Unknown';
    }
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case '1':
        return Colors.purple; // Featured
      case '2':
        return Colors.teal; // Sponsored
      case '3':
        return Colors.amber.shade700; // Promoted
      default:
        return Colors.transparent;
    }
  }

  String _getLabelText(String label) {
    switch (label) {
      case '1':
        return 'Featured';
      case '2':
        return 'Sponsored';
      case '3':
        return 'Promoted';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("My Events", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: AppTheme.primary),
            ),
      body: RefreshIndicator(
        onRefresh: _fetchMyEvents,
        color: AppTheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _myEvents.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.event_available, size: 40, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No Registered Events",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "You haven't registered or hosted any events yet. Check out the Event Marketplace to find upcoming experiences.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (widget.isEmbedded) {
                                // If embedded, we could trigger index change in dashboard, 
                                // but standard routes works as fallback.
                                Navigator.pushNamed(context, AppRoutes.eventMarketplace);
                              } else {
                                Navigator.pushNamed(context, AppRoutes.eventMarketplace);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text("Explore Marketplace", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _myEvents.length,
                    itemBuilder: (context, idx) {
                      final event = _myEvents[idx];
                      final status = event['status']?.toString() ?? '-1';
                      final label = event['label']?.toString() ?? '0';

                      // Make sure we adapt the fields correctly for detail screen
                      // Let's create a map adapter to mimic the mock format for click-through
                      final Map<String, dynamic> adaptedEvent = {
                        'title': event['title'] ?? 'Untitled Event',
                        'category': event['category'] ?? 'Event',
                        'price': 0.0, // fallback
                        'priceDisplay': 'N/A',
                        'organizer': event['vendor']?['name'] ?? 'Organizer',
                        'organizerInitials': 'V',
                        'date': event['date'] ?? 'TBD',
                        'dateFull': event['date'] ?? 'TBD',
                        'time': event['time'] ?? 'TBD',
                        'location': 'Venue',
                        'locationFull': 'Venue Details',
                        'imageUrl': event['image'] ?? 'https://img.evbuc.com/default.jpg',
                        'organizerImageUrl': event['vendor']?['profile_pic'],
                        'rating': 4.8,
                        'reviewsCount': 24,
                        'about': event['description'] ?? 'No description provided.',
                        'tags': ['VendorEvent'],
                      };

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppTheme.outline.withOpacity(0.3)),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: adaptedEvent);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero image & Badges
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      event['image'] ?? 'https://img.evbuc.com/default.jpg',
                                      width: double.infinity,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, trace) => Container(
                                        height: 140,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                      ),
                                    ),
                                  ),
                                  // Status Badge
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getStatusText(status),
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  // Label Badge (if any)
                                  if (label != '0' && label != '')
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getLabelColor(label),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _getLabelText(label),
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event['title'] ?? 'Untitled Event',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                                          onSelected: (action) {
                                            final eId = event['event_id']?.toString() ?? '';
                                            final vId = event['variant_id']?.toString() ?? '';
                                            if (action.startsWith('status_')) {
                                              final newStat = action.substring(7);
                                              _updateStatus(eId, vId, newStat);
                                            } else if (action.startsWith('label_')) {
                                              final newLab = action.substring(6);
                                              _updateLabel(eId, vId, newLab);
                                            } else if (action == 'delete') {
                                              _deleteEventVariant(eId, vId);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              enabled: false,
                                              child: Text("Change Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                            PopupMenuItem(value: "status_1", child: _buildPopupItem("Active", status == '1')),
                                            PopupMenuItem(value: "status_0", child: _buildPopupItem("Unpublish", status == '0')),
                                            PopupMenuItem(value: "status_-1", child: _buildPopupItem("Draft", status == '-1')),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                              enabled: false,
                                              child: Text("Change Label", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                            PopupMenuItem(value: "label_1", child: _buildPopupItem("Featured", label == '1')),
                                            PopupMenuItem(value: "label_2", child: _buildPopupItem("Sponsored", label == '2')),
                                            PopupMenuItem(value: "label_3", child: _buildPopupItem("Promoted", label == '3')),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                              value: "delete",
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                                                  SizedBox(width: 8),
                                                  Text("Delete", style: TextStyle(color: AppTheme.error)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event['description'] ?? 'No description',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                                        const SizedBox(width: 6),
                                        Text(event['date'] ?? 'TBD', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        if (event['time'] != null) ...[
                                          const SizedBox(width: 12),
                                          const Icon(Icons.schedule_outlined, size: 14, color: AppTheme.textSecondary),
                                          const SizedBox(width: 6),
                                          Text(event['time'] ?? 'TBD', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1, thickness: 0.5),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildStatChip(Icons.confirmation_number_outlined, "Tickets: ${event['tickets'] ?? 0}"),
                                        const SizedBox(width: 16),
                                        _buildStatChip(Icons.storefront_outlined, "Stalls: ${event['stalls'] ?? 0}"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );

    return widget.isEmbedded ? content : SafeArea(child: content);
  }

  Widget _buildPopupItem(String text, bool active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        if (active) const Icon(Icons.check, color: AppTheme.primary, size: 16),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
