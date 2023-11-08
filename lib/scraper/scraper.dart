import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'dart:async';
import 'dart:convert' show utf8;

class UnionScraper {
  final String baseUrl = 'https://unionmangas.top/manga/';
  String title = "";

  static final UnionScraper _instance = UnionScraper._internal();
  factory UnionScraper() => _instance;
  UnionScraper._internal();

  Future<Map?> getChapters() async {
    if (title == null) return null;
    var data = {};

    var res = await Client().get((baseUrl + convertTitle('url')!) as Uri);
    var doc = parse(res.body);

    data['title'] = convertTitle('page');
    data['cover'] = doc.querySelector('.img-thumbnail')?.attributes['src'];
    data['info'] = [];
    var info = doc.querySelectorAll('.col-md-8 h4');
    info.forEach((element) {
      data['info'].add(element.text);
    });
    data['chaptersNumbers'] = [];
    data['chapters'] = [];
    var links = doc.querySelectorAll('.row .lancamento-linha a');
    links.forEach((element) {
      if (element.attributes['href']!.contains(convertTitle('chapter') as Pattern)) {
        data['chaptersNumbers'].add(element.text);
        data['chapters'].add({element.text: element.attributes['href']});
      }
    });
    return data;
  }

  Future<List> getPages(String chapter) async {
    var pages = [];
    var res = await Client().get(chapter as Uri);
    var doc = parse(res.body);
    var links = doc.querySelectorAll('img');

    links.forEach((element) {
      if (element.attributes['src']!.contains(convertTitle('page') as Pattern)) {
        pages.add(element.attributes['src']);
      }
    });
    return pages;
  }

  Future<List> mostRead() async {
    var mostRead = [];
    var titles = [];
    var covers = [];

    var res = await get('https://unionleitor.top/mangas/visualizacoes' as Uri);
    var resDecoded = utf8.decode(res.bodyBytes, allowMalformed: true);
    var doc = parse(resDecoded);
    var h4 = doc.querySelectorAll('.lancamento-linha h4');
    // Titles
    h4.forEach((element) {
      if (!titles.contains(element.text)) {
        titles.add(element.text.trim());
      }
    });
    // Cover
    var links = doc.querySelectorAll('.lancamento-linha img');
    links.forEach((element) {
      covers.add(element.attributes['src']);
    });

    for (var i = 0; i < titles.length; i++) {
      mostRead.add({
        'title': titles[i],
        'coverUrl': covers[i],
      });
    }
    return mostRead;
  }

  // ============================================== //
  // Métodos para formatação do título para as urls
  // ============================================== //

  String? convertTitle(String option) {
    var title = this.title;
    if (option == 'url') {
      var words = title.toLowerCase().split(' ');
      for (var i = 0; i < words.length; i++) {
        if (words[i].contains('(') || words[i].contains(')')) {
          if (words[i][0] == '(') {
            words[i] = words[i].split('(').join('');
            words[i] = words[i].split(')').join(' ');
          } else {
            words[i] = words[i].split('(').join('-');
            words[i] = words[i].split(')').join(' ');
          }
        }
        if (words[i].contains(':')) {
          words[i] = words[i].split(':').join('-');
        }
      }
      return words.join('-').replaceAll('--', '-');
    } else if (option == 'chapter') {
      var words = title.split(' ');
      for (var i = 0; i < words.length; i++) {
        if (words[i].contains(':')) {
          var aux = words[i].split(':');
          for (var k = 0; k < aux.length; k++) {
            aux[k] = _capitalize(aux[k]);
          }
          words[i] = aux.join(':');
        }
        words[i] = _capitalize(words[i]);
      }
      return words.join('_');
    } else if (option == 'page') {
      var words = title.split(' ');
      for (var i = 0; i < words.length; i++) {
        if (words[i].contains(':')) {
          var aux = words[i].split(':');
          for (var k = 0; k < aux.length; k++) {
            aux[k] = _capitalize(aux[k]);
          }
          words[i] = aux.join(':');
        }
        words[i] = _capitalize(words[i]);
      }
      return words.join(' ');
    }
    return null;
  }

  String _capitalize(String text) {
    var words = text.split(' ');
    for (var index = 0; index < words.length; index++) {
      if (!['no', 'ni', 'wo', 'of', 'and', 'to', 'e', 'wa']
              .contains(words[index]) &&
          words[index].isNotEmpty) {
        words[index] =
            words[index][0].toUpperCase() + words[index].substring(1);
      }
    }
    return words.join(' ');
  }
}
