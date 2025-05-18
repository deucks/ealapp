import 'dart:async';

import 'package:ealapp/defaults/urls.dart';
import 'package:ealapp/models/base/pathway_model.dart';
import 'package:pocketbase/pocketbase.dart';

class PathwayDatabase {
  final String uid;
  final String token;
  final _service = PocketBase(basePBUrl);
  PathwayDatabase({required this.uid, required this.token}) {
    _service.authStore.save(token, null);
  }

  Future<Stream<PathwayModel>> allPathWayStream() async {
    final controller = StreamController<PathwayModel>.broadcast();
    await _service
        .collection('pathway')
        .subscribe('*', (e) {
          if (e.record != null &&
              (e.action == "update" || e.action == "create")) {
            final data =
                e.record!.toJson(); // Use ! because we checked for null
            final pathway = PathwayModel.fromJson(data);
            controller.add(pathway);
          }
        })
        .then((unsubscribe) {
          // When the controller is cancelled, unsubscribe from PocketBase
          controller.onCancel = unsubscribe;
        })
        .catchError((error) {
          controller.addError(error); // Propagate subscription error
          controller.close();
        });

    return controller.stream;
  }

  Future<List<PathwayModel>> allPathways() async {
    final records = await _service.collection('pathway').getFullList();
    return records.map((e) => PathwayModel.fromJson(e.toJson())).toList();
  }
}
