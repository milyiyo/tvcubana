import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage();

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  var _controller = TextEditingController();
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      setState(() {
        _searchQuery = _controller.text;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notificaciones: ',
                    style: TextStyle(height: 5, fontSize: 20)),
                Expanded(flex: 2, child: Container()),
                Flexible(
                  child: TextField(
                    style: TextStyle(fontSize: 20), 
                    textAlign: TextAlign.center,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    decoration: InputDecoration(
                      hintText: '10',
                    ),
                  ),
                ),
                Text(' minutos antes. ',
                    style: TextStyle(height: 5, fontSize: 20)),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 1.0,
                width: 130.0,
                color: Colors.black12,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mostrar imágenes de películas',
                    style: TextStyle(height: 5, fontSize: 20)),
                LiteRollingSwitch(
                  value: true,
                  textSize: 20,
                  textOn: 'Sí',
                  textOff: 'No',
                  colorOn: Colors.blue[500],
                  colorOff: Colors.blueGrey[100],
                  iconOn: Icons.thumb_up,
                  iconOff: Icons.thumb_down,
                  onChanged: (bool state) {
                    print('turned ${(state) ? 'Sí' : 'No'}');
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 1.0,
                width: 130.0,
                color: Colors.black12,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sobre nosotros...',
                    style: TextStyle(height: 5, fontSize: 20)),
                Icon(Icons.navigate_next)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
