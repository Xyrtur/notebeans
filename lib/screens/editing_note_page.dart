import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:notebeans/blocs/color_cubit.dart';
import 'package:notebeans/blocs/note_bloc.dart';
import 'package:notebeans/models/note.dart';
import '../utils/centre.dart';

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor) {
    if (hexColor == null) {
      return -1;
    } else {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");

      hexColor = "FF$hexColor";

      return int.parse(hexColor, radix: 16);
    }
  }

  HexColor(final String? hexColor) : super(_getColorFromHex(hexColor));
}

class EditingNotePage extends StatefulWidget {
  final Note note;
  const EditingNotePage({super.key, required this.note});

  @override
  State<EditingNotePage> createState() => _EditingNotePageState();
}

class _EditingNotePageState extends State<EditingNotePage> {
  late Note currentNote;
  final titleController = TextEditingController();
  late QuillController contentController;
  // late ZefyrController contentController;
  final FocusNode contentFocus = FocusNode();
  final FocusNode titleFocus = FocusNode();
  final ScrollController scrollController = ScrollController();

  String titleInitial = "";
  String contentInitial = "";

  // Timer variable calls persistData every 5 seconds and cancels timer when page pops
  late Timer saveChangesTimer;

  // Timer to queue the last 5 seconds worth of changes, with changes taken in every 0.5 seconds
  late Timer undoChangesTimer;

  // Queue to store those changes
  final undoQueue = Queue<String>();
  final redoQueue = Queue<String>();

  // Store most recent state of editor (since the last 500ms)
  late String mostRecentEditorState;

  bool isNavigatingBack = false;
  bool dataSavedWithBackClick = false;

  final List<int> colors = [
    const Color(0xFFE2A0FF).value,
    const Color(0xFFEDB6A3).value,
    const Color.fromARGB(255, 255, 92, 92).value,
    const Color.fromARGB(255, 255, 171, 54).value,
    const Color.fromARGB(255, 255, 234, 49).value,
    const Color(0xFF91F5AD).value,
    const Color(0xFF54DEFD).value,
    const Color(0xFFC9F0FF).value
  ];

  void didChangeEditingValue() {
    context.read<ColorCubit>().update(colors.indexOf(HexColor(
            contentController.getSelectionStyle().attributes["color"]?.value)
        .value));
  }

