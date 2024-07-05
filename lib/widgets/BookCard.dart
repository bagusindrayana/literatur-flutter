import 'package:flutter/material.dart';

//make statefull widget BookCard that contain title and thumbnail of the book
class BookCard extends StatefulWidget {
  final String title;
  final Image? thumbnail;
  final bool? selectMode;
  final bool? isSelected;
  final Function? onSelect;
  final Function? onLongPress;

  BookCard(
      {required this.title,
      this.thumbnail,
      this.selectMode,
      this.isSelected,
      this.onSelect,
      this.onLongPress});

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool isSelected = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isSelected = widget.isSelected ?? false;
    });
    print("BOOK");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: InkWell(
        onLongPress: () {
          if (widget.selectMode != null && widget.selectMode! == false) {
            isSelected = true;
          }
          if (widget.onLongPress != null) {
            widget.onLongPress!();
          }
        },
        child: Stack(children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Expanded(
                    child: widget.thumbnail != null
                        ? AspectRatio(
                            aspectRatio: 1,
                            child: widget.thumbnail!,
                          )
                        : Container()),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(widget.title),
                ),
              ],
            ),
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
    );
  }
}
