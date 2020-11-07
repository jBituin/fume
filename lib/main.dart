import 'package:flutter/material.dart';
import 'package:fume/views/vehicle_list.dart';
import 'package:fume/utils/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
     new MyApp()
    );
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getTheme(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return MaterialApp(
            onGenerateTitle: (BuildContext context) =>
                'Loading',
            supportedLocales: [
              const Locale('en', ''),
              const Locale('de', ''),
              const Locale('ru', ''),
            ],
            home: Scaffold(
              body: Center(
                child: Text(snapshot.toString()),
              ),
            ),
          );
        } else {
          return StreamBuilder(
            stream: bloc.darkThemeEnabled,
            initialData: snapshot.data,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: Text("Mwhehhehe"),
                    ),
                  ),
                );
              } else {
                return MaterialApp(
                  onGenerateTitle: (BuildContext context) =>
                      'Kure kure',
                  supportedLocales: [
                    const Locale('en', ''),
                    const Locale('de', ''),
                    const Locale('ru', ''),
                  ],
                  debugShowCheckedModeBanner: false,
                  navigatorObservers: [routeObserver],
                  home: VehicleList(snapshot.data as bool),
                  
                );
              }
            },
          );
        }
      },
    );
  }

  Future<bool> _getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool val = prefs.getBool('darkTheme');
    if(val == null){
      val = true;
    }
    return val;
  }
}