import 'package:flutter/material.dart';

class SectionChoice extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;
  const SectionChoice({Key key, this.onTap, this.selectedIndex})
      : super(key: key);

  @override
  _SectionChoiceState createState() => _SectionChoiceState();
}

class _SectionChoiceState extends State<SectionChoice> {

  int selectedIndex;
  List<String> sectionsText = ['Today', 'Tomorrow', 'Upcoming'];

  @override
  Widget build(BuildContext context) {
    selectedIndex ??= widget.selectedIndex;
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onTap(index);
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: width / 3,
              height: 70,
              child: Center(
                child: Text(sectionsText[index],
                    style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.deepPurple
                            : Colors.black54,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}
