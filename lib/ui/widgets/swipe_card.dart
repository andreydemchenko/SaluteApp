import 'package:flutter/material.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/ui/widgets/rounded_icon_button.dart';
import 'package:salute/util/constants.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SwipeCard extends StatefulWidget {
  final AppUser person;

  const SwipeCard({super.key, required this.person});

  @override
  _SwipeCardState createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  bool showInfo = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.725,
          width: MediaQuery.of(context).size.width * 0.85,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              onPageChanged: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              itemCount: widget.person.profilePhotoPaths.length,
              itemBuilder: (context, index) => Container(
                color: Colors.white,
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred background
                      ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Image.network(
                          widget.person.profilePhotoPaths[index],
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Main image
                      Image.network(
                        widget.person.profilePhotoPaths[index],
                        fit: BoxFit.fitHeight,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              )

            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.person.profilePhotoPaths.map((url) {
              int index = widget.person.profilePhotoPaths.indexOf(url);
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 12,
                width: 12,
                margin: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  color: _currentIndex == index ? Colors.white : Colors.transparent,
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: showInfo
                ? MediaQuery.of(context).size.height * 0.25
                : MediaQuery.of(context).size.height * 0.15,
            decoration: BoxDecoration(
              gradient: kGrayGradient,
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            child: Column(
              children: [
                Padding(
                    padding: showInfo
                        ? EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                        : EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: getUserContent(context)),
                showInfo ? getBottomInfo() : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getUserContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(
                  style: DefaultTextStyle
                      .of(context)
                      .style,
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.person.name,
                      style: TextStyle(fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                    ),
                    TextSpan(text: '  ${widget.person.age}',
                        style: TextStyle(fontSize: 30, color: kPrimaryColor)),
                  ],
                )),
          ],
        ),
        RoundedIconButton(
            onPressed: () {
              setState(() {
                showInfo = !showInfo;
              });
            },
            iconData: showInfo ? Icons.arrow_downward : null,
            iconSize: 28,
            paddingReduce: 14,
            buttonColor: Colors.transparent,
            iconColor: kPrimaryColor,
            imageAsset: 'images/info_icon.png'
        ),
      ],
    );
  }

  Widget getBottomInfo() {
    return Column(
      children: [
        Divider(
          color: kAccentColor,
          thickness: 1.5,
          height: 0,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft:              Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            //color: Colors.black.withOpacity(.7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    widget.person.bio.isNotEmpty
                        ? widget.person.bio
                        : AppLocalizations.of(context)!.noBio,
                    style: TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

