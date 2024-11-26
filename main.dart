import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,   // Solo permite modo vertical normal
    DeviceOrientation.portraitDown, // Opcional: permite modo vertical invertido
  ]).then((_) {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: MyApp(),
      ),
    );
  });

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistente IA',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFF218563),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CounterProvider with ChangeNotifier {

  // Estos contadores son para el almacenamiento de las consultas y su muestra por pantalla
  int _counter = 0;
  int _max=0;
  bool _hayFavs = false;
  bool _cargando = false;



  int get counter => _counter;
  int get max => _max;
  bool get favs => _hayFavs;
  bool get cargando => _cargando;

  void increment() {
    _max++;
    _counter=_max;
    notifyListeners(); // Notifica a los widgets que escuchan para que se reconstruyan
  }

  void decrement() {
    _counter--;
    notifyListeners();
  }

  void avanza(){
    if(_counter<_max){
      _counter++;
      notifyListeners();
    }
  }

  void retrocede(){
    if(_counter>0){
      _counter--;
      notifyListeners();
    }
  }
  void pos(int i){
      _counter=i;
      notifyListeners();
  }

  void reset(){
    _counter=0;
    _max=0;
    notifyListeners();
  }

  void adjust(int i){
    _counter=0;
    _max=i;
    notifyListeners();
  }
}

class IndexProvider with ChangeNotifier {
  int _index = 1;
  int get indice => _index;

  void pos(int i){
    _index=i;
    notifyListeners();
  }
}


class _MyHomePageState extends State<MyHomePage>  with WidgetsBindingObserver {
  int _selectedIndex = IndexProvider().indice;// Índice del elemento seleccionado
  final TextEditingController textController = TextEditingController();

  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> texts = [];
  late List<PageContent> _pages;
  final ValueNotifier<bool> isKeyboardVisibleNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    resetDatabase();
    _loadTexts();

    // Inicializar la lista de páginas aquí
    _pages = [
      PageContent(
        title: 'FAVORITOS',
        description: 'Contenido de la Página 1',
        preguntaSel: (index) => _onItemTapped(index),
        isKeyboardVisibleNotifier: isKeyboardVisibleNotifier
      ),
      PageContent(
        title: 'INICIO',
        description: 'Contenido de la Página 2',
        controller: textController, // Pasar el controlador a la página 2
        imagePath: 'assets/fav1.png',
        imageHeight: 50,
        imageWidth: 50,
        preguntaSel: (index) => _onItemTapped(index),
        isKeyboardVisibleNotifier: isKeyboardVisibleNotifier
      ),
      PageContent(
        title: 'HISTORIAL',
        description: 'Contenido de la Página 3',
        preguntaSel: (index) => _onItemTapped(index),
        isKeyboardVisibleNotifier: isKeyboardVisibleNotifier,
      ),
    ];

  }

  Future<void> resetDatabase() async {
    await databaseHelper.resetDatabase();
    print('Base de datos reiniciada');
  }


  Future<void> _loadTexts() async {
    texts = await databaseHelper.getTexts();
    setState(() {});
  }

  void _onItemTapped(int index) {
    print("Índice seleccionado desde PageContent: $index");
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    isKeyboardVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    bool isVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    isKeyboardVisibleNotifier.value = isVisible;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 1
          ? AppBar(
        title: Text(_pages[_selectedIndex].title,
          style: TextStyle(
          fontSize: 55,
          fontWeight: FontWeight.normal,
          fontFamily: 'Titulos',
          color: Color(0xFF218563),
        ),
        ),
        centerTitle: true,
        toolbarHeight: 110, // Ajusta la altura del AppBar
        backgroundColor: Color(0xFFfff8e3),
      )
          : null,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fondo.png"), // Ruta de la imagen de fondo
            fit: BoxFit.cover, // Ajuste de la imagen
          ),
        ),
        child: _pages[_selectedIndex], // Muestra la página correspondiente
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'FAVORITOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ASISTENTE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'HISTORIAL',
          ),
        ],
        currentIndex: _selectedIndex, // Índice seleccionado
        selectedItemColor: Color(0xFF218563), // Color del elemento seleccionado
        backgroundColor: Color(0xFFfff8e3),
        onTap: _onItemTapped,
        iconSize: 38.0,
        selectedFontSize: 18.0,
        unselectedFontSize: 15.0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class MyAnimatedText extends StatefulWidget {
  final String text;

  const MyAnimatedText({Key? key, required this.text}) : super(key: key);

  @override
  _MyAnimatedTextState createState() => _MyAnimatedTextState();
}

