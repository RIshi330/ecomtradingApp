// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// // ══════════════════════════════════════════════════════════
// // DESIGN SYSTEM
// // ══════════════════════════════════════════════════════════
// class IGTheme {
//   static const Color background = Colors.white;
//   static const Color textDark = Color(0xFF262626);
//   static const Color textGray = Color(0xFF8E8E8E);
//   static const Color hairline = Color(0xFFDBDBDB);
//   static const Color blue = Color(0xFF0095F6);
//   static const Color primaryTeal = Color(0xFF006565);
//   static const Color surfaceContainerLow = Color(0xFFF4F3F3);
//   static const Color successGreen = Color(0xFF34A853);
//   static const Color warningOrange = Color(0xFFFBBC04);
//   static const Color shadowColor = Color(0x1A000000);
//
//   static TextStyle username({double size = 13.5, Color color = textDark}) =>
//       TextStyle(fontWeight: FontWeight.w600, fontSize: size, color: color, fontFamily: 'Manrope');
//
//   static TextStyle body(double size, {Color color = textDark, FontWeight w = FontWeight.normal}) =>
//       TextStyle(fontSize: size, color: color, fontWeight: w, height: 1.35, fontFamily: 'Inter');
// }
//
// // ══════════════════════════════════════════════════════════
// // MEDIA ITEM MODEL
// // ══════════════════════════════════════════════════════════
// enum MediaType { image, video }
//
// class MediaItem {
//   final String? url;
//   final File? file;
//   final MediaType type;
//   final String title;
//
//   MediaItem({
//     this.url,
//     this.file,
//     required this.type,
//     this.title = '',
//   });
//
//   bool get isNetworkImage => url != null && file == null;
//   bool get isLocalFile => file != null;
// }
//
// // ══════════════════════════════════════════════════════════
// // MAIN CREATE POST SCREEN
// // ══════════════════════════════════════════════════════════
// class CreatePostScreen extends StatefulWidget {
//   const CreatePostScreen({super.key});
//
//   @override
//   State<CreatePostScreen> createState() => _CreatePostScreenState();
// }
//
// class _CreatePostScreenState extends State<CreatePostScreen> {
//   final TextEditingController _captionController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//
//   String _selectedCategory = 'Strategic Update';
//   String _selectedCommunity = 'Global Leadership';
//   bool _isSponsored = false;
//   bool _isScheduled = false;
//   DateTime? _scheduledDate;
//
//   // Media Selection State
//   List<MediaItem> _selectedMedia = [];
//   bool _isVideo = false;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void dispose() {
//     _captionController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // SIMPLIFIED IMAGE PICKER FUNCTIONS
//   // ══════════════════════════════════════════════════════════
//
//   Future<void> _pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           _selectedMedia = [
//             MediaItem(
//               file: File(image.path),
//               type: MediaType.image,
//               title: 'Image',
//             )
//           ];
//           _isVideo = false;
//         });
//       }
//     } catch (e) {
//       _showError('Failed to pick image');
//     }
//   }
//
//   Future<void> _pickVideo() async {
//     try {
//       final XFile? video = await _picker.pickVideo(
//         source: ImageSource.gallery,
//         maxDuration: const Duration(seconds: 60),
//       );
//
//       if (video != null) {
//         setState(() {
//           _selectedMedia = [
//             MediaItem(
//               file: File(video.path),
//               type: MediaType.video,
//               title: 'Video',
//             )
//           ];
//           _isVideo = true;
//         });
//       }
//     } catch (e) {
//       _showError('Failed to pick video');
//     }
//   }
//
//   Future<void> _takePhoto() async {
//     try {
//       final XFile? photo = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );
//
//       if (photo != null) {
//         setState(() {
//           _selectedMedia = [
//             MediaItem(
//               file: File(photo.path),
//               type: MediaType.image,
//               title: 'Photo',
//             )
//           ];
//           _isVideo = false;
//         });
//       }
//     } catch (e) {
//       _showError('Failed to take photo');
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _removeMedia() {
//     setState(() {
//       _selectedMedia = [];
//       _isVideo = false;
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // SIMPLIFIED MEDIA PICKER BOTTOM SHEET
//   // ══════════════════════════════════════════════════════════
//
//   void _showMediaPicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Drag handle
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: IGTheme.hairline,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Title
//             Text(
//               'Add Media',
//               style: IGTheme.username(size: 18),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Choose a photo or video to share',
//               style: IGTheme.body(12, color: IGTheme.textGray),
//             ),
//             const SizedBox(height: 20),
//
//             // Media Options Grid
//             Row(
//               children: [
//                 _buildMediaOption(
//                   icon: Icons.photo_library,
//                   label: 'Gallery',
//                   subtitle: 'Photos & Videos',
//                   color: IGTheme.primaryTeal,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _showGalleryPicker();
//                   },
//                 ),
//                 const SizedBox(width: 12),
//                 _buildMediaOption(
//                   icon: Icons.camera_alt,
//                   label: 'Camera',
//                   subtitle: 'Take Photo',
//                   color: IGTheme.blue,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _takePhoto();
//                   },
//                 ),
//                 const SizedBox(width: 12),
//                 _buildMediaOption(
//                   icon: Icons.videocam,
//                   label: 'Video',
//                   subtitle: 'Record Video',
//                   color: IGTheme.warningOrange,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickVideo();
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMediaOption({
//     required IconData icon,
//     required String label,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.2)),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 32),
//               const SizedBox(height: 6),
//               Text(
//                 label,
//                 style: IGTheme.body(13, color: color, w: FontWeight.w600),
//               ),
//               Text(
//                 subtitle,
//                 style: IGTheme.body(9, color: IGTheme.textGray),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showGalleryPicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: IGTheme.hairline,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Choose from Gallery',
//               style: IGTheme.username(size: 16),
//             ),
//             const SizedBox(height: 16),
//             _buildGalleryOption(
//               icon: Icons.image,
//               label: 'Pick Image',
//               subtitle: 'Select a photo',
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage();
//               },
//             ),
//             const Divider(color: IGTheme.hairline),
//             _buildGalleryOption(
//               icon: Icons.video_library,
//               label: 'Pick Video',
//               subtitle: 'Select a video',
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickVideo();
//               },
//             ),
//             const Divider(color: IGTheme.hairline),
//             _buildGalleryOption(
//               icon: Icons.multiple_stop,
//               label: 'Multiple Images',
//               subtitle: 'Select multiple photos',
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickMultipleImages();
//               },
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGalleryOption({
//     required IconData icon,
//     required String label,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: IGTheme.surfaceContainerLow,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: IGTheme.primaryTeal, size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(label, style: IGTheme.body(14, w: FontWeight.w600)),
//                   Text(subtitle, style: IGTheme.body(11, color: IGTheme.textGray)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: IGTheme.textGray, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickMultipleImages() async {
//     try {
//       final List<XFile> images = await _picker.pickMultiImage(
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );
//
//       if (images.isNotEmpty) {
//         setState(() {
//           _selectedMedia = images.map((file) => MediaItem(
//             file: File(file.path),
//             type: MediaType.image,
//             title: 'Image ${images.indexOf(file) + 1}',
//           )).toList();
//           _isVideo = false;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${images.length} images selected!'),
//             backgroundColor: IGTheme.successGreen,
//             duration: const Duration(seconds: 1),
//           ),
//         );
//       }
//     } catch (e) {
//       _showError('Failed to pick images');
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // MEDIA PREVIEW WIDGETS
//   // ══════════════════════════════════════════════════════════
//
//   Widget _buildMediaThumbnail() {
//     if (_selectedMedia.isEmpty) {
//       return GestureDetector(
//         onTap: _showMediaPicker,
//         child: Container(
//           width: 100,
//           height: 100,
//           decoration: BoxDecoration(
//             color: IGTheme.surfaceContainerLow,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: IGTheme.hairline, width: 0.5),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.add_photo_alternate_outlined, color: IGTheme.textGray, size: 28),
//                 SizedBox(height: 4),
//                 Text('Add', style: TextStyle(fontSize: 10, color: IGTheme.textGray)),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     final media = _selectedMedia.first;
//     return Stack(
//       children: [
//         Container(
//           width: 76,
//           height: 76,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: IGTheme.primaryTeal, width: 2),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: media.isLocalFile
//                 ? _buildLocalMediaPreview(media.file!)
//                 : _buildNetworkMediaPreview(media.url!),
//           ),
//         ),
//         // Multiple images indicator
//         if (_selectedMedia.length > 1)
//           Positioned(
//             bottom: 4,
//             right: 4,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 '+${_selectedMedia.length - 1}',
//                 style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         // Video indicator
//         if (_isVideo)
//           Positioned(
//             bottom: 4,
//             left: 4,
//             child: Container(
//               padding: const EdgeInsets.all(3),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: const Icon(
//                 Icons.play_arrow_rounded,
//                 color: Colors.white,
//                 size: 14,
//               ),
//             ),
//           ),
//         // Remove button
//         Positioned(
//           top: -4,
//           right: -4,
//           child: GestureDetector(
//             onTap: _removeMedia,
//             child: Container(
//               padding: const EdgeInsets.all(3),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 14,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLocalMediaPreview(File file) {
//     if (_isVideo) {
//       return Container(
//         color: Colors.black,
//         child: const Center(
//           child: Icon(Icons.video_library, color: Colors.white, size: 30),
//         ),
//       );
//     }
//     return Image.file(
//       file,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: IGTheme.surfaceContainerLow,
//           child: const Icon(Icons.broken_image, color: IGTheme.textGray),
//         );
//       },
//     );
//   }
//
//   Widget _buildNetworkMediaPreview(String url) {
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return Container(
//           color: IGTheme.surfaceContainerLow,
//           child: const Center(
//             child: SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//           ),
//         );
//       },
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: IGTheme.surfaceContainerLow,
//           child: const Icon(Icons.broken_image, color: IGTheme.textGray),
//         );
//       },
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // QUICK ACTION BUTTONS
//   // ══════════════════════════════════════════════════════════
//
//   Widget _buildQuickActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color color = IGTheme.textDark,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           border: Border.all(color: IGTheme.hairline, width: 0.5),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 18),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: IGTheme.body(11, color: color, w: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // ACTION ROW BUILDER
//   // ══════════════════════════════════════════════════════════
//
//   Widget _buildActionRow({
//     required IconData icon,
//     required String title,
//     required Widget trailing,
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: const BoxDecoration(
//           border: Border(bottom: BorderSide(color: IGTheme.hairline, width: 0.5)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: IGTheme.surfaceContainerLow,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Icon(icon, color: IGTheme.textDark, size: 18),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: IGTheme.body(13.5, color: IGTheme.textDark),
//                 ),
//               ],
//             ),
//             trailing,
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // OTHER FUNCTIONS
//   // ══════════════════════════════════════════════════════════
//
//   void _showSchedulePicker(BuildContext context) async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: IGTheme.primaryTeal,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (date != null) {
//       final time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (context, child) {
//           return Theme(
//             data: ThemeData.light().copyWith(
//               colorScheme: const ColorScheme.light(
//                 primary: IGTheme.primaryTeal,
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );
//
//       if (time != null) {
//         setState(() {
//           _scheduledDate = DateTime(
//             date.year,
//             date.month,
//             date.day,
//             time.hour,
//             time.minute,
//           );
//           _isScheduled = true;
//         });
//       }
//     }
//   }
//
//   void _publishPost() {
//     if (_captionController.text.trim().isEmpty && _selectedMedia.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please add a caption or media to publish'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _isScheduled
//               ? 'Post scheduled for ${_formatDate(_scheduledDate!)}'
//               : 'Post published successfully!',
//         ),
//         backgroundColor: IGTheme.primaryTeal,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//     Navigator.maybePop(context);
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
//
//   void _showTagDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Tag Products', style: IGTheme.username(size: 16)),
//         content: SizedBox(
//           width: 300,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Search and tag products or services',
//                 style: IGTheme.body(13, color: IGTheme.textGray),
//               ),
//               const SizedBox(height: 12),
//               const TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search products...',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.search),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 8,
//                 children: [
//                   _buildChip('ANC Headset'),
//                   _buildChip('Precision Mouse'),
//                   _buildChip('Executive Kit'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: IGTheme.body(13)),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: IGTheme.primaryTeal,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Tag Selected'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showJobDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Link Job Opening', style: IGTheme.username(size: 16)),
//         content: SizedBox(
//           width: 300,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Link to a job opening from your organization',
//                 style: IGTheme.body(13, color: IGTheme.textGray),
//               ),
//               const SizedBox(height: 12),
//               const TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Job title',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Job URL',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Recent openings:',
//                 style: IGTheme.body(12, w: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
//               _buildJobOption('Senior Flutter Developer'),
//               _buildJobOption('Product Manager'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: IGTheme.body(13)),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: IGTheme.primaryTeal,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Link Job'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPrivacyDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Privacy Settings', style: IGTheme.username(size: 16)),
//         content: SizedBox(
//           width: 300,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildRadioOption('Public', 'Visible to everyone'),
//               _buildRadioOption('Community', 'Visible to community members'),
//               _buildRadioOption('Private', 'Only visible to you'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: IGTheme.body(13)),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: IGTheme.primaryTeal,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Apply'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChip(String label) {
//     return Chip(
//       label: Text(label, style: IGTheme.body(11)),
//       backgroundColor: IGTheme.surfaceContainerLow,
//       side: const BorderSide(color: IGTheme.hairline),
//       onDeleted: () {},
//       deleteIcon: const Icon(Icons.close, size: 14),
//     );
//   }
//
//   Widget _buildJobOption(String title) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: IGTheme.surfaceContainerLow,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         children: [
//           Text(title, style: IGTheme.body(12, w: FontWeight.w500)),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(Icons.link, color: IGTheme.primaryTeal, size: 18),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRadioOption(String title, String subtitle) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Radio<String>(
//             value: title,
//             groupValue: 'Community',
//             onChanged: (val) {},
//             activeColor: IGTheme.primaryTeal,
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: IGTheme.body(13, w: FontWeight.w500)),
//                 Text(subtitle, style: IGTheme.body(11, color: IGTheme.textGray)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // MAIN BUILD
//   // ══════════════════════════════════════════════════════════
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final isWide = width >= 700;
//
//     return Scaffold(
//       backgroundColor: IGTheme.background,
//       appBar: AppBar(
//         backgroundColor: IGTheme.background,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close_rounded, color: IGTheme.textDark, size: 26),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         title: Text(
//           _isScheduled ? 'Schedule Post' : 'New Post',
//           style: IGTheme.username(size: 18),
//         ),
//         centerTitle: isWide,
//         actions: [
//           if (_isScheduled)
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _isScheduled = false;
//                   _scheduledDate = null;
//                 });
//               },
//               child: Text(
//                 'Cancel',
//                 style: IGTheme.body(12, color: Colors.red, w: FontWeight.w600),
//               ),
//             ),
//           TextButton(
//             onPressed: _publishPost,
//             child: Text(
//               _isScheduled ? 'Schedule' : 'Share',
//               style: IGTheme.username(
//                 size: 16,
//                 color: _captionController.text.trim().isEmpty && _selectedMedia.isEmpty
//                     ? IGTheme.textGray
//                     : IGTheme.blue,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//         ],
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(0.5),
//           child: Divider(color: IGTheme.hairline, height: 0.5, thickness: 0.5),
//         ),
//       ),
//       body: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: isWide ? 520 : double.infinity),
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ═══════════════════════════════════════════════════
//                 // MEDIA SECTION - SIMPLIFIED & EASY TO USE
//                 // ═══════════════════════════════════════════════════
//                 Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Media Thumbnail with Add/Edit functionality
//                       _buildMediaThumbnail(),
//                        const SizedBox(width: 16),
//                       // Caption Input
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               height: 120, // Increased height to 120px (was default ~100px)
//                               child: TextField(
//                                 controller: _captionController,
//                                 maxLines: 5, // Increased from 4 to 5 lines
//                                 keyboardType: TextInputType.multiline,
//                                 style: IGTheme.body(14),
//                                 decoration: InputDecoration(
//                                   hintText: 'Write a caption...',
//                                   hintStyle: IGTheme.body(14, color: IGTheme.textGray),
//                                   border: InputBorder.none,
//                                   isDense: true,
//                                   contentPadding: EdgeInsets.zero,
//                                   counterText: '',
//                                 ),
//                                 onChanged: (value) => setState(() {}),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),                    ],
//                   ),
//                 ),
//
//                 // If media is selected, show media info and options
//                 if (_selectedMedia.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: IGTheme.surfaceContainerLow,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _isVideo ? Icons.videocam : Icons.image,
//                             color: IGTheme.primaryTeal,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               _isVideo
//                                   ? 'Video selected (tap to change)'
//                                   : '${_selectedMedia.length} image${_selectedMedia.length > 1 ? 's' : ''} selected',
//                               style: IGTheme.body(12, color: IGTheme.textGray),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: _showMediaPicker,
//                             child: Text(
//                               'Change',
//                               style: IGTheme.body(12, color: IGTheme.primaryTeal, w: FontWeight.w600),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: _removeMedia,
//                             child: Text(
//                               'Remove',
//                               style: IGTheme.body(12, color: Colors.red, w: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                 const Divider(color: IGTheme.hairline, height: 15, thickness: 0.5),
//
//                 // ═══════════════════════════════════════════════════
//                 // POST SETTINGS
//                 // ═══════════════════════════════════════════════════
//
//                 _buildActionRow(
//                   icon: Icons.layers_outlined,
//                   title: 'Category',
//                   trailing: DropdownButton<String>(
//                     value: _selectedCategory,
//                     underline: const SizedBox(),
//                     icon: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
//                     style: IGTheme.body(13, color: IGTheme.primaryTeal, w: FontWeight.w600),
//                     items: ['Strategic Update', 'Market Insight', 'Official Announcement', 'Community Question']
//                         .map((v) => DropdownMenuItem(
//                       value: v,
//                       child: Text(v, style: IGTheme.body(13)),
//                     )).toList(),
//                     onChanged: (val) => setState(() => _selectedCategory = val!),
//                   ),
//                 ),
//
//                 _buildActionRow(
//                   icon: Icons.diversity_3_outlined,
//                   title: 'Community',
//                   trailing: DropdownButton<String>(
//                     value: _selectedCommunity,
//                     underline: const SizedBox(),
//                     icon: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
//                     style: IGTheme.body(13, color: IGTheme.primaryTeal, w: FontWeight.w600),
//                     items: ['Global Leadership', 'Regional Directors', 'Product Strategy', 'All Members']
//                         .map((v) => DropdownMenuItem(
//                       value: v,
//                       child: Text(v, style: IGTheme.body(13)),
//                     )).toList(),
//                     onChanged: (val) => setState(() => _selectedCommunity = val!),
//                   ),
//                 ),
//
//                 _buildActionRow(
//                   icon: Icons.sell_outlined,
//                   title: 'Tag Products',
//                   trailing: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
//                   onTap: () => _showTagDialog(context),
//                 ),
//
//                 _buildActionRow(
//                   icon: Icons.business_center_outlined,
//                   title: 'Link Job',
//                   trailing: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
//                   onTap: () => _showJobDialog(context),
//                 ),
//
//                 _buildActionRow(
//                   icon: Icons.location_on_outlined,
//                   title: 'Location',
//                   trailing: SizedBox(
//                     width: 120,
//                     child: TextField(
//                       controller: _locationController,
//                       style: IGTheme.body(13, color: IGTheme.primaryTeal),
//                       decoration: InputDecoration(
//                         hintText: 'Add location...',
//                         hintStyle: IGTheme.body(12, color: IGTheme.textGray),
//                         border: InputBorder.none,
//                         isDense: true,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//                   onTap: () {},
//                 ),
//
//                 // ═══════════════════════════════════════════════════
//                 // PROMOTION
//                 // ═══════════════════════════════════════════════════
//
//                 Container(
//                   margin: const EdgeInsets.all(16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         IGTheme.surfaceContainerLow.withOpacity(0.4),
//                         IGTheme.primaryTeal.withOpacity(0.05),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: IGTheme.hairline, width: 0.5),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: const BoxDecoration(
//                           color: IGTheme.primaryTeal,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.bolt_rounded,
//                           color: Colors.white,
//                           size: 18,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Promote this post',
//                               style: IGTheme.username(size: 13),
//                             ),
//                             Text(
//                               'Reach 10x more audience',
//                               style: IGTheme.body(10, color: IGTheme.textGray),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Switch.adaptive(
//                         value: _isSponsored,
//                         activeColor: IGTheme.primaryTeal,
//                         onChanged: (val) => setState(() => _isSponsored = val),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // ═══════════════════════════════════════════════════
//                 // ADVANCED SETTINGS
//                 // ═══════════════════════════════════════════════════
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.settings_outlined, color: IGTheme.textGray, size: 16),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Advanced',
//                         style: IGTheme.body(12, color: IGTheme.textGray, w: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 _buildActionRow(
//                   icon: Icons.schedule_rounded,
//                   title: _isScheduled
//                       ? 'Scheduled for ${_formatDate(_scheduledDate!)}'
//                       : 'Schedule post',
//                   trailing: Row(
//                     children: [
//                       if (_isScheduled)
//                         IconButton(
//                           icon: const Icon(Icons.clear, color: Colors.red, size: 18),
//                           onPressed: () => setState(() {
//                             _isScheduled = false;
//                             _scheduledDate = null;
//                           }),
//                         ),
//                       IconButton(
//                         icon: Icon(
//                           _isScheduled ? Icons.edit : Icons.chevron_right_rounded,
//                           color: IGTheme.textGray,
//                         ),
//                         onPressed: () => _showSchedulePicker(context),
//                       ),
//                     ],
//                   ),
//                   onTap: () => _showSchedulePicker(context),
//                 ),
//
//                 _buildActionRow(
//                   icon: Icons.privacy_tip_outlined,
//                   title: 'Privacy',
//                   trailing: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
//                   onTap: () => _showPrivacyDialog(context),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // ═══════════════════════════════════════════════════
//                 // ACTION BUTTONS
//                 // ═══════════════════════════════════════════════════
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Draft saved!'),
//                                 backgroundColor: IGTheme.textDark,
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.save_outlined, size: 18),
//                           label: Text(
//                             'Save Draft',
//                             style: IGTheme.body(13, w: FontWeight.w600),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: _publishPost,
//                           icon: const Icon(Icons.send_rounded, size: 18),
//                           label: Text(
//                             _isScheduled ? 'Schedule' : 'Publish',
//                             style: IGTheme.body(13, w: FontWeight.w600),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: IGTheme.primaryTeal,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Database/Database.dart';


// ══════════════════════════════════════════════════════════
// DESIGN SYSTEM
// ══════════════════════════════════════════════════════════
class IGTheme {
  static const Color background = Colors.white;
  static const Color textDark = Color(0xFF262626);
  static const Color textGray = Color(0xFF8E8E8E);
  static const Color hairline = Color(0xFFDBDBDB);
  static const Color blue = Color(0xFF0095F6);
  static const Color primaryTeal = Color(0xFF006565);
  static const Color surfaceContainerLow = Color(0xFFF4F3F3);
  static const Color successGreen = Color(0xFF34A853);
  static const Color warningOrange = Color(0xFFFBBC04);
  static const Color shadowColor = Color(0x1A000000);

  static TextStyle username({double size = 13.5, Color color = textDark}) =>
      TextStyle(fontWeight: FontWeight.w600, fontSize: size, color: color, fontFamily: 'Manrope');

  static TextStyle body(double size, {Color color = textDark, FontWeight w = FontWeight.normal}) =>
      TextStyle(fontSize: size, color: color, fontWeight: w, height: 1.35, fontFamily: 'Inter');
}

enum MediaType { image, video }

class MediaItem {
  final String? url;
  final File? file;
  final MediaType type;
  final String title;

  MediaItem({this.url, this.file, required this.type, this.title = ''});

  bool get isNetworkImage => url != null && file == null;
  bool get isLocalFile => file != null;
}

// ══════════════════════════════════════════════════════════
// MAIN CREATE POST SCREEN
// ══════════════════════════════════════════════════════════
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final Database _db = Database();

  String _selectedCategory = 'Strategic Update';
  String _selectedCommunity = 'Global Leadership';
  String _selectedPrivacy = 'Community'; // Public | Community | Private
  bool _isSponsored = false;
  bool _isScheduled = false;
  DateTime? _scheduledDate;
  bool _isPublishing = false;

  List<MediaItem> _selectedMedia = [];
  bool _isVideo = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // MEDIA PICKER FUNCTIONS (unchanged from your original)
  // ══════════════════════════════════════════════════════════

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (image != null) {
        setState(() {
          _selectedMedia = [MediaItem(file: File(image.path), type: MediaType.image, title: 'Image')];
          _isVideo = false;
        });
      }
    } catch (e) {
      _showError('Failed to pick image');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
      if (video != null) {
        setState(() {
          _selectedMedia = [MediaItem(file: File(video.path), type: MediaType.video, title: 'Video')];
          _isVideo = true;
        });
      }
    } catch (e) {
      _showError('Failed to pick video');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (photo != null) {
        setState(() {
          _selectedMedia = [MediaItem(file: File(photo.path), type: MediaType.image, title: 'Photo')];
          _isVideo = false;
        });
      }
    } catch (e) {
      _showError('Failed to take photo');
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (images.isNotEmpty) {
        setState(() {
          _selectedMedia = images
              .map((file) => MediaItem(file: File(file.path), type: MediaType.image, title: 'Image ${images.indexOf(file) + 1}'))
              .toList();
          _isVideo = false;
        });
      }
    } catch (e) {
      _showError('Failed to pick images');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
    );
  }

  void _removeMedia() {
    setState(() {
      _selectedMedia = [];
      _isVideo = false;
    });
  }

  // ══════════════════════════════════════════════════════════
  // PUBLISH — this is the part that actually calls the API
  // ══════════════════════════════════════════════════════════

  Future<void> _publishPost() async {
    if (_captionController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption or media to publish'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isPublishing = true);

    // Map UI state -> the fields create_post expects.
    final contentType = _isVideo
        ? 'video'
        : _selectedMedia.length > 1
        ? 'gallery'
        : _selectedMedia.isNotEmpty
        ? 'image'
        : 'text';

    final visibility = _selectedPrivacy.toLowerCase(); // 'public' | 'community' | 'private'

    final images = _selectedMedia.where((m) => m.isLocalFile && m.type == MediaType.image).map((m) => m.file!).toList();

    final result = await _db.createPost(
      contentType: contentType,
      visibility: visibility,
      label: _captionController.text.trim(),
      tags: _selectedCategory,
      location: _locationController.text.trim(),
      images: images,
    );

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isScheduled ? 'Post scheduled for ${_formatDate(_scheduledDate!)}' : 'Post published successfully!'),
          backgroundColor: IGTheme.primaryTeal,
          duration: const Duration(seconds: 2),
        ),
      );
      // `true` tells the feed screen to refresh when it regains focus.
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Failed to publish post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ══════════════════════════════════════════════════════════
  // MEDIA PICKER BOTTOM SHEETS (unchanged from your original)
  // ══════════════════════════════════════════════════════════

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: IGTheme.hairline, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Add Media', style: IGTheme.username(size: 18)),
            const SizedBox(height: 4),
            Text('Choose a photo or video to share', style: IGTheme.body(12, color: IGTheme.textGray)),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildMediaOption(icon: Icons.photo_library, label: 'Gallery', subtitle: 'Photos & Videos', color: IGTheme.primaryTeal, onTap: () {
                  Navigator.pop(context);
                  _showGalleryPicker();
                }),
                const SizedBox(width: 12),
                _buildMediaOption(icon: Icons.camera_alt, label: 'Camera', subtitle: 'Take Photo', color: IGTheme.blue, onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                }),
                const SizedBox(width: 12),
                _buildMediaOption(icon: Icons.videocam, label: 'Video', subtitle: 'Record Video', color: IGTheme.warningOrange, onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({required IconData icon, required String label, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 6),
              Text(label, style: IGTheme.body(13, color: color, w: FontWeight.w600)),
              Text(subtitle, style: IGTheme.body(9, color: IGTheme.textGray)),
            ],
          ),
        ),
      ),
    );
  }

  void _showGalleryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: IGTheme.hairline, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Choose from Gallery', style: IGTheme.username(size: 16)),
            const SizedBox(height: 16),
            _buildGalleryOption(icon: Icons.image, label: 'Pick Image', subtitle: 'Select a photo', onTap: () {
              Navigator.pop(context);
              _pickImage();
            }),
            const Divider(color: IGTheme.hairline),
            _buildGalleryOption(icon: Icons.video_library, label: 'Pick Video', subtitle: 'Select a video', onTap: () {
              Navigator.pop(context);
              _pickVideo();
            }),
            const Divider(color: IGTheme.hairline),
            _buildGalleryOption(icon: Icons.multiple_stop, label: 'Multiple Images', subtitle: 'Select multiple photos', onTap: () {
              Navigator.pop(context);
              _pickMultipleImages();
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryOption({required IconData icon, required String label, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: IGTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: IGTheme.primaryTeal, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: IGTheme.body(14, w: FontWeight.w600)),
                  Text(subtitle, style: IGTheme.body(11, color: IGTheme.textGray)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: IGTheme.textGray, size: 20),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // MEDIA PREVIEW
  // ══════════════════════════════════════════════════════════

  Widget _buildMediaThumbnail() {
    if (_selectedMedia.isEmpty) {
      return GestureDetector(
        onTap: _showMediaPicker,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: IGTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: IGTheme.hairline, width: 0.5)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: IGTheme.textGray, size: 28),
                SizedBox(height: 4),
                Text('Add', style: TextStyle(fontSize: 10, color: IGTheme.textGray)),
              ],
            ),
          ),
        ),
      );
    }

    final media = _selectedMedia.first;
    return Stack(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: IGTheme.primaryTeal, width: 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _isVideo
                ? Container(color: Colors.black, child: const Center(child: Icon(Icons.video_library, color: Colors.white, size: 30)))
                : Image.file(media.file!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: IGTheme.surfaceContainerLow, child: const Icon(Icons.broken_image, color: IGTheme.textGray))),
          ),
        ),
        if (_selectedMedia.length > 1)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
              child: Text('+${_selectedMedia.length - 1}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: _removeMedia,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Privacy Settings', style: IGTheme.username(size: 16)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _radioOption(setDialogState, 'Public', 'Visible to everyone'),
                _radioOption(setDialogState, 'Community', 'Visible to community members'),
                _radioOption(setDialogState, 'Private', 'Only visible to you'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel', style: IGTheme.body(13))),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(backgroundColor: IGTheme.primaryTeal, foregroundColor: Colors.white),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioOption(StateSetter setDialogState, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Radio<String>(
            value: title,
            groupValue: _selectedPrivacy,
            onChanged: (val) {
              setDialogState(() {});
              setState(() => _selectedPrivacy = val!);
            },
            activeColor: IGTheme.primaryTeal,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: IGTheme.body(13, w: FontWeight.w500)),
                Text(subtitle, style: IGTheme.body(11, color: IGTheme.textGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSchedulePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _isScheduled = true;
        });
      }
    }
  }

  Widget _buildActionRow({required IconData icon, required String title, required Widget trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: IGTheme.hairline, width: 0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: IGTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: IGTheme.textDark, size: 18),
                ),
                const SizedBox(width: 12),
                Text(title, style: IGTheme.body(13.5, color: IGTheme.textDark)),
              ],
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // MAIN BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 700;
    final canPublish = !_isPublishing && (_captionController.text.trim().isNotEmpty || _selectedMedia.isNotEmpty);

    return Scaffold(
      backgroundColor: IGTheme.background,
      appBar: AppBar(
        backgroundColor: IGTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: IGTheme.textDark, size: 26),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(_isScheduled ? 'Schedule Post' : 'New Post', style: IGTheme.username(size: 18)),
        centerTitle: isWide,
        actions: [
          if (_isPublishing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: canPublish ? _publishPost : null,
              child: Text(
                _isScheduled ? 'Schedule' : 'Share',
                style: IGTheme.username(size: 16, color: canPublish ? IGTheme.blue : IGTheme.textGray),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 520 : double.infinity),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMediaThumbnail(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 120,
                          child: TextField(
                            controller: _captionController,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            style: IGTheme.body(14),
                            decoration: InputDecoration(
                              hintText: 'Write a caption...',
                              hintStyle: IGTheme.body(14, color: IGTheme.textGray),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: IGTheme.hairline, height: 15, thickness: 0.5),
                _buildActionRow(
                  icon: Icons.layers_outlined,
                  title: 'Category',
                  trailing: DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    items: ['Strategic Update', 'Market Insight', 'Official Announcement', 'Community Question']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v, style: IGTheme.body(13))))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ),
                _buildActionRow(
                  icon: Icons.diversity_3_outlined,
                  title: 'Community',
                  trailing: DropdownButton<String>(
                    value: _selectedCommunity,
                    underline: const SizedBox(),
                    items: ['Global Leadership', 'Regional Directors', 'Product Strategy', 'All Members']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v, style: IGTheme.body(13))))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCommunity = val!),
                  ),
                ),
                _buildActionRow(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  trailing: SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _locationController,
                      style: IGTheme.body(13, color: IGTheme.primaryTeal),
                      decoration: InputDecoration(hintText: 'Add location...', hintStyle: IGTheme.body(12, color: IGTheme.textGray), border: InputBorder.none, isDense: true),
                    ),
                  ),
                  onTap: () {},
                ),
                _buildActionRow(
                  icon: Icons.schedule_rounded,
                  title: _isScheduled ? 'Scheduled for ${_formatDate(_scheduledDate!)}' : 'Schedule post',
                  trailing: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
                  onTap: () => _showSchedulePicker(context),
                ),
                _buildActionRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy: $_selectedPrivacy',
                  trailing: const Icon(Icons.chevron_right_rounded, color: IGTheme.textGray),
                  onTap: () => _showPrivacyDialog(context),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: canPublish ? _publishPost : null,
                    icon: _isPublishing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isScheduled ? 'Schedule' : 'Publish', style: IGTheme.body(13, color: Colors.white, w: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IGTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}