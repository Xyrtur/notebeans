import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'centre.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    List<int> extents =
        List<int>.generate(10000, (int index) => Random().nextInt(18) + 18);
    Centre().init(context);
    double buttonWidth = Centre.safeBlockHorizontal * 40;

    return SafeArea(
      child: Scaffold(
          backgroundColor: Centre.tileBgColor,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              MasonryGridView.count(
                controller: scrollController,
                crossAxisCount: 2,
                mainAxisSpacing: Centre.safeBlockVertical * 4,
                crossAxisSpacing: Centre.safeBlockHorizontal,
                itemCount: 15,
                itemBuilder: (context, index) {
                  return index == 0 || index == 1
                      ? SizedBox(
                          height: Centre.safeBlockVertical * 5,
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: Centre.safeBlockHorizontal * 4),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Centre.darkerShadowColor,
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(-5, 4),
                                ),
                                BoxShadow(
                                  color: Centre.lighterShadowColor,
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(5, -4),
                                )
                              ],
                              color: Centre.tileBgColor,
                              borderRadius: BorderRadius.circular(8)),
                          height: Centre.safeBlockVertical * extents[index],
                        );
                },
              ),
              NewNoteButton(
                  scrollController: scrollController, buttonWidth: buttonWidth)
            ],
          )),
    );
  }
}

class NewNoteButton extends StatefulWidget {
  final ScrollController scrollController;
  final double buttonWidth;
  const NewNoteButton(
      {super.key, required this.scrollController, required this.buttonWidth});

  @override
  State<NewNoteButton> createState() => _NewNoteButtonState();
}

class _NewNoteButtonState extends State<NewNoteButton> {
  double buttonWidth = 0;
  @override
  void initState() {
    super.initState();
    buttonWidth = widget.buttonWidth;
    widget.scrollController.addListener(onScroll);
  }

  onScroll() {
    setState(() {
      double scrollFraction = widget.scrollController.position.pixels /
          (Centre.safeBlockVertical * 20);
      buttonWidth = Centre.safeBlockHorizontal * 40 -
          (scrollFraction > 1 ? 1 : scrollFraction) *
              Centre.safeBlockHorizontal *
              29;
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.scrollController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          margin: EdgeInsets.only(top: Centre.safeBlockVertical * 2),
          width: buttonWidth,
          height: Centre.safeBlockVertical * 5,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Centre.darkerShadowColor,
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(-3, 2),
                ),
                BoxShadow(
                  color: Centre.lighterShadowColor,
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(3, -2),
                )
              ],
              color: Centre.tileBgColor,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              SizedBox(width: Centre.safeBlockHorizontal * 2.2),
              Icon(
                Icons.add,
                color: Centre.textColor,
                size: Centre.safeBlockHorizontal * 6.5,
              ),
              SizedBox(
                  width: buttonWidth < Centre.safeBlockHorizontal * 15
                      ? Centre.safeBlockHorizontal * 2
                      : Centre.safeBlockHorizontal * 6),
              buttonWidth < Centre.safeBlockHorizontal * 15
                  ? SizedBox()
                  : Expanded(
                      child: Text(
                        "New Note",
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: Centre.noteText,
                      ),
                    )
            ],
          ),
        );
      },
    );
  }
}
