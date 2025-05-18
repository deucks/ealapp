import 'package:ealapp/providers/user_history_pathway_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass/glass.dart';

enum ChatMessageType { sent, received, composing, feedback }

// ChatMessage class to hold message data
class ChatMessage {
  final String id; // Unique ID for each message
  final String text; // Content of the message
  final ChatMessageType chatMessageType;

  ChatMessage({
    required this.id,
    required this.text,
    required this.chatMessageType,
  });
}

class SimulatorView extends ConsumerStatefulWidget {
  final String pathwayId;
  const SimulatorView({Key? key, required this.pathwayId}) : super(key: key);

  @override
  ConsumerState<SimulatorView> createState() => _SimulatorViewState();
}

class _SimulatorViewState extends ConsumerState<SimulatorView> {
  List<ChatMessage> _messages = [];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  TextEditingController _textController = TextEditingController();
  // ScrollController to keep the list scrolled to the bottom
  final ScrollController _scrollController = ScrollController();

  int _messageCounter = 0; // Counter to generate unique message IDs

  void _syncMessagesWithProvider(
    List<ChatMessage> providerMessages,
    List<String> currentUserInputs,
  ) {
    // providerMessages are assumed to be the complete, up-to-date list from the provider,
    // potentially ordered newest first.
    // _messages is our local list, also ordered newest first (due to insert(0)).

    final Set<String> localMessageIds = _messages.map((m) => m.id).toSet();
    List<ChatMessage> messagesToAdd = [];

    // Iterate through provider messages (assuming they are newest first).
    // If a message from the provider isn't in our local list, it's new.
    for (final pMsg in providerMessages) {
      if (pMsg.chatMessageType == ChatMessageType.composing) {
        if (!localMessageIds.contains(pMsg.id)) {
          messagesToAdd.add(pMsg);
        } else {
          // If the message is already in the local list, we might want to update it.
          // This could be a no-op if the message hasn't changed.
          final index = messagesToAdd.indexWhere((m) => m.id == pMsg.id);
          if (index != -1) {
            messagesToAdd[index] = pMsg; // Update the existing message
          } else {
            messagesToAdd.add(pMsg);
          }
        }
      } else {
        if (!localMessageIds.contains(pMsg.id)) {
          messagesToAdd.add(pMsg);
        }
      }
    }

    // Add new messages to the AnimatedList.
    // We iterate `messagesToAdd` in reverse because if it's [newest, newer, new],
    // we want to insert "new" at index 0 first, then "newer" at index 0, etc.
    // This makes them appear sequentially from the bottom up.
    if (messagesToAdd.isNotEmpty) {
      for (final newMessage in messagesToAdd.reversed) {
        // Ensure it's not somehow already added (defensive check)
        if (newMessage.chatMessageType == ChatMessageType.composing) {
          // _messages.insert(0, newMessage); // Add to local list
          final index = _messages.indexWhere((m) => m.id == newMessage.id);
          if (index != -1) {
            _messages[index] = newMessage; // Update the existing message
          }
        }
        if (!_messages.any((m) => m.id == newMessage.id)) {
          _messages.insert(0, newMessage); // Add to local list
          _listKey.currentState?.insertItem(
            0, // Insert at the bottom (due to reverse: true)
            duration: const Duration(milliseconds: 400), // Animation duration
          );
        }
      }
    }

    if (currentUserInputs.isEmpty) {
      _messages.removeWhere(
        (m) => m.chatMessageType == ChatMessageType.composing,
      );
    }

    // Optional: Handle removals if messages can be deleted from the provider
    // This requires comparing _messages with providerMessages to find what's missing.
    // List<String> providerMessageIdsSet = providerMessages.map((m) => m.id).toList();
    // for (int i = _messages.length - 1; i >= 0; i--) {
    //   if (!providerMessageIdsSet.contains(_messages[i].id)) {
    //     final ChatMessage removedMessage = _messages.removeAt(i);
    //     _listKey.currentState?.removeItem(
    //       i,
    //       (context, animation) => _buildChatItem(context, i, animation, removedMessage), // Pass the removed message
    //       duration: const Duration(milliseconds: 300),
    //     );
    //   }
    // }
    // Scroll to bottom (top in reversed list) after adding new items
    if (messagesToAdd.isNotEmpty && _scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SimulatorViewProvider>(
      // Replace UserHistoryPathwayState with your actual provider's state type
      simulatorViewProvider(widget.pathwayId),
      (previousState, nextState) {
        if (!mounted)
          return; // Ensure widget is still mounted in async callback
        _syncMessagesWithProvider(
          nextState.getChatHistoryParsed(),
          nextState.currentUserInputs,
        );
      },
    );
    return Scaffold(
      // appBar: AppBar(title: Text('Simulator')),
      backgroundColor: Colors.grey[200], // Example background color
      body: FutureBuilder(
        future:
            ref
                .read(simulatorViewProvider(widget.pathwayId))
                .fetchInitialData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Stack(
            children: [
              // This represents the main content area of your simulator.
              // Replace this Container with your actual simulator widgets.
              // const Positioned.fill(child: RainbowOverlay(opacity: 0.45)),
              // Positioned.fill(
              //   child: AnimatedList(
              //     key: _listKey,
              //     padding: EdgeInsets.fromLTRB(0, 32, 0, 16),
              //     reverse: true, // Makes the list build from bottom to top
              //     controller: _scrollController,
              //     initialItemCount: _messages.length,
              //     itemBuilder: _buildChatItem,
              //   ),
              // ),
              Positioned(
                height: MediaQuery.of(context).size.height - 15,
                width: MediaQuery.of(context).size.width,
                child: Consumer(
                  builder: (context, ref, child) {
                    var historyRef = ref.watch(
                      simulatorViewProvider(widget.pathwayId),
                    );
                    return AnimatedList(
                      key: _listKey,

                      padding: EdgeInsets.fromLTRB(
                        0,
                        32,
                        0,
                        MediaQuery.of(context).size.height / 2,
                      ),
                      reverse: true, // Makes the list build from bottom to top
                      controller: _scrollController,
                      initialItemCount: _messages.length,
                      itemBuilder: _buildChatItem,
                    );
                  },
                ),
              ),

              Positioned(
                bottom: 0,
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Consumer(
                  builder: (context, ref, child) {
                    var historyRef = ref.watch(
                      simulatorViewProvider(widget.pathwayId),
                    );

                    return Container(
                      // color: Colors.grey[300], // Example background
                      child: Column(
                        children: [
                          // Expanded(child: Container()),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(
                                          16.0,
                                        ),
                                      ),
                                      child:
                                          historyRef.callingML
                                              ? Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,

                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              Colors.lightBlue,
                                                          strokeWidth: 3,
                                                        ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    "Generating a response...",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              )
                                              : historyRef.textEntryMode
                                              ? FullParentTransparentTextField(
                                                controller: _textController,
                                                hintText: 'Type something...',
                                                textStyle: TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.black,
                                                ),
                                                onChanged: (value) {
                                                  // _textController.text =
                                                  //     value.trim();
                                                  historyRef
                                                      .overrideAndAddUserInput(
                                                        value,
                                                      );
                                                },
                                              )
                                              : SingleChildScrollView(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  runAlignment:
                                                      WrapAlignment.center,
                                                  spacing: 16,
                                                  runSpacing: 16,
                                                  children:
                                                      (historyRef.easyMode
                                                              ? historyRef
                                                                  .getCurrentMlResponseSuggestionsDoubleSpace(
                                                                    [],
                                                                  )
                                                              : historyRef
                                                                  .getCurrentMlResponseSuggestionsSingleSpace(
                                                                    [],
                                                                  ))
                                                          .map(
                                                            (
                                                              e,
                                                            ) => GestureDetector(
                                                              key: UniqueKey(),
                                                              onTap: () {
                                                                historyRef
                                                                    .addUserInput(
                                                                      e,
                                                                    );
                                                                // _sendMessage(e);
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          12,
                                                                      horizontal:
                                                                          16,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        32,
                                                                      ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300
                                                                          .withOpacity(
                                                                            0.5,
                                                                          ),
                                                                      blurRadius:
                                                                          1,
                                                                      spreadRadius:
                                                                          1,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  e,
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Material(
                                        color:
                                            Colors.white, // Button background
                                        shape: const CircleBorder(),
                                        elevation:
                                            2.0, // Optional: adds a slight shadow
                                        child: IconButton(
                                          onPressed:
                                              historyRef.callingML
                                                  ? null
                                                  : () {
                                                    historyRef.setTextEntryMode(
                                                      !historyRef.textEntryMode,
                                                    );
                                                  },
                                          icon: Icon(
                                            Icons.text_fields_outlined,
                                          ),
                                          color: Colors.black, // Icon color
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Visibility(
                                        visible: !historyRef.textEntryMode,
                                        child: Row(
                                          children: [
                                            Material(
                                              color:
                                                  Colors
                                                      .white, // Button background
                                              shape: const CircleBorder(),
                                              elevation:
                                                  2.0, // Optional: adds a slight shadow
                                              child: IconButton(
                                                onPressed:
                                                    historyRef.callingML
                                                        ? null
                                                        : () {
                                                          historyRef
                                                              .setEasyMode(
                                                                !historyRef
                                                                    .easyMode,
                                                              );
                                                        },
                                                icon: Icon(
                                                  Icons
                                                      .switch_access_shortcut_rounded,
                                                ),
                                                color:
                                                    Colors.black, // Icon color
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: Material(
                                          color:
                                              Colors.white, // Button background
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(32),
                                            ),
                                          ),
                                          elevation:
                                              2.0, // Optional: adds a slight shadow
                                          child: TextButton(
                                            onPressed:
                                                historyRef
                                                            .currentUserInputs
                                                            .isEmpty ||
                                                        historyRef.callingML
                                                    ? null
                                                    : () async {
                                                      // Call the ML function with the input text
                                                      var response =
                                                          await historyRef
                                                              .askMLWithTextAndSave();
                                                      // Handle the response as needed
                                                      print(response?.reply);
                                                    },
                                            child: Text("Send"),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Material(
                                        color:
                                            Colors.white, // Button background
                                        shape: const CircleBorder(),
                                        elevation:
                                            2.0, // Optional: adds a slight shadow
                                        child: IconButton(
                                          onPressed:
                                              historyRef.callingML
                                                  ? null
                                                  : () {
                                                    historyRef.clearUserInput();
                                                    _textController.clear();
                                                  },
                                          icon: Icon(Icons.delete_forever),
                                          color: Colors.red, // Icon color
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).asGlass();
                  },
                ),
              ),

              // Positioned back button on the top left
              Positioned(
                top:
                    16.0 +
                    MediaQuery.of(context).padding.top, // Adjust for status bar
                left: 16.0,
                child: Material(
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.surface, // Button background
                  shape: const CircleBorder(),
                  elevation: 4.0, // Shadow for visibility
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Go back',
                    onPressed: () {
                      // Check if it's possible to pop the route before doing so
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget to build each chat message item
  Widget _buildChatItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    if (index >= _messages.length) {
      return const SizedBox.shrink(); // Return an empty widget if index is out of range
    }
    final ChatMessage message = _messages[index];
    // Define the slide and fade transition
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(
          0,
          0.5,
        ), // Start from bottom (0.5 of its height down)
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart, // Animation curve
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
        child: SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              // Align message to right if sent by me, else left
              alignment:
                  message.chatMessageType == ChatMessageType.sent
                      ? Alignment.centerRight
                      : message.chatMessageType == ChatMessageType.composing
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 15.0,
                ),
                decoration: BoxDecoration(
                  color:
                      message.chatMessageType == ChatMessageType.sent
                          ? Colors.blue[600]
                          : message.chatMessageType == ChatMessageType.composing
                          ? Colors.blue[600]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    var historyRef = ref.read(
                      simulatorViewProvider(widget.pathwayId),
                    );
                    if (message.id == historyRef.currentSpokenTextId) {
                      return RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children:
                              historyRef.spokenWords.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final word = entry.value;
                                final bool highlighted =
                                    idx == historyRef.currentWordIndex;
                                return TextSpan(
                                  text: '$word ', // keep a trailing space
                                  style: TextStyle(
                                    fontSize:
                                        message.chatMessageType ==
                                                ChatMessageType.sent
                                            ? 18
                                            : 18,
                                    color:
                                        message.chatMessageType ==
                                                ChatMessageType.sent
                                            ? Colors.white
                                            : message.chatMessageType ==
                                                ChatMessageType.composing
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight:
                                        highlighted
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    backgroundColor:
                                        highlighted
                                            ? Colors.yellow.withOpacity(0.4)
                                            : Colors.transparent,
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    }
                    return Text(
                      message.text,
                      style: TextStyle(
                        color:
                            message.chatMessageType == ChatMessageType.sent
                                ? Colors.white
                                : message.chatMessageType ==
                                    ChatMessageType.composing
                                ? Colors.white
                                : Colors.black87,
                        fontSize:
                            message.chatMessageType == ChatMessageType.sent
                                ? 18
                                : 18,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullParentTransparentTextField extends StatelessWidget {
  final TextEditingController? controller; // Optional: For text manipulation
  final String? hintText; // Optional: Placeholder text
  final TextStyle? textStyle; // Optional: Style for the input text
  final TextStyle? hintStyle; // Optional: Style for the hint text
  final Color? cursorColor; // Optional: Color of the cursor
  final ValueChanged<String>? onChanged; // <-- Add this

  const FullParentTransparentTextField({
    super.key,
    this.controller,
    this.hintText,
    this.textStyle,
    this.hintStyle,
    this.cursorColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Use the app's default text style if none is provided
    final effectiveTextStyle =
        textStyle ?? Theme.of(context).textTheme.bodyLarge;
    // Use a slightly dimmer version of text color for hint if no hintStyle provided
    final effectiveHintStyle =
        hintStyle ??
        effectiveTextStyle?.copyWith(
          color: effectiveTextStyle.color?.withOpacity(0.6),
        );
    final effectiveCursorColor =
        cursorColor ??
        effectiveTextStyle?.color ??
        Theme.of(context).primaryColor;

    return TextField(
      controller: controller,
      // Horizontal alignment of the text.
      textAlign: TextAlign.center,
      onChanged: onChanged,
      // Vertical alignment of the text.
      // This works best when expands is true and maxLines is null.
      textAlignVertical: TextAlignVertical.center,
      // Allows the TextField to have an unlimited number of lines.
      // This is required when 'expands' is true.
      maxLines: null,
      // Makes the TextField expand to fill the space provided by its parent.
      expands: true,

      decoration: InputDecoration(
        // To make the background transparent.
        filled: true,
        fillColor: Colors.transparent,
        // To remove any border.
        border: InputBorder.none,
        // Removes focused and enabled borders as well
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        // Optional hint text.
        hintText: hintText,
        hintStyle: effectiveHintStyle,
        // You can set contentPadding to EdgeInsets.zero if you want to remove
        // all internal padding, though textAlignVertical often handles centering well.
        // contentPadding: EdgeInsets.zero,
      ),
      // Style for the text that the user inputs.
      style: effectiveTextStyle,
      // Color of the cursor.
      cursorColor: effectiveCursorColor,
    );
  }
}
