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
    if (widget.caption.length > 90) {
      firstHalf = widget.caption.substring(0, 90);
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
      // child: formatText(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: secondHalf.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: new Text(firstHalf, style: TextStyle(fontSize: 15)),
                  )
                : new Column(
                    children: <Widget>[
                      Text(
                        flag ? (firstHalf + "...") : (firstHalf + secondHalf),
                        style: TextStyle(fontSize: 15),
                      ),
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
