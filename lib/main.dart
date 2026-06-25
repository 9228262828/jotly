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
        child: Padding(
          padding: const EdgeInsets.all(28),
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

    final decoded = jsonDecode(data) as List;
    setState(() {
      notes = decoded.map((e) => JotNote.fromJson(e)).toList();
      sortNotes();
    });
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
    var list = notes.where((note) {
      final query = search.toLowerCase();
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final index = notes.indexWhere((n) => n.id == note.id);
    setState(() => notes.removeWhere((n) => n.id == note.id));
    await saveNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              notes.insert(max(0, index), note);
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
      notes[index] = note.copyWith(pinned: !note.pinned);
      sortNotes();
    });
    saveNotes();
  }

  Future<void> toggleFavorite(JotNote note) async {
    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      notes[index] = note.copyWith(favorite: !note.favorite);
    });
    saveNotes();
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
                onChanged: (value) => setState(() => search = value),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search_rounded),
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
                  ? EmptyNotesState(onAdd: () => openEditor())
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                itemCount: visible.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .78,
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
    final heightOffset = index.isEven ? 0.0 : 18.0;

    return Transform.translate(
      offset: Offset(0, heightOffset),
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
                  if (note.pinned) const Icon(Icons.push_pin, size: 18),
                  const Spacer(),
                  GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      note.favorite ? Icons.star_rounded : Icons.star_border,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close_rounded, size: 21),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                  maxLines: 7,
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
                  GestureDetector(
                    onTap: onPin,
                    child: Icon(
                      note.pinned
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                      size: 19,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyNotesState extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyNotesState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 90,
              height: 90,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.sticky_note_2_rounded, size: 80),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notes yet',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Write your first quick idea, plan, or reminder.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
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
              color: tab == HomeTab.notes ? _yellow : Colors.white54,
              onPressed: () => onTab(HomeTab.notes),
              icon: const Icon(Icons.sticky_note_2_rounded),
            ),
            IconButton(
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
                child: const Icon(Icons.add_rounded),
              ),
            ),
            const Spacer(),
            IconButton(
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: _ink),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => pinned = !pinned),
                    icon: Icon(
                      pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: _ink,
                    ),
                  ),
                  IconButton(
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
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                IconButton(
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
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontWeight: FontWeight.w700),
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
      text:
      'Jotly stores your notes, favorite status, pinned status, colors, and app settings locally on your device. Jotly does not require login, does not use backend servers, does not use Firebase, does not show ads, does not use analytics, and does not share your notes with third parties. You can delete notes inside the app, clear app data, or uninstall the app to remove locally stored information.',
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextPage(
      title: 'Terms & Conditions',
      text:
      'Jotly is provided as a simple personal notes app. You are responsible for the content you enter and for keeping your device secure. Jotly does not provide cloud backup or account recovery. The app is provided as-is without guarantees. Do not use Jotly to store passwords, financial secrets, or highly sensitive information unless you understand it is stored locally on your device.',
    );
  }
}

class TextPage extends StatelessWidget {
  final String title;
  final String text;

  const TextPage({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: _ink,
                fontSize: 16,
                height: 1.7,
              ),
            ),
          ),
        ],
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