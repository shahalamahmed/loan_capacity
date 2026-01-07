import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/form_field_item.dart';

class DynamicForm extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<String> predefinedFields;
  final VoidCallback onSave;
  final Function(Map<String, double>) onDataCollected;
  final bool isLoading;

  const DynamicForm({
    Key? key,
    required this.title,
    required this.color,
    required this.icon,
    required this.predefinedFields,
    required this.onSave,
    required this.onDataCollected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final List<FormFieldItem> _fields = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializePredefinedFields();
  }

  void _initializePredefinedFields() {
    for (var field in widget.predefinedFields) {
      _fields.add(
        FormFieldItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + field,
          label: field,
          controller: TextEditingController(),
          isPredefined: true,
        ),
      );
    }
  }

  void _addNewField() {
    setState(() {
      _fields.add(
        FormFieldItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: '',
          controller: TextEditingController(),
          isPredefined: false,
        ),
      );
    });

    // Scroll to bottom after adding
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeField(String id) {
    setState(() {
      final index = _fields.indexWhere((f) => f.id == id);
      if (index != -1) {
        _fields[index].controller.dispose();
        _fields.removeAt(index);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var field in _fields) {
      final value = double.tryParse(field.controller.text) ?? 0;
      total += value;
    }
    return total;
  }

  Map<String, double> _collectData() {
    Map<String, double> data = {};
    for (var field in _fields) {
      final amount = double.tryParse(field.controller.text) ?? 0;
      if (amount > 0) {
        final label = field.isPredefined
            ? field.label
            : (field.label.isEmpty ? 'অন্যান্য' : field.label);
        data[label] = amount;
      }
    }
    return data;
  }

  void _handleSave() {
    final data = _collectData();
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অন্তত একটি ফিল্ড পূরণ করুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    widget.onDataCollected(data);
    widget.onSave();
  }

  @override
  void dispose() {
    for (var field in _fields) {
      field.controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [widget.color.withOpacity(0.1), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  Icon(widget.icon, color: widget.color, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fields List
                    ..._fields.asMap().entries.map((entry) {
                      final index = entry.key;
                      final field = entry.value;
                      return _buildFieldRow(field, index);
                    }),

                    const SizedBox(height: 20),

                    // Add Button
                    InkWell(
                      onTap: _addNewField,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.color.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle, color: widget.color),
                            const SizedBox(width: 10),
                            Text(
                              'নতুন ফিল্ড যোগ করুন',
                              style: TextStyle(
                                color: widget.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Total Display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.color, widget.color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'মোট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _getTotalNotifier(),
                            builder: (context, value, child) {
                              return Text(
                                '৳${_formatNumber(_calculateTotal())}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Save Button (Fixed at bottom)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: widget.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'সংরক্ষণ করুন',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(FormFieldItem field, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  field.isPredefined ? field.label : 'কাস্টম ফিল্ড',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (!field.isPredefined)
                IconButton(
                  onPressed: () => _removeField(field.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom field label input
          if (!field.isPredefined) ...[
            TextField(
              onChanged: (value) {
                field.label = value;
              },
              decoration: InputDecoration(
                labelText: 'বিবরণ',
                hintText: 'যেমন: অন্যান্য আয়',
                prefixIcon: const Icon(Icons.description, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Amount input
          TextField(
            controller: field.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'টাকার পরিমাণ',
              hintText: '0',
              prefixIcon: const Icon(Icons.currency_exchange, size: 20),
              prefixText: '৳ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  ValueNotifier<int> _getTotalNotifier() {
    // Create a notifier that updates when any field changes
    final notifier = ValueNotifier<int>(0);
    for (var field in _fields) {
      field.controller.addListener(() {
        notifier.value++;
      });
    }
    return notifier;
  }

  String _formatNumber(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} কোটি';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)} লক্ষ';
    } else if (number >= 1000) {
      return number
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return number.toStringAsFixed(0);
  }
}
