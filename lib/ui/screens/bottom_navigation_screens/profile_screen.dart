import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/start_screen.dart';
import 'package:salute/ui/widgets/custom_modal_progress_hud.dart';
import 'package:salute/ui/widgets/input_dialog.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/ui/widgets/rounded_icon_button.dart';
import 'package:salute/ui/widgets/rounded_outlined_button.dart';
import 'package:salute/util/constants.dart';

import '../../widgets/image_grid_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  //final Function(List<String>) onPhotosChanged;
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _imagePaths = List.filled(6, '');
  bool _showGridView = false;
  bool _isUploading = false;

  void logoutPressed(UserProvider userProvider, BuildContext context) async {
    userProvider.logoutUser();
    Navigator.pop(context);
    Navigator.pushNamed(context, StartScreen.id);
  }

  void handleImagePathsChanged(List<String> newImagePaths) {
    _imagePaths = newImagePaths;
    //widget.onPhotosChanged(_imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 30.0,
        ),
        child: Consumer<UserProvider?>(builder: (context, userProvider, child) {
          return FutureBuilder<AppUser?>(
              future: userProvider?.user,
              builder: (context, userSnapshot) {
                return CustomModalProgressHUD(
                  inAsyncCall: userProvider?.user == null ||
                      userProvider!.isLoading ||
                      _isUploading,
                  offset: null,
                  child: userSnapshot.hasData
                      ? Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _showGridView
                                        ? getGridImageView(
                                            userSnapshot.data!, userProvider!)
                                        : getProfileImage(
                                            userSnapshot.data!, userProvider!),
                                    SizedBox(height: 20),
                                    Text(
                                      '${userSnapshot.data?.name}, ${userSnapshot.data!.age}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(color: kBackgroundColor),
                                    ),
                                    SizedBox(height: 40),
                                    getCity(userSnapshot.data!, userProvider),
                                    SizedBox(height: 20),
                                    getBio(userSnapshot.data!, userProvider),
                                    SizedBox(height: 40),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: RoundedButton(
                                        text: 'LOGOUT',
                                        onPressed: () {
                                           logoutPressed(userProvider, context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                );
              });
        }),
      ),
    );
  }

  Widget getBio(AppUser user, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bio', style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(color: kBackgroundColor)),
            RoundedIconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => InputDialog(
                    onSavePressed: (value) => userProvider.updateUserBio(value),
                    labelText: 'Bio',
                    startInputText: user.bio,
                  ),
                );
              },
              iconData: Icons.edit,
              iconSize: 18,
              paddingReduce: 4,
              buttonColor: kAccentColor,
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          user.bio.trim().isNotEmpty ? user.bio : "No bio.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget getProfileImage(AppUser user, UserProvider firebaseProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBackgroundColor, width: 1.0),
          ),
          child: CircleAvatar(
            backgroundImage:
                NetworkImage(user.profilePhotoPaths[user.profilePhotoIndex]),
            radius: 80,
          ),
        ),
        Positioned(
          right: 0.0,
          bottom: 0.0,
          child: RoundedIconButton(
            onPressed: () async {
              setState(() {
                _showGridView = true;
              });
              // final pickedFile =
              //     await ImagePicker().getImage(source: ImageSource.gallery);
              // if (pickedFile != null) {
              //   firebaseProvider.updateUserProfilePhoto(
              //       pickedFile.path, 0, _scaffoldKey);
              // }
            },
            buttonColor: kAccentColor,
            iconData: Icons.edit,
            iconSize: 18,
          ),
        ),
      ],
    );
  }

  void uploadPhotos(UserProvider userProvider) async {
    setState(() {
      _isUploading = true;
    });

    await userProvider.updateUserPhotos(_imagePaths);

    setState(() {
      _isUploading = false;
      _showGridView = false;
    });
  }

  Widget getGridImageView(AppUser user, UserProvider userProvider) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: kBlueColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 400, // Set the same height as the parent Container
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: ImageGridView(
                  initialImagePaths: user.profilePhotoPaths,
                  onImagePathsChanged: handleImagePathsChanged,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showGridView = false;
                      });
                    },
                    child: Text('Cancel'),
                  ),

                  //SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading == false
                        ? () => {uploadPhotos(userProvider)}
                        : () {},
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCity(AppUser user, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('City', style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: kBackgroundColor)),
            user.city.trim().isNotEmpty
                ? RoundedIconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => InputDialog(
                          onSavePressed: (value) =>
                              userProvider.updateUserCity(value),
                          labelText: 'City',
                          startInputText: user.city,
                        ),
                      );
                    },
                    iconData: Icons.edit,
                    iconSize: 18,
                    paddingReduce: 4,
                    buttonColor: kAccentColor,
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 5),
        if (user.city.trim().isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 140,
              height: 30,
              child: RoundedOutlinedButton(
                text: 'Set your city',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => InputDialog(
                      onSavePressed: (value) =>
                          userProvider.updateUserCity(value),
                      labelText: 'City',
                      startInputText: user.city,
                    ),
                  );
                },
              ),
            ),
          )
        else
          Text(
            user.city,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}
