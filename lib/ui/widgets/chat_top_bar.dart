import 'package:flutter/material.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/ui/screens/user_details_screen.dart';
import 'package:salute/util/constants.dart';

class ChatTopBar extends StatelessWidget {
  final AppUser user;

  const ChatTopBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, UserDetailsScreen.id, arguments: user);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccentColor, width: 1.0),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage:
                  NetworkImage(user.profilePhotoPaths[user.profilePhotoIndex]),
                ),
              )
            ],
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: kBackgroundColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

