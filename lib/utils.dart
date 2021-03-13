import 'package:flutter/material.dart';

import 'models/ProgramItem.dart';

var sportNames = [
  r"\b[e-é]isbol",
  r"\f[u-ú]tbol",
  'basket',
  'baloncesto',
  'boxeo',
  r'\nataci[o-ó]n',
  'judo',
  'taekwondo',
  'lucha'
];

Map<String, String> getChannelImages() {
  Map<String, String> images = new Map<String, String>();

  images['Canal Caribe'] = 'assets/images/canal_caribe.jpg';
  images['Telerebelde'] = 'assets/images/telerebelde-icon.jpg';
  images['Educativo'] = 'assets/images/educativo-icon.png';
  images['Educativo 2'] = 'assets/images/educativo2-icon.png';
  images['Multivisión'] = 'assets/images/multivision-icon.png';
  images['Clave'] = 'assets/images/clave.jpg';
  images['Cubavisión'] = 'assets/images/cubavision-icon.png';
  images['Cubavisión Plus'] = 'assets/images/cubavision_plus.png';
  images['Cubavisión Internacional'] =
      'assets/images/cubavision_internacional.png';
  images['Canal Habana'] = 'assets/images/canalHabana-icon.png';
  images['Artv'] = 'assets/images/artemisa_tv.jpg';
  images['Telemayabeque'] = 'assets/images/tele_mayabeque.jpg';
  images['Centrovisión Yayabo'] = 'assets/images/yayabo_tv.jpg';
  images['Tele Pinar'] = 'assets/images/telepinar-icon.jpg';
  images['Telecubanacan'] = 'assets/images/tele_cubanacan.jpg';
  images['Tele Cristal'] = 'assets/images/tele_cristal.jpg';
  images['MiTV'] = 'assets/images/mitv.jpg';
  images['Islavisión'] = 'assets/images/islavision-icon.png';
  images['CNC Tv'] = 'assets/images/cnctv-icon.jpeg';
  images['Perlavisión'] = 'assets/images/perlavision-icon.png';
  images['Solvisión'] = 'assets/images/solvision-icon.jpeg';
  images['Tele Turquino'] = 'assets/images/tvSantiago-icon.jpg';
  images['Tunasvisión'] = 'assets/images/tunasvision-icon.png';
  images['TV Avileña'] = 'assets/images/tvavilena-icon.png';
  images['TV Camaguey'] = 'assets/images/tvcamaguey-icon.png';
  images['TV Yumuri'] = 'assets/images/tvyumuri-icon.png';
  images['Telerebelde Plus'] = 'assets/images/telerebeldePlus-icon.png';
  images['Russia Today'] = 'assets/images/rusiaToday-icon.png';

  return images;
}

Widget getImageForChannel(String channelName, double dimension) {
  var images = getChannelImages();
  if (images.containsKey(channelName)) {
    return Image.asset(images[channelName],
        height: dimension, width: dimension);
  }
  return Container(
      margin: EdgeInsets.only(top: 10),
      child: Icon(Icons.live_tv, size: 50, color: Colors.lightBlue[200]));
}

String getStrDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';
}

List<ProgramItem> getTheCurrentProgram(List<ProgramItem> pitemsList) {
  List<ProgramItem> result = [null, null];
  for (var i = 0; i < pitemsList.length; i++) {
    var pitem = pitemsList[i];

    var now = new DateTime.now();
    var dateStartProg = DateTime.parse(pitem.dateStart +
        ' ' +
        pitem.timeStart +
        (pitem.timeStart.length == 8 ? '' : '0'));
    var dateEndProg = DateTime.parse(pitem.dateEnd +
        ' ' +
        pitem.timeEnd +
        (pitem.timeEnd.length == 8 ? '' : '0'));

    if ((dateStartProg.isBefore(now) && dateEndProg.isAfter(now)) ||
        dateStartProg == now ||
        dateEndProg == now) {
      result[0] = pitem;
      if (i + 1 < pitemsList.length) result[1] = pitemsList[i + 1];
      break;
    }
  }
  return result;
}

