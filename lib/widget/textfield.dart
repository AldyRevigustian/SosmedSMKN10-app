import 'package:flutter/material.dart';
import 'package:instagram_redesign_ui/const.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final validator;
  const TextFieldInput({
    Key key,
    @required this.textEditingController,
    this.isPass = false,
    @required this.hintText,
    @required this.textInputType,
    @required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextFormField(
      controller: textEditingController,
      validator: validator,
      decoration: InputDecoration(
        fillColor: CustColors.primaryWhite,
        hintText: hintText,
        // hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: CustColors.primaryWhite)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: CustColors.primaryWhite)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: CustColors.primaryWhite)),
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
