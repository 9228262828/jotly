import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JotlyApp());
}

const _cream = Color(0xFFFFF8EA);
const _ink = Color(0xFF222222);
const _coral = Color(0xFFFF6F61);
const _yellow = Color(0xFFFFD45A);
const _sky = Color(0xFF8FD3FF);
const _mint = Color(0xFFA7F3D0);
const _lavender = Color(0xFFD8B4FE);

const _notesKey = 'jotly.notes.v1';
const _darkKey = 'jotly.dark.v1';
const _appVersion = '1.0.0';
const _appBuildNumber = '1';
const _lastUpdatedLabel = 'june, 2026';

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({
    required this.heading,
    required this.body,
  });
}

const _privacySections = [
  LegalSection(
    heading: 'Introduction',
    body:
        'Jotly is designed as a simple, private notes app for capturing ideas quickly. This Privacy Policy explains how Jotly handles information when you create, edit, organize, search, favorite, pin, or delete notes. The app is intentionally local-only and does not require an account or any online service to function.',
  ),
  LegalSection(
    heading: 'Information We Store',
    body:
        'Jotly stores the notes you choose to create, including note titles, note bodies, selected note colors, favorite status, pinned status, creation dates, and app preferences such as dark mode. This information is stored so the app can restore your notes and settings the next time you open it.',
  ),
  LegalSection(
    heading: 'Local Device Storage',
    body:
        'All Jotly note data and app settings are saved locally on your device using SharedPreferences. Jotly does not upload your notes to a server, synchronize your notes across devices, or provide cloud backup. If your device is lost, reset, damaged, or if app data is cleared, your locally stored Jotly data may be lost.',
  ),
  LegalSection(
    heading: 'No Account Required',
    body:
        'Jotly does not ask you to create an account, sign in, provide an email address, or submit profile information. Because there is no account system, Jotly does not provide account recovery, password reset, or server-side restore features.',
  ),
  LegalSection(
    heading: 'No Personal Data Collection',
    body:
        'Jotly does not collect personal data from you. The app does not request your name, email address, phone number, precise location, contacts, photos, microphone, camera, or other personal information. Any personal information you type into a note remains part of your local note content on your device.',
  ),
  LegalSection(
    heading: 'No Analytics',
    body:
        'Jotly does not include analytics, tracking pixels, behavioral measurement tools, crash reporting SDKs, or event logging services. We do not measure how you use the app, which notes you create, what you search for, or how often you open particular screens.',
  ),
  LegalSection(
    heading: 'No Advertising',
    body:
        'Jotly does not display advertisements and does not use advertising identifiers. The app does not create advertising profiles, does not perform ad targeting, and does not share information with ad networks.',
  ),
  LegalSection(
    heading: 'No Third-Party Sharing',
    body:
        'Because Jotly keeps your data on your device and does not operate a backend service, Jotly does not sell, rent, trade, disclose, or share your notes or app settings with third parties. Your device platform may provide its own system-level backup or storage behavior outside of Jotly; those platform features are governed by the policies and settings of your device provider.',
  ),
  LegalSection(
    heading: 'Data Security',
    body:
        'Jotly relies on your device and operating system to protect locally stored app data. You are responsible for using appropriate device security measures, such as a passcode, biometric lock, and secure backups if available. Jotly is not intended to be a dedicated vault for passwords, financial secrets, medical records, or highly sensitive information.',
  ),
  LegalSection(
    heading: 'Data Deletion',
    body:
        'You can delete individual notes in Jotly. After deleting a note, the app provides a short undo option. Once the undo period passes, the deleted note is removed from Jotly storage. You can also remove all locally stored Jotly data by clearing the app data through your device settings or uninstalling the app.',
  ),
  LegalSection(
    heading: 'Children\'s Privacy',
    body:
        'Jotly does not knowingly collect personal information from children. The app does not include account registration, messaging, public posting, advertising, analytics, or server-side collection features. Parents or guardians who allow a child to use Jotly should understand that note content remains locally on the device.',
  ),
  LegalSection(
    heading: 'Changes to this Policy',
    body:
        'We may update this Privacy Policy when Jotly changes or when legal, operational, or clarity improvements are needed. The updated policy will include a new last updated date. Continuing to use Jotly after an update means you acknowledge the revised policy.',
  ),
  LegalSection(
    heading: 'Contact Information',
    body:
        'If you have questions about this Privacy Policy or Jotly\'s privacy practices, contact the Jotly team through the support or contact method provided with the app listing or project page.',
  ),
];

