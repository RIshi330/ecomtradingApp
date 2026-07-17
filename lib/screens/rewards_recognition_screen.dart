import 'package:flutter/material.dart';
import '../Database/Database.dart'; // To use Database connection if needed
import '../widgets/stat_card.dart'; // To preserve existing widget imports

class RewardsRecognitionScreen extends StatefulWidget {
  final bool isEmbedded;
  const RewardsRecognitionScreen({super.key, this.isEmbedded = false});

  @override
  State<RewardsRecognitionScreen> createState() => _RewardsRecognitionScreenState();
}

class _RewardsRecognitionScreenState extends State<RewardsRecognitionScreen> {
  // Screen metrics state
  double _totalDistributed = 128400.0;
  int _pendingApprovalsCount = 42;
  int _activeCampaignsCount = 15;
  double _budgetUtilization = 64.0; // 64%

  // Toast Notification state
  bool _showToast = false;
  String _toastMessage = "";

  // Data lists corresponding to HTML segments
  final List<Map<String, dynamic>> _pendingRequests = [
    {
      'id': '1',
      'initials': 'JD',
      'name': 'Jane Doe',
      'role': 'Product Designer',
      'points': '500 PTS',
      'message': '"Amazing work on the Q3 project delivery!"',
      'recipient': 'Marcus Chen',
    },
    {
      'id': '2',
      'initials': 'SL',
      'name': 'Sarah Lee',
      'role': 'HR Manager',
      'points': '250 PTS',
      'message': '"Thanks for helping the new cohorts settle in."',
      'recipient': 'Alex Rivera',
    },
  ];

  final List<Map<String, dynamic>> _nominations = [
    {
      'initials': 'MS',
      'name': 'Michael Scott',
      'role': 'Regional Manager • Completed Q3 Targets',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB7mbD5cc1KAqgJ3UGElt3ej7jY55PgVR0Xs22TgRox9vYy3jGgsjL-OyNbLFMzv6NxpTWRc-GksheYn9hwatK7T3cQUh2dMte6X3n1XrzD6mPSYFSP_iC4b135VebW0r-4c70likeDB6C8hUgammqChVIXUdOkjHnBqNnFs-eKnbtduoGsRsjBNjSoGW2nT65EPPz-8CXletCFMwPGXDKbI_xtDTDSI1sm7zr51vG1wpqia6wIFVp9',
    },
    {
      'initials': 'DS',
      'name': 'Dwight Schrute',
      'role': 'Sales Lead • Project Delta Launch',
      'avatarUrl': '',
    },
  ];

  final List<Map<String, dynamic>> _history = [
    {
      'date': 'Oct 24, 2023 • 14:20',
      'recipient': 'Pam Beesly',
      'type': 'Voucher',
      'amount': '250 PTS',
      'status': 'Processed',
    },
    {
      'date': 'Oct 23, 2023 • 09:15',
      'recipient': 'Jim Halpert',
      'type': 'Monetary',
      'amount': '\$500.00',
      'status': 'Pending',
    },
  ];

  final List<Map<String, dynamic>> _teamPerformance = [
    {
      'date': 'Oct 24, 2023',
      'recipient': 'Pam Beesly',
      'task': 'Q3 Sales Target',
      'type': 'Voucher',
      'amount': '250 PTS',
      'status': 'Distributed',
    },
    {
      'date': 'Oct 23, 2023',
      'recipient': 'Jim Halpert',
      'task': 'Client Retention',
      'type': 'Monetary',
      'amount': '\$500.00',
      'status': 'Scheduled',
    },
  ];

  // Performance Rules configuration state
  double _ruleWeightMultiplier = 1.5;
  int _ruleTasksCompleted = 10;
  double _ruleRevenueTarget = 5000.0;
  bool _ruleAutoPayout = true;
  List<bool> _ruleTriggers = [true, false, true]; // Project Submission, Document Verification, Milestone Achievement

  void _triggerToast(String message) {
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }

  void _approveRequest(String id, String name, String points) {
    setState(() {
      _pendingRequests.removeWhere((item) => item['id'] == id);
      _pendingApprovalsCount = _pendingRequests.length;
      _totalDistributed += 250; // increment mock stats
      _history.insert(0, {
        'date': 'Just now',
        'recipient': name,
        'type': 'Points',
        'amount': points,
        'status': 'Processed',
      });
      _teamPerformance.insert(0, {
        'date': 'Just now',
        'recipient': name,
        'task': 'Milestone Achieved',
        'type': 'Points',
        'amount': points,
        'status': 'Distributed',
      });
    });
    _triggerToast("Reward Request Approved for $name");
  }

