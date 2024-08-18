library flutter_markup;

import 'package:flutter/material.dart';

import 'package:flutter_markup/models.dart';

/// takes an FIML string and returns a corresponding widget tree
class FIML extends StatelessWidget {
  final String input;
  final String style; // style in FQSS (Flutter Query Style Sheet)
  late FIMLTree tree;

  //constructor, style is optional named param
  FIML(this.input, {this.style = ''}) {
    //check if input is empty
    if (input.isEmpty) {
      throw Exception("Please add a tag to your input");
    }
    tree = FIMLTree(elements: FIMLParser().buildMarkupTree(input));
  }

  @override
  Widget build(BuildContext context) {
    return tree.buildWidgetTree(context);
  }
}

/// Parses the FIML string and returns a list of FIMLElements
class FIMLParser {
  final RegExp selfClosingTagPattern = RegExp(r'<(\w+)(\s+\w+="[^"]*")*\s*\/>');
  final RegExp fullTagPattern =
      RegExp(r'<\s*([a-zA-Z0-9]+)\s*([^>]*?)\s*>([\s\S]*?)<\/\s*\1\s*>');
  final RegExp combinedTagPattern = RegExp(
      r'(<(\w+)(\s+\w+="[^"]*")*\s*\/>)|(<\s*([a-zA-Z0-9]+)\s*([^>]*?)\s*>([\s\S]*?)<\/\s*\5\s*>)');
  final RegExp attributesPattern =
      RegExp(r'([\w-]+)=(?:("[^"]*")|([^ ]+)|(\d+))');

  List<dynamic> buildMarkupTree(String input) {
    List<dynamic> elements = [];
    int lastIndex = 0;

    final matches = combinedTagPattern.allMatches(input);

    for (var match in matches) {
      // Capture any plain text before this tag
      if (match.start > lastIndex) {
        final text = input.substring(lastIndex, match.start).trim();
        if (text.isNotEmpty) {
          elements.add(text); // Add plain text directly as String
        }
      }

      if (match.group(1) != null) {
        // Self-closing tag
        final tagName = match.group(2)!;
        final attributesRaw = match.group(3) ?? "";
        List<FIMLAttribute> attributes = _parseAttributes(attributesRaw);

        elements.add(FIMLElement(tag: tagName, children: null, attributes: attributes));
      } else if (match.group(4) != null) {
        // Full tag with content
        final tagName = match.group(5)!;
        final attributesRaw = match.group(6) ?? "";
        final children = match.group(7)?.trim() ?? "";

        List<FIMLAttribute> attributes = _parseAttributes(attributesRaw);
        List<dynamic> childrenElements = buildMarkupTree(children);

        elements.add(FIMLElement(tag: tagName, children: childrenElements, attributes: attributes));
      }

      lastIndex = match.end;
    }

    // Capture remaining text after the last tag
    if (lastIndex < input.length) {
      final text = input.substring(lastIndex).trim();
      if (text.isNotEmpty) {
        elements.add(text); // Add plain text directly as String
      }
    }

    return elements;
  }

  List<FIMLAttribute> _parseAttributes(String attributesRaw) {
    List<FIMLAttribute> attributes = [];

    if (attributesRaw.isNotEmpty) {
      final attribsSplit = attributesPattern.allMatches(attributesRaw);
      for (var attribMatch in attribsSplit) {
        final g = attribMatch.group(0)!.split("=");
        //print g2 groups

        final attribute = FIMLAttribute(name: g[0], value: int.tryParse(g[1]) ?? g[1].substring(1, g[1].length - 1));
        attributes.add(attribute);
      }
      var g2 = [];
      for(var c in attributesRaw.split(attributesPattern)){
        var y = c.split(" ");
        if(c != ""){
          g2.addAll(y);
        }

      }
      g2.removeWhere((element) => element == "");
      print("hi");
      if(g2.isNotEmpty){
        attributes.addAll(g2.map(
          (e) => FIMLAttribute(name: e, value: true)
        ));
      }
      
    }
    return attributes;
  }
}



class Range {
  final int start;
  final int end;

  Range(this.start, this.end);
}