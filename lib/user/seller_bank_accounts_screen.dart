import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import '../core/theme/app_theme.dart';
import '../Database/Database.dart';

/* =========================================================
   MODEL
========================================================= */

class BankAccount {
  String? id;
  String bankName;
  String accountHolder;
  String accountNumber;
  String ifsc;
  String branch;
  String city;
  String state;
  String micr;
  String accountType;
  bool isDefault;

  BankAccount({
    this.id,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.branch,
    required this.city,
    required this.state,
    required this.micr,
    required this.accountType,
    this.isDefault = false,
  });

  factory BankAccount.fromMap(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id']?.toString(),
      bankName: json['bank_name'] ?? '',
      accountHolder: json['account_name'] ?? json['account_holder'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifsc: json['ifsc'] ?? '',
      branch: json['branch_name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      micr: json['MICR_code'] ?? json['micr'] ?? '',
      accountType: json['account_type'] ?? 'Savings',
      isDefault: json['default'] == "1" || json['is_default'] == true,
    );
  }
}

/* =========================================================
   SCREEN
========================================================= */

class SellerBankAccountsScreen extends StatefulWidget {
  const SellerBankAccountsScreen({super.key});

  @override
  State<SellerBankAccountsScreen> createState() =>
      _SellerBankAccountsScreenState();
}

class _SellerBankAccountsScreenState extends State<SellerBankAccountsScreen> {
  final Database _db = Database();
  List<BankAccount> accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  /* =========================================================
     BANKING API METHODS
  ========================================================= */

  Future<List<BankAccount>?> fetchBankAccounts() async {
    try {
      debugPrint(" Fetching bank accounts...");
      
      final response = await _db.getData({
        'action': 'fetch_all',
      });

      debugPrint(" Bank accounts API response: ${response['success']}");
      
      if ((response['success'] == true || response['status'] == 200) && response['data'] != null) {
        debugPrint(" Bank accounts fetched successfully");
        final List data = response['data'];
        return data.map((e) => BankAccount.fromMap(Map<String, dynamic>.from(e))).toList();
      } else {
        debugPrint(" Failed to fetch bank accounts: ${response['message']}");
        return null;
      }
    } catch (e) {
      debugPrint(" Error fetching bank accounts: $e");
      return null;
    }
  }

  Future<bool> addBankAccount({
    required String accountNumber,
    required String accountHolder,
    required String ifsc,
    required String bankName,
    required String branchName,
    required String city,
    required String state,
    String? branchCode,
    String? micr,
    String? accountType,
    bool isApiData = false,
  }) async {
    try {
      debugPrint("🔄 Adding bank account...");
      
      final Map<String, dynamic> requestData = {
        'action': 'add_bank',
        'is_api': isApiData,
        'bank_data': {
          'account_holder': accountHolder,
          'account_number': accountNumber,
          'ifsc': ifsc,
          'bank_name': bankName,
          'branch_name': branchName,
          'branch_code': branchCode ?? '',
          'city': city,
          'state': state,
          'micr': micr ?? '',
          'account_type': accountType ?? 'SAVINGS',
        }
      };

      final response = await _db.getData(requestData);

      debugPrint("📡 Add bank account response: ${response['success']}");
      return response['success'] == true || response['status'] == 200;
    } catch (e) {
      debugPrint("💥 Error adding bank account: $e");
      return false;
    }
  }

  Future<bool> updateBankAccount({
    required String id,
    required String accountNumber,
    required String accountHolder,
    required String ifsc,
    required String bankName,
    required String branchName,
    required String city,
    required String state,
    String? branchCode,
    String? micr,
    String? accountType,
    bool isApiData = false,
  }) async {
    try {
      debugPrint("🔄 Updating bank account...");
      
      final response = await _db.getData({
        'action': 'edit_bank',
        'is_api': isApiData,
        'bank_id': id,
        'bank_data': {
          'account_holder': accountHolder,
          'account_number': accountNumber,
          'ifsc': ifsc,
          'bank_name': bankName,
          'branch_name': branchName,
          'branch_code': branchCode ?? '',
          'city': city,
          'state': state,
          'micr': micr ?? '',
          'account_type': accountType ?? 'SAVINGS',
        }
      });

      debugPrint("📡 Update bank account response: ${response['success']}");
      return response['success'] == true || response['status'] == 200;
    } catch (e) {
      debugPrint("💥 Error updating bank account: $e");
      return false;
    }
  }

  Future<bool> deleteBankAccount(String id) async {
    try {
      debugPrint("🔄 Deleting bank account...");
      
      final response = await _db.getData({
        'action': 'delete_bank',
        'bank_id': id,
      });

      debugPrint("📡 Delete bank account response: ${response['success']}");
      return response['success'] == true || response['status'] == 200;
    } catch (e) {
      debugPrint("💥 Error deleting bank account: $e");
      return false;
    }
  }

