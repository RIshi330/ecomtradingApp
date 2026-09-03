import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

class CampaignSchedulerScreen extends StatefulWidget {
  const CampaignSchedulerScreen({super.key});

  @override
  State<CampaignSchedulerScreen> createState() => _CampaignSchedulerScreenState();
}

class _CampaignSchedulerScreenState extends State<CampaignSchedulerScreen> {
  String _selectedView = "Month"; // Month, Week, Day
  DateTime _currentCalendarDate = DateTime.now(); // Tracker for month/year

  // API loading & data states
  bool _isLoadingCalendar = false;
  bool _isLoadingAgenda = false;
  Map<String, Map<String, dynamic>> _calendarDays = {}; // "YYYY-MM-DD" -> {date, campaign_count, statuses}
  List<Map<String, dynamic>> _agendaCampaigns = [];
  String? _selectedDateString; // Current active tapped date e.g. "YYYY-MM-DD"

  @override
  void initState() {
    super.initState();
    _selectedDateString = _formatDateString(_currentCalendarDate);
    _loadCalendarMonthData();
    _loadDailyAgenda();
  }

  // Helper date formatter
  String _formatDateString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Load calendar month metadata from API
  Future<void> _loadCalendarMonthData() async {
    _isLoadingCalendar = true;
    try {
      final response = await Database().getData({
        'action': 'fetch_calendar_month',
        'month': _currentCalendarDate.month,
        'year': _currentCalendarDate.year,'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: 'new_apis/campaign_schedular_api.php');

      if (response['success'] == true && response['data'] != null) {
        final List daysList = response['data']['days'] is List ? response['data']['days'] : [];
        if (mounted) {
          setState(() {
            _calendarDays = {
              for (var d in daysList) d['date'].toString(): Map<String, dynamic>.from(d)
            };
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading calendar: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCalendar = false;
        });
      }
    }
  }

  // Load daily agenda for selected date
  Future<void> _loadDailyAgenda() async {
    if (_selectedDateString == null) return;
    _isLoadingAgenda = true;
    try {
      final response = await Database().getData({
        'action': 'fetch_daily_agenda',
        'date': _selectedDateString!,'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: 'new_apis/campaign_schedular_api.php');

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['campaigns'] is List ? response['data']['campaigns'] : [];
        if (mounted) {
          setState(() {
            _agendaCampaigns = list.map((item) => Map<String, dynamic>.from(item)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading daily agenda: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAgenda = false;
        });
      }
    }
  }

  // Fetch campaign detailed metrics & open modal details dialog
  Future<void> _fetchAndShowCampaignDetails(int feedId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      final response = await Database().getData({
        'action': 'fetch_campaign_modal_details',
        'feed_id': feedId,'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: 'new_apis/campaign_schedular_api.php');

      Navigator.pop(context); // Close loading indicator

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        _showCampaignModal(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to fetch details"),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading indicator
      debugPrint("Error loading campaign detail: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // Move calendar months
  void _changeMonth(int offset) {
    setState(() {
      _currentCalendarDate = DateTime(
        _currentCalendarDate.year,
        _currentCalendarDate.month + offset,
        1,
      );
      // Select the first day of the new month by default
      _selectedDateString = _formatDateString(_currentCalendarDate);
    });
    _loadCalendarMonthData();
    _loadDailyAgenda();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Campaign Scheduler",
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Search is not implemented yet.")),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context); // Navigates back to Schedule Campaign screen
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Schedule New Campaign", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Navigator Header
                  _buildSchedulerHeader(),
                  const SizedBox(height: 24),

                  // Calendar Grid Card
                  _isLoadingCalendar
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(48.0),
                            child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                          ),
                        )
                      : _buildCalendarGridCard(),
                  const SizedBox(height: 32),

                  // Daily Agenda Header
                  _buildDailyAgendaHeader(_agendaCampaigns.length),
                  const SizedBox(height: 16),

                  // Daily Agenda Cards List
                  _isLoadingAgenda
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : _agendaCampaigns.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppTheme.outline),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 48, color: AppTheme.textSecondary),
                                  SizedBox(height: 12),
                                  Text(
                                    "No Campaigns Scheduled",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "There are no active campaigns scheduled for this date.",
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _agendaCampaigns.map((campaign) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: _buildCampaignCard(campaign),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Column(
                                  children: _agendaCampaigns.map((campaign) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: _buildCampaignCard(campaign),
                                    );
                                  }).toList(),
                                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Month switcher header
  Widget _buildSchedulerHeader() {
    final List<String> monthsNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    final String currentMonthName = monthsNames[_currentCalendarDate.month - 1];
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    final Widget leftNav = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          "$currentMonthName ${_currentCalendarDate.year}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );

    final Widget rightSelector = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
        children: ["Month", "Week", "Day"].map((view) {
          final bool isSelected = _selectedView == view;
          final Widget tabContent = Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: AppTheme.outline) : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                  : null,
            ),
            child: Text(
              view,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          );

          return isDesktop
              ? InkWell(
                  onTap: () {
                    setState(() {
                      _selectedView = view;
                    });
                  },
                  child: tabContent,
                )
              : Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedView = view;
                      });
                    },
                    child: tabContent,
                  ),
                );
        }).toList(),
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leftNav,
          rightSelector,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftNav,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: rightSelector,
          ),
        ],
      );
    }
  }

  // Calendar Grid
  Widget _buildCalendarGridCard() {
    final List<String> weekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

    // Find the first day of the current month
    final DateTime firstOfMonth = DateTime(_currentCalendarDate.year, _currentCalendarDate.month, 1);
    // Day of the week (1-Monday to 7-Sunday) for the first day
    int weekdayOffset = firstOfMonth.weekday - 1; // 0-indexed offset

    // Get number of days in the month
    final int daysInMonth = DateTime(_currentCalendarDate.year, _currentCalendarDate.month + 1, 0).day;

    // Calculate grid items
    final int totalGridItems = weekdayOffset + daysInMonth;
    final int rowsNeeded = (totalGridItems / 7).ceil();
    final int gridItemCount = rowsNeeded * 7;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // Week days header
            Container(
              color: const Color(0xFFF4F3F3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: weekDays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Day numbers grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: gridItemCount,
              itemBuilder: (context, index) {
                int? dayNumber;
                DateTime? gridDate;
                bool isCurrentMonth = false;

                if (index >= weekdayOffset && index < (weekdayOffset + daysInMonth)) {
                  dayNumber = index - weekdayOffset + 1;
                  gridDate = DateTime(_currentCalendarDate.year, _currentCalendarDate.month, dayNumber);
                  isCurrentMonth = true;
                } else {
                  // Padding days of adjacent months
                  if (index < weekdayOffset) {
                    final prevMonthDate = firstOfMonth.subtract(Duration(days: weekdayOffset - index));
                    dayNumber = prevMonthDate.day;
                  } else {
                    final nextMonthDate = DateTime(_currentCalendarDate.year, _currentCalendarDate.month + 1, index - weekdayOffset - daysInMonth + 1);
                    dayNumber = nextMonthDate.day;
                  }
                }

                final String dateString = gridDate != null ? _formatDateString(gridDate) : "";
                final bool isSelected = isCurrentMonth && _selectedDateString == dateString;
                
                // Get indicators from database calendar monthly payload
                final dayMeta = _calendarDays[dateString];
                final int campaignCount = dayMeta != null ? (dayMeta['campaign_count'] as int? ?? 0) : 0;
                final List statuses = dayMeta != null ? (dayMeta['statuses'] as List? ?? []) : [];

                return InkWell(
                  onTap: isCurrentMonth
                      ? () {
                          setState(() {
                            _selectedDateString = dateString;
                          });
                          _loadDailyAgenda();
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEED), width: 0.5),
                      color: !isCurrentMonth
                          ? const Color(0xFFFFFFFF)
                          : isSelected
                              ? AppTheme.primary.withOpacity(0.05)
                              : Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: !isCurrentMonth
                                ? AppTheme.textSecondary.withOpacity(0.4)
                                : isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                          ),
                        ),
                        // Event status indicators
                        if (campaignCount > 0)
                          Column(
                            children: statuses.map((status) {
                              final String statusStr = status.toString();
                              final Color color = (statusStr == 'ACTIVE' || statusStr == '1')
                                  ? AppTheme.primary
                                  : const Color(0xFFB45309);
                              
                              return Container(
                                width: double.infinity,
                                height: 3,
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Daily agenda list header
  Widget _buildDailyAgendaHeader(int count) {
    String dateLabel = "";
    if (_selectedDateString != null) {
      final parts = _selectedDateString!.split('-');
      if (parts.length == 3) {
        dateLabel = "Oct ${parts[2]}th"; // Formatting dynamically for UI looks matching original
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Daily Agenda — $dateLabel",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          "$count Active Campaign${count == 1 ? '' : 's'}",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // Agenda Card
  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    // campaign['status'] can be -1 (rejected), 0 (draft), 1 (active), 2 (scheduled)
    final String statusStr = campaign["status"].toString();
    final bool isActive = statusStr == "1" || statusStr == "ACTIVE";
    final Color accentColor = isActive ? AppTheme.primary : const Color(0xFFB45309);
    final String displayStatus = isActive ? "ACTIVE" : "SCHEDULED";

    final double progress = double.tryParse(campaign["progress_percent"]?.toString() ?? '0') ?? 0.0;
    // Map progress to float [0.0 - 1.0] if it is in percent scale (e.g. 78.0)
    final double displayProgress = progress > 1.0 ? progress / 100.0 : progress;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _fetchAndShowCampaignDetails(campaign['id'] as int),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: isActive ? 4 : 1),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign["title"] as String? ?? "Campaign",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Client: ${campaign['client_name'] ?? 'Generic Client'}",
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Performance",
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  Text(
                    campaign["performance_note"]?.toString() ?? "${(displayProgress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green.shade700 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: displayProgress,
                color: accentColor,
                backgroundColor: const Color(0xFFF4F3F3),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    "Time: ${campaign['schedule_time'] ?? '00:00:00'}",
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog: Campaign Details Modal
  void _showCampaignModal(Map<String, dynamic> campaign) {
    final String statusStr = campaign["status"].toString();
    final bool isActive = statusStr == "1" || statusStr == "ACTIVE";
    final Color accentColor = isActive ? AppTheme.primary : const Color(0xFFB45309);
    final String displayStatus = isActive ? "ACTIVE" : "SCHEDULED";

    final performance = campaign['performance'] is Map ? campaign['performance'] as Map : {};
    final String impressions = performance['impressions']?.toString() ?? '0';
    final String reach = performance['reach']?.toString() ?? '0';
    final String ctr = performance['ctr']?.toString() ?? '0%';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Title Status bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign["title"] as String? ?? "Campaign Name",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              border: Border.all(color: accentColor.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayStatus,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content details
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ORDER DETAILS",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text("Order ID: ${campaign['order_id'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text("Client: ${campaign['client_name'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text("Package Tier: ${campaign['package_tier'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                    const SizedBox(height: 20),
                    const Text(
                      "PERFORMANCE OVERVIEW",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMetricTile("Impressions", impressions),
                        const SizedBox(width: 8),
                        _buildMetricTile("Reach", reach),
                        const SizedBox(width: 8),
                        _buildMetricTile("CTR", ctr, isCTR: true),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Actions buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Editing Campaign Schedule")),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        child: const Text("Edit Schedule"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(String label, String value, {bool isCTR = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3F3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isCTR && value != "0%" && value != "0.0%" ? Colors.green.shade700 : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
