import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/chat_screen.dart';
import 'package:salute/ui/widgets/portrait.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/ui/widgets/rounded_outlined_button.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/util/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rive/rive.dart';

class MatchedScreen extends StatefulWidget {
  static const String id = 'matched_screen';

  final String myProfilePhotoPath;
  final String myUserId;
  final String otherUserProfilePhotoPath;
  final String otherUserId;

  const MatchedScreen(
      {super.key,
      required this.myProfilePhotoPath,
      required this.myUserId,
      required this.otherUserProfilePhotoPath,
      required this.otherUserId});

  @override
  _MatchedScreenState createState() => _MatchedScreenState();
}

class _MatchedScreenState extends State<MatchedScreen> {
  void sendMessagePressed(BuildContext context) async {
    AppUser? user =
        await Provider.of<UserProvider>(context, listen: false).user;

    Navigator.pop(context);
    Navigator.pushNamed(context, ChatScreen.id, arguments: {
      "chat_id": compareAndCombineIds(widget.myUserId, widget.otherUserId),
      "user_id": user!.id,
      "other_user_id": widget.otherUserId
    });
  }

  Future<Artboard>? _artboard;
  SMIBool? _input;

  Future<Artboard> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset('animations/like.riv');
      final artboard = file.mainArtboard;
      var controller = StateMachineController.fromArtboard(
          artboard, 'State Machine 1',
          onStateChange: _onStateChange);

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
  void initState() {
    super.initState();
    _artboard = _loadRiveFile();

  }

  void keepSwipingPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _showAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
          _input!.value = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 42.0,
            horizontal: 18.0,
          ),
          margin: EdgeInsets.only(bottom: 40),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: 270),
                height: 500,
                child: RiveAnimation.asset("animations/findthedog_thanks.riv"),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Image.asset('images/tinder_icon.png', width: 40),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Portrait(imageUrl: widget.myProfilePhotoPath),
                      Portrait(imageUrl: widget.otherUserProfilePhotoPath)
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      RoundedButton(
                        buttonColor: kPrimaryColor,
                          text: AppLocalizations.of(context)!.sendMessage,
                          onPressed: () {
                            sendMessagePressed(context);
                          }),
                      SizedBox(height: 20),
                      RoundedOutlinedButton(
                        buttonColor: kPrimaryColor,
                          text: AppLocalizations.of(context)!.keepSwiping,
                          onPressed: () {
                            keepSwipingPressed(context);
                          }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