const _termsSections = [
  LegalSection(
    heading: 'Acceptance of Terms',
    body:
        'By downloading, installing, opening, or using Jotly, you agree to these Terms & Conditions. If you do not agree with these terms, do not use the app. These terms apply to your use of Jotly as a local-only personal notes application.',
  ),
  LegalSection(
    heading: 'Description of the App',
    body:
        'Jotly is a lightweight notes app that lets you create, edit, search, pin, favorite, color-code, and delete notes on your device. Jotly is intended for quick personal note taking and does not include cloud synchronization, online accounts, collaboration, backend storage, advertising, analytics, or notification services.',
  ),
  LegalSection(
    heading: 'User Responsibilities',
    body:
        'You are responsible for the content you enter into Jotly and for deciding whether the app is appropriate for your intended use. You should keep your device secure, maintain backups if you need them, and avoid storing information that requires stronger protections than local app storage provides. You are also responsible for complying with laws and obligations that apply to your own note content.',
  ),
  LegalSection(
    heading: 'Intellectual Property',
    body:
        'Jotly, including its name, design, interface, visual elements, and app materials, is protected by applicable intellectual property rights. You retain responsibility for and ownership of the original content you type into your notes. These terms do not grant you ownership of the Jotly app, branding, or related materials.',
  ),
  LegalSection(
    heading: 'Data Storage',
    body:
        'Jotly stores notes and settings locally on your device using SharedPreferences. The app does not provide cloud backup, device-to-device sync, web access, account recovery, or server-side restore. Deleting the app, clearing app data, replacing your device, or relying on device settings that remove local data may permanently remove your notes.',
  ),
  LegalSection(
    heading: 'Limitation of Liability',
    body:
        'Jotly is provided for general personal note taking. To the maximum extent permitted by law, Jotly and its developers are not liable for lost notes, lost data, device issues, missed reminders, business interruption, indirect damages, incidental damages, consequential damages, or losses resulting from your use of or inability to use the app.',
  ),
  LegalSection(
    heading: 'Availability',
    body:
        'Jotly is designed to work locally on supported devices, but availability may vary based on your device, operating system, storage state, platform changes, or app store requirements. We do not guarantee uninterrupted availability, compatibility with every device, or continued support for all operating system versions.',
  ),
  LegalSection(
    heading: 'Updates',
    body:
        'Jotly may receive updates that improve reliability, usability, accessibility, legal content, or compatibility. Updates may change or remove features while preserving the app\'s local-only purpose. You are responsible for installing updates through your platform when they are available.',
  ),
  LegalSection(
    heading: 'Termination',
    body:
        'You may stop using Jotly at any time by deleting your notes, clearing app data, or uninstalling the app. We may discontinue or change the app in the future. Because Jotly does not use accounts, there is no account termination process within the app.',
  ),
  LegalSection(
    heading: 'Governing Terms',
    body:
        'These Terms & Conditions are intended to describe the relationship between you and Jotly for use of the app. If any part of these terms is found unenforceable, the remaining sections remain in effect to the fullest extent permitted by law.',
  ),
  LegalSection(
    heading: 'Contact Information',
    body:
        'If you have questions about these Terms & Conditions, contact the Jotly team through the support or contact method provided with the app listing or project page.',
  ),
];

class JotlyApp extends StatefulWidget {
  const JotlyApp({super.key});

  @override
  State<JotlyApp> createState() => _JotlyAppState();
}

