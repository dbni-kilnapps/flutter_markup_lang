import 'package:flutter/material.dart';
import 'package:flutter_markup/flutter_markup.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//FIML implementation
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FIML("""
    <Scaffold>
      <AppBar title="${widget.title}" />
      <body>
        <Column main-axis-alignment="center" centered>
          <Text>You have pushed the button this many times:</Text>
          <Text>$_counter</Text>
          <img src="https://picsum.photos/200/300" alt="Joseph" />
          <Icon icon="add" />
          <a href="https://flutter.dev">Flutter</a>
        </Column>
        <p>howdy <b>everyone</b> how <i>are you</i> today?</p>
        <Row main-axis-alignment="space-between" cross-axis-alignment="center">
          <h1>howdy</h1>
          <h2>partner</h2>
        </Row>
      </body>
      <FloatingActionButton tooltip="Click to increment counter">
        <Text>Hello</Text>
      </FloatingActionButton>
    </Scaffold>
    <Text>You have pushed the button this many times:</Text>

    """, style: """
    AppBar {
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    }
    """);
  }
}

/*
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/