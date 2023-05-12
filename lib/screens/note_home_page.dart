import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notebeans/blocs/color_cubit.dart';
import 'package:notebeans/blocs/note_bloc.dart';
import 'package:notebeans/models/note.dart';
import 'package:notebeans/screens/editing_note_page.dart';

import '../utils/centre.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Centre().init(context);
    double buttonWidth = Centre.safeBlockHorizontal * 40;
    context.read<NoteBloc>().add(const FetchNotes());

    return SafeArea(
      child: Scaffold(
          backgroundColor: Centre.tileBgColor,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              BlocBuilder<NoteBloc, NoteState>(builder: (unUsedcontext, state) {
                return MasonryGridView.count(
                  controller: scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: Centre.safeBlockVertical * 4,
                  crossAxisSpacing: Centre.safeBlockHorizontal,
                  itemCount: (state is! NotesFetched)
                      ? 0
                      : (state).notesList.length + 2,
                  itemBuilder: (unUsedcontext, index) {
                    // The list should "start" with two duds because otherwise the notes will collide with the new note button due to Stack widget
                    Note? currentNote = index == 0 || index == 1
                        ? null
                        : (state as NotesFetched).notesList[index - 2];

                    return index == 0 || index == 1
                        ? SizedBox(
                            height: Centre.safeBlockVertical * 5,
                          )
                        : NoteTile(note: currentNote!, index: index - 2);
                  },
                );
              }),
              NewNoteButton(
                  scrollController: scrollController, buttonWidth: buttonWidth)
            ],
          )),
    );
  }
}

class NoteTile extends StatefulWidget {
  final Note note;
  final int index;
  const NoteTile({super.key, required this.note, required this.index});

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  late QuillController controller;
  late NoteBloc _noteBloc;
  late ScrollController scrollController;
  List<int> extents =
      List<int>.generate(10000, (int index) => Random().nextInt(18) + 18);

  // The reference to the navigator
  late NavigatorState _navigator;

  @override
  void didChangeDependencies() {
    _navigator = Navigator.of(context);
    _noteBloc = context.read<NoteBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    controller = QuillController(
        selection: const TextSelection.collapsed(offset: 0),
        document: Document.fromJson(jsonDecode(widget.note.content)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigator
            .push(MaterialPageRoute(
                builder: (unUsedcontext) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                            value: context.read<NoteBloc>(),
                          ),
                          BlocProvider<ColorCubit>(
                            create: (_) => ColorCubit(-1),
                          ),
                          BlocProvider<ColorPressedCubit>(
                            create: (_) => ColorPressedCubit(),
                          ),
                        ],
                        child: EditingNotePage(
                          note: widget.note,
                        ))))
            .then((value) {
          _noteBloc.add(const FetchNotes());
        });
      },
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal * 4),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Centre.darkerShadowColor,
            spreadRadius: 0.01,
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Centre.lighterShadowColor,
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(-4, -4),
          )
        ], color: Centre.tileBgColor, borderRadius: BorderRadius.circular(8)),
        height: Centre.safeBlockVertical * extents[widget.index],
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                Centre.safeBlockHorizontal * 2,
                Centre.safeBlockVertical * 0.5,
                Centre.safeBlockHorizontal * 2,
                Centre.safeBlockHorizontal * 1.5),
            child: AutoSizeText(
              widget.note.title,
              style: Centre.noteText,
              maxLines: 2,
              textScaleFactor: 1.5,
            ),
          ),
          Expanded(
            child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    Centre.safeBlockHorizontal * 2,
                    0,
                    Centre.safeBlockHorizontal * 2,
                    Centre.safeBlockVertical * 3),
                child: QuillStyles(
                  data: DefaultStyles(
                      bold: const TextStyle(fontWeight: FontWeight.bold),
                      italic: const TextStyle(fontStyle: FontStyle.italic),
                      underline:
                          const TextStyle(decoration: TextDecoration.underline),
                      strikeThrough: const TextStyle(
                          decoration: TextDecoration.lineThrough),
                      link: TextStyle(
                        color: Centre.linkColor,
                        decoration: TextDecoration.underline,
                      ),
                      paragraph: DefaultTextBlockStyle(
                          Centre.noteText,
                          const VerticalSpacing(6.0, 6),
                          const VerticalSpacing(0.0, 0),
                          null),
                      h3: DefaultTextBlockStyle(
                          Centre.noteText.copyWith(
                            fontSize: Centre.safeBlockHorizontal * 5,
                            height: 1.15,
                          ),
                          const VerticalSpacing(6.0, 10),
                          const VerticalSpacing(0.0, 0),
                          null),
                      lists: DefaultListBlockStyle(
                          Centre.noteText,
                          const VerticalSpacing(6.0, 10),
                          const VerticalSpacing(0.0, 0),
                          null,
                          null),
                      quote: DefaultTextBlockStyle(
                          Centre.noteText.copyWith(
                              fontSize: Centre.safeBlockHorizontal * 3),
                          const VerticalSpacing(4.0, 4),
                          const VerticalSpacing(0.0, 0),
                          null),
                      code: DefaultTextBlockStyle(
                          Centre.noteText,
                          const VerticalSpacing(6.0, 10),
                          const VerticalSpacing(0.0, 0),
                          BoxDecoration(
                            color: Centre.lighterShadowColor,
                            borderRadius: BorderRadius.circular(2),
                          ))),
                  child: QuillEditor(
                    showCursor: false,
                    enableInteractiveSelection: false,
                    controller: controller,
                    scrollController: scrollController,
                    readOnly: true,
                    scrollable: false,
                    autoFocus: false,
                    expands: false,
                    focusNode: FocusNode(),
                    padding: const EdgeInsets.all(0),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: Centre.safeBlockVertical * 1.5,
          )
        ]),
      ),
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
  late double buttonWidth;
  late NoteBloc _noteBloc;
  // The reference to the navigator
  late NavigatorState _navigator;

  @override
  void didChangeDependencies() {
    _navigator = Navigator.of(context);
    _noteBloc = context.read<NoteBloc>();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    buttonWidth = widget.buttonWidth;
    widget.scrollController.addListener(onScroll);
  }

  onScroll() {
    setState(() {
      double scrollFraction = widget.scrollController.position.pixels /
          (Centre.safeBlockVertical * 15);
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
      builder: (BuildContext unUsedcontext, Widget? child) {
        return GestureDetector(
          onTap: () {
            _navigator
                .push(MaterialPageRoute(
                    builder: (unUsedcontext) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<NoteBloc>(),
                              ),
                              BlocProvider<ColorCubit>(
                                create: (_) => ColorCubit(-1),
                              ),
                              BlocProvider<ColorPressedCubit>(
                                create: (_) => ColorPressedCubit(),
                              ),
                            ],
                            child: EditingNotePage(
                              note: Note(null, "", "", DateTime.now()),
                            ))))
                .then((value) {
              _noteBloc.add(const FetchNotes());
            });
          },
          child: Container(
            margin: EdgeInsets.only(top: Centre.safeBlockVertical * 2),
            width: buttonWidth,
            height: Centre.safeBlockVertical * 5,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Centre.darkerShadowColor,
                    spreadRadius: 1.5,
                    blurRadius: 3,
                    offset: const Offset(3, 3),
                  ),
                  BoxShadow(
                    color: Centre.lighterShadowColor,
                    spreadRadius: 1.5,
                    blurRadius: 12,
                    offset: const Offset(-3, -3),
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
                    ? const SizedBox()
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
          ),
        );
      },
    );
  }
}
