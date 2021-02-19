// Note that this example uses shared_preferences to persistently store the fact that one is logged in

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrouter/vrouter.dart';

main() {
  runApp(
    VRouter(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
            backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black),
            textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
      // beforeEnter is called to check that we do not access something we are not supposed to
      beforeEnter: (vRedirector) async {
        if (vRedirector.to != '/login') {
          final sharedPreferences = await SharedPreferences.getInstance();
          // If isLoggedIn is false, we are not logged in, so we get redirected
          if (!(sharedPreferences.getBool('isLoggedIn') ?? false)) vRedirector.push('/login');
        }
      },
      routes: [
        VStacked(
          path: '/login',
          widget: LoginPage(),
          // If we are already connected, no need to go here so we redirect to "/home"
          beforeEnter: (vRedirector) async {
            final sharedPreferences = await SharedPreferences.getInstance();
            if (sharedPreferences.getBool('isLoggedIn') ?? false) vRedirector.push('/home');
          },
        ),
        VStacked(path: '/home', widget: HomePage()),
        VRouteRedirector(path: ':_(.*)', redirectTo: '/home')
      ],
    ),
  );
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          final sharedPreferences = await SharedPreferences.getInstance();
          await sharedPreferences.setBool('isLoggedIn', true);
          VRouterData.of(context).push('/home');
        },
        child: Text('Click to connect!'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Well done, you are connected!'),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                final sharedPreferences = await SharedPreferences.getInstance();
                await sharedPreferences.setBool('isLoggedIn', false);
                VRouterData.of(context).push('/login');
              },
              child: Text('Click to logout!'),
            ),
          ],
        ),
      ),
    );
  }
}
