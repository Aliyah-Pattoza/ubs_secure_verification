import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../controllers/transaction_controller.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, pending, high_value
  bool _isTableView = false; // Toggle antara Card dan Table view

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> transactions) {
    var filtered = transactions.where((t) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesDoc = t.documentNumber.toLowerCase().contains(query);
        final matchesRequester = t.requesterName?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesDoc && !matchesRequester) {
          return false;
        }
      }

      // Status filter
      if (_selectedFilter == 'pending' && t.status != 'pending') {
        return false;
      }
      if (_selectedFilter == 'high_value' && t.amount < 100000000) {
        return false;
      }

      return true;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(TransactionController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(controller),

            // Search & Filter Bar
            _buildSearchAndFilter(controller),

            // Stats Cards
            _buildStatsCards(controller),

            // View Toggle & Title
            _buildViewToggle(controller),

            // Transaction List/Table
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoading();
                }
                if (controller.errorMessage.value != null) {
                  return _buildError(controller);
                }

                final filteredTransactions = _getFilteredTransactions(controller.transactions);

                if (filteredTransactions.isEmpty) {
                  return _buildEmpty();
                }

                if (_isTableView) {
                  return _buildDataTable(controller, filteredTransactions);
                } else {
                  return _buildTransactionList(controller, filteredTransactions);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TransactionController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo UBS Gold - DIGANTI dengan image asset
          Image.asset(
            'assets/images/logo_full.png',
            height: 45,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted.withOpacity(0.8),
                  ),
                ),
                Text(
                  controller.user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Notification Badge
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Get.snackbar(
                    'Notifications',
                    'You have ${controller.transactions.length} pending transactions',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
              ),
              Obx(() => controller.transactions.isNotEmpty
                  ? Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${controller.transactions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  : const SizedBox()),
            ],
          ),

          // Logout - DIGANTI dengan showDialog agar cancel berfungsi
          IconButton(
            onPressed: () => _showLogoutDialog(controller),
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(TransactionController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted.withOpacity(0.6),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.clear, size: 20),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                icon: const Icon(Icons.filter_list_rounded, size: 20),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'high_value', child: Text('High Value')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(TransactionController controller) {
    return Obx(() {
      final transactions = controller.transactions;
      final totalAmount = transactions.fold<double>(0, (sum, t) => sum + t.amount);
      final highValueCount = transactions.where((t) => t.amount >= 100000000).length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.primary,
                title: 'Total',
                value: '${transactions.length}',
                subtitle: 'transactions',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.gold,
                title: 'Value',
                value: _formatCompactCurrency(totalAmount),
                subtitle: 'total amount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.error,
                title: 'High Value',
                value: '$highValueCount',
                subtitle: '≥ 100M',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(TransactionController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pending Approval',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: controller.loadTransactions,
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.gold,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.view_agenda_rounded,
                      isSelected: !_isTableView,
                      onTap: () => setState(() => _isTableView = false),
                    ),
                    _buildViewToggleButton(
                      icon: Icons.table_chart_rounded,
                      isSelected: _isTableView,
                      onTap: () => setState(() => _isTableView = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.gold : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.gold, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Loading transactions...',
            style: TextStyle(color: AppColors.textMuted.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(TransactionController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to load transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              controller.errorMessage.value ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: controller.loadTransactions,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inbox_rounded,
              size: 55,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty ? 'No results found' : 'No pending transactions',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? 'Try different keywords' : 'All transactions have been processed',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(TransactionController controller, List<TransactionModel> transactions) {
    return RefreshIndicator(
      onRefresh: controller.refreshTransactions,
      color: AppColors.gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.05)),
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
              dataTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              columnSpacing: 24,
              horizontalMargin: 20,
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Document No')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Amount'), numeric: true),
                DataColumn(label: Text('Requester')),
                DataColumn(label: Text('Department')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: transactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (index.isEven) return AppColors.backgroundLight.withOpacity(0.5);
                    return null;
                  }),
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(transaction.documentNumber, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
                    DataCell(SizedBox(width: 150, child: Text(transaction.title, overflow: TextOverflow.ellipsis))),
                    DataCell(Text(
                      transaction.formattedAmount,
                      style: TextStyle(fontWeight: FontWeight.w600, color: transaction.amount >= 100000000 ? AppColors.error : AppColors.goldDark),
                    )),
                    DataCell(Text(transaction.requesterName ?? '-')),
                    DataCell(
                      transaction.department != null
                          ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(transaction.department!, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                      )
                          : const Text('-'),
                    ),
                    DataCell(Text(transaction.formattedDate)),
                    DataCell(_buildTableActions(controller, transaction)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableActions(TransactionController controller, TransactionModel transaction) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showApprovalDialog(controller, transaction, 'accept'),
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
          tooltip: 'Accept',
          iconSize: 24,
        ),
        IconButton(
          onPressed: () => _showApprovalDialog(controller, transaction, 'reject'),
          icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
          tooltip: 'Reject',
          iconSize: 24,
        ),
        IconButton(
          onPressed: () => _showTransactionDetail(transaction, controller),
          icon: Icon(Icons.info_outline_rounded, color: AppColors.primary.withOpacity(0.7)),
          tooltip: 'Details',
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionController controller, List<TransactionModel> transactions) {
    return RefreshIndicator(
      onRefresh: controller.refreshTransactions,
      color: AppColors.gold,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(controller, transactions[index], index + 1);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionController controller, TransactionModel transaction, int number) {
    final isHighValue = transaction.amount >= 100000000;

    return GestureDetector(
      onTap: () => _showTransactionDetail(transaction, controller),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isHighValue ? Border.all(color: AppColors.error.withOpacity(0.3), width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            if (isHighValue)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.error),
                    SizedBox(width: 6),
                    Text('HIGH VALUE TRANSACTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error, letterSpacing: 0.5)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('#$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transaction.documentNumber, style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.9), fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(transaction.formattedDate, style: TextStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.7))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(transaction.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(transaction.formattedAmount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isHighValue ? AppColors.error : AppColors.goldDark)),
                  if (transaction.requesterName != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(transaction.requesterName![0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.requesterName!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                                if (transaction.department != null)
                                  Text(transaction.department!, style: TextStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.8))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showApprovalDialog(controller, transaction, 'accept'),
                            icon: const Icon(Icons.check_rounded, size: 20),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showApprovalDialog(controller, transaction, 'reject'),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(TransactionModel transaction, TransactionController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: AppColors.gold, size: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Transaction Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              Text(transaction.documentNumber, style: TextStyle(fontSize: 13, color: AppColors.textMuted.withOpacity(0.8))),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow('Title', transaction.title),
                    _buildDetailRow('Amount', transaction.formattedAmount, isAmount: true),
                    _buildDetailRow('Requester', transaction.requesterName ?? '-'),
                    _buildDetailRow('Department', transaction.department ?? '-'),
                    _buildDetailRow('Created Date', transaction.formattedDate),
                    _buildDetailRow('Status', transaction.status.toUpperCase(), statusColor: AppColors.warning),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back();
                                _showApprovalDialog(controller, transaction, 'accept');
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Accept'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back();
                                _showApprovalDialog(controller, transaction, 'reject');
                              },
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted.withOpacity(0.8)))),
          Expanded(
            child: statusColor != null
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusColor)),
            )
                : Text(value, style: TextStyle(fontSize: isAmount ? 18 : 14, fontWeight: isAmount ? FontWeight.bold : FontWeight.w500, color: isAmount ? AppColors.goldDark : AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000000) return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(0)}M';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  // ================================
  // DIALOG METHODS - CANCEL BUTTON FIXED
  // ================================

  void _showApprovalDialog(TransactionController controller, TransactionModel transaction, String action) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            action == 'accept' ? 'Accept Transaction?' : 'Reject Transaction?',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(transaction.formattedAmount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: action == 'accept' ? AppColors.success : AppColors.error)),
              const SizedBox(height: 12),
              const Text('You will need to verify with Face Recognition', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Get.toNamed(AppRoutes.faceRecognition, arguments: {'user': controller.user, 'token': controller.token, 'transaction': transaction, 'action': action});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'accept' ? AppColors.success : AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(action == 'accept' ? 'Accept' : 'Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(TransactionController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Logout', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Get.offAllNamed(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}