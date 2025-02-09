import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;
import 'globals.dart' as globals;
import 'private/constants.dart';

import 'free_conversation_menu.dart';

class PurchaseApi{
  static Future<List<Offering>> fetchOffers() async{
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }
  static Future<bool> purchasePackage(Package package) async{
    try{
      await Purchases.purchasePackage(package);
      return true;
    }catch(e){
      return false;
    }

  }
}
Future<void> initPlatformState() async {
  await Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration configuration;

  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(public_google_api_key);
  }
  else if (Platform.isIOS) {
    configuration = PurchasesConfiguration('');
  }else{
    throw new Exception("Error, Neither Android nor IOS");
  }
  await Purchases.configure(configuration);
}

Future fetchOffers(context,language) async{
  final offerings = await PurchaseApi.fetchOffers();

  if (offerings.isNotEmpty) {
    final offer = offerings[0];
    _showPaywall(context,offer,language);
  }else{
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No plans found'),
    ));
  }

}

void _showPaywall(BuildContext context, Offering offer, String language) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: PaywallWidget(offer : offer, language:language),
      );
    },
  );
}

class PaywallWidget extends StatelessWidget {
  PaywallWidget({Key? key,required this.offer, required this.language}) : super(key: key);
  final String language;
  final Offering offer;
  double calculateFontSize(BuildContext context) {
    // Get the available width for the buttons
    final double availableWidth = MediaQuery.of(context).size.width - 40; // Subtracting padding

    // Calculate the desired width for the buttons
    final double buttonWidth = availableWidth / 2;

    // Calculate the ideal font size based on the button width
    return buttonWidth / 13; // Adjust this ratio as needed
  }
  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      // When returning from the new page, close the dialog
      Navigator.of(context).pop();
    });
  }
  @override
  Widget build(BuildContext context) {
    String offer_tittle=this.language=="en"?'Access to Speaking Practice feature':this.language=="esp"?'Acceso a la sección de práctica oral':"Accès à la fonctionnalité Pratique orale";
    String offer_text=this.language=="en"?'This subscription includes a free seven-days trial with access to the Speaking Practice feature. After this trial, the subscription will automatically convert to a paid subscription at a cost of ${this.offer.availablePackages.first.storeProduct.priceString} per month. You may cancel at any time during the trial period to avoid charges.':this.language=="esp"?'Esta suscripción incluye una prueba gratuita de siete días con acceso a la función Speaking Practice. Después de esta prueba, la suscripción se convertirá automáticamente en una suscripción paga a un costo de ${this.offer.availablePackages.first.storeProduct.priceString} por mes. Puede cancelar en cualquier momento durante el período de prueba para evitar cargos.':"Cet abonnement comprend un essai gratuit de sept jours avec accès à la fonctionnalité Speaking Practice. Après cet essai, l'abonnement sera automatiquement converti en abonnement payant au coût de ${this.offer.availablePackages.first.storeProduct.priceString} par mois. Vous pouvez annuler à tout moment pendant la période d'essai pour éviter des frais.";
    String free_trial=this.language=="en"?'Free trial':this.language=="esp"?'Prueba gratis':"Essai gratuit";
    String two_responses=this.language=="en"?'Only two interactions':this.language=="esp"?'Solo dos interacciones':"Deux interactions";
    String subscribe=this.language=="en"?'Subscribe now':this.language=="esp"?'Suscríbete ya':"Abonnez-vous";
    String mes=this.language=="en"?'month':this.language=="esp"?'mes':"mois";

    double buttonFontSize = calculateFontSize(context);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            offer_tittle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(offer_text),
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  if(globals.used_freeconversation==false){
                    // Free trial
                    navigateTo(context, freeconversationmenu(language:this.language));
                  }else{
                    showDialog(context: context,builder: (BuildContext context) {return SubscriptionDialog(language:this.language);},);
                  }
                },
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Text>[
                    Text(
                      free_trial,
                      style: TextStyle(fontSize: buttonFontSize),
                    ),
                    Text(
                      two_responses,
                      style: TextStyle(fontSize: buttonFontSize*0.6),
                    )
                  ],
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  // Handle subscription logic
                  await PurchaseApi.purchasePackage(this.offer.availablePackages[0]);
                  print('fuera');
                  Navigator.pop(context);
                },
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Text>[
                    Text(
                      subscribe,
                      style: TextStyle(fontSize: buttonFontSize),
                    ),
                    Text(
                      this.offer.availablePackages.first.storeProduct.priceString+" / "+mes,
                      style: TextStyle(fontSize: buttonFontSize*0.9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}