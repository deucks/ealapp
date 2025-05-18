import 'package:ealapp/models/base/pathway_model.dart';
import 'package:ealapp/providers/pathway_provider.dart';
import 'package:ealapp/providers/top_level_provier.dart';
import 'package:ealapp/views/simulator/simulator_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    var pathwayProviderRef = ref.watch(pathwayProvider);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          0,
          MediaQuery.of(context).padding.top,
          0,
          MediaQuery.of(context).padding.bottom + 100,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Text(
                "EAL Conversational Simulator",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              ),
              Padding(padding: EdgeInsets.only(top: 5)),
              Text(
                "Welcome Raajit!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Text(
                "Please choose a pathway below to start your learning journey.",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Divider(),
              ListView.separated(
                itemBuilder: (context, index) {
                  PathwayModel pathway = pathwayProviderRef.allPathways[index];
                  return PathwayTileWidget(
                    onTap: () {
                      // Handle tap
                      if (pathway.id == null) {
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => SimulatorView(
                                key: UniqueKey(),
                                pathwayId: pathway.id!,
                              ),
                        ),
                      );
                    },
                    pathway: pathway,
                  );
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pathwayProviderRef.allPathways.length,
                separatorBuilder: (context, index) => SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PathwayTileWidget extends ConsumerWidget {
  final PathwayModel pathway;
  final VoidCallback? onTap;

  const PathwayTileWidget({
    Key? key,
    required this.pathway,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    pathway.backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pathway.difficulty ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      pathway.name ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    Text(
                      pathway.description ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 5),
                        Chip(
                          label: Text("Resume"),
                          // backgroundColor: Colors.green.shade200,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
