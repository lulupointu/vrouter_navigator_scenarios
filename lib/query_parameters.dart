import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

main() {
  runApp(
    VRouter(
      routes: [
        VStacked(
          path: '/products',
          widgetBuilder: (context) => ProductsPage(
              sortAlphabetically:
                  VRouteData.of(context).queryParameters['sortAlphabetically'] == 'true'),
        ),
        VRouteRedirector(path: ':_(.*)', redirectTo: '/products'),
      ],
    ),
  );
}

class ProductsPage extends StatelessWidget {
  final itemCount = 200;

  final bool sortAlphabetically;

  const ProductsPage({Key key, @required this.sortAlphabetically}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Query Parameters')),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () => VRouterData.of(context).pushReplacement('/products',
                queryParameters: {'sortAlphabetically': (!sortAlphabetically).toString()}),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Click to sort'),
                Icon(sortAlphabetically ? Icons.arrow_downward : Icons.arrow_upward),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black)),
                  ),
                  height: 50,
                  child: Text(
                      'Book number ${sortAlphabetically ? index : (itemCount - index - 1)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
