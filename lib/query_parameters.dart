import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

main() {
  runApp(
    VRouter(
      routes: [
        VStacked(
          path: '/products',
          widget: ProductsPage(),
        ),
        VRouteRedirector(path: ':_(.*)', redirectTo: '/products'),
      ],
    ),
  );
}

class ProductsPage extends StatefulWidget {
  final itemCount = 200;

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool sortAlphabetically = true;

  @override
  Widget build(BuildContext context) {
    return VNavigationGuard(
      // After we enter or update, we check sortAlphabetically queryParameter to see if the
      // UI is synced with the url
      afterEnter: (_, __, ___) => setState(() => sortAlphabetically =
          VRouteData.of(context).queryParameters['sortAlphabetically'] == 'true'),
      afterUpdate: (_, __, ___) => setState(() => sortAlphabetically =
          VRouteData.of(context).queryParameters['sortAlphabetically'] == 'true'),
      child: Scaffold(
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
                itemCount: widget.itemCount,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.black)),
                    ),
                    height: 50,
                    child: Text(
                        'Book number ${sortAlphabetically ? index : (widget.itemCount - index - 1)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
