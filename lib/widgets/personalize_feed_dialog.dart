// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trading_ecommerce_admin/Database/Database.dart';
// import 'package:trading_ecommerce_admin/services/auth_service.dart';
//
// class PersonalizeFeedDialog extends StatefulWidget {
//   final bool isEmbedded;
//   const PersonalizeFeedDialog({super.key, this.isEmbedded = false});
//
//   @override
//   State<PersonalizeFeedDialog> createState() => _PersonalizeFeedDialogState();
// }
//
// class _PersonalizeFeedDialogState extends State<PersonalizeFeedDialog> {
//   bool _isLoading = true;
//   List<dynamic> _dbInterests = [];
//   final Set<int> _selectedInterestIds = {};
//
//   // Categorized static topics matching the HTML layout
//   final List<Map<String, dynamic>> _categories = [
//     {
//       "name": "Strategy & Leadership",
//       "icon": Icons.leaderboard_rounded,
//       "items": [
//         {"title": "Corporate Governance", "icon": Icons.corporate_fare_rounded},
//         {"title": "Change Management", "icon": Icons.diversity_3_rounded},
//         {"title": "Strategic Planning", "icon": Icons.insights_rounded},
//         {"title": "Executive Coaching", "icon": Icons.psychology_rounded},
//       ]
//     },
//     {
//       "name": "Tech & Innovation",
//       "icon": Icons.memory_rounded,
//       "items": [
//         {"title": "Artificial Intelligence", "icon": Icons.smart_toy_rounded},
//         {"title": "Web3 & Blockchain", "icon": Icons.hub_rounded},
//         {"title": "SaaS Solutions", "icon": Icons.cloud_rounded},
//         {"title": "Cybersecurity", "icon": Icons.security_rounded},
//       ]
//     },
//     {
//       "name": "Marketing & Sales",
//       "icon": Icons.campaign_rounded,
//       "items": [
//         {"title": "Brand Advocacy", "icon": Icons.public_rounded},
//         {"title": "Performance Marketing", "icon": Icons.ads_click_rounded},
//         {"title": "Strategic Partnerships", "icon": Icons.handshake_rounded},
//       ]
//     },
//     {
//       "name": "Finance & Investment",
//       "icon": Icons.account_balance_rounded,
//       "items": [
//         {"title": "Venture Capital", "icon": Icons.monetization_on_rounded},
//         {"title": "Asset Management", "icon": Icons.trending_up_rounded},
//         {"title": "Mergers & Acquisitions", "icon": Icons.pie_chart_rounded},
//       ]
//     }
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchInterests();
//   }
//
//   Future<void> _fetchInterests() async {
//     try {
//       final userData = await AuthService.getCachedUserData();
//       final vendorId = userData != null ? userData['id'] : null;
//
//       final response = await Database().getData({
//         'action': 'get_interests',
//         if (vendorId != null) 'vendor_id': vendorId.toString(),
//       }, endpoint: 'new_apis/community_app_interests_API.php');
//
//       if (response != null && response['success'] == true) {
//         setState(() {
//           _dbInterests = response['data'] ?? [];
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching interests: $e");
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   int? _findIdForTitle(String title) {
//     for (var interest in _dbInterests) {
//       if (interest['title'].toString().toLowerCase() == title.toLowerCase()) {
//         return int.tryParse(interest['id'].toString());
//       }
//     }
//     return null;
//   }
//
//   Future<void> _savePreferences() async {
//     if (_selectedInterestIds.length < 3) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final userData = await AuthService.getCachedUserData();
//       final vendorId = userData != null ? userData['id'] : null;
//
//       final response = await Database().getData({
//         'action': 'save_user_interests',
//         'interests': _selectedInterestIds.join(','),
//         if (vendorId != null) 'vendor_id': vendorId.toString(),
//       }, endpoint: 'new_apis/community_app_interests_API.php');
//
//       if (response != null && response['success'] == true) {
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('has_personalized_feed', true);
//
//         if (mounted) {
//           if (!widget.isEmbedded) {
//             Navigator.of(context).pop();
//           } else {
//             setState(() {
//               _isLoading = false;
//             });
//           }
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Preferences saved successfully!"),
//               backgroundColor: Color(0xFF006565),
//             ),
//           );
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response?['message'] ?? "Failed to save preferences"),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _skipForNow() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_personalized_feed', true);
//     if (mounted) {
//       if (!widget.isEmbedded) {
//         Navigator.of(context).pop();
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const primaryColor = Color(0xFF006565);
//     const primaryContainer = Color(0xFF008080);
//     const surfaceContainerLow = Color(0xFFF4F3F3);
//     const outlineVariant = Color(0xFFBDC9C8);
//     const textOnSurfaceVariant = Color(0xFF3E4949);
//
//     final Widget content = SizedBox(
//       width: MediaQuery.of(context).size.width.clamp(0.0, 600.0),
//       height: widget.isEmbedded ? null : MediaQuery.of(context).size.height.clamp(0.0, 750.0),
//       child: _isLoading
//             ? const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(40.0),
//                   child: CircularProgressIndicator(color: primaryColor),
//                 ),
//               )
//             : Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Modal Header
//                   Padding(
//                     padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 16.0),
//                     child: Column(
//                       children: [
//                         const Text(
//                           "TAILORED EXPERIENCE",
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 0.8,
//                             color: primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "What are you interested in?",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "Select at least 3 topics to tailor your experience and discover high-value partnerships.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: textOnSurfaceVariant,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(color: outlineVariant, height: 1),
//
//                   // Scrollable categories area
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: _categories.map((category) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 24.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Category title row
//                                 Row(
//                                   children: [
//                                     Icon(category['icon'] as IconData, color: primaryColor, size: 20),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       category['name'] as String,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 // Chips wrap
//                                 Wrap(
//                                   spacing: 8.0,
//                                   runSpacing: 8.0,
//                                   children: (category['items'] as List<Map<String, dynamic>>).map((item) {
//                                     final title = item['title'] as String;
//                                     final icon = item['icon'] as IconData;
//                                     final id = _findIdForTitle(title);
//
//                                     // If not in DB, fallback to hash code for UI toggle only
//                                     final resolvedId = id ?? title.hashCode;
//                                     final isSelected = _selectedInterestIds.contains(resolvedId);
//
//                                     return InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           if (isSelected) {
//                                             _selectedInterestIds.remove(resolvedId);
//                                           } else {
//                                             _selectedInterestIds.add(resolvedId);
//                                           }
//                                         });
//                                       },
//                                       borderRadius: BorderRadius.circular(20),
//                                       child: AnimatedContainer(
//                                         duration: const Duration(milliseconds: 200),
//                                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                                         decoration: BoxDecoration(
//                                           color: isSelected ? primaryContainer : surfaceContainerLow,
//                                           border: Border.all(
//                                             color: isSelected ? primaryContainer : outlineVariant,
//                                             width: 1,
//                                           ),
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               icon,
//                                               size: 18,
//                                               color: isSelected ? Colors.white : textOnSurfaceVariant,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Text(
//                                               title,
//                                               style: TextStyle(
//                                                 fontSize: 13,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: isSelected ? Colors.white : textOnSurfaceVariant,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                   const Divider(color: outlineVariant, height: 1),
//
//                   // Modal Footer
//                   Container(
//                     color: surfaceContainerLow,
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Progress visualization indicators on left
//                             Row(
//                               children: [
//                                 Row(
//                                   children: List.generate(3, (index) {
//                                     final isActive = _selectedInterestIds.length > index;
//                                     return Container(
//                                       width: 24,
//                                       height: 24,
//                                       margin: const EdgeInsets.only(right: 4),
//                                       decoration: BoxDecoration(
//                                         color: isActive ? primaryColor : Colors.white,
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: isActive ? primaryColor : outlineVariant,
//                                           width: 1,
//                                         ),
//                                       ),
//                                       alignment: Alignment.center,
//                                       child: Text(
//                                         "${index + 1}",
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold,
//                                           color: isActive ? Colors.white : textOnSurfaceVariant,
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "${_selectedInterestIds.length}/3 topics selected",
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: textOnSurfaceVariant,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // Skip button
//                             if (!widget.isEmbedded)
//                               TextButton(
//                                 onPressed: _skipForNow,
//                                 child: const Text(
//                                   "Skip for now",
//                                   style: TextStyle(
//                                     color: primaryColor,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         // Save Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _selectedInterestIds.length >= 3 ? _savePreferences : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: primaryColor.withOpacity(0.4),
//                               disabledForegroundColor: Colors.white.withOpacity(0.6),
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: const Text(
//                               "Save Preferences",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//     );
//
//     if (widget.isEmbedded) {
//       return content;
//     }
//
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 24,
//       backgroundColor: Colors.white,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//       child: content,
//     );
//   }
// }
