import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      content: Text(widget.language=="en"?'Subscribe to send unlimited messages':widget.language=="esp"?'Suscríbete para enviar mensajes de forma ilimitada':"Abonnez-vous pour envoyer des messages illimités"),
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