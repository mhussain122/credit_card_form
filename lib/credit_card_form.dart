library credit_card_form;

import 'package:credit_card_form/utils.dart';
import 'package:credit_card_form/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'component.dart';
part 'theme.dart';

enum CardType { master, visa, others, invalid }

class CreditCardResult {
  final String cardNumber;
  final String cvc;
  final String cardHolderName;
  final String expirationMonth;
  final String expirationYear;
  final CardType? cardType;
  final bool isValid;
  final String nickName;
  const CreditCardResult({
    required this.cardNumber,
    required this.cvc,
    required this.nickName,
    required this.isValid,
    required this.cardHolderName,
    required this.expirationMonth,
    required this.expirationYear,
    this.cardType,
  });
}
