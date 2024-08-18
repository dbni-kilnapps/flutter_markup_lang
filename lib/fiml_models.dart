import 'package:flutter/material.dart';
import 'package:flutter_markup/icons_map.dart';
import 'package:url_launcher/url_launcher.dart';
export 'package:flutter_markup/fiml_models.dart';

/// A basic FIML tag
/// Tags can be any Flutter widget or an HTML tag
///
/// Example:
/// <Text size=12 foo="bar">Hello, world!</Text>
///
/// Some usable HTML tags are:
/// - Text
///   - headlines (1-6) <hN>
///   - paragraph <p>
/// - Anchors <a href="">
/// - Images <img src="">
/// - Lists <ul> <ol> <li>
/// - Tables <table> <tr> <td>
/// - Forms <form> <input> <button>
/// - Divs <div> (use Container instead)
/// - Spans <span> (use TextSpan instead)
///
/// TODO: Widgets that use "Props" will have dedicateed slots for attributes
/// Example:
/// <Scaffold>
///  appbar:<AppBar title="widget.title" />
///  body:<Center>
///        <Column main-axis-alignment="center">
///         <Text>You have pushed the button this many times:</Text>
///        <Text>$_counter</Text>
///      </Column>
///   </Center>
/// </Scaffold>
class FIMLElement {
  final String tag;
  final dynamic children; // either plain text or a list of FIMLElements
  final List<FIMLAttribute> attributes;
  final List<FIMLStyle>? styles;

  // Constructor with named params, attributes are optional
  FIMLElement({
    required this.tag,
    required this.children,
    this.attributes = const [],
    //optional named param
    this.styles = const [],
  });

  @override
  String toString() {
    return "FIMLElement(tag: $tag, children: $children, attributes: $attributes)";
  }

  dynamic tryGetAttribute(String name) {
    final attrib = attributes.firstWhere(
      (attribute) => attribute.name == name,
      orElse: () => FIMLAttribute(name: name, value: null),
    );

    var reservedKeywords = <String, dynamic>{
      'main-axis-alignment': {
        'start': MainAxisAlignment.start,
        'end': MainAxisAlignment.end,
        'center': MainAxisAlignment.center,
        'space-between': MainAxisAlignment.spaceBetween,
        'space-around': MainAxisAlignment.spaceAround,
        'space-evenly': MainAxisAlignment.spaceEvenly,
      },
      'cross-axis-alignment': {
        'start': CrossAxisAlignment.start,
        'end': CrossAxisAlignment.end,
        'center': CrossAxisAlignment.center,
        'stretch': CrossAxisAlignment.stretch,
        'baseline': CrossAxisAlignment.baseline,
      },
      'box-fit': {
        'fill': BoxFit.fill,
        'contain': BoxFit.contain,
        'cover': BoxFit.cover,
        'fit-width': BoxFit.fitWidth,
        'fit-height': BoxFit.fitHeight,
        'none': BoxFit.none,
        'scale-down': BoxFit.scaleDown,
      },
      'icon': iconsMap,
      'color': {
        // 'primary': Theme.of(context).colorScheme.primary,
        // 'primary-variant': Theme.of(context).colorScheme.primaryVariant,
        'red': Colors.red,
        'blue': Colors.blue,
        'green': Colors.green,
        'yellow': Colors.yellow,
        'orange': Colors.orange,
        'purple': Colors.purple,
        'black': Colors.black,
        'white': Colors.white,
        'transparent': Colors.transparent,
      }
    };

    for (var key in reservedKeywords.keys) {
      if (key == attrib.name) {
        return reservedKeywords[attrib.name][attrib.value];
      }
    }

    if (attrib.value == "key") {
      return Key(attrib.value);
    }

    if (attrib.value == "on-pressed") {
      return Function.apply(attrib.value, []);
    }

    return attrib[name];
  }

  dynamic tryGetStyle(String name){
    final style = styles!.firstWhere(
      (style) => style.name == name,
      orElse: () => FIMLStyle(name: name, value: null),
    );

    var colors = {
      'color':{
        'red': Colors.red,
        'blue': Colors.blue,
        'green': Colors.green,
        'yellow': Colors.yellow,
        'orange': Colors.orange,
        'purple': Colors.purple,
        'black': Colors.black,
        'white': Colors.white,
        'transparent': Colors.transparent,
      }
    };

    return style[name];
  }


