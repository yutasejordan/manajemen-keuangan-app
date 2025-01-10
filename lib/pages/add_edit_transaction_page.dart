import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditTransactionPage extends StatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionPage({Key? key, this.transaction}) : super(key: key);

  @override
  _AddEditTransactionPageState createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Pemasukan'; // Default kategori
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Isi data jika mode edit
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final transactionId = widget.transaction?.id ?? Uuid().v4();
    final transaction = TransactionModel(
      id: transactionId,
      userId: userId,
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      date: _selectedDate,
    );

    try {
      if (widget.transaction == null) {
        await FirestoreService.addTransaction(transaction);
      } else {
        await FirestoreService.updateTransaction(transaction);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deskripsi Transaksi
                _buildLabel('Deskripsi'),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Masukkan deskripsi transaksi'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Jumlah Transaksi
                _buildLabel('Jumlah (Rp)'),
                TextFormField(
                  controller: _amountController,
                  decoration: _inputDecoration('Masukkan jumlah transaksi'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Kategori
                _buildLabel('Kategori'),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ['Pemasukan', 'Pengeluaran'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  decoration: _inputDecoration(null),
                ),
                SizedBox(height: 16),

                // Tanggal
                _buildLabel('Tanggal'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Tanggal: ${_selectedDate.toLocal()}'.split(' ')[0],
                  ),
                  trailing:
                      Icon(Icons.calendar_today, color: Colors.blueGrey[800]),
                  onTap: _pickDate,
                ),
                SizedBox(height: 24),

                // Tombol Simpan
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      backgroundColor: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                    label: Text(
                      widget.transaction == null ? 'Tambah' : 'Simpan',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
