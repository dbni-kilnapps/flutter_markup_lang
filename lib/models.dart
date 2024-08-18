import 'package:flutter/material.dart';
export 'package:flutter_markup/models.dart';

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
  final dynamic children; //either plain text or a list of FIMLElements
  final List<FIMLAttribute> attributes;

  //constructor with named params, attributes are optional
  FIMLElement(
      {required this.tag, required this.children, this.attributes = const []});

  @override
  String toString() {
    return "FIMLElement(tag: $tag, children: $children, attributes: $attributes)";
  }

  dynamic tryGetAttribute(String name) {
    final attrib = attributes.firstWhere(
      (attribute) => attribute.name == name,
      orElse: () => FIMLAttribute(name: name, value: null),
    );

    if(attrib.name == "main-axis-alignment"){
      switch(attrib.value){
        case "start":
          return MainAxisAlignment.start;
        case "end":
          return MainAxisAlignment.end;
        case "center":
          return MainAxisAlignment.center;
      }
    }

    if(attrib.name == "icon"){
      switch(attrib.value){
        case "add":
          return Icon(Icons.add);
        case "photo":
          return Icon(Icons.add_a_photo);
      
      }
    }

    return attrib[name];
  }

  Widget toWidget(BuildContext context) {
    switch (tag) {
      case 'AppBar':
        return AppBar(title: Text(tryGetAttribute('title')));
      case 'body':
        return _buildChildWidget(context);
      case 'FloatingActionButton':
        return FloatingActionButton(
          onPressed: () {},
          tooltip: tryGetAttribute('tooltip'),
          child: _buildChildWidget(context),
        );
      case 'Icon':
        return tryGetAttribute('icon');
      // Alignment widgets
      case 'Center':
        return Center(
          key: tryGetAttribute('key'),
          child: _buildChildWidget(context),
        );

      // Collection widgets
      case 'Column':
        return Column(
          mainAxisAlignment: tryGetAttribute('main-axis-alignment'),
          children: children is List
              ? (children as List<FIMLElement>).map<Widget>((e) => e.toWidget(context)).toList()
              : [_buildChildWidget(context)],
        );

      // Text widgets
      case 'Text':
        return Text(children);
      case 'h5':
        return Text(children, style: Theme.of(context).textTheme.headlineSmall);
      case 'p':
        return Text(children);
    }
    return Container(); //TODO: custom widget logic
  }


  Widget _buildChildWidget(BuildContext context) {
    if (children is FIMLElement) {
      return (children as FIMLElement).toWidget(context);
    } else if (children is String) {
      return Text(children);
    } else {
      return Container(); // or handle other cases if necessary
    }
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
  final List<FIMLElement> elements;

  //constructor
  FIMLTree({required this.elements});

  @override
  String toString() {
    return "FIMLTree(elements: $elements)";
  }

  Widget buildWidgetTree(BuildContext context) {
    for(FIMLElement element in elements){
      //top level elements
      if(element.tag == 'Scaffold'){
        //find the appbar and body
        final appbar = queryElement('AppBar');
        final body = queryElement('body');
        final floatingActionButton = queryElement('FloatingActionButton');

        return Scaffold(
          appBar: appbar.toWidget(context) as AppBar,
          body: body.toWidget(context),
          floatingActionButton: floatingActionButton.toWidget(context),
        );
        
      }
    }
    throw Exception("No elements found in the tree");
  }

  FIMLElement queryElement(String tag) {
    return _queryElementRecursive(elements, tag) ?? FIMLElement(tag: "Container", children: "No element found");
  }
  FIMLElement? _queryElementRecursive(List<FIMLElement> elements, String tag) {
    for (var element in elements) {
      if (element.tag == tag) {
        return element;
      }
      if (element.children is List<FIMLElement>) {
        var result = _queryElementRecursive(element.children as List<FIMLElement>, tag);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }
}
