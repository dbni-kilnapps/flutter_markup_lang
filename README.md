# flutter_markup (STILL WIP)

A Flutter package for rendering markup into Flutter widgets.

## Features

- Convert markup strings into Flutter widgets.
- Support for various HTML tags like `<div>`, `<span>`, `<img>`, and more.
- Customizable styles and attributes for tags.
- Easy integration with existing Flutter projects.

## Getting started

To start using the `flutter_markup` package, add it to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_markup: ^1.0.0
```
Then, run `flutter pub get` to install the package.

# Usage
Here is a simple example of how to use the flutter_markup package:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_markup/flutter_markup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Markup Example'),
        ),
        body: Center(
          child: FIML(
            """
            <Scaffold> // meant to be autodetected
            <AppBar title="${widget.title}" />
                <body>
                        <Center>
                        <Column main-axis-alignment="center">
                            <Text>You have pushed the button this many times:</Text>
                            <Text>$_counter</Text>
                        </Column>
                        </Center>
                    </body>
                <FloatingActionButton on-pressed="_incrementCounter" tooltip="Increment">
                    <Icon icon="add" />
                </FloatingActionButton>
            </Scaffold>
            """
          ),
        ),
      ),
    );
  }
}
```

For more examples, check the `/example` folder.

