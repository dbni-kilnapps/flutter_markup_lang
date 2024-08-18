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

  // Widget buildWidgetTree(BuildContext context) {
  //   for (FIMLElement element in tree.elements) {
  //     //top level elements
  //     if (element.tag == 'Scaffold') {
  //       //find the appbar and body
  //       final appbar = tree.queryElement('AppBar');
  //       final body = tree.queryElement('body');
  //       final floatingActionButton = tree.queryElement('FloatingActionButton');

  //       return Scaffold(
  //         appBar: appbar.toWidget(context) as AppBar,
  //         body: body.toWidget(context),
  //         floatingActionButton: floatingActionButton.toWidget(context),
  //       );
  //     }
  //   }
  //   throw Exception("No elements found in the tree");
  // }
}

/// Parses the FIML string and returns a list of FIMLElements
class FIMLParser {
  final RegExp selfClosingTagPattern = RegExp(r'<(\w+)(\s+\w+="[^"]*")*\s*\/>');
  final RegExp fullTagPattern =
      RegExp(r'(<\s*([a-zA-Z0-9]+)\s*([^>]*?)\s*>)([\s\S]*?)(<\/\s*\2\s*>)');
  final RegExp attributesPattern =
      RegExp(r'([\w-]+)=(?:("[^"]*")|([^ ]+)|(\d+))');

  List<FIMLElement> buildMarkupTree(String input) {
    final matches = fullTagPattern.allMatches(input);
    final selfClosingMatches = selfClosingTagPattern.allMatches(input);
    if (matches.isEmpty && selfClosingMatches.isEmpty) {
      throw Exception("Please add a tag to your input");
    }

    List<FIMLElement> elements = [];
    List<Range> fullTagRanges = [];

    // Process full tags
    for (var match in matches) {
      final tagName = match.group(2)!;
      final attributesRaw = match.group(3) ?? "";
      final children = match.group(4) ?? "";

      List<FIMLAttribute> attributes = [];

      if (attributesRaw.isNotEmpty) {
        final attribsSplit = attributesPattern.allMatches(attributesRaw);
        for (var attribMatch in attribsSplit) {
          final g = attribMatch.group(0)!.split("=");

          final attribute = FIMLAttribute(
              name: g[0],
              value: int.tryParse(g[1]) ?? g[1].substring(1, g[1].length - 1));

          attributes.add(attribute);
        }
      }

      dynamic childrenElements;

      // Check if content has nested tags
      final nestedTagMatches = fullTagPattern.allMatches(children);
      if (nestedTagMatches.isNotEmpty) {
        List<FIMLElement> nestedElements = buildMarkupTree(children);
        childrenElements =
            nestedElements.length == 1 ? nestedElements.first : nestedElements;
      } else if (children.isNotEmpty) {
        childrenElements = children;
      } else {
        childrenElements = null;
      }

      elements.add(FIMLElement(
          tag: tagName, children: childrenElements, attributes: attributes));

      // Add the range of this full tag to the list
      fullTagRanges.add(Range(match.start, match.end));
    }

    // Process self-closing tags
    for (var match in selfClosingMatches) {
      final tagName = match.group(1)!;
      final attributesRaw = match.group(2) ?? "";

      bool isWithinFullTag = fullTagRanges.any((range) =>
          match.start >= range.start && match.end <= range.end);

      if (isWithinFullTag) {
        continue; // Skip this self-closing tag
      }

      List<FIMLAttribute> attributes = [];

      if (attributesRaw.isNotEmpty) {
        final attribsSplit = attributesPattern.allMatches(attributesRaw);
        for (var attribMatch in attribsSplit) {
          final g = attribMatch.group(0)!.split("=");

          final attribute = FIMLAttribute(
              name: g[0],
              value: int.tryParse(g[1]) ?? g[1].substring(1, g[1].length - 1));

          attributes.add(attribute);
        }
      }

      elements.add(
          FIMLElement(tag: tagName, children: null, attributes: attributes));
    }

    return elements;
  }
}

class Range {
  final int start;
  final int end;

  Range(this.start, this.end);
}