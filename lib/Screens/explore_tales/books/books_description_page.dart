import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ink_tale_version1/Screens/explore_tales/books/preview_webview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/booksController.dart';

class BookDescription extends StatefulWidget {
  final String pdfUrl;
  final String description;
  final String imageUrl;
  final String title;
  final String previewLink;
  final List category;
  final double? avgRating;
  final num? ratingCount;
  final bool isFav;
  final int index;
  final BooksController booksController;
  const BookDescription({super.key, required this.pdfUrl, required this.description, required this.imageUrl, required this.title, required this.previewLink, required this.category, required this.avgRating, required this.ratingCount, required this.isFav, required this.index, required this.booksController});

  @override
  State<BookDescription> createState() => _BookDescriptionState();
}

class _BookDescriptionState extends State<BookDescription> {

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFav;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          // IconButton(
          //   icon: isFavorite
          //       ? Icon(Icons.favorite, color: Colors.red)
          //       : Icon(Icons.favorite_border),
          //   onPressed: () {
          //     setState(() {
          //       isFavorite = !isFavorite;
          //     });
          //
          //     widget.booksController.toggleFavorite(widget.index);
          //     // Handle favorite toggle here
          //     // You can call your existing method or use the booksController.toggleFavorite method
          //     // booksController.toggleFavorite(index);
          //   },
          // ),
          SizedBox(width: 10,)
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 300.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                      'assets/images/explore_images/Books.jpg'))),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    top: 180.0,
                    child: Container(
                      height: 190.0,
                      width: 190.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(40),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                widget.imageUrl),
                          ),
                          border: Border.all(color: Colors.white, width: 4.0)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 75,),
              Divider(
                indent: 15,
                endIndent: 15,
                color: Colors.black,
                thickness: 1,
              ),
              SizedBox(height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RatingBar.builder(
                            initialRating: widget.avgRating ?? 0.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: (widget.avgRating ?? 0.0).toInt().clamp(
                                1, 5),
                            // Set a minimum of 1 star
                            itemSize: 20,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                            itemBuilder: (context, _) =>
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                            onRatingUpdate: (rating) {},
                          ),
                          SizedBox(width: 5),
                          Text(widget.avgRating != null
                              ? "${widget.avgRating}"
                              : "Not Available",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight
                                .w800, color: Colors.grey),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 35),
                      child: Row(
                        children: [
                          Text(widget.ratingCount != null
                              ? "${widget.ratingCount}"
                              : "0", style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                          SizedBox(width: 5),
                          Text('Ratings', style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey))
                        ],
                      ),
                    ),
                  ],
                ),

              ),
              Divider(
                indent: 15,
                endIndent: 15,
                color: Colors.black,
                thickness: 1,
              ),
              SizedBox(height: 15,),
              Text('Book Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(widget.description),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                onPressed: (() {
                  if(widget.previewLink!=null && widget.previewLink.isNotEmpty)
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WebViewPage(url : widget.previewLink,title:widget.title)));
                  // _launchURL();
                }),
                child: Text('Preview in App'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),),
              ElevatedButton(
                onPressed: (() {
                  if(widget.previewLink!=null && widget.previewLink.isNotEmpty)
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>WebViewPage(url : widget.previewLink)));
                  _launchURL();
                }),
                child: Text('Preview in Browser'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),)
            ],
          ),
        ),
      ),
    );
  }

  _launchURL() async {
    final Uri url = Uri.parse(widget.previewLink);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch ${widget.previewLink}');
    }
  }
}
