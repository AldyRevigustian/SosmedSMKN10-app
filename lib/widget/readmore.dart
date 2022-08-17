import 'package:flutter/material.dart';

class Readmore extends StatefulWidget {
  const Readmore({
    Key key,
    this.caption,
    this.user,
  }) : super(key: key);
  final String caption;
  final String user;

  @override
  State<Readmore> createState() => _ReadmoreState();
}

class _ReadmoreState extends State<Readmore> {
  String firstHalf;
  String secondHalf;
  bool flag = true;

  @override
  void initState() {
    if (widget.caption.length > 100) {
      firstHalf = widget.caption.substring(0, 100);
      secondHalf = widget.caption.substring(50, widget.caption.length);
    } else {
      firstHalf = widget.caption;
      secondHalf = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 15, bottom: 15, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: secondHalf.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            children: [
                          TextSpan(
                              text: "@" + widget.user + " ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: firstHalf),
                        ])),
                  )
                : new Column(
                    children: <Widget>[
                      flag
                          ? RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  children: [
                                  TextSpan(
                                      text: "@" + widget.user + " ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: firstHalf + "..."),
                                ]))
                          : RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black), //apply style to all
                                  children: [
                                  TextSpan(
                                      text: "@" + widget.user + " ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: firstHalf + secondHalf),
                                ])),
                      new InkWell(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: new Text(
                                flag ? "Baca Selengkapnya" : "Lebih Sedikit",
                                style: new TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            flag = !flag;
                          });
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