class _MyAnimatedTextState extends State<MyAnimatedText> {
  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          widget.text,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          speed: Duration(milliseconds: 7),
        ),
      ],
      totalRepeatCount: 1,
      pause: Duration(milliseconds: 1000),
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }
}

// Widget que define el contenido de cada página
class PageContent extends StatefulWidget {
  final String title;
  final String description;
  final String? imagePath;
  final double? imageHeight; // Altura opcional
  final double? imageWidth;  // Ancho opcional
  final TextEditingController? controller;
  final Function(int)? preguntaSel; // Callback para cambiar el índice
  final ValueNotifier<bool> isKeyboardVisibleNotifier;


  const PageContent({
    Key? key,
    required this.title,
    required this.description,
    this.imagePath,
    this.imageHeight,
    this.imageWidth,
    this.controller,
    this.preguntaSel,
    required this.isKeyboardVisibleNotifier,
  }) : super(key: key);

  @override
  _PageContentState createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  bool _isSelected = false; // Estado de selección
  bool _isFav=false; // PARA LOS FAVORITOS
  bool favs = CounterProvider()._hayFavs;
  String currentTime = '';
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> texts = []; // Lista para almacenar los textos


  @override
  void initState() {
    super.initState();
    _getCurrentTime();
    _loadTexts();
  }