Widget getImageForCategory(ProgramItem pitem) {
  var categories = pitem.classification.join(' ').toLowerCase();

  var containsAnyOf = (String text, List<String> words) {
    for (var word in words) {
      if (text.contains(word)) return true;
    }
    return false;
  };

  var getIcon =
      (IconData icon) => Icon(icon, size: 50, color: Colors.lightBlue[400]);

  if (categories.contains('musical'))
    return getIcon(Icons.music_video);

  if (categories.contains('filme'))
    return getIcon(Icons.movie);

  if (categories.contains('documental')) return getIcon(Icons.videocam);
  if (categories.contains('deporte')) return getIcon(Icons.accessibility);

  if (categories.contains('educativo'))
    return getIcon(Icons.school);

  if (categories.contains('infantiles'))
    return getIcon(Icons.child_care);

  if (categories.contains('humor'))
    return getIcon(Icons.emoji_emotions);

  if (categories.contains('historia'))
    return getIcon(Icons.museum);

  if (categories.contains('noticias')) return getIcon(Icons.mic);

  if (categories.contains('utilitario')) //no incluido en clasificacion
    return Icon(Icons.home, size: 50, color: Colors.lightBlue[400]);

  // if (containsAnyOf(categories, ['seriado', 'serie']))
  //   return getIcon(Icons.subscriptions);

  if (categories.contains('novela')) return getIcon(Icons.dvr);

  return Icon(Icons.live_tv, size: 50, color: Colors.lightBlue[400]);
}

