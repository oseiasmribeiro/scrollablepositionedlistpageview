import 'package:flutter/material.dart';
import 'package:flutter_app/bible-bloc.dart';
import 'package:flutter_app/bible-model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Bible extends StatefulWidget {

  Bible({key}) : super(key: key);

  @override
  _BibleState createState() => _BibleState();

}

class _BibleState extends State<Bible> {

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionListener = ItemPositionsListener.create();
  final BibleBloc _bloc = BibleBloc();
  final TextEditingController _textEditingController = TextEditingController();

  PageController _controller;
  
  int initialChapter = 1;
  int _currentChapter = 0;
  int _totalChapters = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: initialChapter, keepPage: true);
    super.initState();
  }

  void _mbsChangeChapter(BuildContext context, int totalChapterInBook){
    showModalBottomSheet(
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Capítulos", style: TextStyle(fontSize: 16))
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                crossAxisCount: 5,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10.0,
                childAspectRatio: 1,
                children: List.generate(totalChapterInBook, (index) {
                  return GestureDetector(
                    onTap: (){
                      _controller.jumpToPage(index);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Center(
                              child: Text("${index + 1}",
                                style: TextStyle(
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  );
                })
              ),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    _bloc.getBibleData();

    return ValueListenableBuilder<List<BibleModel>>(
      valueListenable: _bloc.bibleData,
      builder: (context, bibleData, child){

        if (bibleData == null){
          return Center(
              child: CircularProgressIndicator()
          );
        }

        _totalChapters = bibleData[0].chapters.length;

        _bloc.setCurrentChapter(initialChapter);
        
        return MaterialApp(
          title: 'Bible',
          debugShowCheckedModeBanner: false,
          home: ValueListenableBuilder<int>(
            valueListenable: _bloc.currentChapter,
            builder: (context, currentChapter, child){

              _bloc.getListTextVersesInChapter(currentChapter - 1);

              return Scaffold(
                appBar: AppBar(
                  title: Text("$currentChapter"),
                ),
                body: Column(
                  children: <Widget>[
                    Expanded(
                      child: PageView.builder(
                        onPageChanged: (page){
                          _currentChapter = page + 1;
                          _bloc.getListTextVersesInChapter(_currentChapter - 1);
                          _bloc.setCurrentChapter(_currentChapter);
                        },
                        controller: _controller,
                        itemCount: _totalChapters,
                        itemBuilder: (context, position){

                          _currentChapter = position;

                          return ValueListenableBuilder<List<dynamic>>(
                            valueListenable: _bloc.listTextVersesInChapter,
                            builder: (context, listTextVersesInChapter, child){

                              if (listTextVersesInChapter == null){
                                return Center(
                                    child: CircularProgressIndicator()
                                );
                              }

                              if(listTextVersesInChapter.isNotEmpty){
                                return Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: ScrollablePositionedList.builder(
                                        initialScrollIndex: _currentChapter == 3 ? 10 : 0, 
                                        initialAlignment: 0,
                                        itemScrollController: _itemScrollController,
                                        itemPositionsListener: _itemPositionListener,
                                        itemCount: listTextVersesInChapter.length,
                                        itemBuilder: (context, index){
                                          return Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 12, top: 2, right: 12, bottom: 2),
                                              child: Container(
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(text: "${index + 1} - ", style: TextStyle(color: Colors.blue)),
                                                      TextSpan(text: listTextVersesInChapter[index], style: TextStyle(color: Colors.black))
                                                    ]
                                                  )
                                                )
                                              )
                                            )
                                          );
                                        }
                                      ) 
                                    ),
                                  ]
                                ); 
                              }else{
                                return Center(
                                    child: CircularProgressIndicator()
                                );
                              }
                            },
                          );
                        }
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _currentChapter > 1 ?
                          FlatButton(
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.arrow_back)
                            ),
                            onPressed: () => {
                              _controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                            }
                          ) : Container(
                            padding: EdgeInsets.only(right: 25, left: 25),
                            width: 88,
                            height: 50
                          ),
                          SizedBox(width: 44),
                          GestureDetector(
                            child: Icon(Icons.apps),
                            onTap: (){
                              _mbsChangeChapter(context, _totalChapters);
                            },
                          ),
                          SizedBox(width: 44),
                          _currentChapter < _totalChapters ?
                          FlatButton(
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.arrow_forward)
                            ),
                            onPressed: () => {
                              _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                            }
                          ) : Container(
                            padding: EdgeInsets.only(right: 25, left: 25),
                            width: 88,
                            height: 50
                          )
                        ]
                      )
                    )
                  ],
                ) 
              );
            }
          )
        );
      }
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
