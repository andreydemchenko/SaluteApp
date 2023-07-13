import 'package:flutter/material.dart';
import '../../data/db/entity/app_user.dart';
import '../../util/constants.dart';
import 'dart:ui' as ui;

class UserDetailsScreen extends StatefulWidget {
  final AppUser user;

  const UserDetailsScreen({super.key, required this.user});

  static const String id = 'user_details_screen';

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  onPageChanged: (value) {
                    setState(() {
                      _currentIndex = value;
                    });
                  },
                  itemCount: widget.user.profilePhotoPaths.length,
                  itemBuilder: (context, index) => Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred background
                      ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Image.network(
                          widget.user.profilePhotoPaths[index],
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Main image
                      Center(
                        child: Image.network(
                          widget.user.profilePhotoPaths[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.user.profilePhotoPaths.map((url) {
                    int index = widget.user.profilePhotoPaths.indexOf(url);
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 12,
                      width: 12,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 1),
                        color: _currentIndex == index
                            ? kPrimaryColor
                            : Colors.transparent,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${widget.user.name}, ${widget.user.age}',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: kBackgroundColor)),
                  Text(
                    widget.user.bio.trim().isNotEmpty
                        ? widget.user.bio
                        : "No bio",
                    style: Theme.of(context)
                        .textTheme.bodyLarge
                        ?.copyWith(color: kAccentColor),
                  ),
                  SizedBox(height: 5),
                  widget.user.city.isNotEmpty ?
                      Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(
                                'City:',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: kBackgroundColor),
                              ),
                            ),
                            Text(
                              widget.user.city,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: kBackgroundColor),
                            )
                          ])
                    : Container()
                ]),
          )
        ],
      ),
    );
  }
}
