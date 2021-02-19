import 'package:flutter/material.dart';
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
      routes: [
        VStacked(
          path: '/search',
          widget: SearchResultPage(),
          subroutes: [
            VStacked(
              path: ':productName',
              name: 'productPage',
              widgetBuilder: (context) => ProductPage(
                product: allProducts.firstWhere(
                  (product) =>
                      product.name ==
                      VRouteElementData.of(context).pathParameters['productName'],
                ),
              ),
            ),
          ],
        ),
        VStacked(
          // In parenthesis is a regExp which allows us to limit the productType
          //    - This is less verbose than creating multiple route
          //    - We can access the product type with the path parameter productType
          path: r'/:productType(book|shoes|pillow)',
          widgetBuilder: (context) => CategoryPage(
            products: allProducts
                .where((product) =>
                    productTypeToString(product.type) ==
                    VRouteElementData.of(context).pathParameters['productType'])
                .toList(),
          ),
          subroutes: [
            VStacked(
              path: ':productName',
              name: 'productPage',
              widgetBuilder: (context) => ProductPage(
                product: allProducts.firstWhere(
                  (product) =>
                      product.name ==
                      VRouteElementData.of(context).pathParameters['productName'],
                ),
              ),
            ),
          ],
        ),
        VRouteRedirector(path: ':_(.*)', redirectTo: '/search'),
      ],
    ),
  );
}

// We do not implement a search bar but only the page on which a user would be
// after he/she typed in a certain url
class SearchResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dynamic linking')),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Here is the result for you search "stars":',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ProductList(
            products: allProducts.where((product) => product.name.contains("stars")).toList(),
          )
        ],
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dynamic linking')),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => VRouterData.of(context).push('/search'),
          )
        ],
      ),
      body: Hero(
        tag: product.name,
        child: Material(
          child: Container(
            color: productTypeColor(product.type),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Type: ${productTypeToString(product.type)}'),
                  Text(product.name),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () =>
                        VRouterData.of(context).push('/${productTypeToString(product.type)}'),
                    child: Text(
                      'See all ${productTypeToString(product.type)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final List<Product> products;

  const CategoryPage({Key key, @required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dynamic linking')),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => VRouterData.of(context).push('/search'),
          )
        ],
      ),
      body: ProductList(
        products: products,
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({Key key, @required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: products,
      ),
    );
  }
}

class Product extends StatelessWidget {
  final String name;
  final ProductTypes type;

  const Product({Key key, @required this.name, @required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => VRouterData.of(context).push(name),
      child: Hero(
        tag: name,
        child: Material(
          child: Container(
            height: 200,
            width: 200,
            color: productTypeColor(type),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Type: ${productTypeToString(type)}'),
                  Text(name),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ProductTypes { book, shoe, pillow }

Color productTypeColor(ProductTypes itemType) {
  switch (itemType) {
    case ProductTypes.book:
      return Colors.greenAccent;
    case ProductTypes.shoe:
      return Colors.redAccent;
    case ProductTypes.pillow:
      return Colors.blueAccent;
    default:
      return Colors.black;
  }
}

String productTypeToString(ProductTypes itemType) {
  switch (itemType) {
    case ProductTypes.book:
      return 'book';
    case ProductTypes.shoe:
      return 'shoes';
    case ProductTypes.pillow:
      return 'pillow';
    default:
      return 'unknown';
  }
}

final bookProducts = <Product>[
  Product(name: 'Book stars', type: ProductTypes.book),
  Product(name: 'old book', type: ProductTypes.book),
  Product(name: 'eBook', type: ProductTypes.book),
];

final shoesProducts = <Product>[
  Product(name: 'Shoes of stars', type: ProductTypes.shoe),
  Product(name: 'Only One Shoe', type: ProductTypes.shoe),
  Product(name: 'Shoe fleur', type: ProductTypes.shoe),
];

final pillowProducts = <Product>[
  Product(name: 'Best pillow', type: ProductTypes.pillow),
  Product(name: 'Pillow stars', type: ProductTypes.pillow),
  Product(name: 'This is not a pillow', type: ProductTypes.pillow),
];

final allProducts = <Product>[...bookProducts, ...shoesProducts, ...pillowProducts];
