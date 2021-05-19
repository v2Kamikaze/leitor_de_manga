import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:leitor_de_manga/scraper/scraper.dart';

class ChapterPage extends StatefulWidget {
  final UnionScraper scraper;
  final String chapterURL;
  final String chapterNumber;
  final int itemCount;
  final Map data;
  int currentIndex;
  
  ChapterPage({this.scraper, this.chapterURL, this.chapterNumber, this.itemCount, this.currentIndex, this.data});

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  PageController _controller = PageController();
  var data;
  @override
  void initState() {
    super.initState();
    widget.scraper.getPages(widget.chapterURL).then(
      (value) => setState(()=> data = value)
    );
    // Permitindo rotação
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  dispose(){
    // Setando para impedir a rotação
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark, // Status Bar Color Icons
        backgroundColor: Color(0xFF050B18),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 30.0,
                color: Colors.white,
              ), 
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              width: width * 0.2,
              child: RaisedButton(
                color: Color(0xFF050B18),
                splashColor: Colors.white54,
                elevation: 5.0,
                child: Text(
                  "Anterior",
                  style: GoogleFonts.bangers(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
                onPressed: (){
                  if(widget.currentIndex >= 0 && widget.currentIndex < widget.itemCount - 1){
                    widget.currentIndex++;
                    String chapterNumber = widget.data['chaptersNumbers'][widget.currentIndex];
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => 
                        ChapterPage(
                          scraper: widget.scraper,
                          itemCount: widget.data['chaptersNumbers'].length,
                          currentIndex: widget.currentIndex,
                          chapterNumber: chapterNumber,
                          chapterURL: widget.data['chapters'][widget.currentIndex][chapterNumber],
                          data: widget.data,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Text(
              "${widget.chapterNumber}",
              style: GoogleFonts.bangers(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              width: width * 0.2,
              child: RaisedButton(
                color: Color(0xFF050B18),
                splashColor: Colors.white54,
                elevation: 5.0,
                child: Text(
                  "Próximo",
                  style: GoogleFonts.bangers(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
                onPressed: (){
                  if(widget.currentIndex > 0 && widget.currentIndex < widget.itemCount){
                    widget.currentIndex--;
                    String chapterNumber = widget.data['chaptersNumbers'][widget.currentIndex];
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => 
                        ChapterPage(
                          scraper: widget.scraper,
                          itemCount: widget.data['chaptersNumbers'].length,
                          currentIndex: widget.currentIndex,
                          chapterNumber: chapterNumber,
                          chapterURL: widget.data['chapters'][widget.currentIndex][chapterNumber],
                          data: widget.data,
                        ),
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      body: data == null ?
        Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF050B18)),))
      : PageView.builder(
        controller: _controller,
        physics: BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index){
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Center(
                child: PhotoView(
                  imageProvider: NetworkImage(data[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      if(this.mounted) {
                        setState(() {
                          _controller.previousPage(
                            duration: Duration(milliseconds: 100), 
                            curve: Curves.easeIn,
                          );
                          if(_controller.page == 0) {
                            if(widget.currentIndex >= 0 && widget.currentIndex < widget.itemCount - 1){
                              widget.currentIndex++;
                              String chapterNumber = widget.data['chaptersNumbers'][widget.currentIndex];
                              Navigator.pop(context);
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => 
                                  ChapterPage(
                                    scraper: widget.scraper,
                                    itemCount: widget.data['chaptersNumbers'].length,
                                    currentIndex: widget.currentIndex,
                                    chapterNumber: chapterNumber,
                                    chapterURL: widget.data['chapters'][widget.currentIndex][chapterNumber],
                                    data: widget.data,
                                  ),
                                ),
                              );
                            }
                          }
                        });
                      }
                    },
                    child: Container(
                      height: height,
                      width: width * 0.15,
                      color: Colors.transparent.withAlpha(0),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      if(this.mounted) {
                        setState(() {
                          _controller.nextPage(
                            duration: Duration(milliseconds: 100), 
                            curve: Curves.easeIn,
                          );
                          if(_controller.page == data.length - 1) {
                            if(widget.currentIndex > 0 && widget.currentIndex < widget.itemCount){
                              widget.currentIndex--;
                              String chapterNumber = widget.data['chaptersNumbers'][widget.currentIndex];
                              Navigator.pop(context);
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => 
                                  ChapterPage(
                                    scraper: widget.scraper,
                                    itemCount: widget.data['chaptersNumbers'].length,
                                    currentIndex: widget.currentIndex,
                                    chapterNumber: chapterNumber,
                                    chapterURL: widget.data['chapters'][widget.currentIndex][chapterNumber],
                                    data: widget.data,
                                  ),
                                ),
                              );
                            }
                          }
                        });
                      }
                    },
                    child: Container(
                      height: height,
                      width: width * 0.15,
                      color: Colors.transparent.withAlpha(0),
                    ),
                  ),
                ],
              )
            ],
          );
        }
      )
    );
  }
}

