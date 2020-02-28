import 'package:Medicall/screens/History/doctorSearch.dart';
import 'package:Medicall/screens/History/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

List<Widget> buildActions(BuildContext context, HistoryState model) {
  return [
    Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        Container(
            width: ScreenUtil.screenWidthDp,
            padding: EdgeInsets.only(bottom: 3),
            child: Text(
              'History',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20.0,
              ),
            )),
        Row(
          children: <Widget>[
            DropdownButtonHideUnderline(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PopupMenuButton(
                  offset: Offset(0.0, 80.0),
                  icon: Icon(
                    Icons.sort,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onSelected: (val) {
                    model.sortBy = val;
                    model.setUserHistory(model.db.userHistory);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        "Newest",
                        style: TextStyle(
                            color: model.sortBy == 1
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        "Alphabetical",
                        style: TextStyle(
                            color: model.sortBy == 2
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        "New Status",
                        style: TextStyle(
                            color: model.sortBy == 3
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Text(
                        "In Progress",
                        style: TextStyle(
                            color: model.sortBy == 4
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 5,
                      child: Text(
                        "Needs Payment",
                        style: TextStyle(
                            color: model.sortBy == 5
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                    PopupMenuItem(
                      value: 6,
                      child: Text(
                        "Done Status",
                        style: TextStyle(
                            color: model.sortBy == 6
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            )
          ],
        ),
      ],
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
