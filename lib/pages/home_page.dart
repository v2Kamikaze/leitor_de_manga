import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leitor_de_manga/scraper/data_save.dart/save.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:leitor_de_manga/pages/manga_page.dart';
import 'package:leitor_de_manga/pages/search_page.dart';
import 'package:leitor_de_manga/scraper/scraper.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  UnionScraper scraper = UnionScraper();
  Save save = Save();
  bool _fileReaded = false;
  var data;


  @override
  void initState() {
    super.initState();
    save.readFile().then((_) =>
      setState(() =>_fileReaded = true)
    );
    scraper.mostRead().then((value) => setState(()=> data = value));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF050B18),
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconButton(
                icon: Icon(
                  Icons.adb,
                  size: 40.0,
                  color: Colors.white,
                ),
                onPressed: (){},
              ),
            ),
            Text(
              "Union",
              style: GoogleFonts.bangers(
                fontSize: height * 0.05,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  size: 40.0,
                  color: Colors.white,
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchPage(scraper: scraper,),
                    ),
                  ).then((value) => setState((){}));
                },
              ),
            ),
          ],
        ), systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: data != null ? SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0,),
              CustomPaint(
                size: Size(width, 10.0),
                painter: LinePainter(),
              ),
              SizedBox(height: 10.0,),
              Text(
                "Mais lidos:",
                style: GoogleFonts.bangers(
                  fontSize: height * 0.03,
                  color: Color(0xFF050B18),
                ),
              ),
              CustomPaint(
                size: Size(width, 10.0),
                painter: LinePainter(),
              ),
              Container(
                margin: EdgeInsets.only(top: 15.0),
                width: width,
                height: height * 0.3,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MangaPage(
                              scraper: scraper,
                              title: data[index]['title'],
                            )
                          ),
                        ).then((value) => setState((){}));
                      },
                      child: Container(
                        width: width * 0.33,
                        child: Card(
                            elevation: 5.0,
                            shadowColor: Color(0xFF1F2430),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: data[index]['coverUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              CustomPaint(
                size: Size(width, 10.0),
                painter: LinePainter(),
              ),
              SizedBox(height: 10.0,),
              Text(
                "Favoritos:",
                style: GoogleFonts.bangers(
                  fontSize: height * 0.03,
                  color: Color(0xFF050B18),
                ),
              ),
              CustomPaint(
                size: Size(width, 10.0),
                painter: LinePainter(),
              ),
              SizedBox(height: 10.0,),
              if (_fileReaded) Container(
                width: width,
                height: height * 0.3,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: save.data.length,
                  itemBuilder: (_, index) {
                    String title = save.data[index].keys.toString().replaceFirst("(", "").replaceFirst(")", "");
                    return Card(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MangaPage(
                                scraper: scraper,
                                title: title,
                              )
                            ),
                          );
                        },
                        child: Container(
                          width: width * 0.33,
                          child: Card(
                            elevation: 2.0,
                            shadowColor: Color(0xFF1F2430),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: save.data[index][title]["coverUrl"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                )
              ),
            ],
          ),
        ),
      ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF050B18)),))
    );
  }
}

class LinePainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
      final paint = Paint()
        ..color = Color(0xFF050B18)
        ..strokeWidth = 3.0;
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        paint
      );
    }

    @override
    bool shouldRepaint(CustomPainter old) {
    return false;
  }

}
