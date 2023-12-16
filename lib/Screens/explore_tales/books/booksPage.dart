// BooksPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink_tale_version1/Screens/explore_tales/books/books_description_page.dart';
import 'package:ink_tale_version1/Screens/explore_tales/books/pdf_not_found.dart';
import 'package:ink_tale_version1/auth/login_screen.dart';
import '../../../controller/booksController.dart';

class BooksPage extends StatefulWidget {
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late Future<User?> _userFuture;
  late final BooksController booksController;

  @override
  void initState() {
    booksController = Get.put(BooksController());
    booksController.fetchBooks();
    _loadFavorites();
    _userFuture = FirebaseAuth.instance.authStateChanges().first;
    super.initState();
  }

  Future<void> _loadFavorites() async {
    await booksController.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Books'),
        backgroundColor: Colors.black,
      ),
      body: Obx(
            () {
          if (booksController.books.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: booksController.books.length,
              itemBuilder: (context, index) {
                var book = booksController.books[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
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
                    child: ListTile(
                      onTap: () {
                        // Navigate to the book description page
                        String pdfUrl =
                            book.accessInfo?.pdf?.downloadLink ?? 'default_value';
                        String description = book.volumeInfo.description ?? '';
                        String imageLink = book.volumeInfo.imageLinks.thumbnail;
                        String title = book.volumeInfo.title;
                        String previewLink = book.volumeInfo.previewLink ?? '';
                        List<String> categories = book.volumeInfo.categories;
                        double? avgRating = book.volumeInfo.averageRating;
                        num? ratingCount = book.volumeInfo.ratingsCount;

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookDescription(
                              pdfUrl: pdfUrl,
                              description: description,
                              imageUrl: imageLink,
                              title: title,
                              category: categories,
                              previewLink: previewLink,
                              avgRating: avgRating,
                              ratingCount: ratingCount,
                              isFav: booksController.favorites.contains(index),
                              index: index,
                              booksController: booksController,
                            ),
                          ),
                        );
                      },
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
                      trailing: GestureDetector(
                        onTap: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            // Toggle the favorite status
                            await booksController.toggleFavorite(index);
                            setState(() {}); // Update UI

                          } else {
                            // If user is not logged in, navigate to login screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          }
                        },
                        child: Obx(
                              () {
                            bool isFavorite =
                            booksController.favorites.contains(index);
                            return Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