  void pushUndoChangesToQueue() {
    String currentEditorState =
        jsonEncode(contentController.document.toDelta().toJson());

    if (currentEditorState != mostRecentEditorState) {
      undoQueue.addFirst(currentEditorState);
      mostRecentEditorState = currentEditorState;
      if (undoQueue.length > 10) {
        undoQueue.removeLast();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    currentNote = widget.note;
    titleController.text = currentNote.title;
    contentController = (currentNote.content == ""
        ? QuillController.basic()
        : QuillController(
            document: Document.fromJson(jsonDecode(currentNote.content)),
            selection: const TextSelection.collapsed(offset: 0),
          ));

    contentController.addListener(didChangeEditingValue);

    contentInitial = currentNote.content;
    titleInitial = currentNote.title;

    saveChangesTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      persistData();
    });

    undoChangesTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      pushUndoChangesToQueue();
    });
    mostRecentEditorState = contentInitial;
  }

  @override
  void dispose() {
    contentController.removeListener(didChangeEditingValue);
    contentController.dispose();
    super.dispose();
  }

  void persistData() {
    // Update note info
    currentNote.content =
        jsonEncode(contentController.document.toDelta().toJson());
    currentNote.title = titleController.text;
    if (!(currentNote.title == titleInitial &&
            currentNote.content == contentInitial) ||
        (currentNote.id == null)) {
      // if changes to note or if new note, change the date last edited
      currentNote.dateLastEdited = DateTime.now();
    }
    if (currentNote.id == null) {
      context.read<NoteBloc>().add(NoteCreate(note: currentNote));
    } else {
      context.read<NoteBloc>().add(NoteEdit(note: currentNote));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget undoBtn = GestureDetector(
      onTap: () {
        contentController.undo();
      },
      child: Container(
        padding: EdgeInsets.all(Centre.safeBlockHorizontal),
        margin: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Centre.darkerShadowColor,
            spreadRadius: 0.01,
            blurRadius: 2,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Centre.lighterShadowColor,
            spreadRadius: 0.01,
            blurRadius: 12,
            offset: const Offset(-5, -5),
          )
        ], color: Centre.tileBgColor, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.undo_rounded,
          size: Centre.safeBlockHorizontal * 7,
          color: Centre.toolTextColor,
        ),
      ),
    );

    Widget redoBtn = GestureDetector(
      onTap: () {
        contentController.redo();
      },
      child: Container(
        padding: EdgeInsets.all(Centre.safeBlockHorizontal),
        margin: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Centre.darkerShadowColor,
            spreadRadius: 0.01,
            blurRadius: 2,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Centre.lighterShadowColor,
            spreadRadius: 0.01,
            blurRadius: 12,
            offset: const Offset(-5, -5),
          )
        ], color: Centre.tileBgColor, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.redo_rounded,
          size: Centre.safeBlockHorizontal * 7,
          color: Centre.toolTextColor,
        ),
      ),
    );

    Widget backBtn = GestureDetector(
      onTap: () {
        persistData();
        isNavigatingBack = true;
      },
      child: Container(
        padding: EdgeInsets.all(Centre.safeBlockHorizontal),
        margin: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Centre.darkerShadowColor,
            spreadRadius: 0.01,
            blurRadius: 2,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Centre.lighterShadowColor,
            spreadRadius: 0.01,
            blurRadius: 12,
            offset: const Offset(-5, -5),
          )
        ], color: Centre.tileBgColor, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.arrow_back_rounded,
          size: Centre.safeBlockHorizontal * 7,
          color: Centre.toolTextColor,
        ),
      ),
    );

    Widget deleteBtn = GestureDetector(
      onTap: () {
        if (currentNote.id != -1) {
          showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  titlePadding: EdgeInsets.fromLTRB(
                      Centre.safeBlockHorizontal * 3.5,
                      Centre.safeBlockVertical * 2,
                      Centre.safeBlockHorizontal * 3.5,
                      Centre.safeBlockVertical),
                  contentPadding: EdgeInsets.fromLTRB(
                      Centre.safeBlockHorizontal * 3.5,
                      0,
                      Centre.safeBlockHorizontal * 3.5,
                      Centre.safeBlockVertical),
                  actionsPadding: EdgeInsets.only(
                      right: Centre.safeBlockHorizontal * 4,
                      bottom: Centre.safeBlockVertical * 1.5),
                  backgroundColor: Centre.tileBgColor,
                  title: Text(
                    "Delete the current note?",
                    style: Centre.dialogTitleText,
                  ),
                  content: Text(
                    "This can't be undone",
                    style: Centre.noteText,
                  ),
                  actions: <Widget>[
                    GestureDetector(
                        onTap: () {
                          if (currentNote.id == null) {
                            dataSavedWithBackClick = true;
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pop();
                          } else {
                            dataSavedWithBackClick = true;
                            Navigator.of(dialogContext).pop();
                            context
                                .read<NoteBloc>()
                                .add(NoteDelete(id: currentNote.id!));
                          }
                        },
                        child: SizedBox(
                          height: Centre.safeBlockVertical * 6,
                          width: Centre.safeBlockHorizontal * 10,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("OK", style: Centre.noteText),
                          ),
                        )),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: SizedBox(
                          height: Centre.safeBlockVertical * 6,
                          width: Centre.safeBlockHorizontal * 15,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("Cancel", style: Centre.noteText),
                          ),
                        )),
                  ],
                );
              });
        }
      },
      child: Container(
        padding: EdgeInsets.all(Centre.safeBlockHorizontal),
        margin: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Centre.darkerShadowColor,
            spreadRadius: 0.01,
            blurRadius: 2,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Centre.lighterShadowColor,
            spreadRadius: 0.01,
            blurRadius: 12,
            offset: const Offset(-5, -5),
          )
        ], color: Centre.tileBgColor, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.delete,
          size: Centre.safeBlockHorizontal * 7,
          color: Centre.toolTextColor,
        ),
      ),
    );

    List<Widget> colorList = List<Widget>.generate(
        colors.length,
        (int index) => GestureDetector(
              onTap: () {
                // If selected, unselect it
                int prevColorIndex = context.read<ColorCubit>().state;
                if (index == prevColorIndex) {
                  context.read<ColorCubit>().update(-1);
                  contentController
                      .formatSelection(Attribute.clone(Attribute.color, null));
                } else {
                  contentController.formatSelection(ColorAttribute(
                      '#${colors[index].toRadixString(16).substring(2)}'));
                  context.read<ColorCubit>().update(index);
                }
              },
              child: BlocBuilder<ColorCubit, int>(
                builder: (context, state) => Container(
                  margin: EdgeInsets.only(
                      right: Centre.safeBlockHorizontal * 2,
                      top: Centre.safeBlockVertical * 1.1,
                      bottom: Centre.safeBlockVertical * 1.1),
                  decoration: state == index
                      ? BoxDecoration(
                          color: Centre.lighterShadowColor,
                          borderRadius: BorderRadius.circular(3))
                      : null,
                  child: Container(
                    margin: EdgeInsets.all(Centre.safeBlockHorizontal * 2),
                    decoration: BoxDecoration(
                        color: Color(colors[index]),
                        borderRadius: BorderRadius.circular(20)),
                    height: Centre.safeBlockHorizontal * 5,
                    width: Centre.safeBlockHorizontal * 5,
                  ),
                ),
              ),
            ),
        growable: false);

    if (currentNote.id == null) {
      FocusScope.of(context).requestFocus(titleFocus);
    }

    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        saveChangesTimer.cancel();
        // No need to save the data again if it was already saved
        if (!dataSavedWithBackClick) persistData();
        isNavigatingBack = true;
        // If data has already confirmed to be saved, go back, if not, keep waiting for NoteSaved
        return dataSavedWithBackClick;
      },
      child: Scaffold(
        backgroundColor: Centre.tileBgColor,
        body: BlocListener<NoteBloc, NoteState>(
          listener: (context, state) {
            if (state is NoteSaved) {
              currentNote.id ??= state.id;
              if (isNavigatingBack) {
                dataSavedWithBackClick = true;
                Navigator.maybePop(context);
              }
            } else if (state is NoteDeleted) {
              Navigator.maybePop(context);
            }
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                Centre.safeBlockHorizontal * 5,
                Centre.safeBlockVertical * 2,
                Centre.safeBlockHorizontal * 5,
                Centre.safeBlockVertical),
            child: BlocBuilder<ColorPressedCubit, bool>(
              builder: (context, colorPressed) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        backBtn,
                        const Expanded(child: SizedBox()),
                        // TODO: Put back once devs fix their issue
                        // undoBtn,
                        // redoBtn,
                        // const Expanded(child: SizedBox()),
                        deleteBtn,
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(
                            Centre.safeBlockVertical,
                            Centre.safeBlockVertical * 2,
                            Centre.safeBlockVertical,
                            0),
                        child: TextField(
                          cursorColor: Centre.accentColor,
                          style: Centre.titleNoteText,
                          maxLines: null,
                          focusNode: titleFocus,
                          decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "Title",
                              hintStyle: Centre.titleNoteText.copyWith(
                                  color: Centre.accentColor.withOpacity(0.50))),
                          controller: titleController,
                        )),
                    Container(
                      margin: EdgeInsets.only(
                          left: Centre.safeBlockHorizontal * 2.5,
                          bottom: Centre.safeBlockVertical * 1.5),
                      width: Centre.safeBlockHorizontal * 95,
                      height: Centre.safeBlockVertical * 0.5,
                      decoration: BoxDecoration(
                          color: Centre.accentColor,
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    Expanded(
                      child: QuillStyles(
                          data: DefaultStyles(
                              bold:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              italic:
                                  const TextStyle(fontStyle: FontStyle.italic),
                              underline: const TextStyle(
                                  decoration: TextDecoration.underline),
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
                            focusNode: contentFocus,
                            autoFocus: true,
                            expands: false,
                            padding: EdgeInsets.zero,
                            scrollController: scrollController,
                            scrollable: true,
                            readOnly: false,
                            controller: contentController,
                            keyboardAppearance: Brightness.dark,
                          )),
                    ),
                    colorPressed
                        ? SingleChildScrollView(
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            child: Row(children: colorList),
                          )
                        : const SizedBox(),
                    Toolbar(
                      controller: contentController,
                      contentFocusNode: contentFocus,
                    )
                  ]),
            ),
          ),
        ),
      ),
    ));
  }
}

