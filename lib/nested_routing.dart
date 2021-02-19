import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

main() {
  runApp(
    VRouter(
      routes: [
        VStacked(
          key: ValueKey('MyScaffold'),
          widget: MyScaffold(),
          subroutes: [
            VChild(
              path: '/${HomePage.label}',
              name: HomePage.label,
              widget: HomePage(),
            ),
            VChild(
              path: '/${SchedulePage.label}',
              name: SchedulePage.label,
              widget: SchedulePage(),
              subroutes: [
                VChild(
                  path: '${MainViewTab.label}',
                  name: '${MainViewTab.label}',
                  widget: MainViewTab(), // This will never be used in practice
                ),
                VChild(
                  path: '${KanbanViewTab.label}',
                  name: '${KanbanViewTab.label}',
                  widget: KanbanViewTab(), // This will never be used in practice
                ),
              ],
              // "/schedule" should never be accessed, if it is we redirect to "/schedule/main"
              beforeEnter: (vRedirector) async =>
                  vRedirector.pushReplacement('/${SchedulePage.label}/${MainViewTab.label}'),
            ),
            VChild(
              path: '/${BudgetPage.label}',
              name: BudgetPage.label,
              widget: BudgetPage(),
            ),
            VChild(
              path: '/${TeamPage.label}',
              name: TeamPage.label,
              widget: TeamPage(),
            ),
          ],
        ),
        VRouteRedirector(path: ':_(.*)', redirectTo: '/${HomePage.label}'),
      ],
    ),
  );
}

class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          LeftNavigationBar(),
          Expanded(child: VRouteElementData.of(context).vChild),
        ],
      ),
    );
  }
}

class LeftNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeftNavigationBarTextButton(label: HomePage.label),
        LeftNavigationBarTextButton(label: SchedulePage.label),
        LeftNavigationBarTextButton(label: BudgetPage.label),
        LeftNavigationBarTextButton(label: TeamPage.label),
      ],
    );
  }
}

class LeftNavigationBarTextButton extends StatelessWidget {
  final String label;

  const LeftNavigationBarTextButton({Key key, @required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = (VRouteElementData.of(context).vChildName == label);
    return TextButton(
      onPressed: () {
        if (!isSelected) VRouterData.of(context).pushNamed(label);
      },
      style: ButtonStyle(
        alignment: Alignment.topLeft,
        padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isSelected ? Colors.blueAccent : Colors.black,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  static final label = 'home';

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('This is the $label page.'));
  }
}

class SchedulePage extends StatefulWidget {
  static final label = 'schedule';

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We check the url to see if the current selected tab is the same as the one
    // in the url
    final tabBarViewIndex =
        VRouteElementData.of(context).vChildName == MainViewTab.label ? 0 : 1;
    if (tabBarViewIndex != tabController.index) tabController.animateTo(tabBarViewIndex);

    // We listen to the tabController and push a new route if the index changes
    tabController.addListener(() {
      if (tabBarViewIndex != tabController.index)
        VRouterData.of(context).pushReplacementNamed(
            (tabController.index == 0) ? MainViewTab.label : KanbanViewTab.label);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(child: Text('This is the ${SchedulePage.label} page.')),
        Container(
          color: Colors.greenAccent,
          child: TabBar(
            controller: tabController,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            labelPadding: const EdgeInsets.all(20.0),
            tabs: [
              Center(
                child: Text(MainViewTab.label),
              ),
              Center(
                child: Text(KanbanViewTab.label),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              MainViewTab(),
              KanbanViewTab(),
            ],
          ),
        )
      ],
    );
  }
}

class MainViewTab extends StatelessWidget {
  static final label = 'main';

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('This is the $label tab view.'));
  }
}

class KanbanViewTab extends StatelessWidget {
  static final label = 'kanban';

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('This is the $label tab view.'));
  }
}

class BudgetPage extends StatelessWidget {
  static final label = 'budget';

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('This is the $label page.'));
  }
}

class TeamPage extends StatefulWidget {
  static final label = 'team';

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final List<String> names = [
    'Liam',
    'Olivia',
    'Noah',
    'Emma',
    'Oliver',
    'Ava',
    'William',
    'Sophia',
    'Elijah',
    'Isabella',
    'James',
    'Charlotte',
    'Benjamin',
    'Amelia',
    'Lucas',
    'Mia',
    'Mason',
    'Harper',
    'Ethan',
    'Evelyn'
  ];

  String nameEditBeingShown;

  @override
  Widget build(BuildContext context) {
    final nameBeingEdited = VRouteData.of(context).queryParameters['edit'];
    if (nameBeingEdited != nameEditBeingShown) {
      if (nameBeingEdited == null) {
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        if (nameEditBeingShown != null) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => VRouterData.of(context).push('/team'),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    color: Colors.white,
                    child: Text('You are editing $nameBeingEdited'),
                  ),
                ),
              ),
            ),
          );
        });
      }
      nameEditBeingShown = nameBeingEdited;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200),
        child: Column(
          children: [
            Text('This is the ${TeamPage.label} page.'),
            Expanded(
              child: ListView(
                children: names
                    .map(
                      (name) => ListTile(
                        title: Text(name),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            VRouterData.of(context)
                                .push('/team', queryParameters: {'edit': name});
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
