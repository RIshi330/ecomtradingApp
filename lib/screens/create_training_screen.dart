import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

const Color _teal = Color(0xFF006565);
const Color _tealLight = Color(0xFFE3FFFE);
const Color _bg = Color(0xFFF8F9FF);
const Color _surface = Colors.white;
const Color _textDark = Color(0xFF0B1C30);
const Color _textLight = Color(0xFF6E7979);
const Color _outline = Color(0xFFBDC9C8);
const Color _error = Color(0xFFBA1A1A);

class CreateTrainingScreen extends StatefulWidget {
  const CreateTrainingScreen({super.key});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Section expansion state
  final Map<String, bool> _expanded = {
    'info': true,
    'delivery': false,
    'audience': false,
    'pricing': false,
    'benefits': false,
    'curriculum': false,
  };

  // Program Info
  final _titleCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  // Delivery
  String _mode = 'online';
  final _platformCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();

  // Audience
  final List<String> _audienceOptions = ['Students', 'Professionals', 'Managers', 'Entrepreneurs', 'Researchers'];
  final Set<String> _selectedAudience = {};
  final _otherAudienceCtrl = TextEditingController();

  // Pricing
  String _paid = 'free';
  final _priceCtrl = TextEditingController();

  // Benefits & Media
  final _givesCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  File? _thumbnailFile;

  // Curriculum — Objectives
  final List<TextEditingController> _objectives = [TextEditingController()];

