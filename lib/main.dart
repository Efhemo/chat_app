import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final ThemeData iOSTheme = ThemeData(
  //primarySwatch is a different shades of color,
  //primary color is one of them
  primarySwatch: Colors.red,
  primaryColor: Colors.grey,
  primaryColorBrightness: Brightness.dark,
);

final ThemeData androidTheme =
    ThemeData(primarySwatch: Colors.red, accentColor: Colors.green);

const String defaultUserName = "John Doe";

class MyApp extends StatelessWidget {
  final String appName = "Chat Application";

  //Even things that are not visible to the eye are considered widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: debugDefaultTargetPlatformOverride == TargetPlatform.iOS
          ? iOSTheme
          : androidTheme,
      home: Chat(
        title: appName,
      ),
    );
  }
}

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".
class Chat extends StatefulWidget {
  final String title;

  Chat({Key key, this.title}) : super(key: key);

  @override
  State createState() => ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _message = <Msg>[];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, index) => _message[index],
                itemCount: _message.length,
                padding: EdgeInsets.all(6.0),
                reverse: true,
              ),
            ),
            Divider(),
            Container(
              child: _buildComposer(),
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 9.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textEditingController,
                onChanged: (String txt) {
                  setState(() {
                    _isWriting = txt.length > 0;
                  });
                },
                onSubmitted: _submitMsg,
                decoration: InputDecoration.collapsed(
                    hintText: "Enter some text to send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 3.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text("Submit"),
                      onPressed: _isWriting
                          ? () => _submitMsg(_textEditingController.text)
                          : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.message),
                      onPressed: _isWriting
                          ? () => _submitMsg(_textEditingController.text)
                          : null,
                    ),
            )
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.brown)))
            : null,
      ),
    );
  }

  void _submitMsg(String value) {
    _textEditingController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = Msg(
        txt: value,
        animationController: AnimationController(
            vsync: this, duration: Duration(milliseconds: 800)));

    setState(() {
      _message.insert(0, msg);
    });
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _message) {
      msg.animationController.dispose();
    }
    super.dispose();
  }
}

class Msg extends StatelessWidget {
  final String txt;
  final AnimationController animationController;

  Msg({this.txt, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: animationController, curve: Curves.bounceOut),
        axisAlignment: 0.0,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: CircleAvatar(
                  child: Text(defaultUserName[0]),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      defaultUserName,
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 6.0),
                      child: Text(txt),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
