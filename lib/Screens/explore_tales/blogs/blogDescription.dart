import 'package:flutter/material.dart';


class BlogDescription extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String creatorName;
  final String creatorProfilePhoto;
  const BlogDescription({super.key, required this.title, required this.description, required this.imageUrl, required this.creatorName, required this.creatorProfilePhoto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Details'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          Icon(Icons.favorite_border),
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
                          height: 400.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image:  imageUrl.isNotEmpty?NetworkImage(
                                      imageUrl):AssetImage('assets/images/explore_images/blog.jpg') as ImageProvider)),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    top: 360.0,
                    child: Container(
                      height: 80.0,
                      width: 350.0,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 48.0,
                            child: ClipOval(
                              child: SizedBox(
                                width: 75.0,
                                height: 75.0,
                                child: Image.network(
                                  creatorProfilePhoto,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0), // Add some spacing between the photo and text
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              creatorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white70,
                        border: Border.all(color: Colors.white70, width: 2.0),
                      ),
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
              SizedBox(height: 15,),
              Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(description),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
