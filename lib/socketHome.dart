import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketHome extends StatefulWidget {
  final WebSocketChannel myChannel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.events'));

  SocketHome({Key? key}) : super(key: key);

  @override
  State<SocketHome> createState() => _SocketHomeState(myChannel: myChannel);
}

class _SocketHomeState extends State<SocketHome> {
  List<String> storeData = [];
  final TextEditingController _controller = TextEditingController();
  final WebSocketChannel myChannel;

  late ScrollController _scrollController;

  _SocketHomeState({required this.myChannel}) {
    myChannel.stream.listen((event) {
      setState(() {
        storeData.add(event);
      });
      _scrollToBottom();
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    myChannel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Websocket',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: storeData.length,
                  itemBuilder: (context, index) {
                    String message = storeData[index];
                    double containerWidth = message.length.toDouble() * 10;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: Align(
                        alignment: Alignment.centerRight, // Align messages to the right
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: containerWidth,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              message,
                              maxLines: null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter a message',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: sendMessage,
                    tooltip: "Send a message",
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      myChannel.sink.add(_controller.text);
      _controller.clear();
    }
  }
}
