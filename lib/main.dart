import 'package:ealapp/defaults/urls.dart';
import 'package:ealapp/models/base/user_model.dart';
import 'package:ealapp/providers/top_level_provier.dart';
import 'package:ealapp/services/pocketbase/pathway_database.dart';
import 'package:ealapp/services/pocketbase/user_database.dart';
import 'package:ealapp/views/home/home_view.dart';
import 'package:ealapp/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final PocketBase _service = PocketBase(basePBUrl);

  RecordModel? getSignedInUser() {
    final user = _service.authStore.record;
    return user;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'EAL Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Consumer(
          builder: (context, ref, child) {
            var authState = ref.watch(pocketbaseAuthStateChangesProvider);
            if (authState.hasValue) {
              final user = authState.value;
              if (user != null) {
                UserDatabase? userDatabase = ref.read(userDatabaseProvider);

                if (userDatabase == null) {
                  return LoadingScaffold();
                } else {
                  return FutureBuilder(
                    future: userDatabase.existingOrNewData(
                      incomingUser: UserModel(
                        id: authState.value?.record?.id,
                        email: authState.value?.record?.data['email'],
                        name: authState.value?.record?.data['name'],
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScaffold();
                      } else if (snapshot.hasError) {
                        return LoginView();
                      } else if (snapshot.hasData) {
                        return HomeView();
                      } else {
                        return LoadingScaffold();
                      }
                    },
                  );
                }
              } else {
                return const LoginView();
              }
            } else {
              return const LoginView();
            }
          },
        ),
      ),
    );
  }
}

class LoadingScaffold extends StatelessWidget {
  LoadingScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      body: Center(
        child: SizedBox(
          width: 150.0,
          height: 150.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
