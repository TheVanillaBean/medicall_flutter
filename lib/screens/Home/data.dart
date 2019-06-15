import 'package:flutter/material.dart';
//import 'styles.dart';

class RowBoxData {
  String title;
  String subtitle;
  DecorationImage image;
  RowBoxData({this.subtitle, this.title, this.image});
}

class DataListBuilder {
  List<RowBoxData> rowItemList = List<RowBoxData>();
  RowBoxData row1 = RowBoxData(
      title: 'Catch up with Tom',
      subtitle: '5 - 6pm  Hangouts');
  RowBoxData row2 = RowBoxData(
      title: 'Yoga classes with Emily',
      subtitle: '7 - 8am Workout',);
  RowBoxData row3 = RowBoxData(
      title: 'Breakfast with Harry', subtitle: '9 - 10am ',);
  RowBoxData row4 = RowBoxData(
      title: 'Meet Pheobe ', subtitle: '12 - 1pm  Meeting', );
  RowBoxData row5 = RowBoxData(
      title: 'Lunch with Janet and friends',
      subtitle: '2 - 3pm ',);
  RowBoxData row6 = RowBoxData(
      title: 'Catch up with Tom',
      subtitle: '5 - 6pm  Hangouts', 
      );
  RowBoxData row7 = RowBoxData(
      title: 'Party at Hard Rock',
      subtitle: '8 - 12 Pub and Restaurant',);
  RowBoxData row8 = RowBoxData(
      title: 'Yoga classes with Emily',
      subtitle: '7 - 8am Workout',);

  DataListBuilder() {
    rowItemList.add(row1);
    rowItemList.add(row2);
    rowItemList.add(row3);
    rowItemList.add(row4);
    rowItemList.add(row5);
    rowItemList.add(row6);
    rowItemList.add(row7);
    rowItemList.add(row8);
  }
}