import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:word_generator/word_generator.dart';
import 'dart:math';
import 'dart:async';

class Pronunciation extends StatefulWidget {
  final String language;

  const Pronunciation({Key? key, required this.language}) : super(key: key);
  @override
  _PronunciationState createState() => _PronunciationState();
}

class _PronunciationState extends State<Pronunciation> {
  var wordGenerator = WordGenerator();
  String _word_to_pronunce = "make";
  Color _well_said = Colors.grey;

  //SPEECH TO TEXT
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechToTextAvailable = true;
  Color _speechToTextAvailableColor = Colors.lightBlueAccent;
  int countnumber = 0;

  //TEXT TO SPEECH
  final FlutterTts flutterTts = FlutterTts();

  //Generic vars
  int trys = 0;
  bool enable_stop_listening=false;
  //---------------------------

  @override
  void initState() {
    _word_to_pronunce = wordGenerator.randomNoun();
    while(esMonosilaba(_word_to_pronunce)){
      _word_to_pronunce = wordGenerator.randomNoun();
    }
    super.initState();
    initSpeech();
  }

  //SPEECH TO TEXT
  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await flutterTts.stop();
    countnumber = countnumber + 1;
    int private_countnumber=countnumber;
    _speechToTextAvailable = false;
    await _speechToText.listen(onResult: _onSpeechResult, localeId: 'en_GB');
    print('CUANTGOOOOOSOSOSOSOS');
    Future.delayed(Duration(seconds: 1), () {
      if(_wordsSpoken.length>0 && private_countnumber==countnumber){
        print('paraoo');
        _stopListening();
      }
      else{
        Future.delayed(Duration(seconds: 3), () {
          if(_wordsSpoken.length==0 && private_countnumber==countnumber){
            _stopListening();
          }
        });
      }
    });
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    print("aqui1");
    await _speechToText.stop();
    print("aqui1stoped");
    setState(() {});
    print("Words spoken:"+_wordsSpoken.length.toString());
    if(_wordsSpoken.length==0){
      setState(() {
        _speechToTextAvailableColor = Colors.lightBlueAccent;
        _speechToTextAvailable = true;
      });
    }
  }

  void _onSpeechResult(result) async {
    print("aqui2");
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
    if ((_confidenceLevel * 100) > 0 && _wordsSpoken.length >= 2) {
      print(_wordsSpoken);
      print(soundex(_wordsSpoken));
      print(soundex(_word_to_pronunce));
      print((sonParecidas(_wordsSpoken, _word_to_pronunce)));
      setState(() {
        if ((soundex(_wordsSpoken) == soundex(_word_to_pronunce)) ) {
          _well_said = Colors.green;
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              trys=0;
              _well_said = Colors.grey;
              _word_to_pronunce = wordGenerator.randomNoun();
              while(esMonosilaba(_word_to_pronunce)){
                _word_to_pronunce = wordGenerator.randomNoun();
              }
            });
          });
        } else {
          _well_said = Colors.red;
        }
      });
      Future.delayed(Duration(milliseconds: 500), () {
        speak(_word_to_pronunce);
      });
    }
    print("Lo dicho:"+_wordsSpoken);
    if(_confidenceLevel>0) {
      _wordsSpoken = "";
    }
  }

  //TEXT TO SPEECH
  void speak(reply) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1);
    await flutterTts.speak(reply);
    flutterTts.setCompletionHandler(() {
      setState(() {
        _speechToTextAvailableColor = Colors.lightBlueAccent;
        _speechToTextAvailable = true;
      });
    });
  }

  String soundex(String s) {
    // Phonetic character mappings based on multiple sources
    const codes = {
      "b": "1", "f": "1", "p": "1", "v": "1",
      "c": "2", "g": "2", "j": "2", "k": "2", "q": "2", "s": "2", "x": "2", "z": "2",
      "d": "3", "t": "3",
      "l": "4",
      "m": "5", "n": "5",
      "r": "6",
      "a": "", "e": "", "i": "", "o": "", "u": "", "y": "",
      "h": "", "w": ""
    };

    // Normalize input: convert to lowercase, trim spaces
    s = s.toLowerCase().trim();

    // Retain the first letter of the string
    String result = s[0].toUpperCase();
    String lastDigit = result;

    for (var i = 1; i < s.length; i++) {
      String char = s[i];
      if (codes.containsKey(char)) {
        String digit = codes[char]!;
        // Enhanced rules for English letter combinations
        if (digit != lastDigit) {
          if (digit.isNotEmpty) {
            result += digit;
            lastDigit = digit;
          }
        }
      }
    }

    // Remove vowels and non-coded characters after the first letter
    result = result.replaceAll(RegExp(r'[aeiouyhw]'), '');

    // Ensure the result is at least 4 characters long
    result = result.padRight(4, '0');

    // Ensure the result is truncated to four characters
    return result.substring(0, 4);
  }
  bool esMonosilaba(String palabra) {
    // Definir las vocales en inglés
    final vocales = 'aeiou';

    // Contar las ocurrencias de vocales en la palabra.
    // Esto es una simplificación y no toma en cuenta las complejidades del inglés.
    int contadorDeVocales = 0;
    for (int i = 0; i < palabra.length; i++) {
      if (vocales.contains(palabra[i].toLowerCase())) {
        contadorDeVocales++;
      }
    }

    // Considerar monosílabas a las palabras con 1 vocal (aproximación muy básica).
    return contadorDeVocales == 1;
  }
  //Cuanto de parecidas son dos strings
  int levenshteinDistance(String s, String t) {
    if (s == t) {
      return 0;
    }
    if (s.isEmpty) {
      return t.length;
    }
    if (t.isEmpty) {
      return s.length;
    }

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce(min);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  bool sonParecidas(String s1, String s2, {int umbral = 1}) {
    return levenshteinDistance(s1, s2) <= umbral;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints)
        {
          return Stack(
            children: [
              Positioned(
                top: 0, // Starts immediately below the scrollable list
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dynamic spacing
                      Spacer(),
                      InkWell(
                        onTap: (){
                          if(widget.language=="en"){
                            print("Ingles");
                            menu_choose_language(context,_word_to_pronunce);
                          }else{
                            translate(context,widget.language,_word_to_pronunce);
                          }
                        }
                        ,child: Text(
                          _word_to_pronunce,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _well_said,
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if(widget.language=="en"){
                            print("Ingles");
                            menu_choose_language(context,_word_to_pronunce);
                          }else{
                            translate(context,widget.language,_word_to_pronunce);
                          }
                        },
                        child: Text(
                          'Tap to translate to another language',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _well_said,
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      InkWell(
                        onTap: () {
                          if (_speechToText.isListening) {
                            if(enable_stop_listening){
                              _stopListening();
                            }
                          } else {
                            enable_stop_listening=false;
                            if (_speechToTextAvailable == true) {
                              Timer(Duration(seconds: 1), () {
                                // This block of code will be executed after a delay of 5 seconds.
                                enable_stop_listening=true;
                              });
                              Future.delayed(Duration(seconds: 1), () {
                                trys=trys+1;
                              });
                              _well_said = Colors.grey;
                              _speechToTextAvailableColor = Colors.redAccent;
                              _startListening();
                            }
                          }
                        },
                        child: Icon(
                          Icons.mic,
                          size: 60.0,
                          color: _speechToTextAvailableColor,
                        ),
                      ),
                      Spacer(),
                      Text(
                        _speechToText.isListening
                            ? widget.language=="en"?"Listening...\n":widget.language=="esp"?"Escuchando...\n":"Écoute...\n"
                            : _speechEnabled
                            ? widget.language=="en"?"Tap the microphone to start talking...":widget.language=="esp"?"Pulsa el micrófono para empezar a hablar...":"Appuyez sur le microphone pour commencer à écouter..."
                            : widget.language=="en"?"Speech not available":widget.language=="esp"?"Funcionalidad no disponible":"Fonctionnalité non disponible",
                        style: TextStyle(fontSize:18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              if(trys>=3)
                Positioned( // Positioned widget to place the floating button
                  right: 20, // Adjust the positioning to fit your design
                  top: (viewportConstraints.maxHeight / 20), // Adjust the positioning to fit your design
                  child: FloatingActionButton(
                    onPressed: (){
                      setState(() {
                        trys=0;
                        _well_said = Colors.grey;
                        _word_to_pronunce = wordGenerator.randomNoun();
                        while(esMonosilaba(_word_to_pronunce)){
                          _word_to_pronunce = wordGenerator.randomNoun();
                        }
                      });
                    }, // Function to be called
                    child: Icon(Icons.arrow_forward), // Right arrow icon
                    backgroundColor: Colors.grey[200], // Set the button color to grey
                  ),
                ),
            ],
          );
        }),
      )
    );
  }
}

void translate(context,language,word){
  var translator = GoogleTranslator();
  translator
      .translate(word, to: language=="esp"?"es":"fr")
      .then((result) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$word'),
        content: Text('$result'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(language=="esp"?"Cerrar":"Fermer"),
          ),
        ],
      );
    },
  )
  );
}
void menu_choose_language(context,word){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Translate to'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              translate(context,"esp",word);
            },
            child: Text("Español"),
          ),
          TextButton(
            onPressed: () {
              translate(context,"fr",word);
            },
            child: Text("Français"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close"),
          )
        ],
      );
    },
  );
}
