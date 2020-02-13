import 'package:Medicall/screens/History/doctorSearch.dart';
import 'package:Medicall/screens/History/history_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';

List<Widget> buildActions(
      context, HistoryState _userHistoryState, Database _db) {
    return [
      Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            DropdownButtonHideUnderline(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PopupMenuButton(
                  offset: Offset(0.0, 80.0),
                  icon: Icon(Icons.sort),
                  onSelected: (val) {
                    _userHistoryState.sortBy = val;
                    _userHistoryState.setUserHistory(_db.userHistory);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        "Newest",
                        style: TextStyle(
                            color: _userHistoryState.sortBy == 1
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        "Alphabetical",
                        style: TextStyle(
                            color: _userHistoryState.sortBy == 2
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        "New Status",
                        style: TextStyle(
                            color: _userHistoryState.sortBy == 3
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Text(
                        "In Progress",
                        style: TextStyle(
                            color: _userHistoryState.sortBy == 4
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 5,
                      child: Text(
                        "Needs Payment",
                        style: TextStyle(
                            color: _userHistoryState.sortBy == 5
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 6,
                      child: Text(
                        "Done Status",
                        style: TextStyle(
                            color: _userHistoryState.sortBy == 6
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            ),
          ],
        ),
      ),
      userHasConsults
          ? showSearch(
              context: context,
              delegate: CustomSearchDelegate(),
            )
          : SizedBox(
              width: 0,
            ),
    ];
  }