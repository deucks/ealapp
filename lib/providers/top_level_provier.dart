// Provider for PocketBase client instance.
import 'dart:async';

import 'package:ealapp/defaults/urls.dart';
import 'package:ealapp/models/base/user_pathway_history_model.dart';
import 'package:ealapp/services/pocketbase/pathway_database.dart';
import 'package:ealapp/services/pocketbase/user_database.dart';
import 'package:ealapp/services/pocketbase/user_pathway_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

final pocketbaseProvider = Provider<PocketBase>((ref) {
  return PocketBase(basePBUrl);
});

// StreamProvider for PocketBase auth state.
final pocketbaseAuthStateChangesProvider = StreamProvider<AuthStoreEvent?>((
  ref,
) {
  final pocketbase = ref.watch(pocketbaseProvider);
  final controller = StreamController<AuthStoreEvent?>();

  pocketbase.authStore.onChange.listen((event) {
    print('Auth state changed: ${event.record}');
    controller.add(event);
  });

  return controller.stream;
});

final userDatabaseProvider = Provider<UserDatabase?>((ref) {
  final auth = ref.watch(pocketbaseAuthStateChangesProvider);
  if (auth.asData?.value?.record != null) {
    return UserDatabase(
      uid: auth.asData!.value!.record!.id,
      token: auth.asData!.value!.token,
    );
  }
  return null;
});

final pathwayDatabaseProvider = Provider<PathwayDatabase?>((ref) {
  final auth = ref.watch(pocketbaseAuthStateChangesProvider);
  if (auth.asData?.value?.record != null) {
    return PathwayDatabase(
      uid: auth.asData!.value!.record!.id,
      token: auth.asData!.value!.token,
    );
  }
  return null;
});

final userPathwayHistoryDatabaseProvider = Provider<UserPathwayDatabase?>((
  ref,
) {
  final auth = ref.watch(pocketbaseAuthStateChangesProvider);
  if (auth.asData?.value?.record != null) {
    return UserPathwayDatabase(
      uid: auth.asData!.value!.record!.id,
      token: auth.asData!.value!.token,
    );
  }
  return null;
});
