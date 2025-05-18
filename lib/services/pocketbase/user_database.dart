import 'dart:async';

import 'package:ealapp/defaults/urls.dart';
import 'package:ealapp/models/base/user_model.dart';
import 'package:pocketbase/pocketbase.dart';

class UserDatabase {
  final String uid;
  final String token;
  UserModel? userModelCache;
  final _service = PocketBase(basePBUrl);
  UserDatabase({required this.uid, required this.token}) {
    _service.authStore.save(token, null);
  }

  Future<void> setUser(UserModel user) async {
    var map = user.toJson();
    await _service.collection('users').update(uid, body: map);
  }

  Future<UserModel> existingOrNewData({UserModel? incomingUser}) async {
    RecordModel? record;
    Map<String, dynamic>? map;
    try {
      record = await _service.collection('users').getOne(uid);
      map = record.toJson();
    } on ClientException catch (e) {
      // Handle 404 Not Found specifically as "record doesn't exist"
      if (e.statusCode != 404) {
        // Rethrow other client exceptions (like permission errors)
        rethrow;
      }
      // If 404, record remains null, map remains null, proceed to create new user
      print(
        'User record not found (404), creating new one. Error: ${e.toString()}',
      );
    } catch (e) {
      // Handle other potential errors during fetch
      print('Error fetching user data: $e');
      // Depending on requirements, you might want to rethrow or return a default/error state
      rethrow; // Rethrow for now
    }

    if (map == null) {
      UserModel newUser = UserModel();
      newUser.email = incomingUser?.email;
      newUser.emailVisibility = true;
      newUser.name = incomingUser?.name;
      // newUser.password userModelCache = newUser;

      await _service.collection('users').create(body: newUser.toJson());
      return newUser;
    } else {
      var user = UserModel.fromJson(map);
      userModelCache = user;
      return user;
    }
  }

  Stream<UserModel> userStream() {
    final controller = StreamController<UserModel>();

    _service
        .collection('users')
        .subscribe(uid, (e) {
          if (e.record != null &&
              (e.action == "update" || e.action == "create")) {
            final data =
                e.record!.toJson(); // Use ! because we checked for null
            final user = UserModel.fromJson(data);
            userModelCache = user; // Update cache
            controller.add(user);
          } else if (e.action == "delete") {
            // Handle deletion if necessary, maybe emit a default/empty user or close the stream?
            // For now, let's emit the cached user if available, or a default one
            controller.add(userModelCache ?? UserModel());
          } else if (userModelCache != null) {
            // If no record change but we have a cache, emit it
            controller.add(userModelCache!);
          } else {
            // Optionally fetch initial data if cache is null and no create/update event
            _service
                .collection('users')
                .getOne(uid)
                .then((record) {
                  final user = UserModel.fromJson(record.toJson());
                  userModelCache = user;
                  controller.add(user);
                })
                .catchError((error) {
                  // Handle error, maybe add an error state to the stream
                  controller.addError(error);
                  // Or emit a default user
                  // controller.add(UserModel());
                });
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

    // Fetch initial data immediately if cache is null
    if (userModelCache == null) {
      _service
          .collection('users')
          .getOne(uid)
          .then((record) {
            final user = UserModel.fromJson(record.toJson());
            userModelCache = user;
            if (!controller.isClosed) {
              controller.add(user);
            }
          })
          .catchError((error) {
            if (!controller.isClosed) {
              // Handle error, maybe add an error state to the stream
              controller.addError(error);
              // Or emit a default user
              // controller.add(UserModel());
            }
          });
    } else {
      // Emit cached data immediately
      controller.add(userModelCache!);
    }

    return controller.stream;
  }
}
