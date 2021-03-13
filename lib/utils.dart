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

  if (containsAnyOf(
      categories, ['concierto', 'musi', 'recital', 'espectaculo']))
    return getIcon(Icons.music_video);

  if (containsAnyOf(categories, ['animacion', 'telefilme', 'pelicula', 'cine']))
    return getIcon(Icons.movie);

  if (categories.contains('documenta')) return getIcon(Icons.videocam);
  if (categories.contains('depor')) return getIcon(Icons.accessibility);

  if (containsAnyOf(categories, ['formacion general', 'teleclase']))
    return getIcon(Icons.school);

  if (containsAnyOf(categories, [
    'reportaje',
    'concurso',
    'disertacion especializada',
    'opinión',
    'resumen informativo',
    'promoción de la programación',
    'telediario',
    'noticiero',
    'emision',
    'revista',
    'debate',
    'capsula',
    'boletin',
    'spot'
  ])) return getIcon(Icons.mic);

  if (categories.contains('utilitario'))
    return Icon(Icons.home, size: 50, color: Colors.lightBlue[400]);

  if (containsAnyOf(categories, ['seriado', 'serie']))
    return getIcon(Icons.subscriptions);

  if (categories.contains('novela')) return getIcon(Icons.dvr);

  print(['categories', categories]);

  return Icon(Icons.live_tv, size: 50, color: Colors.lightBlue[400]);
}


