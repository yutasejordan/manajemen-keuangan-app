import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_keuangan_app/pages/login_page.dart';
import 'package:manajemen_keuangan_app/pages/report_page.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import 'add_edit_transaction_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Stream<List<TransactionModel>>? transactionStream;
  double totalIncome = 0;
  double totalExpense = 0;
  final NumberFormat currencyFormatter = NumberFormat("#,##0", "id_ID");

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      transactionStream = FirestoreService.getTransactions(userId);
    }
  }

  void _calculateTotals(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      if (transaction.category == 'Pemasukan') {
        income += transaction.amount;
      } else if (transaction.category == 'Pengeluaran') {
        expense += transaction.amount;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          totalIncome = income;
          totalExpense = expense;
        });
      }
    });
  }

  void _addTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditTransactionPage()),
    );
  }

  void _editTransaction(TransactionModel transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionPage(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await FirestoreService.deleteTransaction(transactionId);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      setState(() {
        transactionStream = null; // Hentikan Stream sebelum logout
      });
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Gagal: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: transactionStream == null
          ? const Center(child: Text('Silakan login untuk melihat data.'))
          : StreamBuilder<List<TransactionModel>>(
              stream: transactionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi.'));
                }

                final transactions = snapshot.data!;
                _calculateTotals(transactions);

                return Column(
                  children: [
                    _buildBalanceCard(totalBalance),
                    const SizedBox(height: 20),
                    _buildSummarySection(),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Transaksi Terbaru',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final formattedDate = DateFormat('dd MMM yyyy')
                              .format(transaction.date);

                          return Column(
                            children: [
                              ListTile(
                                onTap: () => _editTransaction(transaction),
                                leading: Icon(
                                  transaction.category == 'Pemasukan'
                                      ? Icons.arrow_circle_up
                                      : Icons.arrow_circle_down,
                                  color: transaction.category == 'Pemasukan'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(transaction.description),
                                subtitle: Text(formattedDate),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteTransaction(transaction.id),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[800],
        onPressed: _addTransaction,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double totalBalance) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: totalBalance >= 0
              ? [Colors.green, Colors.greenAccent]
              : [Colors.red, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Anda',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'Rp ${currencyFormatter.format(totalBalance)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryCard(
            title: 'Pemasukan',
            amount: totalIncome,
            icon: Icons.arrow_upward,
            color: Colors.green,
          ),
          _buildSummaryCard(
            title: 'Pengeluaran',
            amount: totalExpense,
            icon: Icons.arrow_downward,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${currencyFormatter.format(amount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
