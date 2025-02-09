import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_doctor/scripts/transition.dart';
import 'dart:async';
import 'private/constants.dart';


class ChatMessage {
  String sender;
  String text;
  ChatMessage({required this.sender, required this.text});
}



class Conversationchat extends StatefulWidget {
  final String rol; // Declaration of the field to store the passed argument
  String language='en';
  String subject='Music';

  // Constructor accepting the menuTitle argument
  Conversationchat({Key? key, required this.rol, required this.language,required this.subject}) : super(key: key?? UniqueKey());


  @override
  State<Conversationchat> createState() => _ConversationState();
}

class _ConversationState extends State<Conversationchat> {

  final _textController = TextEditingController();

  // Buttons on the right
  bool _showText = false; // Controls the visibility of the text
  double _textOpacity = 0.0; // Controls the opacity of the text
  Timer? _textTimer; // Timer to hide the text after 5 seconds

  //OPENAI
  String _gpt_response="";
  var messages;
  var chat_messages=[{"role": "assistant", "content":"Hi, what do you want to talk about today?"}];

  TextEditingController userInputTextEditingController = TextEditingController();

  //SPEECH TO TEXT
  String _wordsSpoken="";
  String _newwordsSpoken="";
  double _confidenceLevel = 0 ;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechToTextAvailable = true;
  Color microColor=Colors.lightBlueAccent;

  //TEXT TO SPEECH
  final FlutterTts flutterTts = FlutterTts();
  double _speechspeed = 1;

  //Generic variables
  Color _sendColor = Colors.lightBlue;
  ScrollController _scrollController = new ScrollController();//Controller to scroll down in the chat list
  bool display_conversation=true;
  bool enable_stop_listening=false;

  //---------------------------

