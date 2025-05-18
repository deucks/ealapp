import 'dart:convert';

import 'package:ealapp/defaults/urls.dart';
import 'package:ealapp/models/base/pathway_model.dart';
import 'package:ealapp/models/base/user_pathway_history_model.dart';
import 'package:ealapp/models/sup/last_ml_output.dart';
import 'package:ealapp/models/sup/pathway_history.dart';
import 'package:ealapp/providers/pathway_provider.dart';
import 'package:ealapp/providers/top_level_provier.dart';
import 'package:ealapp/services/pocketbase/pathway_database.dart';
import 'package:ealapp/services/pocketbase/user_pathway_database.dart';
import 'package:ealapp/views/simulator/simulator_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

var simulatorViewProvider =
    ChangeNotifierProvider.family<SimulatorViewProvider, String>((
      ref,
      pathwayId,
    ) {
      return SimulatorViewProvider(
        userPathwayDatabase: ref.watch(userPathwayHistoryDatabaseProvider),
        pathwayProvider: ref.watch(pathwayProvider),
        pathwayId: pathwayId,
      );
    });

class SimulatorViewProvider extends ChangeNotifier {
  UserPathwayDatabase? userPathwayDatabase;
  PathwayProvider? pathwayProvider;
  String pathwayId;
  UserPathwayHistoryModel? currentUserHistoryPathway;

  List<String> currentUserInputs = [];
  final Debouncer _debouncer = Debouncer();

  final FlutterTts _tts = FlutterTts();
  List<String> _spokenWords = [];
  int _currentWordIndex = -1;
  int get currentWordIndex => _currentWordIndex;
  List<String> get spokenWords => _spokenWords;
  String currentSpokenTextId = '';
  bool callingML = false;
  bool easyMode = false;
  bool textEntryMode = false;

  SimulatorViewProvider({
    required this.userPathwayDatabase,
    required this.pathwayProvider,
    required this.pathwayId,
  }) {
    _initTts();
  }

  Future<void> fetchInitialData() async {
    // Get all pathways, then get current history pathways.
    UserPathwayHistoryModel? history = await userPathwayDatabase
        ?.latestHistoryForPathway(pathwayId);

    currentUserHistoryPathway = history;
    if (currentUserHistoryPathway == null) {
      // Create new ML output and set that as current.
      currentUserInputs = [];
      currentUserInputs.add("Hello! I would like to buy a train ticket.");
      currentUserHistoryPathway = await userPathwayDatabase
          ?.createLatestHistoryForPathway(pathwayId, null);

      if (currentUserHistoryPathway != null) {
        await askMLWithTextAndSave();
        notifyListeners();
      }
    }
    notifyListeners();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');

    await _tts.setSpeechRate(0.4); // tweak as you like
    await _tts.setVolume(1);
    // Android & iOS both fire this callback for every *word* spoken
    _tts.setProgressHandler((String text, int start, int end, String? id) {
      // Count how many words come *before* the current start position
      _currentWordIndex =
          text.substring(0, start).trim().split(RegExp(r'\s+')).length - 1;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _currentWordIndex = -1; // clear highlight when done
      notifyListeners();
    });
  }

  void setEasyMode(bool value) {
    easyMode = value;
    notifyListeners();
  }

  void setTextEntryMode(bool value) {
    textEntryMode = value;
    notifyListeners();
  }

  Future<void> _speak(String text) async {
    await _tts.stop(); // stop any previous speech
    _spokenWords = text.split(RegExp(r'\s+')); // cache for RichText
    _currentWordIndex = -1;
    notifyListeners();
    await _tts.speak(text);
  }

  Future<void> _justSpeakThis(String text) async {
    await _tts.stop(); // stop any previous speech
    await _tts.speak(text);
  }

  List<ChatMessage> getChatHistoryParsed() {
    List<ChatMessage> chatHistory = [];

    for (
      int i = 0;
      i < (currentUserHistoryPathway?.conversationHistory?.length ?? 0);
      i++
    ) {
      PathwayHistory? item = currentUserHistoryPathway?.conversationHistory?[i];
      String currentUniqueKey = item?.id ?? '';
      if (item?.input != null) {
        chatHistory.insert(
          0,
          ChatMessage(
            id: currentUniqueKey,
            text: item?.input ?? '',
            chatMessageType: ChatMessageType.sent,
          ),
        );
      }
      if (item?.reply != null) {
        chatHistory.insert(
          0,
          ChatMessage(
            id: currentUniqueKey,
            text: item?.reply ?? '',
            chatMessageType: ChatMessageType.received,
          ),
        );
      }

      if ((i + 1) ==
          (currentUserHistoryPathway?.conversationHistory?.length ?? 0)) {
        currentSpokenTextId = currentUniqueKey;
      }
    }
    final userInput = currentUserInput;
    if (userInput.isNotEmpty) {
      chatHistory.insert(
        0,
        ChatMessage(
          id:
              (currentUserHistoryPathway?.conversationHistory?.length ?? 0)
                  .toString(),
          text: userInput,
          chatMessageType: ChatMessageType.composing,
        ),
      );
    }

    // for (PathwayHistory item
    //     in currentUserHistoryPathway?.conversationHistory ?? []) {
    //   if (item.input != null) {
    //     chatHistory.insert(
    //       0,
    //       ChatMessage(
    //         id: UniqueKey().toString(),
    //         text: item.input!,
    //         chatMessageType: ChatMessageType.sent,
    //       ),
    //     );
    //   }
    //   if (item.reply != null) {
    //     chatHistory.insert(
    //       0,
    //       ChatMessage(
    //         id: UniqueKey().toString(),
    //         text: item.reply!,
    //         chatMessageType: ChatMessageType.received,
    //       ),
    //     );
    //   }
    // }

    return chatHistory;
  }

