import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/login_screen.dart';
import '../../controller/booksController.dart';
import '../../models/book_pdf_model.dart';
import '../explore_tales/books/books_description_page.dart';
import '../explore_tales/books/pdf_not_found.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  late final BooksController booksController;

  @override
  void initState() {
    super.initState();
    booksController = Get.put(BooksController());
    booksController.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Favourites'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          User? user = snapshot.data;

          return GetX<BooksController>(
            builder: (controller) {
              return ListView.builder(
                itemCount: controller.favorites.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index >= 0 && index < controller.books.length) {
                    final int bookIndex = controller.favorites.elementAt(index);
                    final Item book = controller.books[bookIndex];

                    return Container(
                      height: 80,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // ... your existing onTap logic
                        },
                        child: ListTile(
                          title: Text(
                            book.volumeInfo.title,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '- ${book.volumeInfo.authors?.join(", ") ?? "Unknown Author"}',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          leading: Image.network(
                            book.volumeInfo.imageLinks.thumbnail,
                            height: 100,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
