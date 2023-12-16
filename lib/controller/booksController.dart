import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_pdf_model.dart';

class BooksController extends GetxController {
  var books = <Item>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load favorites from SharedPreferences when the controller is initialized
    loadFavorites();
  }

  Future<void> fetchBooks() async {
    final apiKey = 'AIzaSyDMha956W6Cx4wZZTfaOJMEKpaUqNJ3vhs';
    final apiUrl =
        'https://www.googleapis.com/books/v1/volumes?q=subject:fiction&filter=free-ebooks&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = getMap(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final List<Item> fetchedBooks = [];

        for (var item in items) {
          final book = Item(
            kind: Kind.BOOKS_VOLUME,
            id: item['id'] ?? 'Unknown ID',
            etag: item['etag'] ?? 'Unknown ETag',
            selfLink: item['selfLink'] ?? 'Unknown Self Link',
            volumeInfo: VolumeInfo(
              title: item['volumeInfo']['title'] ?? 'Unknown Title',
              authors: (item['volumeInfo']['authors'] as List<dynamic>?)?.cast<String>(),
              publisher: item['volumeInfo']['publisher'] ?? 'Unknown Publisher',
              publishedDate: item['volumeInfo']['publishedDate'] ?? 'Date not available',
              description: item['volumeInfo']['description'] ?? '',
              categories: (item['volumeInfo']['categories'] as List<dynamic>?)?.cast<String>() ?? [],
              language: item['volumeInfo']['language'] ?? '',
              maturityRating: item['volumeInfo']['maturityRating'] ?? 'NOT_MATURE',
              imageLinks: ImageLinks(
                smallThumbnail: item['volumeInfo']['imageLinks']['smallThumbnail'] ?? 'No Small Thumbnail Available',
                thumbnail: item['volumeInfo']['imageLinks']['thumbnail'] ?? 'No Thumbnail Available',
              ),
              pageCount: item['volumeInfo']['pageCount'] ?? 0,
              printType: PrintType.BOOK, // Add your logic to parse printType
              allowAnonLogging: item['volumeInfo']['allowAnonLogging'] ?? false,
              contentVersion: item['volumeInfo']['contentVersion'] ?? 'Unknown Content Version',
              panelizationSummary: PanelizationSummary(
                containsEpubBubbles: item['volumeInfo']['panelizationSummary']['containsEpubBubbles'] ?? false,
                containsImageBubbles: item['volumeInfo']['panelizationSummary']['containsImageBubbles'] ?? false,
              ),
              previewLink: item['volumeInfo']['previewLink'] ?? 'No Preview Link Available',
              infoLink: item['volumeInfo']['infoLink'] ?? 'No Info Link Available',
              canonicalVolumeLink: item['volumeInfo']['canonicalVolumeLink'] ?? 'No Canonical Volume Link Available',
              averageRating: item['volumeInfo']['averageRating']?.toDouble(),
              ratingsCount: item['volumeInfo']['ratingsCount'],
              subtitle: item['volumeInfo']['subtitle'],
            ),
            saleInfo: SaleInfo(
              country: Country.IN,
              saleability: Saleability.FREE,
              isEbook: item['saleInfo']['isEbook'] ?? false,
              buyLink: item['saleInfo']['buyLink'] ?? 'Unknown Buy Link',
            ),
            accessInfo: AccessInfo(
              country: Country.IN,
              viewability: Viewability.ALL_PAGES,
              embeddable: item['accessInfo']['embeddable'] ?? false,
              publicDomain: item['accessInfo']['publicDomain'] ?? false,
              textToSpeechPermission: TextToSpeechPermission.ALLOWED,
              epub: Epub(
                isAvailable: item['accessInfo']['epub']['isAvailable'] ?? false,
                downloadLink: item['accessInfo']['epub']['downloadLink'],
              ),
              pdf: Epub(
                isAvailable: item['accessInfo']['pdf']['isAvailable'] ?? false,
                downloadLink: item['accessInfo']['pdf']['downloadLink'],
              ),
              webReaderLink: item['accessInfo']['webReaderLink'] ?? 'Unknown Web Reader Link',
              accessViewStatus: AccessViewStatus.FULL_PUBLIC_DOMAIN,
              quoteSharingAllowed: item['accessInfo']['quoteSharingAllowed'] ?? false,
            ),
          );

          fetchedBooks.add(book);
          printBookDetails(item);
        }

        books.assignAll(fetchedBooks);
      } else {
        throw Exception('Failed to load books');
      }
    } catch (error) {
      print('Error fetching books: $error');
    }
  }

  Map<String, dynamic> getMap(String jsonString) {
    try {
      return Map<String, dynamic>.from(json.decode(jsonString));
    } catch (e) {
      return {};
    }
  }
  void printBookDetails(Map<String, dynamic> bookData) {
    print('Book Details:');
    print("RESPONSE :: $bookData");
    // Add more details as needed
  }
  RxSet<int> favorites = <int>{}.obs;
  // List<Item> favBooks = [];

  Future<void> toggleFavorite(int index) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection('user_favorites');

        DocumentReference userFavoritesRef = favoritesCollection
            .doc(user.uid)
            .collection('favorites')
            .doc(books[index].id);

        if (await userFavoritesRef.get().then((doc) => doc.exists)) {
          await userFavoritesRef.delete();
          favorites.remove(index);
        } else {
          await userFavoritesRef.set({
            'bookId': books[index].id,
            // Add other book details you want to store
          });
          favorites.add(index);
        }

        update(); // Update UI or perform other actions as needed
      } catch (e) {
        print('Error toggling favorite: $e');
      }
    }
  }




  void printFavoriteBooks(List<Item> favoriteBooks) {
    for (var book in favoriteBooks) {
      print('Book Title: ${book.volumeInfo.title}');
      // Add more details as needed
    }
  }
  void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Convert RxSet<int> to Set<int> before encoding
      Set<int> favoritesSet = favorites.toSet();
      prefs.setString('favorites_${user.uid}', jsonEncode(favoritesSet.toList()));
    }
  }



  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Clear existing favorites for the current user
      favorites.clear();

      // Load favorites for the current user
      await loadFirestoreFavorites(user.uid);

      // You can also load favorites from SharedPreferences if needed
      String? favoritesJson = prefs.getString('favorites_${user.uid}');
      if (favoritesJson != null) {
        favorites.assignAll(jsonDecode(favoritesJson).cast<int>());
      }
    }
  }


  Future<void> loadFirestoreFavorites(String userUid) async {
    try {
      CollectionReference favoritesCollection =
      FirebaseFirestore.instance.collection('user_favorites');

      QuerySnapshot querySnapshot = await favoritesCollection
          .doc(userUid)
          .collection('favorites')
          .get();

      List<String> firestoreFavorites = querySnapshot.docs
          .map((doc) => doc['bookId'] as String)
          .toList();

      // Update the favorites list
      for (int i = 0; i < books.length; i++) {
        if (firestoreFavorites.contains(books[i].id)) {
          favorites.add(i);
        }
      }

      update(); // Update UI or perform other actions as needed
    } catch (e) {
      print('Error loading favorites from Firestore: $e');
    }
  }



  Future<void> clearFavorites() async {
    favorites.clear();
    update();
  }

}