  PathwayModel? get getPathwayModel {
    return pathwayProvider!.getPathwayModel(pathwayId);
  }

  Future<LastMlOutput?> askMLWithText(
    String input,
    PathwayModel? currentPathway,
  ) async {
    callingML = true;
    notifyListeners();
    var lastMlOutput = await userPathwayDatabase?.postDataToML(
      input,
      currentPathway,
      buildTranscript(currentUserHistoryPathway?.conversationHistory ?? []),
    );
    callingML = false;
    notifyListeners();
    return lastMlOutput;
  }

  String buildTranscript(List<PathwayHistory> history) {
    final buffer = StringBuffer();

    for (final item in history) {
      // Add the learner’s utterance, if present.
      final studentLine = item.input?.trim();
      if (studentLine?.isNotEmpty ?? false) {
        buffer.writeln('Student: "$studentLine"');
      }

      // Add the system reply, if present.
      final replyLine = item.reply?.trim();
      if (replyLine?.isNotEmpty ?? false) {
        buffer.writeln('Assistant: "$replyLine"');
      }
    }

    return buffer.toString().trimRight(); // Remove trailing newline, if any.
  }

  Future<LastMlOutput?> askMLWithTextAndSave() async {
    LastMlOutput? lastMlOutput = await askMLWithText(
      currentUserInput,
      getPathwayModel,
    );
    if (lastMlOutput != null) {
      // Add the input to the conversation history.
      List<PathwayHistory> currentHistory =
          currentUserHistoryPathway?.conversationHistory ?? [];
      currentHistory.add(
        PathwayHistory(
          id: UniqueKey().toString(),
          input: currentUserInput,
          reply: null,
          feedback: lastMlOutput.feedback,
          adjustDifficulty: lastMlOutput.adjustDifficulty,
          type: PathwayHistoryType.input,
        ),
      );
      currentHistory.add(
        PathwayHistory(
          id: UniqueKey().toString(),
          input: null,
          reply: lastMlOutput.reply,
          feedback: lastMlOutput.feedback,
          adjustDifficulty: lastMlOutput.adjustDifficulty,
          type: PathwayHistoryType.reply,
        ),
      );

      currentUserHistoryPathway = await userPathwayDatabase
          ?.updateLatestHistoryForPathway(
            currentUserHistoryPathway!.id!,
            currentHistory,
            lastMlOutput,
          );
      currentUserInputs = [];
      notifyListeners();
      if (lastMlOutput.reply?.isNotEmpty ?? false) {
        _speak('${lastMlOutput.feedback ?? ''} \n\n\n ${lastMlOutput.reply}');
      }
    }
    return lastMlOutput;
  }

  void addUserInput(String input) {
    currentUserInputs.add(input);
    currentSpokenTextId = '';
    _justSpeakThis(input);
    notifyListeners();
  }

  void overrideAndAddUserInput(String input) {
    currentUserInputs = [];
    currentUserInputs.add(input);
    currentSpokenTextId = '';

    notifyListeners();
    const duration = Duration(milliseconds: 1000);
    _debouncer.debounce(
      duration: duration,
      onDebounce: () {
        _justSpeakThis(input);
      },
    );
  }

  String get currentUserInput {
    if (currentUserInputs.isNotEmpty) {
      return currentUserInputs.join(' ');
    }
    return '';
  }

  void clearUserInput() {
    _justSpeakThis("Deleted your input. Please enter a new input.");
    currentUserInputs = [];
    notifyListeners();
  }

  String? get currentMlReply {
    return currentUserHistoryPathway?.lastMlOutput?.reply;
  }

  List<String> getCurrentMlResponseSuggestionsSingleSpace(
    List<String> ignoreThese,
  ) {
    Set<String> allSuggestions = {};
    allSuggestions.addAll([".", ",", "?", "!"]);
    allSuggestions.addAll(
      ignoreThese.map((s) => s.replaceAll(RegExp(r'[,.?!]'), '')),
    ); // Remove commas and full stops from ignoreThese

    for (String suggestion
        in currentUserHistoryPathway?.lastMlOutput?.possibleCorrectResponses ??
            []) {
      // Remove commas and full stops from the suggestion string
      String cleanedSuggestion = suggestion.replaceAll(RegExp(r'[,.?!]'), '');
      allSuggestions.addAll(cleanedSuggestion.split(' '));
    }
    var list = allSuggestions.toList();
    // list.shuffle(); // Uncomment if you need to shuffle the list
    return list;
  }

  List<String> getCurrentMlResponseSuggestionsDoubleSpace(
    List<String> ignoreThese,
  ) {
    final Set<String> all = {};
    all.addAll(ignoreThese);

    for (final suggestion
        in currentUserHistoryPathway?.lastMlOutput?.possibleCorrectResponses ??
            []) {
      all.addAll(suggestion.split(RegExp(r'(?<! ) {2}(?! )')));
    }

    var list = all.toList();
    // list.shuffle();
    return list;
  }
}
