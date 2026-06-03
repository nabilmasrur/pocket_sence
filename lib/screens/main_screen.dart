import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import 'loans_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 0;

  static const _panel = Color(0xFF08110E);
  static const _gold = Color(0xFFFFD21F);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: Stack(
            children: [
              _AuroraBackground(light: AppColors.isLight(context)),
              IndexedStack(
                index: _activeTab,
                children: const [
                  _HomeDashboard(),
                  StatsScreen(),
                  LoansScreen(),
                  SettingsScreen(),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _bottomNav(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomNav(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.nav(context),
            border: Border(
              top: BorderSide(color: AppColors.border(context)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.pie_chart_rounded, 'Stats', 1),
              _fab(context),
              _navItem(Icons.account_balance_wallet_rounded, 'Loans', 2),
              _navItem(Icons.settings_rounded, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _activeTab == index;
    final accent = AppColors.accent(context);
    final muted = AppColors.isLight(context)
        ? const Color(0xFF64748B)
        : Colors.white54;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTab = index);
      },
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 58,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? accent : muted),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? accent : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: GestureDetector(
        onTap: () => _showExpenseSheet(context),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent(context),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent(context).withValues(alpha: 0.34),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 34),
        ),
      ),
    );
  }

  static Future<void> _showExpenseSheet(
    BuildContext context, {
    Expense? expense,
  }) async {
    final provider = context.read<ExpenseProvider>();
    final title = TextEditingController(text: expense?.title ?? '');
    final amount = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(0),
    );
    final newCategory = TextEditingController();
    var category = expense?.category ?? provider.budgetCategories.first;
    var date = expense?.date ?? DateTime.now();
    XFile? voucherImage;
    var voucherUrl = expense?.voucherUrl;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              decoration: const BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    expense == null ? 'Add Expense' : 'Edit Expense',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetField(title, 'Title', Icons.edit_note_rounded),
                  const SizedBox(height: 12),
                  _sheetField(
                    amount,
                    'Amount',
                    Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.budgetCategories.map((item) {
                      final active = category == item;
                      return ChoiceChip(
                        label: Text(item),
                        selected: active,
                        selectedColor: _gold,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        labelStyle: TextStyle(
                          color: active ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        side: BorderSide(
                          color: active
                              ? _gold
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                        onSelected: (_) => setSheetState(() => category = item),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _sheetField(
                          newCategory,
                          'New category',
                          Icons.category_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: () async {
                          await provider.addCategory(newCategory.text);
                          if (newCategory.text.trim().isNotEmpty) {
                            setSheetState(() {
                              category = newCategory.text.trim();
                              newCategory.clear();
                            });
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today_rounded,
                      color: _gold,
                    ),
                    title: Text(
                      DateFormat('EEE, MMM d, yyyy').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        initialDate: date,
                      );
                      if (picked != null) setSheetState(() => date = picked);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.image_rounded, color: _gold),
                    title: Text(
                      voucherImage != null || voucherUrl != null
                          ? 'Voucher attached'
                          : 'Attach voucher / receipt',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      voucherImage != null
                          ? voucherImage!.name
                          : voucherUrl ?? 'Optional image upload',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 82,
                      );
                      if (picked != null) {
                        setSheetState(() {
                          voucherImage = picked;
                          voucherUrl = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final parsed = double.tryParse(amount.text.trim());
                        if (title.text.trim().isEmpty || parsed == null) {
                          return;
                        }
                        if (expense == null) {
                          await provider.addExpense(
                            title.text.trim(),
                            parsed,
                            category,
                            date: date,
                            voucherImage: voucherImage,
                          );
                        } else {
                          await provider.updateExpense(
                            expense.id,
                            title.text.trim(),
                            parsed,
                            category,
                            voucherImage: voucherImage,
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _sheetField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _gold),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  static const _panel = Color(0xFF08110E);
  static const _gold = Color(0xFFFFD21F);
  static const _mint = Color(0xFF35E6A8);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final todaySpent = provider.todaySpent;
    final limit = provider.dynamicDailyLimit;
    final progress = limit <= 0 ? 0.0 : (todaySpent / limit).clamp(0.0, 1.0);

    String? warningMsg;
    if (provider.thisMonthSpent > provider.monthlyBudget) {
      warningMsg = 'Monthly budget limit exceeded!';
    } else if (provider.thisWeekSpent > provider.weeklyBudget) {
      warningMsg = 'Weekly budget limit exceeded!';
    } else if (todaySpent > limit) {
      warningMsg = 'Daily budget limit exceeded!';
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 112),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, provider.isCloudConnected),
            const SizedBox(height: 24),
            if (warningMsg != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        warningMsg,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            _summaryCard(context, provider, progress),
            const SizedBox(height: 18),
            _smallCards(context, provider),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Expenses",
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${provider.expensesOn(DateTime.now()).length} items',
                  style: TextStyle(color: AppColors.muted(context)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _expenseList(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool cloud) {
    return FutureBuilder<AppUserProfile>(
      future: AuthService().currentProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.name.trim().isNotEmpty == true
            ? profile!.name
            : 'Pocket Sense User';
        final initial = name.characters.first.toUpperCase();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Hello, $name',
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.waving_hand_rounded, color: _gold),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: TextStyle(color: AppColors.muted(context)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: _gold,
                backgroundImage: profile?.photoUrl == null
                    ? null
                    : NetworkImage(profile!.photoUrl!),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (profile?.photoUrl == null)
                      Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: cloud ? _mint : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF08110E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_rounded, color: _gold),
              title: const Text(
                'Profile Details',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showProfileDetails(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF08110E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => FutureBuilder<AppUserProfile>(
        future: AuthService().currentProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      onPressed: profile == null
                          ? null
                          : () => _showEditProfileSheet(context, profile),
                      icon: const Icon(Icons.edit_rounded, color: _gold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _profileRow('Name', profile?.name ?? ''),
                _profileRow('Email', profile?.email ?? ''),
                _profileRow('Phone Number', profile?.phoneNumber ?? ''),

                _profileRow(
                  'Account creation date',
                  profile == null
                      ? ''
                      : DateFormat('MMM d, yyyy').format(profile.createdAt),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPasswordSheet(context),
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('Password'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 82,
                          );
                          if (picked == null) return;
                          final upload = await CloudinaryService().uploadImage(
                            picked,
                            folder: 'pocket_sense/profiles',
                          );
                          if (!context.mounted) return;
                          if (upload == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo upload failed.'),
                              ),
                            );
                            return;
                          }
                          await AuthService().updateProfilePhoto(upload.secureUrl);
                          if (!context.mounted) return;
                          await context.read<ExpenseProvider>().reconnectCloudSync();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile photo updated.')),
                          );
                        },
                        icon: const Icon(Icons.photo_camera_rounded),
                        label: const Text('Photo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, AppUserProfile profile) {
    final name = TextEditingController(text: profile.name);
    final email = TextEditingController(text: profile.email);
    final phone = TextEditingController(text: profile.phoneNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08110E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _profileField(name, 'Name', Icons.person_rounded),
            const SizedBox(height: 10),
            _profileField(
              email,
              'Email',
              Icons.mail_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _profileField(
              phone,
              'Phone Number',
              Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await AuthService().updateProfile(
                    name: name.text,
                    email: email.text,
                    phoneNumber: phone.text,
                  );
                  if (!context.mounted) return;
                  await context.read<ExpenseProvider>().reconnectCloudSync();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated.')),
                  );
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _gold),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showPasswordSheet(BuildContext context) {
    final controller = TextEditingController();
    final auth = AuthService();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08110E),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _profileField(
              controller,
              'New password',
              Icons.lock_rounded,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final ok = await auth.changePassword(controller.text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Password changed'
                            : 'Login recently and try again.',
                      ),
                    ),
                  );
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? 'Not added' : value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    ExpenseProvider provider,
    double progress,
  ) {
    final isLight = AppColors.isLight(context);
    final left = (provider.dynamicDailyLimit - provider.todaySpent).clamp(
      0.0,
      provider.dynamicDailyLimit,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isLight ? null : AppColors.card(context),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLight
                  ? [
                      const Color(0xFFEEF6FF),
                      Colors.white,
                      const Color(0xFFFFF8D9),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.12),
                      _panel.withValues(alpha: 0.88),
                    ],
            ),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? const Color(0xFF2563EB).withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pill(
                    context,
                    'Daily limit',
                    'BDT ${provider.dynamicDailyLimit.toStringAsFixed(0)}',
                  ),
                  _pill(context, 'Left', 'BDT ${left.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spent today',
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          child: Text(
                            'BDT ${NumberFormat('#,##0').format(provider.todaySpent)}',
                            style: TextStyle(
                              color: AppColors.accent(context),
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor: isLight
                              ? const Color(0xFFDCEAFF)
                              : Colors.white12,
                          color: AppColors.accent(context),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: Colors.white12,
                  color: AppColors.accent(context),
                ),
              ),
              const SizedBox(height: 14),
              if (provider.smartTip.isNotEmpty)
                Text(
                  provider.smartTip,
                  style: TextStyle(color: AppColors.muted(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSoft(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.muted(context))),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallCards(BuildContext context, ExpenseProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _mini(
          context,
          'This month expense',
          'BDT ${provider.thisMonthSpent.toStringAsFixed(0)}',
          Icons.calendar_month_rounded,
          const Color(0xFF54A3FF),
        ),
        _mini(
          context,
          'Monthly budget',
          'BDT ${provider.monthlyBudget.toStringAsFixed(0)}',
          Icons.account_balance_wallet_rounded,
          const Color(0xFFB777FF),
        ),
      ],
    );
  }

  Widget _mini(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: AppColors.isLight(context)
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const Spacer(),
          Text(label, style: TextStyle(color: AppColors.muted(context))),
          const SizedBox(height: 3),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseList(BuildContext context, ExpenseProvider provider) {
    final today = provider.expensesOn(DateTime.now());
    if (today.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.cardSoft(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: AppColors.muted(context),
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses today',
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add a record',
              style: TextStyle(color: AppColors.muted(context)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: today.map((expense) {
        final color = _categoryColor(expense.category);
        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          ),
          onDismissed: (_) => provider.deleteExpense(expense.id),
          child: InkWell(
            onTap: () => _MainScreenState._showExpenseSheet(context, expense: expense),
            onLongPress: () {
              HapticFeedback.heavyImpact();
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.panel,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                        title: const Text('Edit', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          _MainScreenState._showExpenseSheet(context, expense: expense);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                        title: const Text('Delete', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          provider.deleteExpense(expense.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_categoryIcon(expense.category), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${expense.category} - ${DateFormat('h:mm a').format(expense.date)}',
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-BDT ${expense.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.text(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (expense.voucherUrl != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showVoucher(context, expense),
                          icon: const Icon(
                            Icons.image_rounded,
                            color: _gold,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showVoucher(BuildContext context, Expense expense) {
    final url = expense.voucherUrl;
    if (url == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(18),
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_bus_filled_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Health':
        return Icons.local_hospital_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food & Drink':
        return const Color(0xFFFF8A3D);
      case 'Transport':
        return const Color(0xFF54A3FF);
      case 'Shopping':
        return _mint;
      case 'Bills':
        return const Color(0xFFB777FF);
      case 'Education':
        return const Color(0xFFFFD21F);
      case 'Health':
        return const Color(0xFFFF5C7A);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class _AuroraBackground extends StatelessWidget {
  final bool light;

  const _AuroraBackground({this.light = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: light ? Colors.white : const Color(0xFF020403)),
        Positioned(
          top: -140,
          right: -120,
          child: _glow(const Color(0xFFFFD21F), 290, 0.16),
        ),
        Positioned(
          top: 150,
          left: -150,
          child: _glow(const Color(0xFF35E6A8), 340, 0.11),
        ),
      ],
    );
  }

  Widget _glow(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: 120,
            spreadRadius: 55,
          ),
        ],
      ),
    );
  }
}
