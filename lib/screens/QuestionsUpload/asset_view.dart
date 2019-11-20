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
  int _index = 0;
  Asset _asset;
  ByteData byteData;
  List<int> imageData;
  AssetState(this._index, this._asset);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    byteData = await this._asset.getByteData(quality: 100);

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
        byteData.buffer.asUint8List(),
        fit: BoxFit.contain,
      );
  }
}
