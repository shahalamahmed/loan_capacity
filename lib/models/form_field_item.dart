import 'package:flutter/material.dart';

class FormFieldItem {
  final String id;
  String label;
  final TextEditingController controller;
  final bool isPredefined;

  FormFieldItem({
    required this.id,
    required this.label,
    required this.controller,
    this.isPredefined = false,
  });
}
