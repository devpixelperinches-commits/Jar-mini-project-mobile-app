import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/features/stripe/controller/transactions_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/type/date_picker_modal.dart';
import 'package:jarpay/widgets/type/filter_button.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  String? startDate; // stored as ISO string
  String? endDate; // stored as ISO string
  bool isLoading = true;

  // Pagination state
  int page = 1;
  final int limit = 10;
  bool hasMore = true;
  bool isPaginating = false;

  List<dynamic> transactionsList = [];
  final ScrollController _scrollController = ScrollController();

  // currency formatter (reuse)
  final formatter = NumberFormat.currency(symbol: "₹");

  @override
  void initState() {
    super.initState();

    // initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions(reset: true);
    });

    // load more when near bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isPaginating &&
          hasMore &&
          !isLoading) {
        _fetchTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions({bool reset = false}) async {
    if (reset) {
      page = 1;
      hasMore = true;
      transactionsList.clear();
      setState(() => isLoading = true);
    } else {
      setState(() => isPaginating = true);
    }

    debugPrint('🔵 Screen: Fetching transactions (page: $page)');

    final transactionsController = ref.read(transactionsControllerProvider);

    // ✅ NO TRY-CATCH! Let the interceptor handle token refresh!
    final res = await transactionsController.fetchTransactions(
      startDate: startDate ?? "",
      endDate: endDate ?? "",
      page: page,
      limit: limit,
    );

    debugPrint('✅ Screen: Got response: $res');

    final List<dynamic> newData = res['data']['transactions'] ?? [];

    if (newData.isEmpty) {
      hasMore = false;
    } else {
      page++;
      transactionsList.addAll(newData);
    }

    setState(() {
      isLoading = false;
      isPaginating = false;
    });
  }

  // 🔹 Filters options
  List<Map<String, dynamic>> paymentTypeOptions = [
    {"name": "Card Reader", "checked": false},
    {"name": "Pay by Bank", "checked": false},
  ];

  // 🔹 Date pickers (convert between String? and DateTime?)
  void _openStartDatePicker() async {
    final DateTime? initial = startDate != null
        ? DateTime.tryParse(startDate!)
        : null;

    final picked = await DatePickerModal.show(context, initial);

    if (picked != null) {
      setState(() {
        startDate = picked.toIso8601String();
      });
      // refetch with reset
      _fetchTransactions(reset: true);
    }
  }

  void _openEndDatePicker() async {
    final DateTime? initial = endDate != null
        ? DateTime.tryParse(endDate!)
        : null;

    final picked = await DatePickerModal.show(context, initial);

    if (picked != null) {
      setState(() {
        endDate = picked.toIso8601String();
      });
      // refetch with reset
      _fetchTransactions(reset: true);
    }
  }

  // 🔹 Helper: format incoming created_at (String or DateTime)
  String formatDate(dynamic date) {
    try {
      final DateTime parsedDate = date is String
          ? DateTime.parse(date)
          : (date as DateTime);
      return DateFormat('d MMMM yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  // Display-friendly selected date for filters
  String? _displaySelectedDate(String? isoString) {
    if (isoString == null) return null;
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('d MMM yyyy').format(dt);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomHeader(title: "Transaction"),
            const SizedBox(height: 10),

            // 🔹 Filters Row (horizontal)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterButton(
                    title: _displaySelectedDate(startDate) ?? "Start Date",
                    onTap: _openStartDatePicker,
                  ),
                  FilterButton(
                    title: _displaySelectedDate(endDate) ?? "End Date",
                    onTap: _openEndDatePicker,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Transactions List with pagination
            Expanded(
              child: isLoading && transactionsList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : transactionsList.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _fetchTransactions(reset: true);
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            transactionsList.length + (isPaginating ? 1 : 0),
                        itemBuilder: (context, index) {
                          // bottom loader
                          if (index == transactionsList.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = transactionsList[index];
                          final formattedDate = formatDate(item["createdAt"]);

                          Color statusColor;
                          Color textColor;
                          String statusText;

                          switch (item["status"]) {
                            case "PAYMENT_STATUS_EXECUTED":
                            case "succeeded":
                              statusColor = Colors.green.shade100;
                              textColor = Colors.green.shade800;
                              statusText = "Successful";
                              break;
                            case "PAYMENT_STATUS_FAILED":
                              statusColor = Colors.red.shade100;
                              textColor = Colors.red.shade800;
                              statusText = "Failed";
                              break;
                            default:
                              statusColor = Colors.orange.shade100;
                              textColor = Colors.orange.shade800;
                              statusText = "Pending";
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // left
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Description - ${item["description"]}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6C22A6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // right
                                Row(
                                  children: [
                                    Text(
                                      item["amount"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SvgPicture.asset(
                                      AppImages.forward,
                                      height: 14,
                                      width: 14,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 120, color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          "No Transactions Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6C22A6),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your recent transactions will appear here.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );
}
