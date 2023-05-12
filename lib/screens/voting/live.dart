import 'package:flutter/material.dart';
import 'package:vote/info.dart';


class Live extends StatefulWidget {
  const Live({Key? key}) : super(key: key);

  @override
  State<Live> createState() => _LiveState();
}

class _LiveState extends State<Live> {
  final Map<int, Position> _data = Position.positions;
  final List<int> _keys = Position.positions.keys.toList();

  @override
  void initState() {
    super.initState();
  }

  _goToCandidates(int index){
    Position.currentPosition = _keys[index];
    Navigator.of(context).pushNamed('/voted_candidates');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            leading: const Image(
              image: AssetImage('assets/logo.png'),
            ),
            title: Column(
              children: const [
                Text('Makerere University E-voting', style: TextStyle(color: Colors.black),),
                Text('Environment', style: TextStyle(color: Colors.black),),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 1,
          ),

          // if(loading || refresh)
          //   Center(
          //     child: (refresh)?Column(
          //       children: [
          //         IconButton(
          //           onPressed: _getCategories,
          //           icon: const Icon(
          //             Icons.replay,
          //             color: Colors.green,
          //             size: 40,
          //           ),
          //         ),
          //         const Text('Reload!')
          //       ],
          //     ):
          //     const CircularProgressIndicator(color: Colors.green),
          //   ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _data.length,
              itemBuilder: (BuildContext context, int index) {
                Position? position = _data[_keys[index]];
                return Column(
                  children: [
                    Category(
                      category: position?.name ?? '',
                      categoryIndex: index,
                      getCandidates: _goToCandidates,
                    ),
                    if(index+1<_data.length)
                      const Divider(color: Colors.grey, thickness: 1,)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

/*
  @override
  Widget build1(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text('Categories', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25),),
          // ),

          if(loading)
            const Center(child: CircularProgressIndicator(color: Colors.green),),
          Expanded(
            child: _buildPanel(),
          )
        ],
      ),
    );
  }



  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (index, isOpen){
        setState(() {
          _isOpen[index] = !isOpen;
        });
      },
      children: _keys.map<ExpansionPanel>((pos) {
        Position? position = _data[pos];
        List<FetchedCandidate>? candidates = position?.candidates.values.toList();
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(position?.name ?? ""),
            );
          },
          body: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: candidates?.length,
              itemBuilder: (BuildContext context, int index){
                return ExpansionTile(
                  title: Text(candidates?[index].student ?? ""),
                  trailing: Text(candidates?[index].votes.toString() ?? '0'),
                );
              }
          ),
          isExpanded: _isOpen[pos-1],
          canTapOnHeader: true,
        );
      }).toList(),
    );
  }
  */
}

class Category extends StatelessWidget {
  const Category({Key? key, required this.category, required this.categoryIndex, required this.getCandidates}) : super(key: key);
  final String category;
  final int categoryIndex;
  final Function getCandidates;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20,),
      onTap: ()=>getCandidates(categoryIndex),
      splashColor: Colors.green[200],
      iconColor: Colors.black,
      contentPadding: const EdgeInsets.all(0),
      visualDensity: const VisualDensity(vertical: -4),
    );
  }
}