  @override
  void initState() {
    super.initState();
    messages=[
      {"role": "system", "content": widget.rol}
    ];
    initSpeech();
    _showTemporaryText();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  //Buttons on the right
  void _showTemporaryText() {
    setState(() {
      _showText = true; // Show the text
      _textOpacity = 1.0; // Set opacity to fully visible
    });

    _textTimer?.cancel(); // Cancel any existing timer
    _textTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _textOpacity = 0.0; // Start fading out
      });
      // Hide the text completely after the fade-out animation
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _showText = false;
        });
      });
    });
  }
  //OPEN AI
  Future<List> send(String message) async {
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");
    var last_message={"role": "user", "content":message};
    Map<String, dynamic> body_correct_grammar={
      "model":"gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "Do not answer, only correct the grammar and sintax mistakes."},
        last_message,
        //{"role": "assistant", "content": "It´s 3"},
      ],
      "max_tokens":100,
      "stop": ["\n"]
    };
    final response_correct_grammar=await http.post(
      uri,
      headers: {
        "Content-Type":"application/json",
        "Authorization":chatgpt_key,
      },
      body:jsonEncode(body_correct_grammar),
    );
    Map<String,dynamic> parsed_response_correct_grammar=jsonDecode(response_correct_grammar.body);

    String correct_grammar_reply ="";
    try{
      correct_grammar_reply = parsed_response_correct_grammar['choices'][0]['message']['content'];
      setState(() {
        var last_message={"role": "user", "content":correct_grammar_reply};
        messages.add(last_message);
        chat_messages.add({"role": "user", "content":correct_grammar_reply,"before_correcting":message});
      });

    }catch(e){
      print("problem:");
      print(response_correct_grammar.body);
      correct_grammar_reply="Exceeded TPM";
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    Map<String, dynamic> body={
      "model":"gpt-3.5-turbo",
      "messages": getFirstAndLast10(messages),
      "max_tokens":100,
      "temperature": 0.2
    };
    final response=await http.post(
      uri,
      headers: {
        "Content-Type":"application/json",
        "Authorization": chatgpt_key,
      },
      body:jsonEncode(body),
    );
    Map<String,dynamic> parsed_response=jsonDecode(response.body);
    String reply ="";
    try{
      reply = parsed_response['choices'][0]['message']['content'];
      // Find the last index of '.'
      int lastIndex = reply.lastIndexOf('.');
      // If there's at least one '.', find the penultimate '.'
      if (lastIndex > 0) {
        // Find the penultimate index of '.' by searching in the substring that excludes the last '.'
        int penultimateIndex = reply.substring(0, lastIndex).lastIndexOf('.');

        // If there is a short distance between the penultimate dot and the ultimate, remove until the penultimate
        if (penultimateIndex != -1 && lastIndex-penultimateIndex<5) {
          lastIndex=penultimateIndex;
        }
      }

      // Use substring to get everything before the last '.'
      // Add 1 to lastIndex to include the '.' itself in the result
      reply = (lastIndex != -1) ? reply.substring(0, lastIndex + 1) : reply;

    }catch(e){
      print("PROBLEM:");
      print(response.body);
      reply="Exceeded TPM";
    }
    setState(() {
      messages.add({"role": "assistant", "content":reply});
      chat_messages.add({"role": "assistant", "content":reply});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    return [correct_grammar_reply,reply];
  }

  //SPEECH TO TEXT
  void initSpeech() async{
    await _speechToText.initialize();
    setState(() {});
  }
  void _startListening() async {
    userInputTextEditingController.text="";
    microColor=Colors.blueGrey;
    _speechToTextAvailable = false;
    await flutterTts.stop();
    await _speechToText.listen(onResult: _onSpeechResult , localeId: 'en_GB');
    Future.delayed(Duration(seconds: 5), () {
      if(_newwordsSpoken.length==0){
        _stopListening();
      }
    });
    setState(() {
      _confidenceLevel=0;
    });
  }
  void _stopListening() async {
    if (mounted) {
      await _speechToText.stop();
      setState(() {});
      if (_newwordsSpoken.length == 0) {
        setState(() {
          microColor = Colors.lightBlueAccent;
          _speechToTextAvailable = true;
        });
      }
    }
  }
  void _onSpeechResult(result) async{
    setState(()  {
      _wordsSpoken="${result.recognizedWords}";
      _newwordsSpoken=_wordsSpoken;
      _confidenceLevel=result.confidence;

    });
    if ((_confidenceLevel*100)>60 && _wordsSpoken.length>2 && !(_speechToText.isListening)){
      userInputTextEditingController.text=_wordsSpoken;

    }
    if(_confidenceLevel>0){
      _newwordsSpoken="";
      _speechToTextAvailable = true;
      microColor=Colors.lightBlueAccent;
    }
  }

  //TEXT TO SPEECH
  void speak(reply) async{
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate((_speechspeed*0.5)-0.05);
    await flutterTts.speak(reply);
  }
  // What happens when you press the send button

  Future<void> send_message(String message) async {
    userInputTextEditingController.clear();
    List replies=await send(message);
    _gpt_response = replies[1];
    speak(_gpt_response);
    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        _sendColor= Colors.lightBlue;
      });
    });
  }

  // Error dialogs


  void LengthError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AnimatedSnackbar(message: 'Not enough characters!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ACTIVATE CONVERSATION
  void activate_conversation(){
    setState(() {
      display_conversation=!display_conversation;
    });
  }

  //Scroll down
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  List<T> getFirstAndLast10<T>(List<T> list) {
    // Determine the number of elements to be included from the start and end
    int startElements = list.length > 10 ? 10 : list.length;
    int endElements = list.length > 10 ? 10 : 0;

    // Create a new list to hold the first and last elements
    List<T> result = [];

    // Add the first 10 or fewer elements
    result.addAll(list.take(startElements));

    // If the list has more than 20 elements, add the last 10 elements
    if (list.length > 20) {
      result.addAll(list.sublist(list.length - endElements));
    } else if (list.length > 10 && list.length <= 20) {
      // For lists between 11 and 20 in length, add elements to make up a total of 20, avoiding duplicates
      result.addAll(list.sublist(startElements));
    }

    return result;
  }


  //--------------------------------



  Widget _buildMessage(var message) {
    double maxWidth = MediaQuery.of(context).size.width * 0.8;
    String text_message = message["content"];
    bool isMe= message["role"] == "user";
    bool well_written = true;
    if(isMe){
      well_written= text_message.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')==message["before_correcting"].toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
    }
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth, // Usa el ancho máximo definido aquí.
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.green[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: isMe?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    well_written? text_message:message["before_correcting"],
                    style: TextStyle(color:  well_written?Colors.green[300]:Colors.red[400], fontSize: MediaQuery.of(context).size.height*0.02)

                ),
                if(!well_written)
                  Text(
                    'Corrected message: '+text_message,
                    style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height*0.015),

                  )
              ],)
                :
            Text(
              text_message,
              style: TextStyle(color: display_conversation ? Colors.black87 : Colors.green[50],fontSize: MediaQuery.of(context).size.height*0.02),

            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                textAlign: TextAlign.center,
                controller: userInputTextEditingController,
                decoration:
                InputDecoration(hintText: widget.language=="en"?"Here you can edit what you said":widget.language=="esp"?"Aquí puedes editar lo que has dicho":"Ici, vous pouvez modifier ce que vous avez dit",contentPadding: EdgeInsets.symmetric(vertical: 20)),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send,color:_sendColor),
                onPressed: () {
                  if (userInputTextEditingController.text.length>0){
                    if(_sendColor== Colors.lightBlue){
                      setState(() {
                        _sendColor = Colors.blueGrey;
                      });
                      send_message(userInputTextEditingController.text);
                    }
                  }else{
                    LengthError(context);
                  }
                  // Your function to call
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Your function to run when the back button is pressed
        await flutterTts.stop();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(title: Text(widget.subject,style: TextStyle(fontWeight: FontWeight.bold),),centerTitle: true),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints)
              {
                return Stack(
                    children: [
                      Positioned(
                        top: 0, // Starts immediately below the scrollable list
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child:Column(
                          children: [
                            Flexible(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(8.0),
                                reverse: false,
                                itemCount: chat_messages.length,
                                itemBuilder: (_, int index) => _buildMessage(chat_messages[index]),
                              ),
                            ),
                            Divider(height: 1.0),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                              ),
                              child: _buildTextComposer(),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: (viewportConstraints.maxHeight / 50),
                        child: SizedBox(
                          width: viewportConstraints.maxHeight / 23,
                          height: viewportConstraints.maxHeight / 23,
                          child: FloatingActionButton(
                            heroTag: null,
                            onPressed: () { // Show the text
                              setState(() {
                                if (_speechspeed == 1) {
                                  _speechspeed = 1.5;
                                } else if (_speechspeed == 1.5) {
                                  _speechspeed = 0.5;
                                } else if (_speechspeed == 0.5) {
                                  _speechspeed = 1;
                                }
                              });
                            },
                            child: Text('x$_speechspeed'),
                            backgroundColor: _speechspeed == 1
                                ? Colors.grey[200]
                                : _speechspeed == 1.5
                                ? Colors.red[200]
                                : _speechspeed == 0.5
                                ? Colors.blue[200]
                                : Colors.grey[200],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: ((viewportConstraints.maxHeight * 2 / 50) + (viewportConstraints.maxHeight / 13)),
                        child: SizedBox(
                          width: viewportConstraints.maxHeight / 23,
                          height: viewportConstraints.maxHeight / 23,
                          child: FloatingActionButton(
                            heroTag: null,
                            onPressed: () {
                              activate_conversation();
                            },
                            child: Text('Aa'),
                            backgroundColor: display_conversation ? Colors.grey[100] : Colors.red[200],
                          ),
                        ),
                      ),
                      if (_showText)
                        Positioned(
                          right: 20,
                          top: (viewportConstraints.maxHeight / 50),
                          child: AnimatedOpacity(
                            opacity: _textOpacity, // Animate opacity
                            duration: Duration(milliseconds: 500), // Fade duration
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Voice Speed',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),

                      if (_showText)
                        Positioned(
                          right: 20,
                          top: ((viewportConstraints.maxHeight * 2 / 50) + (viewportConstraints.maxHeight / 13)),
                          child: AnimatedOpacity(
                            opacity: _textOpacity, // Animate opacity
                            duration: Duration(milliseconds: 500), // Fade duration
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Conversation Toggled',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: (viewportConstraints.maxHeight - viewportConstraints.maxHeight / 10) / 8,
                        left: (viewportConstraints.maxWidth - viewportConstraints.maxHeight / 10) / 2,
                        child: SizedBox(
                          width: viewportConstraints.maxHeight / 10,
                          height: viewportConstraints.maxHeight / 10,
                          child: FloatingActionButton(
                            backgroundColor: Colors.grey[100],
                            elevation: 0, // Establece la elevación a 0 para eliminar la sombra
                            shape: CircleBorder(),
                            onPressed: () {
                              if( _speechToText.isListening){
                                if(enable_stop_listening){
                                  _stopListening();
                                }
                              }else{
                                enable_stop_listening=false;
                                if(_speechToTextAvailable == true) {
                                  Timer(Duration(seconds: 1), () {
                                    // This block of code will be executed after a delay of 5 seconds.
                                    enable_stop_listening=true;
                                  });
                                  _startListening();
                                }
                              }
                            },
                            child: Icon(Icons.mic,color: microColor,size: viewportConstraints.maxHeight / 10),
                          ),
                        ),
                      ),
                    ]
                );
              }
          )
      ),
    );
  }
}
