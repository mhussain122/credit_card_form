part of credit_card_form;

class CreditCardForm extends StatefulWidget {
  final String? cardNumberLabel;
  final String? cardHolderLabel;
  final String? expiredDateLabel;
  final String? cvcLabel;
  final double fontSize;
  final CreditCardTheme? theme;
  final GlobalKey<FormState> formKey;
  final Function(CreditCardResult) onChanged;
  const CreditCardForm({
    super.key,
    required this.formKey,
    this.theme,
    required this.onChanged,
    this.cardNumberLabel,
    this.cardHolderLabel,
    this.expiredDateLabel,
    this.cvcLabel,
    this.fontSize = 16,
  });

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  Map<String, dynamic> params = {
    "card": '',
    "expired_date": '',
    "card_holder_name": '',
    "cvc": '',
    "nickname": ''
  };

  Map cardImg = {
    "img": 'credit_card.png',
    "width": 30.0,
  };

  String error = '';
  bool? isCardNumberValidated, isExpiryValidated;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CardType? cardType;

  Map<String, TextEditingController> controllers = {
    "card": TextEditingController(),
    "expired_date": TextEditingController(),
    "card_holder_name": TextEditingController(),
    "cvc": TextEditingController(),
    "nickname": TextEditingController()
  };

  validateCard() => widget.formKey.currentState!.validate();

  @override
  Widget build(BuildContext context) {
    CreditCardTheme theme = widget.theme ?? CreditCardLightTheme();
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          textInput(
            controller: controllers['card'],
            label: widget.cardNumberLabel ?? 'Card Number',
            validator: (value) {
              String? validateMsg = cardNumberValidator(value);
              validateMsg == null
                  ? isCardNumberValidated = true
                  : isCardNumberValidated = false;
              setState(() {});
              return validateMsg;
            },
            key: 'card',
            bottom: 1,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            onChanged: (val) {
              Map img = CardUtils.getCardIcon(val);
              CardType type =
                  CardUtils.getCardTypeFrmNumber(val.replaceAll(' ', ''));
              setState(() {
                cardImg = img;
                cardType = type;
              });
              emitResult();
            },
            suffixIcon: isCardNumberValidated == null
                ? const SizedBox()
                : isCardNumberValidated!
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : const Icon(Icons.info_outline),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'images/${cardImg['img']}',
                package: 'credit_card_form',
                width: cardImg['width'] as double?,
              ),
            ),
          ),
          const SizedBox(height: 12),
          textInput(
            label: widget.cardHolderLabel ?? 'Card holder name',
            controller: controllers['card_holder_name'],
            key: 'card_holder_name',
            validator: (value) => emptyValidator(value, 'Account Title'),
            bottom: 1,
            onChanged: (val) {
              emitResult();
            },
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 4,
                child: textInput(
                  label: widget.expiredDateLabel ?? 'MM/YY',
                  hintText: 'MM / YY',
                  right: 1,
                  validator: (value) {
                    String? validateMsg = cardExpiryDateValidator(value);
                    validateMsg == null
                        ? isExpiryValidated = true
                        : isExpiryValidated = false;
                    setState(() {});
                    return validateMsg;
                  },
                  key: 'expired_date',
                  onChanged: (val) {
                    emitResult();
                  },
                  suffixIcon: isExpiryValidated == null
                      ? const SizedBox()
                      : isExpiryValidated!
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : const Icon(Icons.info_outline),
                  controller: controllers['expired_date'],
                  formatters: [
                    CardExpirationFormatter(),
                    LengthLimitingTextInputFormatter(5)
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 4,
                child: textInput(
                    label: widget.cvcLabel ?? 'CVC',
                    hintText: '***',
                    key: 'cvc',
                    validator: cvvValidator,
                    controller: controllers['cvc'],
                    password: true,
                    onChanged: (val) {
                      emitResult();
                    },
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3)
                    ],
                    suffixIcon: Icon(
                      Icons.help,
                      color: theme.borderColor,
                    )),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: textInput(
              label: 'Add a card nickname',
              key: 'nickname',
              keyboardType: TextInputType.name,
              controller: controllers['nickname'],
              validator: (value) => emptyValidator(value, 'Card Nickname'),
              onChanged: (val) => emitResult(),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Example: My Gold Card',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  emitResult() {
    List res = params['expired_date'].split('/');
    CreditCardResult result = CreditCardResult(
        cardNumber: params['card'].replaceAll(' ', ''),
        cvc: params['cvc'],
        cardHolderName: params['card_holder_name'],
        expirationMonth: res[0] ?? '',
        isValid: validateCard(),
        expirationYear: res.asMap().containsKey(1) ? res[1] : '',
        cardType: cardType,
        nickName: params['nickname']);
    widget.onChanged(result);
  }

  Widget textInput({
    required String label,
    required String key,
    double left = 0,
    double right = 0,
    double bottom = 0,
    double top = 0,
    int? maxLength,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    bool? password,
    Function(String)? onChanged,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? hintText,
    String? Function(String?)? validator,
    TextEditingController? controller,
  }) {
    CreditCardTheme theme = widget.theme ?? CreditCardLightTheme();
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        color: theme.textColor,
        fontSize: widget.fontSize,
      ),
      maxLength: maxLength,
      onChanged: (value) {
        setState(() {
          params[key] = value;
        });
        if (onChanged != null) {
          onChanged(value);
        }
      },
      obscureText: password ?? false,
      inputFormatters: formatters ?? [],
      keyboardType: keyboardType ?? TextInputType.number,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorMaxLines: 1,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        contentPadding: const EdgeInsets.all(15),
        label: Text(label),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: theme.borderColor),
            borderRadius: BorderRadius.circular(8)),
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: theme.borderColor),
            borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: theme.borderColor),
            borderRadius: BorderRadius.circular(8)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1, color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(8)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1, color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(8)),
        hintStyle: TextStyle(
          color: theme.labelColor,
          fontSize: widget.fontSize,
        ),
      ),
    );
  }
}