class Toolbar extends StatefulWidget {
  final QuillController controller;
  final FocusNode contentFocusNode;
  const Toolbar(
      {super.key, required this.controller, required this.contentFocusNode});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    Widget chooseColorBtn = GestureDetector(
      onTap: () {
        context.read<ColorPressedCubit>().toggle();
        FocusScope.of(context).requestFocus(widget.contentFocusNode);
      },
      child: BlocBuilder<ColorPressedCubit, bool>(
        builder: (context, colorPressed) => Container(
          padding: EdgeInsets.all(Centre.safeBlockHorizontal),
          margin: EdgeInsets.only(right: Centre.safeBlockHorizontal * 3),
          decoration: BoxDecoration(
              boxShadow: colorPressed
                  ? null
                  : [
                      BoxShadow(
                        color: Centre.lighterShadowColor,
                        spreadRadius: 0.01,
                        blurRadius: 12,
                        offset: const Offset(-4, -4),
                      ),
                      BoxShadow(
                        color: Centre.darkerShadowColor,
                        spreadRadius: 0.01,
                        blurRadius: 2,
                        offset: const Offset(4, 4),
                      ),
                    ],
              color: Centre.tileBgColor,
              borderRadius: BorderRadius.circular(20)),
          child: Icon(
            Icons.palette,
            size: Centre.safeBlockHorizontal * 7,
            color: Centre.toolTextColor,
          ),
        ),
      ),
    );
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chooseColorBtn,
          ToolbarToggleBtn(
            attribute: Attribute.bold,
            icon: Icons.format_bold,
            controller: widget.controller,
          ),
          ToolbarToggleBtn(
            attribute: Attribute.italic,
            icon: Icons.format_italic,
            controller: widget.controller,
          ),
          ToolbarToggleBtn(
            attribute: Attribute.ul,
            controller: widget.controller,
            icon: Icons.format_list_bulleted,
          ),
          ToolbarToggleBtn(
            attribute: Attribute.codeBlock,
            controller: widget.controller,
            icon: Icons.code,
          ),
          ToolbarToggleBtn(
            attribute: Attribute.h3,
            icon: Icons.title,
            controller: widget.controller,
          ),
          ToolbarToggleBtn(
            attribute: Attribute.strikeThrough,
            icon: Icons.format_strikethrough,
            controller: widget.controller,
          ),
          ToolbarToggleBtn(
            attribute: Attribute.ol,
            controller: widget.controller,
            icon: Icons.format_list_numbered,
          ),
        ],
      ),
    );
  }
}

