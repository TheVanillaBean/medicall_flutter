import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Created by Luciferx86 on 08/09/20.
class ProgressTimeline extends StatefulWidget {
  /// a List of all states to be rendered
  final List<SingleState> states;

  /// optional: a List of all completed steps (used when initializing previously saved visit from firestore)
  List<SingleState> completedStates;

  /// height of the widget
  final double height;

  /// Icon used to render a checked stage
  final Icon checkedIcon;

  /// Icon used to render current stage
  final Icon currentIcon;

  /// Icon used to render a failed stage
  final Icon failedIcon;

  /// Icon used to render an unchecked stage
  final Icon uncheckedIcon;

  /// Color of the connectors
  final Color connectorColor;

  /// Length of the connectors
  final double connectorLength;

  /// Width of the connectors
  final double connectorWidth;

  ///Size of Icons rendered in each stage
  final double iconSize;

  /// Style of text used to display stage title
  final TextStyle textStyle;

  /// Curve for Transition can be added, defaults to
  final Curve transitionCurve;

  final Function onTap;

  ProgressTimeline({
    @required this.states,
    this.completedStates,
    this.onTap,
    this.height,
    this.checkedIcon,
    this.currentIcon,
    this.failedIcon,
    this.iconSize,
    this.textStyle,
    this.connectorLength,
    this.connectorWidth,
    this.connectorColor,
    this.uncheckedIcon,
    this.transitionCurve = Curves.fastOutSlowIn,
  });

  final _ProgressTimelineState state = new _ProgressTimelineState();

  void completeStep({SingleState singleState, bool setState}) {
    state.completeStep(state: singleState, shouldSetState: setState);
  }

  void unCompleteStep({SingleState singleState, bool setState}) {
    state.unCompleteStep(state: singleState, shouldSetState: setState);
  }

  /// method to jump to next stage in the process.
  void gotoNextStage() {
    state.gotoNextStage();
  }

  /// method to mark the current stage as failed.
  void failCurrentStage() {
    state.failCurrentStage();
  }

  /// method to go back to previous stage in the process.
  void gotoPreviousStage() {
    state.gotoPreviousStage();
  }

  @override
  _ProgressTimelineState createState() => state;
}

class _ProgressTimelineState extends State<ProgressTimeline> {
  int currentStageIndex = 0;
  List<SingleState> states;
  List<SingleState> completedStates = [];
  Function onTap;
  double height = 100;

  final _controller = ItemScrollController();

  @override
  void initState() {
    states = widget.states;
    if (widget.completedStates != null) {
      completedStates = states;
    }
    onTap = widget.onTap;
    if (widget.height != null) {
      height = widget.height;
    }
    super.initState();
  }

  void gotoNextStage() {
    setState(() {
      if (currentStageIndex <= states.length - 1) {
        currentStageIndex++;
        _controller.scrollTo(
          index: currentStageIndex - 1,
          duration: Duration(milliseconds: 1000),
          curve: widget.transitionCurve,
        );
      }
    });
  }

  void gotoPreviousStage() {
    setState(() {
      if (currentStageIndex >= 0) {
        if (currentStageIndex > 0) currentStageIndex--;
        states[currentStageIndex].isFailed = false;
      }

      if (currentStageIndex > 0) {
        _controller.scrollTo(
          index: currentStageIndex - 1 >= 0
              ? currentStageIndex - 1
              : currentStageIndex,
          duration: Duration(milliseconds: 1000),
          curve: widget.transitionCurve,
        );
      }
    });
  }

  void failCurrentStage() {
    setState(() {
      states[currentStageIndex].isFailed = true;
    });
  }

  void goToStage(int index) {
    setState(() {
      if (index >= 0 && index <= states.length - 1) {
        if (index != currentStageIndex) {
          currentStageIndex = index;
          _controller.scrollTo(
            index: currentStageIndex - 1 >= 0
                ? currentStageIndex - 1
                : currentStageIndex,
            duration: Duration(milliseconds: 1000),
            curve: widget.transitionCurve,
          );
        }
      }
    });
  }

  // set state will cause issues if used when initializing from firestore
  // look into initFromFirestore in each step state
  void completeStep({SingleState state, bool shouldSetState}) {
    if (shouldSetState) {
      setState(() {
        if (!this.completedStates.contains(state)) {
          this.completedStates.add(state);
        }
      });
    } else {
      if (!this.completedStates.contains(state)) {
        this.completedStates.add(state);
      }
    }
  }

