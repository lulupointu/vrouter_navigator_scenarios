import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

main() {
  runApp(
    VRouter(
      routes: [
        VStacked(
          path: '/home',
          widget: HomePage(),
          subroutes: [
            VStacked(
              path: r'/book/:id(\d+)', // We match any id number
              widget: DetailPage(),
            ),
          ],
        ),
        VRouteRedirector(path: ':_(.*)', redirectTo: '/home'),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Path Parameters')),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final bookColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
          return Container(
            color: bookColor,
            height: 50,
            child: TextButton(
              onPressed: () => VRouterData.of(context)
                  .push('/book/$index', routerState: '${bookColor.value}'),
              child: Text('Book number $index'),
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Color bookColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Path Parameters'),
      ),
      body: VNavigationGuard(
        afterEnter: (_, __, ___) => setState(() {
          bookColor = Color(int.tryParse(VRouterData.of(context).historyState));
        }),
        child: Container(
          color: bookColor,
          child: Center(
              child:
              Text('This is book number ${VRouteData.of(context).pathParameters['id']}')),
        ),
      ),
    );
  }
}
