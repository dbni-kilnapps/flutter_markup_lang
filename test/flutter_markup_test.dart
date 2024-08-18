import 'package:flutter_markup/fiml_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_markup/flutter_markup.dart';

void main() {
  test('test a basic tag', () {
    const fmlTextTest = """
      <Text>Hello, world!</Text>
      """;

    final fmlTest = FIMLParser().buildMarkupTree(fmlTextTest);

    print(fmlTest.toString());

    expect([FIMLElement(tag: "Text", children: "Hello, world!").toString()],
        fmlTest.toString());
  });

  test('test a tag with attributes', () {
    final fmlTextTest = """
      <Text money size size=12 foo='bar' color="blue" on-click={print("HI") expanded centered right lef tup down>Hello, world!</Text>
      """;

    final fmlTest = FIMLParser().buildMarkupTree(fmlTextTest);
    print(fmlTest[0].attributes[0]['size']);
    expect([
      FIMLElement(tag: "Text", children: "Hello, world!", attributes: [
        FIMLAttribute(name: "size", value: 12),
        FIMLAttribute(name: "foo", value: "bar"),
        FIMLAttribute(name: "color", value: "blue"),
        FIMLAttribute(name: "on-click", value: "print(\"HI\")")
      ]).toString()
    ], fmlTest.toString());
  });

  test('test nested attributes', () {
    final fmlTextTest = """
      <body>
        <Column>
          <button type="submit" on-click={print("HI")}>Submit</button>
        </Column>
      </body>
      """;

    final fmlTest = FIMLParser().buildMarkupTree(fmlTextTest);

    expect(
        FIMLElement(tag: "body", children: [
          FIMLElement(tag: "Column", children: [
            FIMLElement(tag: "button", children: "Submit", attributes: [
              FIMLAttribute(name: "type", value: "submit"),
              FIMLAttribute(name: "on-click", value: "print(\"HI\")")
            ])
          ])
        ]).toString(),
        fmlTest.toString());
  });

  test('test multiple tags', () {
    final fmlTextTest = """
      <Text>Hello, world!</Text>
      <Text size=12 foo='bar' color="blue" on-click={print("HI")}>Hello, world!</Text>
      <body>
        <Column>
          <button type="submit" on-click={print("HI")}>Submit</button>
          <button type="submit" on-click={print("CANCEL")}>Cancel</button>
        </Column>
      </body>
      """;

    final fmlTest = FIMLParser().buildMarkupTree(fmlTextTest);

    print(fmlTest.toString());

    expect(
        [
          FIMLElement(tag: "Text", children: "Hello, world!"),
          FIMLElement(tag: "Text", children: "Hello, world!", attributes: [
            FIMLAttribute(name: "size", value: 12),
            FIMLAttribute(name: "foo", value: "bar"),
            FIMLAttribute(name: "color", value: "blue"),
            FIMLAttribute(name: "on-click", value: "print(\"HI\")")
          ]),
          FIMLElement(tag: "body", children: [
            FIMLElement(tag: "Column", children: [
              FIMLElement(tag: "button", children: "Submit", attributes: [
                FIMLAttribute(name: "type", value: "submit"),
                FIMLAttribute(name: "on-click", value: "print(\"HI\")")
              ]),
              FIMLElement(tag: "button", children: "Cancel", attributes: [
                FIMLAttribute(name: "type", value: "submit"),
                FIMLAttribute(name: "on-click", value: "print(\"CANCEL\")")
              ])
            ])
          ])
        ].toString(),
        fmlTest.toString());
  });
  test('spans', () {
    const fmlTextTest = """
     <body>
        this is the body
        <p>This is a paragraph with <b>bold</b> text</p>
        <h2>This is a <i>paragraph</i> with <span>spanned</span> text</h2>
        <i>no more</i>
        with trailing text
      </body>
      """;

    final fmlTest = FIMLParser().buildMarkupTree(fmlTextTest);

    print(fmlTest.toString());
  });
  test('make sure comments aren\'t parsed', () {
    const fmlTextTest = """
      <body>
        // this is a comment
        <p>This is a paragraph with <b>bold</b> text</p>
        <h2>This is a <i>paragraph</i> with <span>spanned</span> text</h2>
        <i>no more</i>
        /*
        this is a block comment
        */
        with trailing text
      </body>
      """;

    final fmlTest = FIMLParser().buildMarkupTree(fmlTextTest);

    print(fmlTest.toString());

    expect(
        FIMLElement(tag: "body", children: [
          FIMLElement(tag: "p", children: [
            "This is a paragraph with ",
            FIMLElement(tag: "b", children: "bold"),
            " text"
          ]),
          FIMLElement(tag: "h2", children: [
            "This is a ",
            FIMLElement(tag: "i", children: "paragraph"),
            " with ",
            FIMLElement(tag: "span", children: "spanned"),
            " text"
          ]),
          FIMLElement(tag: "i", children: "no more"),
          "with trailing text"
        ]).toString(),
        fmlTest.toString());
  });
}
