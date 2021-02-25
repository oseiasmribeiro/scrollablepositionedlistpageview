class BibleModel {
	String _book;
	List<List> _chapters;

	BibleModel(String book, List<List> chapters) {
    this._book = book;
    this._chapters = chapters;
  }

	String get book => _book;
	
	List<List> get chapters => _chapters;

	BibleModel.fromJson(Map<String, dynamic> json) {
		_book = json['book'];
		if (json['chapters'] != null) {
			_chapters = List<List>();
			json['chapters'].forEach(
        (chapter) { 
          _chapters.add(List.from(chapter)); 
        }
      );
		}
	}
}