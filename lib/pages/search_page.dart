import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leitor_de_manga/pages/manga_page.dart';
import 'package:leitor_de_manga/scraper/scraper.dart';
import 'package:leitor_de_manga/scraper/list_titles.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class SearchPage extends StatefulWidget {

  final UnionScraper scraper;


  SearchPage({this.scraper});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GlobalKey key = GlobalKey<AutoCompleteTextFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark, // Status Bar Color Icons
        backgroundColor: Color(0xFF050B18),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30.0,
            color: Colors.white,
          ), 
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Container(
            width: width * 0.7,
            height: 40.0,
            child: AutoCompleteTextField(
              style: GoogleFonts.bangers(
                color: Colors.white,
                fontSize: 15.0,
              ),
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.search,
                  size: 30.0,
                  color: Colors.white,
                ),
                labelText: "Digite o mangá que deseja pesquisar ",
                labelStyle: GoogleFonts.bangers(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              itemSubmitted: (item){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => MangaPage(
                      scraper: widget.scraper,
                      title: item,
                    ),
                  ),
                );
              }, 
              key: key, 
              suggestions: Utils.allTitles, 
              itemBuilder: (context, item){
                return Card(
                  elevation: 3.0,
                  shadowColor: Color(0xFF1F2430),
                  child: ListTile(
                    title: Text(
                      item,
                      style: GoogleFonts.bangers(
                        fontSize: 15.0,
                        color: Color(0xFF050B18),
                      ),
                    ),
                  ),
                );
              }, 
              itemSorter: (a,b){
                return a.compareTo(b);
              }, 
              itemFilter: (item, query){
                return item.toLowerCase().startsWith(query.toLowerCase());
              }
            ),
          ),
        ),
      ),
    );
  }
}
