import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vote/info.dart';
import 'package:vote/requests.dart';
import 'category.dart';


class Vote extends StatefulWidget {
  const Vote({Key? key, required this.toggle}) : super(key: key);
  final Function toggle;

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  bool refresh = false;
  bool loading = true;
  late var categories = [];

  _getCategories(){
    if(loading || refresh) {
      RequestCubit.getCategories().then((categories) {
        if (categories is String) {
          setState(() {
            loading = false;
            refresh = true;
          });
        }
        else if (categories is List<dynamic>) {
          var cat = [];
          for (var category in categories) {
            cat.add(category);
            if(CategoryVote.enabledCategories.length<categories.length) {
              CategoryVote.enabledCategories.add(true);
            }
          }

          setState(() {
            loading = false;
            refresh = false;
            this.categories = cat;
          });
        }
      });
    }
  }

  _goToCandidates(int categoryIndex){
    var cat = categories[categoryIndex];
    CategoryVote.set(cat['id'] as int, cat['name'].toString(), cat['affiliation'].toString(), cat['max'] as int);

    Navigator.of(context).pushNamed('/candidates').then((value) {
      if(CategoryVote.done!){
        setState(() {
          CategoryVote.enabledCategories[categoryIndex] = false;
        });
        widget.toggle();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestCubit, String>(
      listener: (context, state){
        if(state == "voted"){
          Navigator.pushReplacementNamed(context, '/done');
        }
      },
      child:
      SafeArea(
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Categories', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25),),
            ),

            if(loading || refresh)
              Center(
                child: (refresh)?Column(
                  children: [
                    IconButton(
                      onPressed: _getCategories,
                      icon: const Icon(
                        Icons.replay,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    const Text('Reload!')
                  ],
                ):
                const CircularProgressIndicator(color: Colors.green),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Category(
                        category: categories[index]['name'] as String,
                        categoryIndex: index,
                        enabled: CategoryVote.enabledCategories[index],
                        getCandidates: _goToCandidates,
                      ),
                      if(index+1<categories.length)
                        const Divider(color: Colors.grey, thickness: 1,)
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