class ToolbarToggleBtn extends StatefulWidget {
  final IconData icon;
  final Attribute attribute;
  final QuillController controller;
  const ToolbarToggleBtn(
      {super.key,
      required this.attribute,
      required this.controller,
      required this.icon});

  @override
  State<ToolbarToggleBtn> createState() => _ToolbarToggleBtnState();
}

class _ToolbarToggleBtnState extends State<ToolbarToggleBtn> {
  late bool toggled;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void didChangeEditingValue() {
    setState(() {
      if (widget.attribute.key == "list") {
        toggled = widget.attribute.value ==
            widget.controller.getSelectionStyle().attributes["list"]?.value;
      } else {
        toggled = widget.controller
            .getSelectionStyle()
            .containsKey(widget.attribute.key);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    toggled = _selectionStyle.containsKey(widget.attribute.key);
    widget.controller.addListener(didChangeEditingValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.controller.formatSelection(toggled
              ? Attribute.clone(widget.attribute, null)
              : widget.attribute);
        });
      },
      child: Container(
        padding: EdgeInsets.all(Centre.safeBlockHorizontal),
        margin: EdgeInsets.only(
            right: Centre.safeBlockHorizontal * 3,
            top: Centre.safeBlockVertical * 1.1,
            bottom: Centre.safeBlockVertical * 1.1),
        decoration: BoxDecoration(
            boxShadow: toggled
                ? null
                : [
                    BoxShadow(
                      color: Centre.lighterShadowColor,
                      spreadRadius: 0.01,
                      blurRadius: 12,
                      offset: const Offset(-4, -4),
                    ),
                    BoxShadow(
                      color: Centre.darkerShadowColor,
                      spreadRadius: 0.01,
                      blurRadius: 2,
                      offset: const Offset(4, 4),
                    ),
                  ],
            color: Centre.tileBgColor,
            borderRadius: BorderRadius.circular(20)),
        child: Icon(
          widget.icon,
          size: Centre.safeBlockHorizontal * 7,
          color: Centre.toolTextColor,
        ),
      ),
    );
  }
}
