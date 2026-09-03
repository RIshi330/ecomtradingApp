import 'package:flutter/material.dart';

import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';

// Set this to whatever this PHP file is actually named/routed as on your
// server (it's passed straight through to Database.getData as `endpoint`,
// same pattern used everywhere else in the app, e.g. `?endpoint=...`).
const String kAddressEndpoint = 'new_apis/checkout_address_API.php';

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  final Database _db = Database();

  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Calls Database.getData directly — action + endpoint passed from here,
    // no new method added to database.dart.
    final result = await _db.getData(
      {'action': 'get_all_address',        'vendor_id': UserSessionSet.instance.vendorId,
      },
      endpoint: kAddressEndpoint,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        final data = result['data'];
        final list = (data is Map ? data['addresses'] : null) as List? ?? [];
        _addresses = List<Map<String, dynamic>>.from(list);
      } else {
        _error = (result['message'] ?? result['error'] ?? 'Failed to load addresses').toString();
      }
    });
  }

  void _deleteAddress(int index) {
    // NOTE: the PHP file you shared doesn't have a delete/remove action yet
    // (only get_all_address / add_new_address). Wire this to a
    // 'delete_address' action once it exists server-side.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Address'),
        content: const Text('Are you sure you want to remove this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete endpoint not implemented on server yet')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(int index) {
    // Same caveat: no "set default" action in the PHP file yet — this only
    // updates local UI state for now.
    setState(() {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i]['is_default'] = (i == index) ? 1 : 0;
      }
    });
  }

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => AddAddressBottomSheet(
        db: _db,
        onSaved: _loadAddresses,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        scrolledUnderElevation: 4.0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Addresses',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadAddresses,
            child: _buildBody(theme),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _showAddAddressSheet,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add New Address',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Center(child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
          const SizedBox(height: 12),
          Center(
            child: TextButton(onPressed: _loadAddresses, child: const Text('Retry')),
          ),
        ],
      );
    }

    if (_addresses.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Center(child: Text('No addresses saved yet')),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved shipping locations',
              style: TextStyle(color: theme.colorScheme.secondary, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '${_addresses.length} Addresses',
                style: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_addresses.length, (index) {
          final item = _addresses[index];
          final isDefault = item['is_default'].toString() == '1';
          final addressLines = [item['address'], item['landmark'], item['pincode']]
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .join(',\n');

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AddressCard(
              name: item['name']?.toString() ?? '',
              phone: item['mobile']?.toString() ?? '',
              address: addressLines,
              isDefault: isDefault,
              tag: item['address_type']?.toString() ?? '',
              onEdit: () {},
              onDelete: () => _deleteAddress(index),
              onSetDefault: () => _setAsDefault(index),
            ),
          );
        }),
        const SizedBox(height: 120),
      ],
    );
  }
}

class AddressCard extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final bool isDefault;
  final String tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.isDefault,
    required this.tag,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isDefault ? Border.all(color: theme.colorScheme.primaryContainer, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(phone, style: TextStyle(color: theme.colorScheme.outline, fontSize: 14)),
                      ],
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Text('DEFAULT',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      )
                    else if (tag.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(tag.toUpperCase(),
                            style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(address, style: TextStyle(color: theme.colorScheme.secondary, fontSize: 16, height: 1.6)),
              ],
            ),
          ),
          Container(
            color: theme.colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primaryContainer,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                      label: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                if (isDefault)
                  Text('Default Saved',
                      style: TextStyle(color: theme.colorScheme.outline.withOpacity(0.5), fontSize: 14))
                else
                  InkWell(
                    onTap: onSetDefault,
                    child: Text('Set as Default',
                        style: TextStyle(
                            color: theme.colorScheme.primaryContainer,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline)),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AddAddressBottomSheet extends StatefulWidget {
  final Database db;
  final VoidCallback onSaved;

  const AddAddressBottomSheet({super.key, required this.db, required this.onSaved});

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  bool _isDefaultAddress = false;
  bool _isSaving = false;

  final _fullNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(); // note: PHP add_new_address has no separate city/state field —
  final _stateCtrl = TextEditingController(); // folded into form_address below
  final _houseCtrl = TextEditingController();
  final _roadCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _pinCodeCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _houseCtrl.dispose();
    _roadCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_fullNameCtrl.text.trim().isEmpty || _mobileCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and mobile number are required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // The backend only has a single `form_address` field (no separate
    // city/state columns in add_new_address), so we combine them here.
    final combinedAddress = [
      _houseCtrl.text.trim(),
      _roadCtrl.text.trim(),
      _cityCtrl.text.trim(),
      _stateCtrl.text.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

    // Calls Database.getData directly — action + endpoint passed from here,
    // no new method added to database.dart.
    final result = await widget.db.getData(
      {
        'action': 'add_new_address',
        'fullname': _fullNameCtrl.text.trim(),
        'add_type': 'Home', // wire to a real selector if you have one
        'form_address': combinedAddress,
        'landmark': '',
        'zip_code': _pinCodeCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'default_add': _isDefaultAddress ? '1' : '0',
        'vendor_id': UserSessionSet.instance.vendorId,

      },
      endpoint: kAddressEndpoint,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      widget.onSaved();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((result['message'] ?? result['error'] ?? 'Failed to save address').toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Address',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Contact Details'),
              _CustomInputField(label: 'Full Name', hint: 'John Doe', controller: _fullNameCtrl),
              _CustomInputField(
                  label: 'Mobile Number',
                  hint: '+1 (555) 000-0000',
                  keyboardType: TextInputType.phone,
                  controller: _mobileCtrl),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Address Information'),
              Row(
                children: [
                  Expanded(
                      child: _CustomInputField(
                          label: 'Pin Code',
                          hint: '10001',
                          keyboardType: TextInputType.number,
                          controller: _pinCodeCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _CustomInputField(label: 'State', hint: 'New York', controller: _stateCtrl)),
                ],
              ),
              _CustomInputField(label: 'City', hint: 'Manhattan', controller: _cityCtrl),
              _CustomInputField(
                  label: 'House No. / Building Name', hint: 'Apt 4B, Serene Heights', controller: _houseCtrl),
              _CustomInputField(
                  label: 'Road Name / Area / Colony', hint: '5th Avenue, Chelsea', controller: _roadCtrl),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Make this my default address',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Used for all future deliveries.',
                            style: TextStyle(color: theme.colorScheme.secondary, fontSize: 14)),
                      ],
                    ),
                    Switch(
                      value: _isDefaultAddress,
                      activeColor: Colors.white,
                      activeTrackColor: theme.colorScheme.primaryContainer,
                      onChanged: (val) => setState(() => _isDefaultAddress = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(_isSaving ? 'Saving...' : 'Save Address',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const _CustomInputField({
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
            child: Text(label, style: TextStyle(color: theme.colorScheme.secondary, fontSize: 14)),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: theme.colorScheme.outlineVariant),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}