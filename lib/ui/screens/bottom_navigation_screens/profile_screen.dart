import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/math.dart';
import 'package:rive/rive.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/start_screen.dart';
import 'package:salute/ui/widgets/custom_modal_progress_hud.dart';
import 'package:salute/ui/widgets/input_dialog.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/ui/widgets/rounded_icon_button.dart';
import 'package:salute/ui/widgets/rounded_outlined_button.dart';
import 'package:salute/util/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/city_input_dialog.dart';
import '../../widgets/image_grid_view.dart';
import '../matched_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  const ProfileScreen({super.key, required this.onLocaleChange});

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

  Artboard? _riveArtboard;

  Future<void> _load() async {
    // You need to manage adding the controller to the artboard yourself,
    // unlike with the RiveAnimation widget that can handle a lot of this logic
    // for you by simply providing the state machine (or animation) name.
    final file = await RiveFile.asset('animations/like.riv');
    final artboard = file.mainArtboard;
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    artboard.addController(controller!);
    setState(() => _riveArtboard = artboard);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void handleImagePathsChanged(List<String> newImagePaths) {
    _imagePaths = newImagePaths;
  }

  void open() {
    Navigator.pushNamed(context, MatchedScreen.id, arguments: {
      "my_user_id": "R1QTRtnMPFNjrGm4WdYZUiUpokY2",
      "my_profile_photo_path":
      "https://firebasestorage.googleapis.com/v0/b/tinderapp-46361.appspot.com/o/user_photos%2FR1QTRtnMPFNjrGm4WdYZUiUpokY2%2Fphoto_0?alt=media&token=e03325e0-daa3-4d7e-8ac8-f8b9471ef5fc",
      "other_user_profile_photo_path":
      "https://firebasestorage.googleapis.com/v0/b/tinderapp-46361.appspot.com/o/user_photos%2FYfxNUkx9IbhiJfFdLIEw4UMJ8By1%2Fphoto_0?alt=media&token=5ed66989-959e-49af-add2-b8b2c827c3d8",
      "other_user_id": "YfxNUkx9IbhiJfFdLIEw4UMJ8By1"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                                physics: BouncingScrollPhysics(),
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
                                    SizedBox(height: 20),
                                    getLanguage(),
                                    SizedBox(height: 120),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: RoundedButton(
                                        text: AppLocalizations.of(context)!.logout,
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

    );
  }

  Widget getLanguage() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext bc) {
              return Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.english),
                    trailing: Localizations.localeOf(context).languageCode == 'en'
                        ? Icon(Icons.check)
                        : null,
                    onTap: () {
                      widget.onLocaleChange(Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.russian),
                    trailing: Localizations.localeOf(context).languageCode == 'ru'
                        ? Icon(Icons.check)
                        : null,
                    onTap: () {
                      widget.onLocaleChange(Locale('ru'));
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            }
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              AppLocalizations.of(context)!.myLanguage,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: kBackgroundColor)
          ),
          Text(
            Localizations.localeOf(context).languageCode == 'en' ? AppLocalizations.of(context)!.english : AppLocalizations.of(context)!.russian,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
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
            Text(AppLocalizations.of(context)!.bio,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: kBackgroundColor)),
            RoundedIconButton(
              onPressed: () {
                open();
                // showDialog(
                //   context: context,
                //   builder: (_) => InputDialog(
                //     onSavePressed: (value) => userProvider.updateUserBio(value),
                //     labelText: AppLocalizations.of(context)!.bio,
                //     startInputText: user.bio,
                //   ),
                // );
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
          user.bio.trim().isNotEmpty ? user.bio : AppLocalizations.of(context)!.noBio,
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
        height: 400,
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
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),

                  //SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading == false
                        ? () => {
                              if (!_imagePaths.every((path) => path.isEmpty))
                                uploadPhotos(userProvider)
                              else
                                setState(() {
                                  _showGridView = false;
                                })
                            }
                        : () {},
                    child: Text(AppLocalizations.of(context)!.save),
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
            Text(AppLocalizations.of(context)!.city,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: kBackgroundColor)),
            user.city.trim().isNotEmpty
                ? RoundedIconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CityInputDialog(
                          labelText: user.city,
                          onSavePressed: (value) =>
                              userProvider.updateUserCity(value),
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
                text: AppLocalizations.of(context)!.setYourCity,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CityInputDialog(
                      labelText: '',
                      onSavePressed: (value) =>
                          userProvider.updateUserCity(value),
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

class MyAnimationWidget extends StatefulWidget {
  @override
  _MyAnimationWidgetState createState() => _MyAnimationWidgetState();
}

class _MyAnimationWidgetState extends State<MyAnimationWidget> {
  Future<Artboard>? _artboard;
  SMIBool? _input;

  @override
  void initState() {
    super.initState();
    _artboard = _loadRiveFile();
  }

  Future<Artboard> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset('animations/like.riv');
      final artboard = file.mainArtboard;
      var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1', onStateChange: _onStateChange);

      if (controller != null) {
        artboard.addController(controller);
        _input = controller.findInput<bool>('Like') as SMIBool;
      }

      return artboard;
    } catch (e) {
      print('Error loading Rive file: $e');
      rethrow;
    }
  }


  void _onStateChange(String stateMachineName, String stateName) {
    print('State Changed to $stateName');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Artboard>(
      future: _artboard,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                if (_input != null) {
                  _input!.value = !_input!.value;
                }
              },
              child: SizedBox(
                width: 150, // or your size
                height: 150, // or your size
                child: Rive(artboard: snapshot.data!),
              ),
            );
          } else {
            return Center(child: Text('Failed to load Rive file.'));
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Text('Failed to load Rive file.'));
        }
      },
    );
  }
}