  void _rejectRequest(String id, String name, String reason) {
    setState(() {
      _pendingRequests.removeWhere((item) => item['id'] == id);
      _pendingApprovalsCount = _pendingRequests.length;
    });
    _triggerToast("Rejected request for $name: $reason");
  }

  void _allocatePoints(String recipient, String points, String contextStr, String message) {
    setState(() {
      _totalDistributed += double.tryParse(points) ?? 100;
      _history.insert(0, {
        'date': 'Just now',
        'recipient': recipient,
        'type': 'Points Allocation',
        'amount': '$points PTS',
        'status': 'Processed',
      });
      _teamPerformance.insert(0, {
        'date': 'Just now',
        'recipient': recipient,
        'task': contextStr,
        'type': 'Points',
        'amount': '$points PTS',
        'status': 'Distributed',
      });
    });
    _triggerToast("Points Allocated Successfully to $recipient");
  }

  void _sendAward(String name, String type, String amount, String message) {
    setState(() {
      _history.insert(0, {
        'date': 'Just now',
        'recipient': name,
        'type': type,
        'amount': amount,
        'status': 'Processed',
      });
      _teamPerformance.insert(0, {
        'date': 'Just now',
        'recipient': name,
        'task': 'Custom Award: $message',
        'type': type,
        'amount': amount,
        'status': 'Distributed',
      });
    });
    _triggerToast("Award successfully sent to $name!");
  }