  void _mostrarCarga(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150, // Altura del modal
          color: Color(0xFFfff8e3),
          child: Center(
            child: Image.asset('assets/load.gif'),
          ),
        );
      },
    );
  }
  void _cerrarCarga(BuildContext context) {
    Navigator.of(context).pop();
  }


  void _mensaje(int i){

    final snackBar;
    if(i==0){
      snackBar = SnackBar(
        content: Text('Esta consulta ya no está guardada'), // Texto del SnackBar
        duration: Duration(seconds: 2), // Duración que se mostrará el SnackBar
      );
    }else if(i==1){
      snackBar = SnackBar(
        content: Text('¡Consulta guardada!'), // Texto del SnackBar
        duration: Duration(seconds: 2), // Duración que se mostrará el SnackBar
      );
    }else if(i==2){
      snackBar = SnackBar(
        content: Text('¡Lista de Favoritos reiniciada!'), // Texto del SnackBar
        duration: Duration(seconds: 2), // Duración que se mostrará el SnackBar
      );
    }else if(i==3){
      snackBar = SnackBar(
        content: Text('¡Historial eliminado!'), // Texto del SnackBar
        duration: Duration(seconds: 2), // Duración que se mostrará el SnackBar
      );
    }else{
      snackBar = SnackBar(
        content: Text('¡Se han eliminado las consultas no favoritas!'), // Texto del SnackBar
        duration: Duration(seconds: 2), // Duración que se mostrará el SnackBar
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar); // Muestra el SnackBar
  }


  Future<void> _favorito(int i) async{
    setState(() {
      if( texts[i]['favorito']==1){
        texts[i]['favorito']=0;
        _mensaje(0);
      }else{
        texts[i]['favorito']=1;
        _mensaje(1);

      }
      _isFav = !_isFav;
    });
    int id = texts[i]['id'];
    int nuevoFavorito = texts[i]['favorito'];
    await databaseHelper.updateFavoriteStatus(id, nuevoFavorito);

    favs = await databaseHelper.hayFavoritos();

  }

  Future<void> _saveText(String pregunta, String respuesta) async {
    await databaseHelper.insertText(pregunta,respuesta,0);
  }
  Future<void> _loadTexts() async {
    texts = await databaseHelper.getTexts(); // Obtener textos de la base de datos
    print('Textos cargados: $texts'); // Imprimir textos cargados
    setState(() {}); // Actualizar el estado para reflejar los cambios
  }

  Future<void> borrarHistorial() async {
    await databaseHelper.resetDatabase();
    print('Base de datos reiniciada');
    await _loadTexts();
  }

  Future<void> borrarNoFavs() async {
    await databaseHelper.resetNoFavs();
    print('Se han borrado las consultas no favoritas');
    await _loadTexts();
  }


  Future<void> resetFav() async {
    await databaseHelper.resetFavoritos();
    print('Lista de favoritos reiniciada');
    await _loadTexts();
  }



  Future<String> sendTextToServer(String text) async {
    final String apiUrl = 'http://172.20.10.6:8000/api';

    try {
      // Realiza una solicitud POST al servidor
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': text}), // Envía el texto como JSON
      );

      if (response.statusCode == 200) {
        // Si el servidor devuelve un OK response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        String answer = jsonResponse['response'] ?? 'Respuesta no encontrada';
        print('Texto enviado correctamente: $answer');
        return answer; // Devuelve la respuesta para usarla en Flutter
      } else {
        // Si el servidor no devuelve un OK response
        print('Error al enviar texto: ${response.statusCode}');
        return 'Error al recibir respuesta del servidor';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error en la conexión al servidor';
    }
  }

  void _getCurrentTime() {
    DateTime now = DateTime.now();
    setState(() {
      currentTime = DateFormat('HH').format(now);
      print(currentTime);// Formato de hora AM/PM
    });
  }

  @override
  Widget build(BuildContext context) {

    final counterProvider = Provider.of<CounterProvider>(context);

    double keyBoard = MediaQuery.of(context).viewInsets.bottom;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double blackSpace= screenHeight * 0.17;
    double blackSpace2= screenHeight * 0.12;

    double main = screenWidth * 0.15;
    double titulo = screenWidth * 0.07;
    double subtitulo = screenWidth * 0.06;
    double respuesta = screenWidth * 0.05;
    double consultar1 = screenWidth * 0.05;
    double consulta2 = screenWidth * 0.05;
    double botones = screenWidth * 0.05;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 15.0,
          top: 10.0,
          right: 15.0,
          bottom: 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Solo muestra la imagen si imagePath no es null
           /* if (widget.imagePath != null)
              Image.asset(
                widget.imagePath!,
                height: widget.imageHeight,
                width: widget.imageWidth,
                fit: BoxFit.cover,
              ),
            */
        // CONTENIDO INICIO
            if (widget.title == 'INICIO' && counterProvider.counter>0)
              SizedBox(height: 35),
            if (widget.title == 'INICIO' && counterProvider.counter>0)
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espacio uniforme entre botones
            children: [
              Expanded(
              child: Text(
                texts[counterProvider.counter-1]['pregunta'],
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Titulos',
                  color: Color(0xFFfff8e3),
                ),
              ),
              ),
              if (widget.imagePath != null)
                if(texts[counterProvider.counter - 1]['favorito']==0)
                  GestureDetector(
                    onTap: () => _favorito(counterProvider.counter - 1),
                      child: Image.asset(
                        'assets/fav1.png',
                        height: widget.imageHeight,
                        width: widget.imageWidth,
                        fit: BoxFit.cover,
                      ),
                  ),
                if(texts[counterProvider.counter - 1]['favorito']==1)
                  GestureDetector(
                    onTap: () => _favorito(counterProvider.counter - 1),
                    child: Image.asset(
                      'assets/fav2.png',
                      height: widget.imageHeight,
                      width: widget.imageWidth,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            if (widget.title == 'INICIO' && counterProvider.counter==0)
              if(int.parse(currentTime)>=06 && int.parse(currentTime)<14)
                Text(
                  "¡Buenos días!",
                  style: TextStyle(
                    fontSize: main,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Titulos',
                    color: Color(0xFFfff8e3),
                  ),
                  textAlign: TextAlign.center,
                ),
            if (widget.title == 'INICIO' && counterProvider.counter==0)
              if(int.parse(currentTime)>=14 && int.parse(currentTime)<20)
                Text(
                  "¡Buenas tardes!",
                  style: TextStyle(
                    fontSize: main,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Titulos',
                    color: Color(0xFFfff8e3),
                  ),
                  textAlign: TextAlign.center,
                ),
            if (widget.title == 'INICIO' && counterProvider.counter==0)
              if(int.parse(currentTime)>=20 && int.parse(currentTime)<24)
                Text(
                  "¡Buenas noches!",
                  style: TextStyle(
                    fontSize: main,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Titulos',
                    color: Color(0xFFfff8e3),
                  ),
                  textAlign: TextAlign.center,
                ),
            if (widget.title == 'INICIO' && counterProvider.counter==0)
              if(int.parse(currentTime)>=00 && int.parse(currentTime)<06)
                Text(
                  "¡Buenas noches!",
                  style: TextStyle(
                    fontSize: main,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Titulos',
                    color: Color(0xFFfff8e3),
                  ),
                  textAlign: TextAlign.center,
                ),
            if (widget.title == 'INICIO' && counterProvider.counter==0)
              SizedBox(height: 20),
            if (widget.title == 'INICIO' && counterProvider.counter==0)
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Soy Silvia, tu asistente de IA para ayudarte a mejorar el planeta.',
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFfff8e3),
                    ),
                    textAlign: TextAlign.center,
                    speed: Duration(milliseconds: 70),
                  ),
                ],
                totalRepeatCount: 1, // Repite una vez
                pause: Duration(milliseconds: 1000), // Pausa al final
                displayFullTextOnTap: true, // Muestra el texto completo al hacer clic
                stopPauseOnTap: true, // Detiene la pausa al hacer clic
              ),
            if (widget.title == 'INICIO')
              SizedBox(height: 30), // Espacio entre el título y la descripción

            // AQUÍ IRIA EL CUADRO DE TEXTO DE LA IA
            if (widget.title == 'INICIO' && counterProvider.counter>=1)
              Expanded(
                child: texts.isNotEmpty // Verifica que la lista no esté vacía
                    ? Container(
                    padding: EdgeInsets.all(8.0), // Ajusta el padding según sea necesario
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView( // Asegúrate de que esté correctamente declarado
                        child: MyAnimatedText(
                          key: ValueKey(texts[counterProvider.counter-1]['respuesta']),
                          text: texts[counterProvider.counter-1]['respuesta'],
                        ),
                      ),
                    )
                )
                    : Center(
                  child: Text(
                    'No hay preguntas disponibles', // Mensaje si la lista está vacía
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (widget.title == 'INICIO' && widget.controller != null && counterProvider.counter>=0)
              SizedBox(height: 20), // Espacio entre el título y la descripción
            if (widget.controller != null && counterProvider.counter>=0) // Solo mostramos el TextField si se ha proporcionado un controlador
              TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  height: 2,
                ),
                controller: widget.controller,
                cursorColor: Colors.black,
                onSubmitted: (String inputText) async {
                  // Verificar si el texto no está vacío
                  if (inputText.isNotEmpty) {
                    try {
                      print('Texto ingresado: $inputText');

                      String pregunta = inputText;

                      widget.controller?.clear();

                      setState(() {
                        _isSelected = false;
                        _mostrarCarga(context);
                      });

                      // Llamada asincrónica
                      String respuesta = await sendTextToServer(pregunta);

                      // Guardar la respuesta y limpiar el controlador
                      await _saveText(pregunta,respuesta);


                      // Recargar los textos después de guardar
                      await _loadTexts();

                      setState(() {
                        _isFav = false;
                        //_isSelected = false;
                        //counterProvider._cargando=false;

                        _cerrarCarga(context);
                        counterProvider.increment();
                      });


                    } catch (e) {
                      print('Error al procesar el texto: $e');
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: '¿En qué puedo ayudarte?',
                  hintStyle: TextStyle(
                    color: Color(0xFFfff8e3), // Color cuando no está enfocado
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: _isSelected ? Color(0xFFfff8e3) : Colors.transparent, // Cambia el color de fondo
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0), // Esquinas redondeadas
                    borderSide: BorderSide(
                      color: Color(0xFFfff8e3), // Color del borde cuando está habilitado
                      width: 2.0, // Ancho del borde
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
                    borderSide: BorderSide(
                      color: Colors.black, // Color del borde cuando está enfocado
                      width: 2.0, // Ancho del borde
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
                    borderSide: BorderSide(
                      color: Colors.redAccent, // Color del borde cuando hay un error
                      width: 2.0, // Ancho del borde
                    ),
                  ),
                ),

                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      _isSelected = false; // Cambiar el estado a no seleccionado
                    });
                  }
                  if (!(value.isEmpty)) {
                    setState(() {
                      _isSelected = true; // Cambiar el estado a no seleccionado
                    });
                  }
                },
                onEditingComplete: () {
                  FocusScope.of(context).unfocus(); // Perder enfoque
                },
              ),
            if (widget.title == 'INICIO')
              SizedBox(height: 10), // Espacio entre botones
            if (widget.title == 'INICIO' && counterProvider.max>0)
              ValueListenableBuilder<bool>(
                valueListenable: widget.isKeyboardVisibleNotifier,
                builder: (context, isKeyboardVisible, child) {
                  return Visibility(
                    visible: !isKeyboardVisible, // Mostrar cuando el teclado está oculto
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {// Volver al estado no seleccionado
                              _isFav=false;
                              counterProvider.retrocede();
                            });
                            print("ATRAS");
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                            backgroundColor:  counterProvider.counter!=0 ? Color(0xFFfff8e3):Color(0xFF7d7d7d),
                            foregroundColor: counterProvider.counter!=0 ? Color(0xFF218563):Color(0xFFffffff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                          child: Text(
                            'Anterior',
                            style: TextStyle(
                              fontSize: botones,
                              fontFamily: 'Titulos',
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 15), // Espacio entre botones
                        ElevatedButton(
                          onPressed: () {
                            setState(() {// Volver al estado no seleccionado
                              _isFav=false;
                              counterProvider.avanza();
                            });
                            print("ALANTE");
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                            backgroundColor:  counterProvider.counter!=counterProvider.max ? Color(0xFFfff8e3):Color(0xFF7d7d7d),
                            foregroundColor: counterProvider.counter!=counterProvider.max ? Color(0xFF218563):Color(0xFFffffff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                          child: Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: botones,
                              fontFamily: 'Titulos',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

      // CONTENIDO FAVORITOS y HISTORIAL
            if (widget.title == 'FAVORITOS' || widget.title == 'HISTORIAL')
              SizedBox(height: 5),
            if (widget.title == 'FAVORITOS')
              Text(
                "AQUÍ ESTÁN LAS CONSULTAS QUE HAS GUARDADO",
                style: TextStyle(
                  fontSize: subtitulo,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Titulos',
                  color: Color(0xFFfff8e3),
                ),
                //textAlign: TextAlign.center,
              ),
            if (widget.title == 'HISTORIAL')
              Text(
                "AQUÍ ESTÁN TODAS TUS CONSULTAS",
                style: TextStyle(
                  fontSize: subtitulo,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Titulos',
                  color: Color(0xFFfff8e3),
                ),
                //textAlign: TextAlign.center,
              ),
            if (widget.title == 'FAVORITOS' || widget.title == 'HISTORIAL')
              SizedBox(height: 10),
            if (widget.title == 'HISTORIAL')
              if (texts.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: texts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector( // Añadido GestureDetector para el onTap
                        onTap: () {
                          if (widget.preguntaSel != null) {
                            widget.preguntaSel!(1); // Cambia el índice a 1 si el callback no es null
                          }
                          counterProvider.pos(index+1);
                        },
                        child: Container(
                          margin: EdgeInsets.all(10), // Espaciado entre los rectángulos
                          padding: EdgeInsets.all(20), // Espaciado interno
                          decoration: BoxDecoration(
                            color: Colors.white, // Color del fondo del rectángulo
                            borderRadius: BorderRadius.circular(0), // Esquinas redondeadas
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 3), // Cambia la dirección de la sombra
                              ),
                            ],
                          ),
                          child: Text(
                            texts[index]['pregunta'],
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

            if (widget.title == 'FAVORITOS')
              if (texts.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: texts.where((element) => element['favorito'] == 1).length,
                    itemBuilder: (context, index) {
                      final filteredTexts = texts.where((element) => element['favorito'] == 1).toList();
                      return GestureDetector( // Añadido GestureDetector para el onTap
                        onTap: () {
                          if (widget.preguntaSel != null) {
                            widget.preguntaSel!(1); // Cambia el índice a 1 si el callback no es null
                          }
                          counterProvider.pos(filteredTexts[index]['id']);
                        },
                        child: Container(
                          margin: EdgeInsets.all(10), // Espaciado entre los rectángulos
                          padding: EdgeInsets.all(20), // Espaciado interno
                          decoration: BoxDecoration(
                            color: Colors.white, // Color del fondo del rectángulo
                            borderRadius: BorderRadius.circular(0), // Esquinas redondeadas
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 3), // Cambia la dirección de la sombra
                              ),
                            ],
                          ),
                          child: Text(
                            filteredTexts[index]['pregunta'],
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

            if (widget.title == 'FAVORITOS' || widget.title == 'HISTORIAL')
              if (texts.isEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: screenWidth,
                        height: blackSpace,
                        color: Colors.transparent,
                      ),
                      Text(
                        "No se han encontrado consultas guardadas. ¡Prueba a realizar tu primera consulta!",
                        style: TextStyle(
                          fontSize: respuesta,
                          color: Color(0xFFfff8e3),
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Titulos',
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: blackSpace,
                        color: Colors.transparent,
                      ),
                    ]
                ),
            if (widget.title == 'FAVORITOS' && favs==false)
              if (!texts.isEmpty)
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: screenWidth,
                        height: blackSpace,
                        color: Colors.transparent,
                      ),
                      Text(
                        "No tienes ninguna consulta favorita. ¡Añade tu primera pinchando en el corazón que aparece en el asistente!",
                        style: TextStyle(
                          fontSize: respuesta,
                          color: Color(0xFFfff8e3),
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Titulos',
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: blackSpace,
                        color: Colors.transparent,
                      ),
                    ]
                ),

            if (widget.title == 'FAVORITOS' || widget.title == 'HISTORIAL')
              SizedBox(height: 15),

            if (widget.title == 'FAVORITOS')
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          resetFav();
                          _mensaje(2);
                        });
                        print("DESMARCA TODAS DE FAVORITOS");
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                        backgroundColor: Color(0xFFfff8e3),
                        foregroundColor: Color(0xFF218563),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        'REINICIAR LISTA',
                        style: TextStyle(
                          fontSize: botones,
                          fontFamily: 'Titulos',
                          height: 2,
                        ),
                      ),
                    ),
            if (widget.title == 'HISTORIAL')
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      borrarHistorial();
                      counterProvider.reset();
                      _mensaje(3);
                    });
                    print("REINICIA LA BASE DE DATOS");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    backgroundColor: Color(0xFFfff8e3),
                    foregroundColor: Color(0xFF218563),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'BORRAR\nHISTORIAL',
                    style: TextStyle(
                      fontSize: botones,
                      fontFamily: 'Titulos',
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 15), // Espacio entre botones
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      borrarNoFavs();
                      counterProvider.adjust(texts.length-1);
                      _mensaje(4);
                    });
                    print("REINICIA LA BASE DE DATOS");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    backgroundColor: Color(0xFFfff8e3),
                    foregroundColor: Color(0xFF218563),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'BORRAR NO\nFAVORITAS',
                    style: TextStyle(
                      fontSize: botones,
                      fontFamily: 'Titulos',
                      height: 1.5,
                    ),
                  ),
                ),
              ]
              ),
          ],
        ),
      ),
    );
  }
}
