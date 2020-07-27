import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

//items can either come from a snapshot or an items list
//if itemsList is true, then snapshot should be false
class ListItemsBuilder<T> extends StatelessWidget {
  const ListItemsBuilder({
    Key key,
    @required this.snapshot,
    this.itemsList,
    @required this.itemBuilder,
    this.displayEmptyContentView = true,
    this.scrollable = true,
  }) : assert((snapshot == null && itemsList != null) ||
            (snapshot != null && itemsList == null));
  final AsyncSnapshot<List<T>> snapshot;
  final List<T> itemsList;
  final ItemWidgetBuilder<T> itemBuilder;
  final bool displayEmptyContentView;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (snapshot != null && snapshot.hasData) {
      final List<T> items = snapshot.data;
      if (items.isNotEmpty) {
        return _buildList(items, context);
      } else {
        return displayEmptyContentView ? const EmptyContent() : Container();
      }
    } else if (this.itemsList != null) {
      if (itemsList.isNotEmpty) {
        return _buildList(itemsList, context);
      } else {
        return displayEmptyContentView ? const EmptyContent() : Container();
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
    final _controller = ScrollController();
    return FadingEdgeScrollView.fromScrollView(
      child: ListView.builder(
        controller: _controller,
        physics: scrollable
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length + 2,
        itemBuilder: (context, index) {
          if (index == 0 || index == items.length + 1) {
            return Container(); // zero height: not visible
          }
          return itemBuilder(context, items[index - 1]);
        },
      ),
    );
  }
}