  Widget toWidget(BuildContext context, {String? parentName}) {
    var _textStyles = {
      'h1': Theme.of(context).textTheme.displayLarge,
      'h2': Theme.of(context).textTheme.displayMedium,
      'h3': Theme.of(context).textTheme.displaySmall,
      'h4': Theme.of(context).textTheme.headlineLarge,
      'h5': Theme.of(context).textTheme.headlineMedium,
      'h6': Theme.of(context).textTheme.headlineSmall,
      'p': Theme.of(context).textTheme.bodySmall,
      'b': const TextStyle(fontWeight: FontWeight.bold),
      'i': const TextStyle(fontStyle: FontStyle.italic),
      'Text': null,
    };

    // Determine the current style based on the tag or the parent's tag name
    TextStyle? currentStyle = _textStyles[tag] ?? _textStyles[parentName];

    switch (tag) {
      //flutter Based
      case 'Scaffold':
        return Scaffold(
          appBar: _findChildByTag('AppBar', required: true)!.toWidget(context, parentName: tag)
              as AppBar,
          body: _findChildByTag('body', required: true)!.toWidget(context, parentName: tag),
          floatingActionButton: _findChildByTag('FloatingActionButton')?.toWidget(context, parentName: tag)
        );
      case 'AppBar':
        return AppBar(
          title: Text(tryGetAttribute('title')),
          backgroundColor: Theme.of(context).primaryColorLight,
        );
      case 'FloatingActionButton':
        return FloatingActionButton(
          onPressed: () {},
          tooltip: tryGetAttribute('tooltip'),
          child: _buildChildWidget(context, currentStyle),
        );
      case 'Icon':
        return Icon(tryGetAttribute('icon'));
      case 'FlutterLogo':
        return FlutterLogo();
      case 'Column':
        return _checkPositionalAttributes(Column(
          mainAxisAlignment:
              tryGetAttribute('main-axis-alignment') ?? MainAxisAlignment.start,
          crossAxisAlignment: tryGetAttribute('cross-axis-alignment') ??
              CrossAxisAlignment.center,
          children: children is List
              ? _buildChildren(context, currentStyle)
              : [_buildChildWidget(context, currentStyle)],
        ));
      case 'Row':
        return Row(
          mainAxisAlignment:
              tryGetAttribute('main-axis-alignment') ?? MainAxisAlignment.start,
          crossAxisAlignment: tryGetAttribute('cross-axis-alignment') ??
              CrossAxisAlignment.center,
          children: children is List
              ? _buildChildren(context, currentStyle)
              : [_buildChildWidget(context, currentStyle)],
        );
      case 'ListView':
        if (tryGetAttribute('type') == 'builder') {
          return Expanded(
            child: ListView.builder(
              itemCount: tryGetAttribute('item-count'),
              itemBuilder: (context, index) {
                //build all children
                return Column(children: 
                  _buildChildren(context, currentStyle)
                );
              },
            ),
          );
        }
        return ListView(
          children: _buildChildren(context, currentStyle),
        );
      case 'ListTile':
        return ListTile(
          onTap: () {
            tryGetAttribute('on-tap');
          },
          leading: _findChildBySlot('leading')?.toWidget(context, parentName: tag),
          title: _findChildBySlot('title', required: true)!.toWidget(context, parentName: tag),
          subtitle: _findChildBySlot('subtitle')?.toWidget(context, parentName: tag),
          trailing: _findChildBySlot('trailing')?.toWidget(context, parentName: tag),
        );

      //HTML based
      case 'body':
        return children is List
            ? Column(children: _buildChildren(context, currentStyle))
            : _buildChildWidget(context, currentStyle);

      case 'img':
        //TODO: Add support for other image attributes
        return Image.network(
          tryGetAttribute('src'),
          fit: tryGetAttribute('box-fit') ?? BoxFit.cover,
        );

      case 'a':
        return GestureDetector(
          onTap: () async {
            final Uri url = Uri.parse(tryGetAttribute('href'));
            if (!await launchUrl(url)) {
              throw Exception('Could not launch $url');
            }
          },
          child: Text(
            children[0],
            style: TextStyle(color: Colors.blue),
          ),
        );
      case 'div':
        return Container(
          width: tryGetAttribute('width').toDouble() ?? double.infinity,
          height: tryGetAttribute('height').toDouble() ?? double.infinity,
          decoration: BoxDecoration(
            color: tryGetAttribute('color') ?? Colors.transparent,
          ),
          child: children is List
              ? Column(children: _buildChildren(context, currentStyle))
              : _buildChildWidget(context, currentStyle),
        );
      //TODO: implement text span adapter
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
      case 'p':
      case 'b':
      case 'i':
      case 'span':
      case 'Text':
        if (children.length == 1) {
          return _checkPositionalAttributes(
            Text(
              children[0],
              style: _textStyles[parentName]?.merge(_textStyles[tag]) ??
                  _textStyles[tag],
            ),
          );
        } else {
          return _checkPositionalAttributes(
            Text.rich(
              TextSpan(children: [
                for (var child in children)
                  if (child is String)
                    TextSpan(text: " $child ", style: currentStyle)
                  else if (child is FIMLElement)
                    WidgetSpan(child: child.toWidget(context, parentName: tag))
              ]),
              textAlign: TextAlign.center,
            ),
          );
          // return Row(
          //   children: _buildChildren(context, currentStyle),
          // );
        }
    }
    return Container(); // Fallback for unsupported tags
  }

