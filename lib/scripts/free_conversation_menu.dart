import 'package:flutter/material.dart';

import 'free_speaking_conversation.dart';
import 'speaking_conversation.dart';

class freeconversationmenu extends StatefulWidget {
  String language='en';

  freeconversationmenu({Key? key, required this.language}) : super(key: key?? UniqueKey());
  @override
  _freeconversationmenu createState() => _freeconversationmenu();
}

class _freeconversationmenu extends State<freeconversationmenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16), // Agrega un poco de padding alrededor de la cuadrícula
          constraints: BoxConstraints(maxWidth: 400), // Limita el ancho máximo de la cuadrícula
          child: MyStatefulWidget(language: widget.language),
        ),
      ),
    );
  }
}
class MyStatefulWidget extends StatefulWidget {
  final String language;

  MyStatefulWidget({Key? key, required this.language}) : super(key: key ?? UniqueKey());
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _buildButton(
          title: widget.language=="en"?'Economy':widget.language=="esp"?'Economía':"Économie",
          icon: Icons.attach_money,
          color: Colors.blue[200]!,
            commands:(){navigateTo(context, FreeConversationchat(rol: 'You are Emna, a right wing economist who loves free market',language: widget.language,subject: widget.language=="en"?'Economy':widget.language=="esp"?'Economía':"Économie",));}
        ),
        _buildButton(
          title: widget.language=="en"?'Art':widget.language=="esp"?'Arte':"Art",
          icon: Icons.brush,
          iconcolor: Colors.red[300]!,
          color: Colors.grey[200]!,
            commands:(){showDialog(context: context,builder: (BuildContext context) {return SubscriptionDialog(language:widget.language);},);}
        ),
        _buildButton(
          title: widget.language=="en"?'Music':widget.language=="esp"?'Música':"Musique",
          icon: Icons.music_note,
            iconcolor: Colors.red[300]!,
          color: Colors.grey[200]!,
            commands:(){showDialog(context: context,builder: (BuildContext context) {return SubscriptionDialog(language:widget.language);},);}
        ),
        _buildButton(
          title: widget.language=="en"?'Sports':widget.language=="esp"?'Deportes':"Des sports",
          icon: Icons.sports_soccer,
            iconcolor: Colors.red[300]!,
          color: Colors.grey[200]!,
            commands:(){showDialog(context: context,builder: (BuildContext context) {return SubscriptionDialog(language:widget.language);},);}
        ),
      ],
    );
  }

  Widget _buildButton({required String title, required IconData icon, required Color color, required commands, Color iconcolor=Colors.white}) {
    return ElevatedButton(
      onPressed: commands,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        elevation: 5, // Añade una sombra para un efecto 3D
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Reduce el espacio extra al mínimo necesario
        children: [
          Icon(icon, size: 48, color: iconcolor), // Ícono grande y en blanco para contraste
          Text(
            title,
            style: TextStyle(color: iconcolor, fontSize: 16), // Texto en blanco para contraste
          ),
        ],
      ),
    );
  }
}
class SubscriptionDialog extends StatefulWidget {
  final String language;

  SubscriptionDialog({Key? key, required this.language}) : super(key: key ?? UniqueKey());
  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.language=="en"?'Not Available':widget.language=="esp"?'No disponible':"Pas disponible"),
      content: Text(widget.language=="en"?'Subscribe to get all the features.':widget.language=="esp"?'Suscribete para obtener todos los modos':"Abonnez-vous pour bénéficier de toutes les fonctionnalités"),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ),
      ],
    );
  }
}