String getCategory(String value) {
  if(value.length < 3)
    return "N/A";

  if(value.toLowerCase().contains("himno apertura") ||
     value.toLowerCase().contains("estocada al tiempo") ||
     value.toLowerCase().contains("la historia") ||
     value.toLowerCase().contains("efemérides") ||
     value.toLowerCase().contains("este dia"))
    return "historia";

  if(value.toLowerCase().contains("multicine") ||
     value.toLowerCase().contains("domingo en casa") ||
     value.toLowerCase().contains("cinema jove") ||
     value.toLowerCase().contains("cine ") ||
     value.toLowerCase().contains("telecine") ||
     value.toLowerCase().contains("cineflash") ||
     value.toLowerCase().contains("filmecito") ||
     value.toLowerCase().contains("película") ||
     value.toLowerCase().contains("set y cine") ||
     value.toLowerCase().contains("título original") ||
     value.toLowerCase().contains("senderos del oeste") ||
     value.toLowerCase().contains("cinevisi") ||
     value.toLowerCase().contains("cinecito en tv") ||
     value.toLowerCase().contains("mision domingo") ||
     value.toLowerCase().contains("camino de fantasias") ||
     value.toLowerCase().contains("telefilme") ||
     value.toLowerCase().contains("solo la verdad"))
    return "filme";

  if(value.toLowerCase().contains("documental") ||
     value.toLowerCase().contains("ciencia de lo absurdo"))
    return "documental";

  // if(value.toLowerCase().contains("serie") ||
  //    value.toLowerCase().contains("lupin"))
  //   return "serie";

  if(value.toLowerCase().contains("novela") ||
     value.toLowerCase().contains("mujeres ambiciosas"))
    return "novela";
  
  if(value.toLowerCase().contains("vivir del cuento") ||
     value.toLowerCase().contains("a otro con ese cuento"))
    return "humor";

  if(value.toLowerCase().contains("animados") ||
     value.toLowerCase().contains("hola chico") ||
     value.toLowerCase().contains("para los niños") ||
     value.toLowerCase().contains("trompatren") ||
     value.toLowerCase().contains("tu si suenas") ||
     value.toLowerCase().contains("los croods") ||
     value.toLowerCase().contains("la sombrilla amarilla") ||
     value.toLowerCase().contains("upa nene") ||
     value.toLowerCase().contains("canta y juega") ||
     value.toLowerCase().contains("hola chico") ||
     value.toLowerCase().contains("fiesta de colores") ||
     value.toLowerCase().contains("chiquillada"))
    return "infantiles";

  if(value.toLowerCase().contains("23 y m") ||
     value.toLowerCase().contains("música") ||
     value.toLowerCase().contains("concierto") ||
     value.toLowerCase().contains("trova tv") ||
     value.toLowerCase().contains("afro ritmo") ||
     value.toLowerCase().contains("cubanos en clip") ||
     value.toLowerCase().contains("musical") ||
     value.toLowerCase().contains("palmas y caña") ||
     value.toLowerCase().contains("lucas") ||
     value.toLowerCase().contains("hora rock") ||
     value.toLowerCase().contains("prince royce") ||
     value.toLowerCase().contains("a toda voz") ||
     value.toLowerCase().contains("baila casino") ||
     value.toLowerCase().contains("a todo jazz") ||
     value.toLowerCase().contains("a capella") ||
     value.toLowerCase().contains("ritmo clip") ||
     value.toLowerCase().contains("nota a nota") ||
     value.toLowerCase().contains("nuestra canci") ||
     value.toLowerCase().contains("talla joven") ||
     value.toLowerCase().contains("de la gran escena") ||
     value.toLowerCase().contains("sitio del arte") ||
     value.toLowerCase().contains("aires de m") ||
     value.toLowerCase().contains("rockanroleando") ||
     value.toLowerCase().contains("clave latina") ||
     value.toLowerCase().contains("cuerda viva") ||
     value.toLowerCase().contains("onda retro") ||
     value.toLowerCase().contains("s latinos") ||
     value.toLowerCase().contains("clave rom") ||
     value.toLowerCase().contains("el complotazo") ||
     value.toLowerCase().contains("n salsera") ||
     value.toLowerCase().contains("dale clave") ||
     value.toLowerCase().contains("antes y despu") ||
     value.toLowerCase().contains("4x4") ||
     value.toLowerCase().contains("video mundo") ||
     value.toLowerCase().contains("videos clip") ||
     value.toLowerCase().contains("entre claves y corcheas"))
    return "musical";

  if(value.toLowerCase().contains("de telesur") ||
     value.toLowerCase().contains("noticias") ||
     value.toLowerCase().contains("cartelera") ||
     value.toLowerCase().contains("telecentro") ||
     value.toLowerCase().contains("mesa redonda") ||
     value.contains("NTV") ||
     value.toLowerCase().contains("informativo") ||
     value.toLowerCase().contains("revista buenos d") ||
     value.toLowerCase().contains("noticiero") ||
     value.toLowerCase().contains("conferencia de prensa") ||
     value.toLowerCase().contains("revista especial covid") ||
     value.toLowerCase().contains("cierre del canal") ||
     value.toLowerCase().contains("teleavances") ||
     value.toLowerCase().contains("de tarde en casa") ||
     value.toLowerCase().contains("al mediodia") ||
     value.toLowerCase().contains("revista informativa") ||
     value.toLowerCase().contains("plataforma habana") ||
     value.toLowerCase().contains("revista hola habana") ||
     value.toLowerCase().contains("el tiempo en el caribe") ||
     value.toLowerCase().contains("libre acceso") ||
     value.toLowerCase().contains("hacemos cuba") ||
     value.toLowerCase().contains("informe covid-19") ||
     value.toLowerCase().contains("noticiario") ||
     value.toLowerCase().contains("revista rtx") ||
     value.toLowerCase().contains("revista especial") ||
     value.toLowerCase().contains("en primer plano"))
    return "noticias";

  if(value.contains("PROGRAMACIÓN EDUCATIV") || 
     value.contains("PROGRAMACIÓN ARTISTICA EDUCATIVA") || 
     value.toLowerCase().contains("8vo grado") || 
     value.toLowerCase().contains("nivel elemental") || 
     value.toLowerCase().contains("nivel medio") || 
     value.toLowerCase().contains("grado y especial") || 
     value.toLowerCase().contains("o grado") || 
     value.toLowerCase().contains("isimo") ||
     value.toLowerCase().contains("upt ") ||
     value.toLowerCase().contains("verde habana"))
    return "educativo";

  if(value.toLowerCase().contains("serie nacional de beisbol") ||
     value.toLowerCase().contains("serie nacional de béisbol") || 
     value.toLowerCase().contains("judo internacional") || 
     value.toLowerCase().contains("deportivo") || 
     value.toLowerCase().contains("vale 3") || 
     value.toLowerCase().contains("baloncesto") || 
     value.toLowerCase().contains("futbol internacional") || 
     value.toLowerCase().contains("deporclip") || 
     value.toLowerCase().contains("nnd") || 
     value.toLowerCase().contains("glorias deportiv") || 
     value.toLowerCase().contains("voleibol") || 
     value.toLowerCase().contains("programa de ejercicios") ||
     value.toLowerCase().contains("bola viva") ||
     value.toLowerCase().contains("deportes") ||
     value.toLowerCase().contains("a todo motor") ||
     value.toLowerCase().contains("la jugada perfecta") ||
     value.toLowerCase().contains("zona deportiva") ||
     value.toLowerCase().contains("al duro y sin guante") ||
     value.toLowerCase().contains("copa del mundo") ||
     value.toLowerCase().contains("panamericano") ||
     value.toLowerCase().contains("olimpiadas"))
    return "deporte";

  return "---";
}
