import 'package:flutter/material.dart';

import 'speaking_conversation.dart';

class conversationmenu extends StatefulWidget {
  String language='en';

  conversationmenu({Key? key, required this.language}) : super(key: key?? UniqueKey());
  @override
  _conversationmenu createState() => _conversationmenu();
}

class _conversationmenu extends State<conversationmenu> {
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
            commands:(){navigateTo(context, Conversationchat(rol: 'You are Emna, a right wing economist who loves free market',language: widget.language,subject: widget.language=="en"?'Economy':widget.language=="esp"?'Economía':"Économie",));}
        ),
        _buildButton(
          title: widget.language=="en"?'Art':widget.language=="esp"?'Arte':"Art",
          icon: Icons.brush,
          color: Colors.red[200]!,
            commands:(){navigateTo(context, Conversationchat(rol: 'You are Louis, a painter from Paris that loves art and is always happy',language: widget.language,subject: widget.language=="en"?'Art':widget.language=="esp"?'Arte':"Art",));}
        ),
        _buildButton(
          title: widget.language=="en"?'Music':widget.language=="esp"?'Música':"Musique",
          icon: Icons.music_note,
          color: Colors.green[200]!,
            commands:(){navigateTo(context, Conversationchat(rol: 'You are Nerea, a passionate for musician who is always happy',language: widget.language,subject: widget.language=="en"?'Music':widget.language=="esp"?'Música':"Musique",));}
        ),
        _buildButton(
          title: widget.language=="en"?'Sports':widget.language=="esp"?'Deportes':"Des sports",
          icon: Icons.sports_soccer,
          color: Colors.orange[200]!,
          commands:(){navigateTo(context, Conversationchat(rol: 'You are Alexis, a football fan who loves Real Madrid who is always happy',language: widget.language,subject: widget.language=="en"?'Sports':widget.language=="esp"?'Deportes':"Des sports",));}
        ),
      ],
    );
  }

  Widget _buildButton({required String title, required IconData icon, required Color color, required commands}) {
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
          Icon(icon, size: 48, color: Colors.white), // Ícono grande y en blanco para contraste
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16), // Texto en blanco para contraste
          ),
        ],
      ),
    );
  }
}