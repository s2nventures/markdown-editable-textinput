import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';

/// Widget with markdown buttons
class MarkdownTextInput extends StatefulWidget {
  /// Callback called when text changed
  final ValueChanged<String> onTextChanged;

  /// Initial value you want to display
  final String initialValue;

  /// Validator for the TextFormField
  final String? Function(String? value)? validator;

  /// String displayed in [InputDecoration.labelText]
  final String? label;

  /// String displayed in [InputDecoration.hintText]
  final String? hint;

  /// String displayed in [InputDecoration.helperText]
  final String? helper;

  /// Radius of the border
  final BorderRadius? borderRadius;

  /// Color of the border
  final Color? borderColor;

  /// Change the text direction of the input (RTL / LTR)
  final TextDirection? textDirection;

  /// The maximum of lines that can be display in the input
  final int? maxLines;

  /// List of action the component can handle
  final List<MarkdownType> actions;

  /// Focus node for input
  final FocusNode? focusNode;

  /// Optional controller to manage the input
  final TextEditingController? controller;

  /// Keyboard type (e.g. [TextInputType.multiline])
  final TextInputType? keyboardType;

  /// The primary action button on the keyboard (e.g. [TextInputAction.done])
  final TextInputAction? textInputAction;

  /// An icon for the input decoration
  final Widget? icon;

  /// Constructor for [MarkdownTextInput]
  MarkdownTextInput(
    this.onTextChanged,
    this.initialValue, {
    this.borderRadius,
    this.borderColor,
    this.label,
    this.hint,
    this.helper,
    this.validator,
    this.textDirection = TextDirection.ltr,
    this.maxLines = 10,
    this.actions = const [
      MarkdownType.bold,
      MarkdownType.italic,
      MarkdownType.title,
      MarkdownType.link,
      MarkdownType.list
    ],
    this.focusNode,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.icon,
  });

  @override
  _MarkdownTextInputState createState() =>
      _MarkdownTextInputState(controller ?? TextEditingController());
}

class _MarkdownTextInputState extends State<MarkdownTextInput> {
  final TextEditingController _controller;
  TextSelection textSelection =
      const TextSelection(baseOffset: 0, extentOffset: 0);

  _MarkdownTextInputState(this._controller);

  void onTap(MarkdownType type, {int titleSize = 1}) {
    final basePosition = textSelection.baseOffset;
    var noTextSelected =
        (textSelection.baseOffset - textSelection.extentOffset) == 0;

    final result = FormatMarkdown.convertToMarkdown(type, _controller.text,
        textSelection.baseOffset, textSelection.extentOffset,
        titleSize: titleSize);

    _controller.value = _controller.value.copyWith(
        text: result.data,
        selection:
            TextSelection.collapsed(offset: basePosition + result.cursorIndex));

    if (noTextSelected) {
      _controller.selection = TextSelection.collapsed(
          offset: _controller.selection.end - result.replaceCursorIndex);
    }
  }

  @override
  void initState() {
    _controller.text = widget.initialValue;
    _controller.addListener(() {
      if (_controller.selection.baseOffset != -1)
        textSelection = _controller.selection;
      widget.onTextChanged(_controller.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: widget.borderColor ?? Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
        borderRadius:
            widget.borderRadius ?? const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          TextFormField(
            textInputAction: widget.textInputAction ?? TextInputAction.newline,
            maxLines: widget.maxLines,
            controller: _controller,
            focusNode: widget.focusNode,
            textCapitalization: TextCapitalization.sentences,
            validator: widget.validator,
            textDirection: widget.textDirection,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              icon: widget.icon,
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              labelText: widget.label,
              hintText: widget.hint,
              hintStyle:
                  const TextStyle(color: Color.fromRGBO(63, 61, 86, 0.5)),
              helperText: widget.helper,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
          ),
          SizedBox(
            height: 44,
            child: Material(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x1AFFFFFF)
                  : const Color(0x0A000000),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.actions.map((type) {
                  return type == MarkdownType.title
                      ? ExpandableNotifier(
                          child: Expandable(
                            key: Key('H#_button'),
                            collapsed: ExpandableButton(
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'H#',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            expanded: Container(
                              color: Colors.white10,
                              child: Row(
                                children: [
                                  for (int i = 1; i <= 6; i++)
                                    InkWell(
                                      key: Key('H${i}_button'),
                                      onTap: () => onTap(MarkdownType.title,
                                          titleSize: i),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          'H$i',
                                          style: TextStyle(
                                              fontSize: (18 - i).toDouble(),
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ExpandableButton(
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.close,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          key: Key(type.key),
                          onTap: () => onTap(type),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(type.icon),
                          ),
                        );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
