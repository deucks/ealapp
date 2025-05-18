import 'dart:async';
import 'dart:convert';

import 'package:ealapp/defaults/urls.dart';
import 'package:ealapp/models/base/pathway_model.dart';
import 'package:ealapp/models/base/user_pathway_history_model.dart';
import 'package:ealapp/models/sup/last_ml_output.dart';
import 'package:ealapp/models/sup/pathway_history.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

class UserPathwayDatabase {
  final String uid;
  final String token;
  final _service = PocketBase(basePBUrl);
  UserPathwayDatabase({required this.uid, required this.token}) {
    _service.authStore.save(token, null);
  }

  Future<Stream<PathwayModel>> currentUserHistoryPathwayStream(
    String historyId,
  ) async {
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
        }, filter: "user = '$uid' and pathway = '$historyId")
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

  Future<UserPathwayHistoryModel?> latestHistoryForPathway(
    String pathway,
  ) async {
    try {
      final record = await _service
          .collection('user_pathway_history')
          .getFirstListItem(
            "user = '$uid' && pathway = '$pathway'",
            query: {'sort': '-created'},
          );
      // Convert the single RecordModel to UserPathwayHistoryModel
      return UserPathwayHistoryModel.fromJson(record.toJson());
    } on ClientException catch (e) {
      // If the error is 404 (Not Found), return null
      if (e.statusCode == 404) {
        return null;
      }
      // Otherwise, rethrow the exception
      rethrow;
    } catch (e) {
      // Rethrow any other unexpected errors
      rethrow;
    }
  }

  Future<UserPathwayHistoryModel?> createLatestHistoryForPathway(
    String pathway,
    LastMlOutput? lastMlOutput,
  ) async {
    try {
      final record = await _service
          .collection('user_pathway_history')
          .create(
            body: {
              'user': uid,
              'pathway': pathway,
              'lastMlOutput': lastMlOutput,
            },
          );
      return UserPathwayHistoryModel.fromJson(record.toJson());
    } catch (e) {
      // Handle any errors that occur during the creation
      print('Error creating latest history: $e');
      return null;
    }
  }

  Future<UserPathwayHistoryModel?> updateLatestHistoryForPathway(
    String pathway,
    List<PathwayHistory> history,
    LastMlOutput lastMlOutput,
  ) async {
    try {
      final record = await _service
          .collection('user_pathway_history')
          .update(
            pathway,
            body: {
              'lastMlOutput': lastMlOutput,
              'conversationHistory': history,
            },
          );
      return UserPathwayHistoryModel.fromJson(record.toJson());
    } catch (e) {
      // Handle any errors that occur during the update
      print('Error updating latest history: $e');
      return null;
    }
  }

  Future<LastMlOutput?> postDataToML(
    String newPrompt,
    PathwayModel? pathway,
    String conversationHistory,
  ) async {
    if (pathway == null) {
      print('Pathway is null, cannot make POST request.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(baseMLUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'text': newPrompt,
          'scenario': pathway.scenarioForMl,
          'history': conversationHistory,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Request was successful
        print('POST request successful: ${response.body}');
        return LastMlOutput.fromJson(jsonDecode(response.body));
      } else {
        // Request failed
        print('POST request failed with status: ${response.statusCode}.');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      // Handle network errors or exceptions during the request
      print('Error making POST request: $e');
      return null;
      // Handle exceptions (e.g., show a network error message)
    }
  }
}