  Future<bool> setDefaultBankAccount(String id, bool isDefault) async {
    try {
      debugPrint("🔄 Setting default bank account...");
      
      final response = await _db.getData({
        'action': 'set_default',
        'bank_id': id,
        'status': isDefault ? '1' : '0',
      });

      debugPrint("📡 Set default bank account response: ${response['success']}");
      return response['success'] == true || response['status'] == 200;
    } catch (e) {
      debugPrint("💥 Error setting default bank account: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> lookupIfsc(String ifsc) async {
    try {
      debugPrint("🔄 Looking up IFSC code: $ifsc");
      
      final response = await _db.getData({
        'action': 'ifsc_lookup',
        'ifsc': ifsc,
      });

      debugPrint("📡 IFSC lookup response: ${response['success']}");
      
      if ((response['success'] == true || response['status'] == 200) && response['data'] != null) {
        debugPrint("✅ IFSC data fetched successfully");
        return Map<String, dynamic>.from(response['data']);
      } else {
        debugPrint("❌ Failed to lookup IFSC: ${response['message']}");
        return null;
      }
    } catch (e) {
      debugPrint("💥 Error looking up IFSC: $e");
      return null;
    }
  }

  Future<void> _fetchAccounts() async {
    if (!mounted) return;
    if (accounts.isEmpty) setState(() => isLoading = true);

    try {
      final response = await fetchBankAccounts();

      if (mounted) {
        if (response != null) {
          setState(() {
            accounts = response;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            accounts = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError("Something went wrong: $e");
      }
    }
  }

  /// 🔹 DELETE ACCOUNT
  Future<void> _deleteAccount(String accountId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete this bank account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _showLoader();

    try {
      final response = await _db.getData({
        "module": "bank",
        "submodule": "remove_account",
        "id": accountId,
      });

      if (mounted) Navigator.pop(context); // Close Loader

      if (response['status'] == 200 || response['success'] == true) {
        _showSuccess("Account deleted successfully");
        setState(() {
          accounts.removeWhere((acc) => acc.id == accountId);
        });
        _fetchAccounts();
      } else {
        _showError(response['message'] ?? "Failed to delete account");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError("Error deleting account: $e");
    }
  }

  /// 🔹 CHANGE DEFAULT
  Future<void> _setDefaultAccount(String accountId) async {
    _showLoader();

    try {
      final success = await setDefaultBankAccount(accountId, true);
      
      if (mounted) Navigator.pop(context); // Close Loader

      if (success) {
        _showSuccess("Default account updated!");
        
        setState(() {
          for (var acc in accounts) {
            acc.isDefault = (acc.id == accountId);
          }
        });

        _fetchAccounts();
      } else {
        _showError("Failed to update default account");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError("Error updating default: $e");
    }
  }

  /* =========================================================
     HELPER WIDGETS
  ========================================================= */

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bank Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1B1B),
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xfff5f7fa),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAccounts,
              child: accounts.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...accounts.map(_bankCard).toList(),
                        const SizedBox(height: 16),
                        _buildAddButton(),
                      ],
                    ),
            ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text("Add New Bank Account"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _openAddBankModal(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No bank accounts added yet.",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  /* =========================================================
     BANK CARD
  ========================================================= */

  Widget _bankCard(BankAccount acc) {
    final bool isDefault = acc.isDefault;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: HoverableCard(
        borderRadius: 20.0,
        borderColor: isDefault ? Colors.green : AppTheme.primaryColor,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDefault ? Colors.green : AppTheme.primaryColor.withOpacity(0.3),
                width: 5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance, color: Color(0xff006565), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      acc.bankName.isNotEmpty ? acc.bankName : "Bank Account",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1C1B1B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            "Primary",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'edit') _openAddBankModal(edit: acc);
                      if (val == 'delete') {
                        if (acc.id != null) {
                          _deleteAccount(acc.id!);
                        } else {
                          _showError("Cannot delete account without ID");
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFE6E6F0)),
              _infoRow("Holder Name", acc.accountHolder),
              _infoRow("Account Type", acc.accountType),
              _infoRow("Account No.", acc.accountNumber),
              _infoRow("IFSC Code", acc.ifsc),
              if (acc.branch.isNotEmpty) _infoRow("Branch", acc.branch),
              
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  if (!isDefault && acc.id != null) {
                    _setDefaultAccount(acc.id!);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? Colors.green.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDefault
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDefault ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isDefault ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isDefault
                              ? "Primary Payout Account"
                              : "Set as primary payout account",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDefault ? Colors.green : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1C1B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* =========================================================
     ADD / EDIT MODAL
  ========================================================= */

  void _openAddBankModal({BankAccount? edit}) {
    final accountNumber = TextEditingController(text: edit?.accountNumber);
    final reAccountNumber = TextEditingController(text: edit?.accountNumber);
    final holder = TextEditingController(text: edit?.accountHolder);
    final ifsc = TextEditingController(text: edit?.ifsc);
    final bank = TextEditingController(text: edit?.bankName);
    final branch = TextEditingController(text: edit?.branch);
    final city = TextEditingController(text: edit?.city);
    final state = TextEditingController(text: edit?.state);
    final micr = TextEditingController(text: edit?.micr);
    
    String accountType = edit?.accountType ?? "Savings";
    bool manual = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (c, setM) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(c).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      edit == null ? "Enter Bank Details" : "Edit Bank Details",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1C1B1B))),
                  const SizedBox(height: 16),

                  // Toggle Fetch / Manual
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Fetch using IFSC"),
                        selected: !manual,
                        selectedColor: const Color(0xff006565).withOpacity(0.15),
                        disabledColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: !manual ? const Color(0xff006565) : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setM(() => manual = false),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Enter Manually"),
                        selected: manual,
                        selectedColor: const Color(0xff006565).withOpacity(0.15),
                        disabledColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: manual ? const Color(0xff006565) : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setM(() => manual = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Basic Fields
                  _field("Account Number", accountNumber, isNumber: true),
                  if (edit == null)
                    _field("Re-enter Account Number", reAccountNumber, isNumber: true),
                  _field("Account Holder Name", holder),

                  // Account Type Selection
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Text(
                          "Account Type:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3E4949)),
                        ),
                        const SizedBox(width: 16),
                        Radio<String>(
                            value: "Savings",
                            activeColor: const Color(0xff006565),
                            groupValue: accountType,
                            onChanged: (v) => setM(() => accountType = v!)),
                        const Text("Savings", style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 16),
                        Radio<String>(
                            value: "Current",
                            activeColor: const Color(0xff006565),
                            groupValue: accountType,
                            onChanged: (v) => setM(() => accountType = v!)),
                        const Text("Current", style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),

                  _field("IFSC Code", ifsc),

                  // Fetch Button
                  if (!manual)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text("Fetch Bank Details"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff006565),
                            side: const BorderSide(color: Color(0xff006565)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (ifsc.text.isEmpty) {
                              _showError("Please enter IFSC code");
                              return;
                            }
                            _showLoader();
                            final data = await lookupIfsc(ifsc.text);
                            if (mounted) Navigator.pop(context); // Close loader
                            if (data != null) {
                              setM(() {
                                bank.text = data['bank_name']?.toString() ?? data['bank']?.toString() ?? '';
                                branch.text = data['branch_name']?.toString() ?? data['branch']?.toString() ?? '';
                                city.text = data['city']?.toString() ?? '';
                                state.text = data['state']?.toString() ?? '';
                              });
                            } else {
                              _showError("IFSC lookup failed");
                            }
                          },
                        ),
                      ),
                    ),

                  // Bank Detail Fields
                  if (manual || bank.text.isNotEmpty) ...[
                    _field("Bank Name", bank),
                    _field("Branch Name", branch),
                    _field("City", city),
                    _field("State", state),
                    _field("MICR", micr),
                  ],

                  const SizedBox(height: 16),
                  
                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 45)),
                      onPressed: () async {
                        // 1. Validation
                        if (edit == null &&
                            accountNumber.text != reAccountNumber.text) {
                          _showError("Account numbers do not match");
                          return;
                        }
                        
                        if (ifsc.text.length < 5) {
                          _showError("Please enter valid IFSC");
                          return;
                        }

                        if (holder.text.isEmpty ||
                            accountNumber.text.isEmpty ||
                            ifsc.text.isEmpty) {
                          _showError("Please fill all mandatory fields");
                          return;
                        }

                        // 2. Logic: Add vs Edit
                        if (edit == null) {
                          // ADD - Use new API method
                          _showLoader();
                          
                          final success = await addBankAccount(
                            accountNumber: accountNumber.text,
                            accountHolder: holder.text,
                            ifsc: ifsc.text,
                            bankName: bank.text,
                            branchName: branch.text,
                            city: city.text,
                            state: state.text,
                            micr: micr.text,
                            accountType: accountType,
                            isApiData: false,
                          );
                          
                          if (mounted) Navigator.pop(context); // Close Loader
                          
                          if (success) {
                            _showSuccess("Bank account added successfully!");
                            Navigator.pop(context);
                            _fetchAccounts();
                          } else {
                            _showError("Failed to add bank account");
                          }
                        } else {
                          // EDIT - Use new API method
                          if (edit.id == null) {
                             _showError("Cannot edit account without ID");
                             return;
                          }
                          _showLoader();
                          
                          final success = await updateBankAccount(
                            id: edit.id!,
                            accountNumber: accountNumber.text,
                            accountHolder: holder.text,
                            ifsc: ifsc.text,
                            bankName: bank.text,
                            branchName: branch.text,
                            city: city.text,
                            state: state.text,
                            micr: micr.text,
                            accountType: accountType,
                            isApiData: false,
                          );
                          
                          if (mounted) Navigator.pop(context); // Close Loader
                          
                          if (success) {
                            _showSuccess("Bank account updated successfully!");
                            Navigator.pop(context);
                            _fetchAccounts();
                          } else {
                            _showError("Failed to update bank account");
                          }
                        }
                      },
                      child: const Text("Save Bank Account", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _field(String label, TextEditingController c, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF3E4949), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffE6E6F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}