  List<Widget> _buildChildren(BuildContext context, TextStyle? currentStyle, {List<dynamic> parameters = const []}) {
    return (children as List).map<Widget>((e) {
      if (e is FIMLElement) {
        return e.toWidget(context,
            parentName: tag); // Passing the tag name as parentName
      } else if (e is String) {
        return Text(e, style: currentStyle);
      }
      return Container();
    }).toList();
  }

  Widget _buildChildWidget(BuildContext context, TextStyle? currentStyle) {
    if (children is FIMLElement) {
      return (children as FIMLElement).toWidget(context,
          parentName: tag); // Passing the tag name as parentName
    } else if (children is String) {
      return Text(children, style: currentStyle);
    } else {
      return Container(); // Handle other cases if necessary
    }
  }

  /// Find a child element by its tag name (used for widgets which require a specific child)
  /// Throws an exception if the tag is not found
  FIMLElement? _findChildByTag(String tag, {bool required = false}) {
    if (children is List) {
      return (children as List).firstWhere((element) => element.tag == tag,
          orElse: () => required ? throw Exception("Missing required widget $tag") : null);
    }
    throw Exception("Something went wrong");
  }

  ///modifies the given widget based on the attributes
  Widget _checkPositionalAttributes(Widget widget) {
    //check if attributes contains named attribute "centered"
    if (tryGetAttribute('centered') == true) {
      return Center(child: widget);
    }
    return widget;
  }
  
  _findChildBySlot(String slot, {bool required = false}) {
    if (children is List) {
      return (children as List).firstWhere((element) => element.tryGetAttribute('slot') == slot,
          orElse: () => null);
    }
    throw Exception("Something went wrong");
  }
}

class FIMLStyle{
  final String name;
  final dynamic value;

  FIMLStyle({required this.name, required this.value});

  dynamic operator [](String key) {
    return value;
  }

  @override
  String toString() {
    return "FIMLStyle(name: $name, value: $value)";
  }
}

class FIMLAttribute {
  final String name;
  final dynamic value;

  //constructor, nameed params
  FIMLAttribute({required this.name, required this.value});

  dynamic operator [](String key) {
    return value;
  }

  @override
  String toString() {
    return "FIMLAttribute(name: $name, value: $value)";
  }
}

class FIMLTree {
  final List<dynamic> elements;

  //constructor
  FIMLTree({required this.elements});

  @override
  String toString() {
    return "FIMLTree(elements: $elements)";
  }

  Widget buildWidgetTree(BuildContext context) {
    if (elements.isEmpty) {
      throw Exception("No elements found in the tree");
    }
    // var widg = <Widget>[];
    // for(FIMLElement element in elements){
    //   widg.add(element.toWidget(context));
    // }
    return elements[0].toWidget(context);
  }

  FIMLElement queryElement(String tag) {
    return _queryElementRecursive(elements, tag) ??
        FIMLElement(tag: "Container", children: "No element found");
  }

  FIMLElement? _queryElementRecursive(List<dynamic> elements, String tag) {
    for (var element in elements) {
      if (element.tag == tag) {
        return element;
      }
      if (element.children is List<FIMLElement>) {
        var result = _queryElementRecursive(element.children as List, tag);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }
}