class _JotlyAppState extends State<JotlyApp> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => darkMode = prefs.getBool(_darkKey) ?? false);
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    setState(() => darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jotly',
      debugShowCheckedModeBanner: false,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _cream,
        colorSchemeSeed: _coral,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: _coral,
      ),
      home: SplashScreen(
        darkMode: darkMode,
        onDarkModeChanged: setDarkMode,
      ),
    );
  }
}

class JotNote {
  final String id;
  final String title;
  final String body;
  final int colorValue;
  final bool pinned;
  final bool favorite;
  final DateTime createdAt;

  JotNote({
    required this.id,
    required this.title,
    required this.body,
    required this.colorValue,
    required this.pinned,
    required this.favorite,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'colorValue': colorValue,
    'pinned': pinned,
    'favorite': favorite,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JotNote.fromJson(Map<String, dynamic> json) {
    return JotNote(
      id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      colorValue: json['colorValue'] ?? _yellow.value,
      pinned: json['pinned'] ?? false,
      favorite: json['favorite'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  JotNote copyWith({
    String? title,
    String? body,
    int? colorValue,
    bool? pinned,
    bool? favorite,
  }) {
    return JotNote(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      colorValue: colorValue ?? this.colorValue,
      pinned: pinned ?? this.pinned,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt,
    );
  }
}

class SplashScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SplashScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: max(0, constraints.maxHeight - 56),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Image.asset(
                        'assets/logo.png',
                        width: 150,
                        height: 150,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: _yellow,
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: const Icon(Icons.edit_note_rounded, size: 80),
                        ),
                      ),
                      const SizedBox(height: 34),
                      const Text(
                        'Jotly',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 54,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Capture ideas instantly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5F5A52),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _ink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeScreen(
                                  darkMode: darkMode,
                                  onDarkModeChanged: onDarkModeChanged,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Open Notes',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const HomeScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum HomeTab { notes, favorites, settings }

class _HomeScreenState extends State<HomeScreen> {
  List<JotNote> notes = [];
  HomeTab tab = HomeTab.notes;
  String search = '';

  final searchController = TextEditingController();
  final colors = const [_yellow, _sky, _mint, _lavender, Color(0xFFFFB4A2)];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_notesKey);

    if (data == null) return;

    try {
      final decoded = jsonDecode(data) as List;
      setState(() {
        notes = decoded.map((e) => JotNote.fromJson(e)).toList();
        sortNotes();
      });
    } on Object {
      // If local storage is ever corrupted, keep the app usable.
      setState(() => notes = []);
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesKey,
      jsonEncode(notes.map((e) => e.toJson()).toList()),
    );
  }

  void sortNotes() {
    notes.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  List<JotNote> get filteredNotes {
    final query = search.trim().toLowerCase();
    var list = notes.where((note) {
      if (query.isEmpty) return true;
      return note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query);
    }).toList();

    if (tab == HomeTab.favorites) {
      list = list.where((note) => note.favorite).toList();
    }

    return list;
  }

  Future<void> openEditor([JotNote? note]) async {
    final result = await Navigator.push<JotNote>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          note: note,
          colors: colors,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      final index = notes.indexWhere((n) => n.id == result.id);
      if (index == -1) {
        notes.add(result);
      } else {
        notes[index] = result;
      }
      sortNotes();
    });

    saveNotes();
  }

  Future<void> deleteNote(JotNote note) async {
    final noteTitle = note.title.trim().isEmpty ? 'Untitled' : note.title;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Delete this note?'),
        content: Text(
          'This will remove "$noteTitle" from Jotly. You can undo the delete immediately after it happens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep note'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _coral,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete note'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final index = notes.indexWhere((n) => n.id == note.id);
    if (index == -1) return;

    setState(() => notes.removeWhere((n) => n.id == note.id));
    await saveNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$noteTitle" deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              notes.insert(min(max(0, index), notes.length), note);
              sortNotes();
            });
            saveNotes();
          },
        ),
      ),
    );
  }

  Future<void> togglePin(JotNote note) async {
    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index == -1) return;
      notes[index] = note.copyWith(pinned: !note.pinned);
      sortNotes();
    });
    saveNotes();
  }

  Future<void> toggleFavorite(JotNote note) async {
    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index == -1) return;
      notes[index] = note.copyWith(favorite: !note.favorite);
    });
    saveNotes();
  }

  void clearSearch() {
    searchController.clear();
    setState(() => search = '');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (tab == HomeTab.settings) {
      return SettingsScreen(
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
        onBackToNotes: () => setState(() => tab = HomeTab.notes),
      );
    }

    final visible = filteredNotes;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : _cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 46,
                    height: 46,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.edit_note_rounded, size: 42),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Jotly',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => tab = HomeTab.settings),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() => search = value),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: search.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? EmptyNotesState(
                      hasNotes: notes.isNotEmpty,
                      hasSearch: search.trim().isNotEmpty,
                      favoritesOnly: tab == HomeTab.favorites,
                      onAdd: () => openEditor(),
                      onClearSearch: clearSearch,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 360
                            ? 1
                            : constraints.maxWidth < 720
                                ? 2
                                : 3;

                        return GridView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(18, 4, 18, 100),
                          itemCount: visible.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: crossAxisCount == 1 ? 1.45 : .78,
                          ),
                          itemBuilder: (context, index) {
                            final note = visible[index];
                            return NoteTile(
                              note: note,
                              index: index,
                              onTap: () => openEditor(note),
                              onDelete: () => deleteNote(note),
                              onPin: () => togglePin(note),
                              onFavorite: () => toggleFavorite(note),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: JotlyBottomBar(
        tab: tab,
        onTab: (newTab) => setState(() => tab = newTab),
        onAdd: () => openEditor(),
      ),
    );
  }
}

