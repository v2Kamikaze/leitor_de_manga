import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leitor_de_manga/pages/chapter_page.dart';
import 'package:leitor_de_manga/scraper/data_save.dart/save.dart';
import 'package:leitor_de_manga/scraper/scraper.dart';
import 'package:transparent_image/transparent_image.dart';

class MangaPage extends StatefulWidget {
  final UnionScraper scraper;
  final String title;

  MangaPage({required this.scraper, required this.title});

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  bool _isFavorited = false;
  bool _inList = true;
  late PageController _controller;
  late ScrollController _scrollController;
  late Map data;
  late int _currentTile;
  Save save = Save();
  bool readedFile = false;

  @override
    void initState() {
      super.initState();
      _controller = PageController(initialPage: 0);
      _scrollController = ScrollController();
      widget.scraper.title = widget.title;
      widget.scraper.getChapters().then(
        (value) => setState((){
          data = value!;
        })
      );
      save.readFile().then((_) {
        setState((){
          readedFile = true;
          for(var manga in save.data) {
            if(manga[widget.title] != null){
              _isFavorited = manga[widget.title]["fav"];
            }
          }
        });
      });

  }

  @override
  Widget build(BuildContext context) {

    double appbarHeight = AppBar().preferredSize.height;
    double paddingTop = MediaQuery.of(context).padding.top;
    double height = MediaQuery.of(context).size.height - appbarHeight - paddingTop;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF050B18),
        centerTitle: true,
        title: Text(
          "${widget.title}",
          style: GoogleFonts.bangers(
            fontSize: 30.0,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                _isFavorited ? Icons.star : Icons.star_border,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: (){
                if(readedFile){
                  setState((){
                    _isFavorited = !_isFavorited;
                    if(!_isFavorited) {
                      for(var i = 0 ; i < save.data.length; i++){
                        if(save.data[i].containsKey(widget.title)) {
                          save.data.removeAt(i);
                          break;
                        }
                      }
                    }else {
                      save.add(
                        widget.title,
                        {
                          "fav": _isFavorited,
                          "lastReaded": _currentTile,
                          "coverUrl": data['cover'],
                        }
                      );
                    }
                  });
                }
              }
            ),
          ),
        ], systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: data == null
      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF050B18))),)
      : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            height: height * 0.4,
            child: Row(
              children: <Widget>[
                Card(
                  elevation: 5.0,
                  shadowColor: Color(0xFF1F2430),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: data['cover'],
                      width: width * 0.3,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  width: width * 0.5,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: List.generate(
                      data['info'].length,
                      (index){
                        return Text(
                          data['info'][index],
                          style: GoogleFonts.bangers(
                            color: Color(0xFF050B18),
                            fontSize: 17.0,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Capítulos:",
              style: GoogleFonts.bangers(
                fontSize: 30.0,
                color: Color(0xFF050B18),
              ),
            ),
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.view_list,
                    color: _inList ? Color(0xFF050B18) : Colors.grey,
                    size: 30.0,
                  ),
                  onPressed: (){
                    _controller.animateToPage(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.bounceIn,
                    );
                    setState(() => _inList = true);
                  }
                ),
                IconButton(
                  icon: Icon(
                    Icons.grid_on,
                    color: _inList ? Colors.grey : Color(0xFF050B18),
                    size: 30.0,
                  ),
                  onPressed: (){
                    _controller.animateToPage(
                      1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                    setState(() => _inList = false);
                  }
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data['chaptersNumbers'].length,
                  itemBuilder: (context, index){
                    return Card(
                      color: _currentTile == index ? Color(0xFF050B18) : null,
                      elevation: 3.0,
                      shadowColor: Color(0xFF1F2430),
                      child: ListTile(
                        leading: Icon(
                          Icons.view_carousel,
                          size: 25.0,
                          color: _currentTile == index ? Colors.white : Color(0xFF050B18),
                        ),
                        title: Text(
                          data['chaptersNumbers'][index],
                          style: GoogleFonts.bangers(
                            color: _currentTile == index ? Colors.white : Color(0xFF050B18),
                            fontSize: 20.0,
                          ),
                        ),
                        onTap: (){
                          String chapterNumber = data['chaptersNumbers'][index];
                          setState(() => _currentTile = index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChapterPage(
                                itemCount: data['chaptersNumbers'].length,
                                currentIndex: index,
                                scraper: widget.scraper,
                                chapterNumber: chapterNumber,
                                chapterURL: data['chapters'][index][chapterNumber],
                                data: data,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                ),
                GridView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data['chaptersNumbers'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Card(
                        color: _currentTile == index ? Color(0xFF050B18) : null,
                        elevation: 3.0,
                        shadowColor: Color(0xFF1F2430),
                        child: Center(
                          child: Text(
                            data['chaptersNumbers'][index],
                            style: GoogleFonts.bangers(
                              color: _currentTile == index ? Colors.white : Color(0xFF050B18),
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                      onTap: (){
                        var chapterNumber = data['chaptersNumbers'][index];
                        setState(() => _currentTile = index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChapterPage(
                              scraper: widget.scraper,
                              chapterNumber: chapterNumber,
                              chapterURL: data['chapters'][index][chapterNumber],
                              itemCount: data['chaptersNumbers'].length,
                              currentIndex: index,
                              data: data,
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ],
            )
          ),
        ],
      )
    );
  }
}