  // Curriculum — Modules
  final List<_ModuleData> _modules = [_ModuleData()];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _organizerCtrl.dispose();
    _summaryCtrl.dispose();
    _platformCtrl.dispose();
    _venueCtrl.dispose();
    _otherAudienceCtrl.dispose();
    _priceCtrl.dispose();
    _givesCtrl.dispose();
    _tagsCtrl.dispose();
    for (var c in _objectives) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _thumbnailFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Expand the first section with an error
      setState(() => _expanded['info'] = true);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _showErr('Training title is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final modules = _modules.map((m) => {
        'title': m.titleCtrl.text.trim(),
        'description': m.descCtrl.text.trim(),
        'sessions': m.sessions.map((s) => {
          'title': s.titleCtrl.text.trim(),
          'description': '',
          'duration': s.durationCtrl.text.trim(),
          'time': s.timeCtrl.text.trim(),
        }).toList(),
      }).toList();

      final body = {
        'action': 'save_training',
        'training_title': _titleCtrl.text.trim(),
        'organizer': _organizerCtrl.text.trim(),
        'summary': _summaryCtrl.text.trim(),
        'mode': _mode,
        'platform': _platformCtrl.text.trim(),
        'venue_address': _venueCtrl.text.trim(),
        'suitable_for': _selectedAudience.toList(),
        'suitable_other': _otherAudienceCtrl.text.trim(),
        'paid': _paid,
        'price': _paid == 'paid' ? (_priceCtrl.text.trim().isEmpty ? '0' : _priceCtrl.text.trim()) : '0',
        'gives': _givesCtrl.text.trim(),
        'tags': _tagsCtrl.text.trim(),
        'objectives': _objectives.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
        'modules': modules,
      };

      final res = await Database().getData(body, endpoint: 'new_apis/training_form_API.php');

      if (!mounted) return;
      if (res['success'] == true) {
        _showSuccess();
      } else {
        _showErr(res['message'] ?? 'Failed to create training');
      }
    } catch (e) {
      _showErr('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: _error, content: Text(msg, style: const TextStyle(color: Colors.white))),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: _tealLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: _teal, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Program Created!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 8),
              const Text('Your training program is under review and will be live shortly.', textAlign: TextAlign.center, style: TextStyle(color: _textLight, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                  child: const Text('Back to Trainings', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: const Text('Create Training', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // Progress chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _progressChip('1. Program', true),
                  const SizedBox(width: 8),
                  _progressChip('2. Details', false),
                  const SizedBox(width: 8),
                  _progressChip('3. Curriculum', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Accordion sections
            _buildSection('info', Icons.info_outline_rounded, 'Program Info', _buildProgramInfo()),
            const SizedBox(height: 12),
            _buildSection('delivery', Icons.wifi_rounded, 'Delivery Mode', _buildDelivery()),
            const SizedBox(height: 12),
            _buildSection('audience', Icons.groups_rounded, 'Target Audience', _buildAudience()),
            const SizedBox(height: 12),
            _buildSection('pricing', Icons.payments_outlined, 'Pricing', _buildPricing()),
            const SizedBox(height: 12),
            _buildSection('benefits', Icons.card_giftcard_rounded, 'Benefits & Media', _buildBenefits()),
            const SizedBox(height: 12),
            _buildSection('curriculum', Icons.menu_book_rounded, 'Curriculum', _buildCurriculum()),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _progressChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active ? _teal : const Color(0xFFC6E9E9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF4A6A6A), fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildSection(String key, IconData icon, String title, Widget content) {
    final isOpen = _expanded[key] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outline.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded[key] = !isOpen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: _teal, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark))),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: _textLight),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  // ── SECTION: Program Info ──────────────────────────────────────────────────
  Widget _buildProgramInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Program Title *'),
        _field(_titleCtrl, hint: 'e.g. Masterclass in Brand Design', validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        _label('Organizer Name *'),
        _field(_organizerCtrl, hint: 'Individual or Company', validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        _label('Short Summary *'),
        _multiField(_summaryCtrl, hint: 'Briefly describe what this program is about...', maxLines: 3, validator: (v) => v!.length < 10 ? 'Min 10 characters' : null),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder(
            valueListenable: _summaryCtrl,
            builder: (_, __, ___) => Text('${_summaryCtrl.text.length} / 500', style: const TextStyle(fontSize: 10, color: _textLight)),
          ),
        ),
      ],
    );
  }

  // ── SECTION: Delivery Mode ─────────────────────────────────────────────────
  Widget _buildDelivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('How will training be delivered?'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: ['online', 'offline', 'hybrid'].map((m) {
              final active = _mode == m;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mode = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? _teal : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m[0].toUpperCase() + m.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: active ? Colors.white : _textLight, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_mode == 'online' || _mode == 'hybrid') ...[
          _label('Online Platform'),
          _field(_platformCtrl, hint: 'e.g. Zoom, Google Meet'),
          const SizedBox(height: 12),
        ],
        if (_mode == 'offline' || _mode == 'hybrid') ...[
          _label('Venue Address'),
          _multiField(_venueCtrl, hint: 'Enter the physical location details...', maxLines: 3),
        ],
      ],
    );
  }

  // ── SECTION: Target Audience ───────────────────────────────────────────────
  Widget _buildAudience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._audienceOptions.map((opt) => CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: _teal,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(opt, style: const TextStyle(fontSize: 14, color: _textDark)),
          value: _selectedAudience.contains(opt),
          onChanged: (v) => setState(() => v! ? _selectedAudience.add(opt) : _selectedAudience.remove(opt)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        )),
        const SizedBox(height: 8),
        _label('Other Audience (Optional)'),
        _field(_otherAudienceCtrl, hint: 'e.g. High school teachers'),
      ],
    );
  }

  // ── SECTION: Pricing ───────────────────────────────────────────────────────
  Widget _buildPricing() {
    return Column(
      children: [
        Row(
          children: ['free', 'paid'].map((p) {
            final active = _paid == p;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paid = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: active ? _tealLight : Colors.white,
                    border: Border.all(color: active ? _teal : _outline, width: active ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p == 'free' ? '🆓  Free' : '💳  Paid',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: active ? _teal : _textLight, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_paid == 'paid') ...[
          const SizedBox(height: 12),
          _label('Price (₹)'),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textDark, fontSize: 14),
            validator: (v) => _paid == 'paid' && (v == null || v.isEmpty) ? 'Enter price' : null,
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: const TextStyle(color: _textLight),
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: _teal, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _outline)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _outline)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _teal, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  // ── SECTION: Benefits & Media ──────────────────────────────────────────────
  Widget _buildBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('What attendees will get'),
        _multiField(_givesCtrl, hint: 'e.g. Certificate, PDF resources, 1-on-1 session...', maxLines: 3),
        const SizedBox(height: 12),
        _label('Tags (comma-separated)'),
        _field(_tagsCtrl, hint: 'e.g. flutter, dart, mobile'),
        const SizedBox(height: 12),
        _label('Thumbnail Upload'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(color: _thumbnailFile != null ? _teal : _outline, width: _thumbnailFile != null ? 2 : 1.5, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(14),
              color: _thumbnailFile != null ? Colors.transparent : _bg,
            ),
            clipBehavior: Clip.antiAlias,
            child: _thumbnailFile != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_thumbnailFile!, fit: BoxFit.cover),
                      Positioned(
                        right: 8, top: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _thumbnailFile = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.upload_file_rounded, color: _textLight, size: 36),
                      SizedBox(height: 6),
                      Text('Tap to upload thumbnail', style: TextStyle(fontWeight: FontWeight.bold, color: _textLight, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('JPG, PNG, WEBP (Max 5MB)', style: TextStyle(fontSize: 10, color: _textLight)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── SECTION: Curriculum ────────────────────────────────────────────────────
  Widget _buildCurriculum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Learning Objectives'),
        const SizedBox(height: 8),
        ..._objectives.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: e.value,
                  style: const TextStyle(fontSize: 13, color: _textDark),
                  decoration: _inputDeco(hint: 'e.g. Learn Flutter Basics'),
                ),
              ),
              const SizedBox(width: 8),
              if (_objectives.length > 1)
                GestureDetector(
                  onTap: () => setState(() { e.value.dispose(); _objectives.removeAt(e.key); }),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline, color: _error, size: 18)),
                ),
            ],
          ),
        )),
        TextButton.icon(
          onPressed: () => setState(() => _objectives.add(TextEditingController())),
          icon: const Icon(Icons.add, color: _teal, size: 18),
          label: const Text('Add Objective', style: TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const Divider(height: 24),
        _label('Program Modules'),
        const SizedBox(height: 8),
        ..._modules.asMap().entries.map((e) => _buildModuleCard(e.key, e.value)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: _teal, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => setState(() => _modules.add(_ModuleData())),
            icon: const Icon(Icons.add),
            label: const Text('Add Module', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(int mIdx, _ModuleData mod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Module ${(mIdx + 1).toString().padLeft(2, '0')}', style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              if (_modules.length > 1)
                GestureDetector(
                  onTap: () => setState(() => _modules.removeAt(mIdx)),
                  child: const Icon(Icons.delete_outline, color: _error, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(controller: mod.titleCtrl, style: const TextStyle(fontSize: 13, color: _textDark), decoration: _inputDeco(hint: 'Module Title')),
          const SizedBox(height: 8),
          TextFormField(controller: mod.descCtrl, maxLines: 2, style: const TextStyle(fontSize: 13, color: _textDark), decoration: _inputDeco(hint: 'Module Description')),
          const SizedBox(height: 10),
          // Sessions
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: _teal, width: 2))),
            child: Column(
              children: [
                ...mod.sessions.asMap().entries.map((se) => _buildSessionCard(mIdx, se.key, se.value)),
                TextButton.icon(
                  onPressed: () => setState(() => mod.sessions.add(_SessionData())),
                  icon: const Icon(Icons.add, color: _teal, size: 16),
                  label: const Text('Add Session', style: TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(int mIdx, int sIdx, _SessionData s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _outline.withOpacity(0.4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Session ${(sIdx + 1).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: _textLight, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (s != _modules[mIdx].sessions.first || _modules[mIdx].sessions.length > 1)
                GestureDetector(
                  onTap: () => setState(() => _modules[mIdx].sessions.removeAt(sIdx)),
                  child: const Icon(Icons.close, size: 16, color: _error),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(controller: s.titleCtrl, style: const TextStyle(fontSize: 13, color: _textDark), decoration: _inputDeco(hint: 'Session Title')),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: s.durationCtrl,
                  style: const TextStyle(fontSize: 12, color: _textDark),
                  decoration: _inputDeco(hint: '1h 30m').copyWith(prefixIcon: const Icon(Icons.schedule, size: 16, color: _textLight)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: s.timeCtrl,
                  style: const TextStyle(fontSize: 12, color: _textDark),
                  keyboardType: TextInputType.datetime,
                  decoration: _inputDeco(hint: '09:00 AM').copyWith(prefixIcon: const Icon(Icons.alarm, size: 16, color: _textLight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _outline),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _textLight, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                shadowColor: _teal.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Review & Publish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textLight)),
  );

  InputDecoration _inputDeco({String hint = ''}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _textLight, fontSize: 13),
    filled: true,
    fillColor: _bg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _outline)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _outline)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _teal, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _error)),
  );

  Widget _field(TextEditingController ctrl, {String hint = '', String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl,
      validator: validator,
      style: const TextStyle(color: _textDark, fontSize: 14),
      decoration: _inputDeco(hint: hint),
    );

  Widget _multiField(TextEditingController ctrl, {String hint = '', int maxLines = 3, String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: _textDark, fontSize: 14),
      decoration: _inputDeco(hint: hint),
    );
}

// ── Data Models ────────────────────────────────────────────────────────────
class _ModuleData {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final List<_SessionData> sessions = [_SessionData()];
}

class _SessionData {
  final titleCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
}
