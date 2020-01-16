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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          byteData = snapshot.data;
          // YOUR CUSTOM CODE GOES HERE
          return Image.memory(
            byteData.buffer.asUint8List(),
            fit: BoxFit.fitWidth,
            height: MediaQuery.of(context).size.height - 250,
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }
      },
      future: widget._asset.getByteData(quality: 100),
    );
  }
}
