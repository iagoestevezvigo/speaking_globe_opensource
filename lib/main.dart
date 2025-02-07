import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doctor/scripts/conversation_menu.dart';
import 'package:flutter_doctor/scripts/offers.dart';
import 'package:flutter_doctor/scripts/speaking_pronunciation.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:translator/translator.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


String language="en";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlatformState();
  await _configureLocalTimeZone();
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo permite la orientación vertical
  ]);
  runApp(MyApp());
}
Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones(); // Inicializa los datos de zona horaria
  var location = tz.getLocation('America/Detroit');
  tz.setLocalLocation(location);
}

MaterialColor swatchify(MaterialColor color, int value) {
  return MaterialColor(color[value].hashCode, <int, Color>{
    50: color[value]!,
    100: color[value]!,
    200: color[value]!,
    300: color[value]!,
    400: color[value]!,
    500: color[value]!,
    600: color[value]!,
    700: color[value]!,
    800: color[value]!,
    900: color[value]!,
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Light and airy color scheme
        primarySwatch: swatchify(Colors.blue, 200),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue[200]!,
          textTheme: ButtonTextTheme.primary,
        ),
        // Modern and clean text theme
        textTheme: TextTheme(
          labelLarge: TextStyle(color: Colors.white70), // This replaces the `button` property.
        ),
      ),
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  void _updateLanguage(String newLanguage) {
    setState(() {
      language = newLanguage;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints)
            {
              return Stack(
                  children: [
                    Positioned(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 0.0,    // Padding at the top
                          bottom: 40.0, // Padding at the bottom
                          left: 20.0,   // Padding on the left
                          right: 20.0,  // Padding on the right
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Dynamic spacing
                            Spacer(),
                            MenuButton(
                              title: language=="en"?"Speaking Practice":language=="esp"?'Práctica Oral':"Pratique Orale",
                              icon: Icons.record_voice_over,
                              color: Colors.lightBlueAccent.shade100,
                              onPressed: ()  async {
                                try {
                                  CustomerInfo customerInfo = await Purchases.getCustomerInfo();
                                  if(!customerInfo.entitlements.active.isEmpty){
                                    navigateTo(context, conversationmenu(language:language));
                                  }else{
                                    fetchOffers(context,language);
                                  }
                                  // access latest customerInfo
                                } on PlatformException catch (e) {
                                  // Error fetching customer info
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: Colors.red.shade300,
                                    content: Text('Error, connection problem',style: TextStyle(color: Colors.white),),
                                  ));
                                }
                                // navigateTo(context, conversationmenu(language:language));
                              }
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height / 13),
                            MenuButton(
                              title: language=="en"?"Pronunciation Exercises":language=="esp"?'Ejercicios de Pronunciación':"Exercices de Prononciation",
                              icon: Icons.mic_none_outlined,
                              color: Colors.green[200]!,
                              onPressed: () => navigateTo(context, Pronunciation(language:language)),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: (MediaQuery.of(context).size.height / 50), // Adjust the positioning to fit your design
                        child: MyDropdownButton(onLanguageChanged: _updateLanguage,)
                    ),
                  ]
              );
            }
            )
      ),
    );
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class MenuButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  MenuButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key?? UniqueKey());

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width*0.65,
        height: MediaQuery.of(context).size.width*0.65,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante para evitar el espacio extra
            children: <Widget>[
              Icon(widget.icon, size: MediaQuery.of(context).size.height*0.1, color: Colors.white), // Icono
              SizedBox(height: MediaQuery.of(context).size.height*0.01), // Espacio entre icono y texto
              Text(widget.title, style: TextStyle(color: Colors.white, fontSize: 18)), // Texto
            ],
          ),
        ),
      ),
    );
  }
}
class MyDropdownButton extends StatefulWidget {
  final Function(String) onLanguageChanged;

  MyDropdownButton({Key? key, required this.onLanguageChanged}) : super(key: key?? UniqueKey());
  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.07, // Tamaño de la pantalla
      width: MediaQuery.of(context).size.width, // Tamaño de la pantalla
      child: Align(
        alignment: Alignment.center,
        child:
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.013,bottom:MediaQuery.of(context).size.height*0.013),
            width: MediaQuery.of(context).size.width*0.8,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra los botones
              children: <Widget>[
                // Botón de idioma en español
                GestureDetector(
                  onTap: () {
                    widget.onLanguageChanged('esp');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0), // Más espacio entre los botones
                    child: Text(
                      'Español',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // Botón de idioma en inglés
                GestureDetector(
                  onTap: () {
                    widget.onLanguageChanged('en');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0), // Más espacio entre los botones
                    child: Text(
                      'English',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // Botón de idioma en francés
                GestureDetector(
                  onTap: () {
                    widget.onLanguageChanged('fr');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0), // Más espacio entre los botones
                    child: Text(
                      'Français',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
