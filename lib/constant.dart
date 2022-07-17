// ----- STRINGS ------
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:numeral/fun.dart';

// const baseURL = 'http://your-Ip:8000/api';
const baseURL = 'http://192.168.0.11:8000/api';
const baseURLMobile = 'http://192.168.0.11:8000';
// const baseURL = 'http://10.0.2.2:8000/api';
// const baseURLMobile = 'http://10.0.2.2:8000';
const loginURL = baseURL + '/login';
const registerURL = baseURL + '/register';
const logoutURL = baseURL + '/logout';
const userURL = baseURL + '/user';
const postsURL = baseURL + '/posts';
const commentsURL = baseURL + '/comments';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';

// --- input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.black)));
}

// button

TextButton kTextButton(String label, Function onPressed) {
  return TextButton(
    child: Text(
      label,
      style: TextStyle(color: Colors.white),
    ),
    style: ButtonStyle(
        backgroundColor:
            MaterialStateColor.resolveWith((states) => Colors.blue),
        padding: MaterialStateProperty.resolveWith(
            (states) => EdgeInsets.symmetric(vertical: 10))),
    onPressed: () => onPressed(),
  );
}

// loginRegisterHint
Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
          child: Text(label, style: TextStyle(color: Colors.blue)),
          onTap: () => onTap())
    ],
  );
}

// likes and comment btn

kLikeAndComment(IconData icon, Color color, Function onTap) {
  return ConstrainedBox(
    constraints: new BoxConstraints(
      minWidth: 50.0,
      // maxHeight: 60.0,
    ),
    child: Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: color,
              ),
              // Text(
              //   numeral(value ?? 0),
              //   // intl.NumberFormat.decimalPattern().format(100000),
              //   style: TextStyle(
              //       fontWeight: FontWeight.w600, color: Colors.black54),
              // )
              // Text(
              //   '$value',
              //   style: TextStyle(fontWeight: FontWeight.w600),
              // )
            ],
          ),
        ),
      ),
    ),
  );
}

kComment(IconData icon, Color color, Function onTap) {
  return ConstrainedBox(
    constraints: new BoxConstraints(
      minWidth: 60.0,
      // maxHeight: 60.0,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: color,
              ),

              // Text(
              //   '$value',
              //   style: TextStyle(fontWeight: FontWeight.w600),
              // )
            ],
          ),
        ),
      ),
    ),
  );
}