class NoteTile extends StatelessWidget {
  final JotNote note;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onFavorite;

  const NoteTile({
    super.key,
    required this.note,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final compactWidth = MediaQuery.sizeOf(context).width < 360;
    final heightOffset = compactWidth ? 0.0 : index.isEven ? 0.0 : 18.0;

    return Transform.translate(
      offset: Offset(0, heightOffset),
      child: Semantics(
        button: true,
        label: 'Open note ${note.title}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: note.color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.pinned)
                      const Icon(Icons.push_pin, size: 18),
                    const Spacer(),
                    IconButton(
                      tooltip: note.favorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: onFavorite,
                      icon: Icon(
                        note.favorite
                            ? Icons.star_rounded
                            : Icons.star_border,
                        size: 22,
                        color: _ink,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete note',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 21,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    note.body,
                    maxLines: compactWidth ? 4 : 7,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _ink.withOpacity(.78),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _shortDate(note.createdAt),
                      style: TextStyle(
                        color: _ink.withOpacity(.55),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: note.pinned ? 'Unpin note' : 'Pin note',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: onPin,
                      icon: Icon(
                        note.pinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        size: 19,
                        color: _ink,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyNotesState extends StatelessWidget {
  final bool hasNotes;
  final bool hasSearch;
  final bool favoritesOnly;
  final VoidCallback onAdd;
  final VoidCallback onClearSearch;

  const EmptyNotesState({
    super.key,
    required this.hasNotes,
    required this.hasSearch,
    required this.favoritesOnly,
    required this.onAdd,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final title = hasSearch
        ? 'No matches found'
        : favoritesOnly && hasNotes
            ? 'No favorites yet'
            : 'No notes yet';
    final message = hasSearch
        ? 'Try a different word or clear search to see all your notes.'
        : favoritesOnly && hasNotes
            ? 'Tap the star on a note to keep it close at hand.'
            : 'Write your first quick idea, plan, or reminder.';
    final icon = hasSearch
        ? Icons.search_off_rounded
        : favoritesOnly && hasNotes
            ? Icons.star_border_rounded
            : Icons.sticky_note_2_rounded;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _yellow.withOpacity(.85),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 56, color: _ink),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            if (hasSearch)
              OutlinedButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Clear search'),
              )
            else
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Note'),
              ),
          ],
        ),
      ),
    );
  }
}

class JotlyBottomBar extends StatelessWidget {
  final HomeTab tab;
  final ValueChanged<HomeTab> onTab;
  final VoidCallback onAdd;

  const JotlyBottomBar({
    super.key,
    required this.tab,
    required this.onTab,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'All notes',
              color: tab == HomeTab.notes ? _yellow : Colors.white54,
              onPressed: () => onTab(HomeTab.notes),
              icon: const Icon(Icons.sticky_note_2_rounded),
            ),
            IconButton(
              tooltip: 'Favorites',
              color: tab == HomeTab.favorites ? _yellow : Colors.white54,
              onPressed: () => onTab(HomeTab.favorites),
              icon: const Icon(Icons.star_rounded),
            ),
            const Spacer(),
            SizedBox(
              width: 58,
              height: 58,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _coral,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                onPressed: onAdd,
                child: const Icon(
                  Icons.add_rounded,
                  semanticLabel: 'Create note',
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Settings',
              color: tab == HomeTab.settings ? _yellow : Colors.white54,
              onPressed: () => onTab(HomeTab.settings),
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditorScreen extends StatefulWidget {
  final JotNote? note;
  final List<Color> colors;

  const NoteEditorScreen({
    super.key,
    this.note,
    required this.colors,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController titleController;
  late final TextEditingController bodyController;

  late Color selectedColor;
  bool pinned = false;
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    bodyController = TextEditingController(text: widget.note?.body ?? '');
    selectedColor = widget.note?.color ?? widget.colors.first;
    pinned = widget.note?.pinned ?? false;
    favorite = widget.note?.favorite ?? false;
  }

  void save() {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first')),
      );
      return;
    }

    Navigator.pop(
      context,
      JotNote(
        id: widget.note?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Untitled' : title,
        body: body,
        colorValue: selectedColor.value,
        pinned: pinned,
        favorite: favorite,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close editor',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: _ink),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: pinned ? 'Unpin note' : 'Pin note',
                    onPressed: () => setState(() => pinned = !pinned),
                    icon: Icon(
                      pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: _ink,
                    ),
                  ),
                  IconButton(
                    tooltip: favorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: () => setState(() => favorite = !favorite),
                    icon: Icon(
                      favorite ? Icons.star_rounded : Icons.star_border,
                      color: _ink,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.55),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      maxLines: 2,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: bodyController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          height: 1.45,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Start writing...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Row(
                      children: widget.colors.map((color) {
                        final active = selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: active ? _ink : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onBackToNotes;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
    required this.onBackToNotes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : _cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back to notes',
                  onPressed: onBackToNotes,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 72,
                    height: 72,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.edit_note_rounded, size: 60),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Jotly\nCapture ideas instantly.',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              value: darkMode,
              onChanged: onDarkModeChanged,
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode_rounded),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('App Version'),
              subtitle: const Text('Version $_appVersion ($_appBuildNumber)'),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Made for quick, private notes.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article_rounded),
              title: const Text('Terms & Conditions'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextPage(
      title: 'Privacy Policy',
      sections: _privacySections,
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextPage(
      title: 'Terms & Conditions',
      sections: _termsSections,
    );
  }
}

class TextPage extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const TextPage({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2B2B2B) : Colors.white;
    final bodyColor = isDark ? Colors.white.withOpacity(.82) : _ink.withOpacity(.8);

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : _cream,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: $_lastUpdatedLabel',
                      style: TextStyle(
                        color: bodyColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final section in sections) ...[
                      Text(
                        section.heading,
                        style: const TextStyle(
                          fontSize: 19,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.body,
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 16,
                          height: 1.65,
                        ),
                      ),
                      if (section != sections.last) const SizedBox(height: 22),
                    ],
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

String _shortDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}';
}