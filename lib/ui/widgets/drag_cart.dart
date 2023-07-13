
import 'package:flutter/material.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/ui/widgets/swipe_card.dart';
import 'package:salute/ui/widgets/tag_widget.dart';

import '../../data/db/entity/swipe_model.dart';

class DragWidget extends StatefulWidget {
  const DragWidget({
    Key? key,
    required this.myUser,
    required this.profile,
    required this.index,
    required this.swipeNotifier,
    required this.onSwipeCompleted,
    this.isLastCard = false,
  }) : super(key: key);

  final AppUser myUser;
  final AppUser profile;
  final int index;
  final ValueNotifier<Swipe> swipeNotifier;
  final Function(AppUser, AppUser, bool) onSwipeCompleted;
  final bool isLastCard;

  @override
  State<DragWidget> createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Draggable<int>(
        // Data is the value this Draggable stores.
        data: widget.index,
        feedback: Material(
          color: Colors.transparent,
          child: ValueListenableBuilder(
            valueListenable: widget.swipeNotifier,
            builder: (context, swipe, _) {
              return RotationTransition(
                turns: widget.swipeNotifier.value != Swipe.none
                    ? widget.swipeNotifier.value == Swipe.left
                    ? const AlwaysStoppedAnimation(-15 / 360)
                    : const AlwaysStoppedAnimation(15 / 360)
                    : const AlwaysStoppedAnimation(0),
                child: Stack(
                  children: [
                    SwipeCard(person: widget.profile),
                    widget.swipeNotifier.value != Swipe.none
                        ? widget.swipeNotifier.value == Swipe.right
                        ? Positioned(
                      top: 40,
                      left: 20,
                      child: Transform.rotate(
                        angle: 12,
                        child: TagWidget(
                          text: 'LIKE',
                          color: Colors.green[400]!,
                        ),
                      ),
                    )
                        : Positioned(
                      top: 50,
                      right: 24,
                      child: Transform.rotate(
                        angle: -12,
                        child: TagWidget(
                          text: 'DISLIKE',
                          color: Colors.red[400]!,
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
        ),
        onDragUpdate: (DragUpdateDetails dragUpdateDetails) {
          if (dragUpdateDetails.delta.dx > 0 &&
              dragUpdateDetails.globalPosition.dx >
                  MediaQuery.of(context).size.width / 2) {
            widget.swipeNotifier.value = Swipe.right;
          }
          if (dragUpdateDetails.delta.dx < 0 &&
              dragUpdateDetails.globalPosition.dx <
                  MediaQuery.of(context).size.width / 2) {
            widget.swipeNotifier.value = Swipe.left;
          }
        },
        onDragEnd: (drag) {
          if(widget.swipeNotifier.value == Swipe.right){
            widget.onSwipeCompleted(widget.myUser, widget.profile, true);
          } else if(widget.swipeNotifier.value == Swipe.left){
            widget.onSwipeCompleted(widget.myUser, widget.profile, false);
          }
          widget.swipeNotifier.value = Swipe.none;
        },

        childWhenDragging: Container(
          color: Colors.transparent,
        ),

        //This will be visible when we press action button
        child: ValueListenableBuilder(
            valueListenable: widget.swipeNotifier,
            builder: (BuildContext context, Swipe swipe, Widget? child) {
              return Stack(
                children: [
                  SwipeCard(person: widget.profile),
                  // heck if this is the last card and Swipe is not equal to Swipe.none
                  swipe != Swipe.none && widget.isLastCard
                      ? swipe == Swipe.right
                      ? Positioned(
                    top: 40,
                    left: 20,
                    child: Transform.rotate(
                      angle: 12,
                      child: TagWidget(
                        text: 'LIKE',
                        color: Colors.green[400]!,
                      ),
                    ),
                  )
                      : Positioned(
                    top: 50,
                    right: 24,
                    child: Transform.rotate(
                      angle: -12,
                      child: TagWidget(
                        text: 'DISLIKE',
                        color: Colors.red[400]!,
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ],
              );
            }),
      ),
    );
  }
}