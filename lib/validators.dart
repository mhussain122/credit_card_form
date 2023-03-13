import 'package:credit_card_form/credit_card_form.dart';
import 'package:credit_card_form/utils.dart';
import 'package:flutter/material.dart';

String? cvvValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'CVC is Required';
  }
  final regex = RegExp(r'^[0-9]{3}$');
  if (!regex.hasMatch(value)) {
    return 'Invalid CVV';
  }
  return null;
}

String? emptyValidator(String? value, String? label) {
  if (value == null || value.trim() == '') {
    return '${label ?? 'Field'} is Required';
  }
  return null;
}

String? cardNumberValidator(String? value) {
  if (value == null || value.isEmpty || value == '') {
    return 'Card Number is Required';
  }
  if (CardUtils.getCardTypeFrmNumber(value) == CardType.invalid ||
      CardUtils.getCardTypeFrmNumber(value) == CardType.others) {
    return 'Only VISA and MASTERCARD cards are allowed';
  }
  String cleanedValue = value.replaceAll(' ', '');
  if (cleanedValue.length < 16) {
    return '16 Digits Card Number Required';
  }
  if (!_validateCardNumberWithLuhnAlgorithm(cleanedValue)) {
    return 'Invalid Card Number';
  }
  return null;
}

bool _validateCardNumberWithLuhnAlgorithm(String input) {
  int sum = 0;
  for (int i = 0; i < input.length; i++) {
    int digit = int.parse(input[input.length - i - 1]);
    if (i % 2 == 1) {
      digit *= 2;
    }
    sum += digit > 9 ? (digit - 9) : digit;
  }
  if (sum % 10 == 0) {
    return true;
  }
  return false;
}

String? cardExpiryDateValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Expiry Date is Required';
  }
  final regex = RegExp(r'^\d{2}/\d{2}$');
  if (!regex.hasMatch(value)) {
    return 'Invalid format (MM/YY)';
  }
  final parts = value.split('/');
  final month = int.tryParse(parts[0]) ?? 0;
  final year = int.tryParse(parts[1]) ?? 0;
  if (month < 1 || month > 12) {
    return 'Invalid month in expiry date';
  }
  final currentYear = DateTime.now().year;
  final currentMonth = DateTime.now().month;
  final cardYear = 2000 + year;
  if (cardYear < currentYear ||
      (cardYear == currentYear && month < currentMonth)) {
    return 'Card has expired';
  }
  return null;
}
