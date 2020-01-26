import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AssetView extends StatefulWidget {
  final int _index;
  final Asset _asset;

  AssetView(
    this._index,
    this._asset, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AssetState(this._index, this._asset);
}

class AssetState extends State<AssetView> {
  ByteData byteData;
  List<int> imageData;
  AssetState(_index, _asset);
  Uint8List thisByte;

  @override
  void initState() {
    super.initState();
    _getByteData();
  }

  _getByteData() async {
    return await widget._asset.getByteData(quality: 100).then((onValue) {
      setState(() {
        thisByte = onValue.buffer.asUint8List();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AssetThumb(
      asset: widget._asset,
      width: MediaQuery.of(context).size.width.toInt(),
      height: MediaQuery.of(context).size.height.toInt(),
      spinner: Center(
        child: Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
