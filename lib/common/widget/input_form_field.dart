
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputFormField extends StatelessWidget {
  const InputFormField({
    super.key,
    required this.labelText, required this.Controller, this.onSaved,
  });
  final String labelText;
  final TextEditingController Controller;
  final FormFieldValidator<String>? onSaved;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: Controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: onSaved,
    );
  }
}

