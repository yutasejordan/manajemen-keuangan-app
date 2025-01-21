import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Tambahkan import intl
import '../services/firestore_service.dart';

class ReportPage extends StatelessWidget {
  ReportPage({Key? key}) : super(key: key);

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  Future<Map<String, dynamic>> _fetchReportData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Ambil semua transaksi pengguna dari Firestore
    final transactions = await FirestoreService.getTransactions(userId).first;

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var transaction in transactions) {
      if (transaction.category == 'Pemasukan') {
        totalIncome += transaction.amount;
      } else if (transaction.category == 'Pengeluaran') {
        totalExpense += transaction.amount;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final reportData = snapshot.data!;
          final totalIncome = reportData['totalIncome'];
          final totalExpense = reportData['totalExpense'];
          final balance = reportData['balance'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ringkasan Keuangan',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Total Pemasukan',
                  amount: totalIncome,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Total Pengeluaran',
                  amount: totalExpense,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Saldo Akhir',
                  amount: balance,
                  color: balance >= 0 ? Colors.blue : Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: color),
        ),
        trailing: Text(
          currencyFormatter
              .format(amount), // Gunakan formatter untuk format Rupiah
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