  // Modals builders
  void _showAllocationModal() {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    final messageController = TextEditingController();
    String selectedContext = 'Project Milestone';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Allocate Points", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("RECIPIENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: recipientController,
                      decoration: InputDecoration(
                        hintText: "Search employee or team...",
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("AMOUNT (PTS)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "0",
                                  filled: true,
                                  fillColor: const Color(0xFFF1F4F6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("CONTEXT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: selectedContext,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F4F6),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Project Milestone', child: Text('Milestone', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Client Success', child: Text('Client Success', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Peer Mentorship', child: Text('Mentorship', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setModalState(() {
                                      selectedContext = v;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("MESSAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Optional congratulatory message...",
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final rec = recipientController.text.trim();
                    final pts = amountController.text.trim();
                    final msg = messageController.text.trim();
                    if (rec.isEmpty || pts.isEmpty) {
                      _triggerToast("Please fill all required fields");
                      return;
                    }
                    Navigator.pop(ctx);
                    _allocatePoints(rec, pts, selectedContext, msg);
                  },
                  child: const Text("Send Points", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRejectionModal(String requestId, String name) {
    String selectedReason = 'Incomplete data';
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Rejection Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SELECT REASON", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Incomplete data', child: Text('Incomplete data')),
                        DropdownMenuItem(value: 'Budget cap reached', child: Text('Budget cap reached')),
                        DropdownMenuItem(value: 'Policy violation', child: Text('Policy violation')),
                        DropdownMenuItem(value: 'Duplicate request', child: Text('Duplicate request')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            selectedReason = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("ADDITIONAL COMMENTS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: commentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Briefly explain the reason...",
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBA1A1A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final comments = commentsController.text.trim();
                    final reasonText = comments.isNotEmpty ? "$selectedReason ($comments)" : selectedReason;
                    Navigator.pop(ctx);
                    _rejectRequest(requestId, name, reasonText);
                  },
                  child: const Text("Confirm Rejection", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfigModal() {
    double tempWeight = _ruleWeightMultiplier;
    int tempTasks = _ruleTasksCompleted;
    double tempRevenue = _ruleRevenueTarget;
    bool tempAutoPay = _ruleAutoPayout;
    List<bool> tempTriggers = List.from(_ruleTriggers);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Rule Configuration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PERFORMANCE TARGETS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tasks Completed", style: TextStyle(fontSize: 9, color: Color(0xFF6E7979))),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: tempTasks.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F4F6),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (v) {
                                  final val = int.tryParse(v);
                                  if (val != null) tempTasks = val;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Revenue Target (\$)", style: TextStyle(fontSize: 9, color: Color(0xFF6E7979))),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: tempRevenue.toStringAsFixed(0),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F4F6),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (v) {
                                  final val = double.tryParse(v);
                                  if (val != null) tempRevenue = val;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("SUBMISSION TRIGGERS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      title: const Text("Project Submission", style: TextStyle(fontSize: 12)),
                      value: tempTriggers[0],
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF006565),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            tempTriggers[0] = v;
                          });
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Document Verification", style: TextStyle(fontSize: 12)),
                      value: tempTriggers[1],
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF006565),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            tempTriggers[1] = v;
                          });
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Milestone Achievement", style: TextStyle(fontSize: 12)),
                      value: tempTriggers[2],
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF006565),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            tempTriggers[2] = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("REAL-TIME LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      title: const Text("Automatic Real-time Payout", style: TextStyle(fontSize: 12)),
                      subtitle: const Text("If disabled, rewards require Manual Admin Review", style: TextStyle(fontSize: 9, color: Color(0xFF6E7979))),
                      value: tempAutoPay,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF006565),
                      onChanged: (v) {
                        setModalState(() {
                          tempAutoPay = v;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("WEIGHT / MULTIPLIER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                        Text("${tempWeight.toStringAsFixed(1)}x", style: const TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Slider(
                      value: tempWeight,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      activeColor: const Color(0xFF006565),
                      onChanged: (v) {
                        setModalState(() {
                          tempWeight = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      _ruleWeightMultiplier = tempWeight;
                      _ruleTasksCompleted = tempTasks;
                      _ruleRevenueTarget = tempRevenue;
                      _ruleAutoPayout = tempAutoPay;
                      _ruleTriggers = tempTriggers;
                    });
                    Navigator.pop(ctx);
                    _triggerToast("Performance Rule Saved Successfully");
                  },
                  child: const Text("Save Configuration", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSendRecognitionModal(String name) {
    final amountController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'Bonus (Monetary)';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Send Recognition Award", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006565).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                            child: const Text("MS", style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const Text("Regional Manager", style: TextStyle(fontSize: 10, color: Color(0xFF6E7979))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("AWARD TYPE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Bonus (Monetary)', child: Text('Bonus (Monetary)')),
                        DropdownMenuItem(value: 'Voucher (Gift Card)', child: Text('Voucher (Gift Card)')),
                        DropdownMenuItem(value: 'Points (Internal)', child: Text('Points (Internal)')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            selectedType = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("AMOUNT / POINTS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        hintText: "e.g. 500 or \$50",
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("CONGRATULATORY MESSAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write a congratulatory message...",
                        filled: true,
                        fillColor: const Color(0xFFF1F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final amt = amountController.text.trim();
                    final msg = messageController.text.trim();
                    if (amt.isEmpty || msg.isEmpty) {
                      _triggerToast("Please fill all required fields");
                      return;
                    }
                    Navigator.pop(ctx);
                    _sendAward(name, selectedType, amt, msg);
                  },
                  child: const Text("Confirm & Send", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              title: const Text(
                "Rewards & Recognition Hub",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF006565),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFE6EEFF), height: 1),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006565),
        foregroundColor: Colors.white,
        onPressed: _showAllocationModal,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: System Overview (Stats Slider)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "System Overview",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121C2A)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _triggerToast("Downloading full analytics report PDF...");
                      },
                      icon: const Icon(Icons.download, size: 16, color: Color(0xFF006565)),
                      label: const Text(
                        "Download Report",
                        style: TextStyle(color: Color(0xFF006565), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildOverviewStatCard(
                        title: "Total Distributed",
                        value: "\$${(_totalDistributed / 1000).toStringAsFixed(1)}k",
                        subtitle: "+12% Since last period",
                        isUrgent: false,
                        showProgressBar: false,
                      ),
                      _buildOverviewStatCard(
                        title: "Pending Approvals",
                        value: "$_pendingApprovalsCount",
                        subtitle: "Awaiting review",
                        isUrgent: _pendingApprovalsCount > 0,
                        showProgressBar: false,
                      ),
                      _buildOverviewStatCard(
                        title: "Active Campaigns",
                        value: "$_activeCampaignsCount",
                        subtitle: "Running programs",
                        isUrgent: false,
                        showProgressBar: true,
                        progressVal: 0.75,
                      ),
                      _buildOverviewStatCard(
                        title: "Budget Utilization",
                        value: "${_budgetUtilization.toStringAsFixed(0)}%",
                        subtitle: "\$22k remaining",
                        isUrgent: false,
                        showProgressBar: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Pending Approvals (Horizontal Cards Slider)
                if (_pendingRequests.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.pending_actions, color: Color(0xFF735C00), size: 20),
                      SizedBox(width: 6),
                      Text(
                        "Pending Approvals",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121C2A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _pendingRequests.map((req) {
                        return _buildPendingApprovalCard(req);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Section 3: Dynamic Performance Rules
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dynamic Performance Rules",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121C2A)),
                    ),
                    TextButton.icon(
                      onPressed: () => _triggerToast("Category builder coming soon!"),
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF006565)),
                      label: const Text(
                        "Add Category",
                        style: TextStyle(color: Color(0xFF006565), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildRuleCategoryCard(
                      title: "Monetary Bonuses",
                      desc: "Direct payroll additions for performance.",
                      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCtBCNS1GguNtpjKW5S6sEOoUqA-p9U8-OaFdcsPaa5lPRly1dFLBOxGg2HoUCCM8dPcgBXDvsow87kYzxBGHFR44GJU_OYjvVpVOVbrgiLlPs7RwSkV1g-F1pGuijHo1-9sX9Yo3xkwSiP0hht7dK7-KtDm_9CW_3Y2ws0W0RxaiDxDB9VjqaE6uaeXVRkaKSbuaSF_qh-L93O4kkD-rrFFiZ8zl4AZDcaJn1BUFAP5UCA8RZcjWR-",
                    ),
                    _buildRuleCategoryCard(
                      title: "Vouchers",
                      desc: "Gift cards for popular retailers.",
                      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuArWEshTJvnPafuG1Ceftx1mhZQxBdITcjOFfOaO7gw-uPeDcNN9VNsJgj-nwOJHLMAsWXRCeeIkPlT1pVHuSMpycpYyKZ2UBEVhTDpb-oXmJXU4ePGqV4Unfa-dQwM-V5nS_JAyKj_7AgI5EwoYIjs5elokLGMDla2yJJ4oLC3MeRKMmvkpHd2V55xNZuQZ86ryGE8b_3MpQY7Ow6CYlOrPAsoVePAeVgw8IZItFoZskEYIV6Z904f",
                    ),
                    _buildRuleCategoryCard(
                      title: "Experiences",
                      desc: "Wellness retreats and PTO perks.",
                      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDwlWBjePeg-ImYhg9iMOmYY6eTffParomwH_e9V45mZWKCzQHO_Yb4wtbYc0jvE6K5iHmgXhMu7cv93XDL8RPVOomE0q8-VrE5YSku4RUlYdgtvpP7oCh3F9pv2cuSwDlLW-eqhtsz6Igl6JJ0f3O6w74TDH-itV42hd6Kr0U1Y8Nm8C2uuLOmQ-j1qkolLxsoTWDg8aBbOzL9nIKVY0X_gF-_4KB5UEw9PwyWTnrwSyqskvuQs0gA",
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 4: Due for Recognition
                if (_nominations.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.celebration, color: Color(0xFF006565), size: 20),
                      SizedBox(width: 6),
                      Text(
                        "Due for Recognition",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121C2A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                    childAspectRatio: 3.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: _nominations.map((nom) {
                      return _buildNominationCard(nom);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Section 5: Tables (Recognition History)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recognition History",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121C2A)),
                    ),
                    TextButton(
                      onPressed: () => _triggerToast("Opening comprehensive history log..."),
                      child: const Text("View All", style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                _buildHistoryTable(),
                const SizedBox(height: 24),

                // Section 6: Team Performance Table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Team Performance",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121C2A)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EEFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _triggerToast("Switching to Weekly stats..."),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: const Text("Weekly", style: TextStyle(fontSize: 10, color: Color(0xFF3E4949))),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006565),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("Monthly", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPerformanceTable(),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Sliding checkmark Toast Notification overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: _showToast ? 16 : -80,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showToast ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF006565),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _toastMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Stat Card builder
  Widget _buildOverviewStatCard({
    required String title,
    required String value,
    required String subtitle,
    required bool isUrgent,
    required bool showProgressBar,
    double progressVal = 0.0,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF3E4949),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF006565),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "URGENT",
                    style: TextStyle(color: Color(0xFF93000A), fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (showProgressBar) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressVal,
                backgroundColor: const Color(0xFFE5E9EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006565)),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6E7979), fontSize: 10, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // UI Pending Approval Card builder
  Widget _buildPendingApprovalCard(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFDEE9FC),
                child: Text(req['initials'], style: const TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF121C2A))),
                    Text(req['role'], style: const TextStyle(fontSize: 10, color: Color(0xFF6E7979))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED65B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req['points'],
                  style: const TextStyle(color: Color(0xFF241A00), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              req['message'],
              style: const TextStyle(color: Color(0xFF3E4949), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Recipient: ${req['recipient']}",
            style: const TextStyle(color: Color(0xFF6E7979), fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _approveRequest(req['id'], req['recipient'], req['points']),
                  child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6E7979)),
                    foregroundColor: const Color(0xFF6E7979),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showRejectionModal(req['id'], req['recipient']),
                  child: const Text("Reject", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Performance Rule Category Cards
  Widget _buildRuleCategoryCard({
    required String title,
    required String desc,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD4AF37),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5E9EB), child: const Icon(Icons.stars, color: Color(0xFF006565))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF121C2A))),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFF6E7979), fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: const Color(0xFF006565).withOpacity(0.3)),
                          foregroundColor: const Color(0xFF006565),
                          minimumSize: const Size(0, 28),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _triggerToast("Category editor coming soon!"),
                        child: const Text("Edit", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6E7979)),
                          foregroundColor: const Color(0xFF121C2A),
                          minimumSize: const Size(0, 28),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _showConfigModal,
                        child: const Text("Configure", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Due for Recognition Nomination Cards
  Widget _buildNominationCard(Map<String, dynamic> nom) {
    final avatar = nom['avatarUrl']?.toString() ?? '';
    final name = nom['name'];
    final initials = nom['initials'];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE5E9EB),
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? Text(initials, style: const TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 12))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF121C2A))),
                Text(nom['role'], style: const TextStyle(color: Color(0xFF6E7979), fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006565),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showSendRecognitionModal(name),
            child: const Text("Reward", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF6E7979)),
            onPressed: () {
              setState(() {
                _nominations.removeWhere((item) => item['name'] == name);
              });
            },
          ),
        ],
      ),
    );
  }

  // Recognition History Table
  Widget _buildHistoryTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
          columnSpacing: 24,
          horizontalMargin: 12,
          columns: const [
            DataColumn(label: Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('RECIPIENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('RECEIPT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
          ],
          rows: _history.map((item) {
            final status = item['status']?.toString() ?? '';
            final isProcessed = status == 'Processed';
            return DataRow(cells: [
              DataCell(Text(item['date']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF6E7979)))),
              DataCell(Text(item['recipient']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              DataCell(Text(item['type']?.toString() ?? '', style: const TextStyle(fontSize: 11))),
              DataCell(Text(item['amount']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006565)))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isProcessed ? const Color(0xFF006565).withOpacity(0.1) : const Color(0xFFFED65B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isProcessed ? const Color(0xFF006565) : const Color(0xFF745C00),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.receipt_long, size: 18, color: Color(0xFF6E7979)),
                  onPressed: () => _triggerToast("Opening receipt log details..."),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // Team Performance Table
  Widget _buildPerformanceTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
          columnSpacing: 24,
          horizontalMargin: 12,
          columns: const [
            DataColumn(label: Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('RECIPIENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('PROJECT/TASK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('AMOUNT/POINTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)))),
          ],
          rows: _teamPerformance.map((item) {
            final status = item['status']?.toString() ?? '';
            final isDistributed = status == 'Distributed';
            return DataRow(cells: [
              DataCell(Text(item['date']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF6E7979)))),
              DataCell(Text(item['recipient']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              DataCell(Text(item['task']?.toString() ?? '', style: const TextStyle(fontSize: 11))),
              DataCell(Text(item['type']?.toString() ?? '', style: const TextStyle(fontSize: 11))),
              DataCell(Text(item['amount']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006565)))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDistributed ? const Color(0xFF006565).withOpacity(0.1) : const Color(0xFFFED65B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isDistributed ? const Color(0xFF006565) : const Color(0xFF745C00),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.receipt_long, size: 18, color: Color(0xFF6E7979)),
                  onPressed: () => _triggerToast("Opening receipt log details..."),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
