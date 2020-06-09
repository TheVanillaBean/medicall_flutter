import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/screens/Questions/option_item_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OptionListItem extends StatefulWidget {
  final OptionListViewModel model;

  final String type;
  final Option option;
  final VoidCallback onTap;
  final VoidCallback onInput;

  const OptionListItem({
    @required this.type,
    @required this.option,
    @required this.onTap,
    @required this.onInput,
    @required this.model,
  });

  static Widget create({
    @required BuildContext context,
    @required String type,
    @required Option option,
    @required VoidCallback onTap,
    @required VoidCallback onInput,
  }) {
    return ChangeNotifierProvider<OptionListViewModel>(
      create: (context) => OptionListViewModel(),
      child: Consumer<OptionListViewModel>(
        builder: (_, model, __) => OptionListItem(
          model: model,
          type: type,
          option: option,
          onInput: onInput,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  _OptionListItemState createState() => _OptionListItemState();
}

class _OptionListItemState extends State<OptionListItem> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  OptionListViewModel get model => widget.model;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == "FR") {
      return _buildFreeResponseOption(context);
    }
    return _buildMultipleChoiceOption(context);
  }

  Widget _buildMultipleChoiceOption(BuildContext context) {
    return Container(
      height: 90,
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.lightBlue,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    widget.option.value,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeResponseOption(BuildContext context) {
    return Expanded(child: Column());
  }

  TextField _buildFRTextField() {
    return TextField(
      controller: _inputController,
      focusNode: _inputFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(100),
        labelText: 'Enter response',
        errorText: model.inputErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }
}
//model.selected = opt;
//          model.nextPage();

//child: Row(
//children: [
//Icon(
//model.selected == opt ? Icons.create : Icons.cached,
//size: 30),
//Expanded(
//child: Container(
//margin: EdgeInsets.only(left: 16),
//child: Text(
//opt.value,
//style: Theme.of(context).textTheme.bodyText1,
//),
//),
//)
//],
//),
