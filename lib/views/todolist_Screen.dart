import 'dart:async';
import 'package:flutter/material.dart';
import 'package:motilaloswaltest/views/search_Screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../views/tododetail_Screen.dart';
import 'package:sqflite/sqflite.dart';
import '../ViewModel/dbViewModel.dart';
import '../model/todos.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ToDoListState();
  }
}

class ToDoListState extends State<ToDoList> {
  DatabaseViewModel databaseHelper = DatabaseViewModel();
  List<ToDO> todoList;
  int count = 0;
  int axisCount = 4;

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = [];
      updateListView();
    }

    Widget myAppBar() {
      return AppBar(

        title: Text('Your ToDo', style: Theme.of(context).textTheme.headline5),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        leading: todoList.isEmpty
            ? Container()
            : IconButton(
                splashRadius: 22,
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final ToDO result = await showSearch(
                      context: context, delegate: ToDosSearch(todos: todoList));
                  if (result != null) {
                    navigateToDetail(result, 'Edit ToDo');
                  }
                },
              ),
        actions: <Widget>[
          todoList.isEmpty
              ? Container()
              : IconButton(
                  splashRadius: 22,
                  icon: Icon(
                    axisCount == 2 ? Icons.list : Icons.grid_on,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      axisCount = axisCount == 2 ? 4 : 2;
                    });
                  },
                )
        ],
      );
    }

    return Scaffold(
      appBar: myAppBar(),
      body: todoList.isEmpty
          ? Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Click on the add button to add a new ToDo!',
                      style: Theme.of(context).textTheme.bodyText2),
                ),
              ),
            )
          : Container(
              color: Colors.white,
              child: getToDosList(),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton(
          onPressed: () {
            navigateToDetail(ToDO('', '', 3, 0), 'Add ToDO');
          },
          tooltip: 'Add ToDO',
          shape: const CircleBorder(
              side: BorderSide(color: Colors.deepPurple, width: 1.0,)),
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.deepPurple,),
        ),
      ),
    );
  }

  Widget getToDosList() {
    return StaggeredGridView.countBuilder(
      physics: const BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(todoList[index], 'Edit ToDO');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          todoList[index].title,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ),
                    Text(
                      getSectionText(todoList[index].section),
                      style: TextStyle(
                          color: getSectionColor(todoList[index].section)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            todoList[index].description ?? '',
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(todoList[index].date,
                          style: Theme.of(context).textTheme.subtitle2),
                    ])
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  // Returns the section color
  Color getSectionColor(int section) {
    switch (section) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.teal;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the section icon
  String getSectionText(int section) {
    switch (section) {
      case 1:
        return 'Upcoming';
        break;
      case 2:
        return 'Tomorrow';
        break;
      case 3:
        return 'Today';
        break;

      default:
        return 'Today';
    }
  }

  void navigateToDetail(ToDO todo, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ToDoDetail(todo, title)));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<ToDO>> todoListFuture = databaseHelper.getToDoList();
      todoListFuture.then((todolist) {
        setState(() {
          todoList = todolist;
          count = todolist.length;
        });
      });
    });
  }
}
