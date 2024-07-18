import 'package:flutter/material.dart';

//make statefull widget BookCard that contain title and thumbnail of the book
class BookCard extends StatefulWidget {
  final String title;
  final Image? thumbnail;
  final bool? selectMode;
  final bool? isSelected;
  final Function? onSelect;
  final Function? onLongPress;
  final Function? onTap;

  BookCard(
      {required this.title,
      this.thumbnail,
      this.selectMode,
      this.isSelected,
      this.onSelect,
      this.onLongPress,
      this.onTap});

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool isSelected = false;

  @override
  void didUpdateWidget(BookCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectMode != widget.selectMode) {
      setState(() {
        isSelected = widget.isSelected ?? false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isSelected = widget.isSelected ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onLongPress: () {
          if (widget.selectMode != null && widget.selectMode == false) {
            isSelected = true;
          }
          if (widget.onLongPress != null) {
            widget.onLongPress!();
          }
        },
        onTap: () {
          if (widget.selectMode == true) {
            setState(() {
              isSelected = !isSelected;
            });
            if (widget.onSelect != null) {
              widget.onSelect!(isSelected);
            }
          }
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: Column(
          children: [
            Container(
              height: 150,
              color: Colors.grey,
              child: Stack(children: [
                Align(
                  alignment: Alignment.center,
                  child: widget.thumbnail != null
                      ? AspectRatio(
                          aspectRatio: 1,
                          child: widget.thumbnail!,
                        )
                      : Container(),
                ),
                //checkbox
                if (widget.selectMode != null && widget.selectMode!)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                        child: Icon(isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank),
                        onTap: () {
                          setState(() {
                            isSelected = !isSelected;
                          });
                          if (widget.onSelect != null) {
                            widget.onSelect!(isSelected);
                          }
                        }),
                  ),
              ]),
            ),
            Text(widget.title),
          ],
        ),
      ),
    );
  }
}
