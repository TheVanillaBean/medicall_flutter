import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  const ListItemsBuilder({
    Key key,
    @required this.snapshot,
    @required this.itemBuilder,
    @required this.displayEmptyContent,
  }) : super(key: key);
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final bool displayEmptyContent;
  @override
  Widget build(BuildContext context) {
    if (snapshot != null && snapshot.hasData) {
      final List<T> items = snapshot.data;
      if (items.isNotEmpty) {
        return _buildList(items, context);
      } else {
        return displayEmptyContent ? const EmptyContent() : Container();
      }
    } else if (snapshot != null && snapshot.hasError) {
      return const EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<T> items, context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length + 2,
      separatorBuilder: (context, index) => const Divider(height: 0.5),
      itemBuilder: (context, index) {
        if (index == 0 || index == items.length + 1) {
          return Container(); // zero height: not visible
        }
        return itemBuilder(context, items[index - 1]);
      },
    );
  }
}
