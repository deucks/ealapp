import 'package:collection/collection.dart';
import 'package:ealapp/models/base/pathway_model.dart';
import 'package:ealapp/providers/top_level_provier.dart';
import 'package:ealapp/services/pocketbase/pathway_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

var pathwayProvider = ChangeNotifierProvider<PathwayProvider>((ref) {
  return PathwayProvider(pathwayDatabase: ref.watch(pathwayDatabaseProvider));
});

class PathwayProvider extends ChangeNotifier {
  PathwayDatabase? pathwayDatabase;
  List<PathwayModel> allPathways = [];
  PathwayProvider({required this.pathwayDatabase}) {
    getAllPathways().then((_) {
      subscribeToPathwayStream();
    });
  }

  PathwayModel? getPathwayModel(String pathwayId) {
    PathwayModel? pathway = allPathways.firstWhereOrNull(
      (element) => element.id == pathwayId,
    );
    return pathway;
  }

  Future<void> getAllPathways() async {
    if (pathwayDatabase != null) {
      await pathwayDatabase!.allPathways().then((pathways) {
        allPathways = pathways;
        notifyListeners();
      });
    }
  }

  Future<void> subscribeToPathwayStream() async {
    if (pathwayDatabase != null) {
      await pathwayDatabase!.allPathWayStream().then((stream) {
        stream.listen(
          (pathway) {
            addPathwayToAllList(pathway);
          },
          onError: (error) {
            // Handle error
            print("Error in pathway stream: $error");
          },
        );
      });
    }
  }

  void addPathwayToAllList(PathwayModel pathway) {
    PathwayModel? existingPathway = allPathways.firstWhereOrNull(
      (element) => element.id == pathway.id,
    );
    if (existingPathway != null) {
      // Find the index of the existing pathway
      int index = allPathways.indexWhere((element) => element.id == pathway.id);
      if (index != -1) {
        // Update the pathway at the found index
        allPathways[index] = pathway;
        notifyListeners();
        return; // Exit after updating
      }
    }
    // If pathway doesn't exist, add it (this line remains from original code)
    allPathways.add(pathway);
    notifyListeners();
  }
}
