import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  runApp(
    VRouter(
      routes: [
        VStacked(path: '/books', widget: BooksListScreen(books: books), subroutes: [
          VStacked(
            path: r':title',
            // This path will match "/books/:title" with ":title" being any string
            widgetBuilder: (context) => BookDetailsScreen(
                // :title is a path parameter which can be found in VRouteData or VRouteElementData
                book: books.firstWhere((book) =>
                    book.title == VRouteElementData.of(context).pathParameters['title'])),
          ),
        ]),
        VStacked(path: '/unknown', widget: UnknownScreen()),
        // This redirects any wrongly typed path to unknown
        VRouteRedirector(path: r':_(.*)', redirectTo: '/unknown'),
      ],
    ),
  );
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  BooksListScreen({
    @required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => VRouterData.of(context).push('${book.title}'),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}
