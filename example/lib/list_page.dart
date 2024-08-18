import 'package:flutter/material.dart';
import 'package:flutter_markup/flutter_markup.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return FIML("""
      <Scaffold>
        <AppBar title="List Page" />
        <body> // body is the default container for the scaffold
          <ListView type="builder" item-count=5>
            <ListTile on-tap={print()}>
              <FlutterLogo slot="leading" />
              <Text slot="title">Tile title</Text>
              <Text slot="subtitle">Tile subtitle</Text>
              <Icon icon="add" slot="trailing" />
            </ListTile>
          </ListView>
        </body>
      </Scaffold>
      """
    );
  }
}