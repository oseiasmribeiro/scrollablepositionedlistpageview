import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/bible-model.dart';

class BibleBloc {

  List<BibleModel> _bibleData = [];

  //=========================================================================================
  final _pageCurrentNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> get listChapterLength => _pageCurrentNotifier;

  setPageCurrent(int page){
    listChapterLength.value = page;
  }

  //=========================================================================================
  final _bibleDataNotifier = ValueNotifier<List<BibleModel>>(null);
  ValueNotifier<List<BibleModel>> get bibleData => _bibleDataNotifier;

  getBibleData() async{
    var v = await rootBundle.loadString('assets/bible.json');
    _bibleData = parseJosn(v.toString());
    bibleData.value = List.from(_bibleData);
  }

  List<BibleModel> parseJosn(String response) {
    if(response == null){
      return [];
    }
    final parsed = json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<BibleModel>((json) => BibleModel.fromJson(json)).toList();
  }

  //=========================================================================================
  final _listTextVersesInChapterNotifier = ValueNotifier<List<String>>(null);
  ValueNotifier<List<String>> get listTextVersesInChapter => _listTextVersesInChapterNotifier;

  getListTextVersesInChapter(int chapter){
    List<String> list = [];
    for(int x = 0; x < _bibleData[0].chapters[chapter].length ; x++){
      list.add(_bibleData[0].chapters[chapter][x]);
    }
    print(list is List<String>);
    listTextVersesInChapter.value = List.from(list);
  }

  //=========================================================================================
  final _currentChapterNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> get currentChapter => _currentChapterNotifier;

  setCurrentChapter(int chapter){
    currentChapter.value = chapter;
  }

}