  void unCompleteStep({SingleState state, bool shouldSetState}) {
    if (shouldSetState) {
      setState(() {
        this.completedStates.remove(state);
      });
    } else {
      this.completedStates.remove(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: ScrollablePositionedList.builder(
        itemCount: buildStates().length,
        itemScrollController: _controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              this.onTap(index);
              this.goToStage(index);
            },
            child: buildStates()[index],
          );
        },
      ),
    );
  }

  List<Widget> buildStates() {
    List<Widget> allStates = [];
    for (var i = 0; i < states.length; i++) {
      allStates.add(_RenderedState(
        textStyle: widget.textStyle,
        connectorLength: widget.connectorLength,
        connectorWidth: widget.connectorWidth,
        connectorColor: widget.connectorColor,
        iconSize: widget.iconSize,
        checkedIcon: widget.checkedIcon,
        failedIcon: widget.failedIcon,
        currentIcon: widget.currentIcon,
        uncheckedIcon: widget.uncheckedIcon,
        stateNumber: i + 1,
        isCurrent: i == currentStageIndex,
        isFailed: states[i].isFailed,
        isChecked: completedStates.contains(states[i]),
        stateTitle: states[i].stateTitle,
        isLeading: i == 0,
        isTrailing: i == states.length - 1,
      ));
    }

    return allStates;
  }
}

class _RenderedState extends StatelessWidget {
  final Icon checkedIcon;
  final Icon currentIcon;
  final Icon failedIcon;
  final Icon uncheckedIcon;
  final bool isChecked;
  final String stateTitle;
  final TextStyle textStyle;
  final bool isLeading;
  final bool isTrailing;
  final int stateNumber;
  final bool isFailed;
  final bool isCurrent;
  final double iconSize;
  final Color connectorColor;
  final double connectorLength;
  final double connectorWidth;

  _RenderedState({
    @required this.isChecked,
    @required this.stateTitle,
    @required this.stateNumber,
    double iconSize,
    Color connectorColor,
    double connectorLength,
    double connectorWidth,
    TextStyle textStyle,
    this.failedIcon,
    this.currentIcon,
    this.checkedIcon,
    this.uncheckedIcon,
    this.isFailed = false,
    this.isCurrent,
    this.isLeading = false,
    this.isTrailing = false,
  })  : this.iconSize = iconSize ?? 25,
        this.connectorColor = connectorColor ?? Colors.green,
        this.connectorLength =
            connectorLength != null ? connectorLength / 2 : 40,
        this.connectorWidth = connectorWidth ?? 5,
        this.textStyle = textStyle ?? TextStyle();

  Widget line() {
    return Container(
      color: connectorColor,
      height: connectorWidth,
      width: connectorLength,
    );
  }

  Widget spacer() {
    return Container(
      width: 3.0,
    );
  }

  Widget getCheckedIcon() {
    return this.checkedIcon != null
        ? Icon(
            this.checkedIcon.icon,
            color: this.checkedIcon.color,
            size: iconSize,
          )
        : Icon(
            Icons.check_circle,
            color: Colors.green,
            size: iconSize,
          );
  }

  Widget getFailedIcon() {
    return this.failedIcon != null
        ? Icon(
            this.failedIcon.icon,
            color: this.failedIcon.color,
            size: iconSize,
          )
        : Icon(
            Icons.highlight_off,
            color: Colors.redAccent,
            size: iconSize,
          );
  }

  Widget getCurrentIcon() {
    return this.currentIcon != null
        ? Icon(
            this.currentIcon.icon,
            color: this.currentIcon.color,
            size: iconSize,
          )
        : Icon(
            Icons.adjust,
            color: Colors.green,
            size: iconSize,
          );
  }

  Widget getUnCheckedIcon() {
    return this.uncheckedIcon != null
        ? Icon(
            this.uncheckedIcon.icon,
            color: this.uncheckedIcon.color,
            size: iconSize,
          )
        : Icon(
            Icons.radio_button_unchecked,
            color: Colors.green,
            size: iconSize,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: isLeading
              ? const EdgeInsets.only(left: 30.0)
              : isTrailing
                  ? const EdgeInsets.only(right: 30.0)
                  : const EdgeInsets.all(0.0),
          child: Row(
            children: [
              if (!isLeading) line(),
              renderCurrentState(),
              if (!isTrailing) line(),
            ],
          ),
        ),
        Container(
          child: Text(
            stateTitle,
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Widget renderCurrentState() {
    if (isFailed != null && isFailed) {
      return getFailedIcon();
    } else if (isChecked != null && isChecked) {
      return getCheckedIcon();
    } else if (isCurrent != null && isCurrent) {
      return getCurrentIcon();
    }
    return getUnCheckedIcon();
  }
}

class SingleState {
  /// Do not use this explicitly(in most cases)
  bool isFailed;

  /// Title of a state
  String stateTitle;

  SingleState({@required this.stateTitle, this.isFailed});
}
