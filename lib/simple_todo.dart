// lib/simple_todo.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// =============================== MODELS ===============================

enum TaskStatus { open, completed, postponed }

extension TaskStatusX on TaskStatus {
  String get ar {
    switch (this) {
      case TaskStatus.open:
        return 'مفتوحة';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.postponed:
        return 'مؤجلة';
    }
  }
}

enum TaskTag { worship, study, general, dhikr, dua }

extension TaskTagX on TaskTag {
  String get ar {
    switch (this) {
      case TaskTag.worship:
        return 'عبادة';
      case TaskTag.study:
        return 'دراسة';
      case TaskTag.general:
        return 'عام';
      case TaskTag.dhikr:
        return 'ذكر';
      case TaskTag.dua:
        return 'دعاء';
    }
  }
}

enum TaskPriority { low, normal, high, urgent }

extension TaskPriorityX on TaskPriority {
  String get ar {
    switch (this) {
      case TaskPriority.low:
        return 'منخفضة';
      case TaskPriority.normal:
        return 'عادية';
      case TaskPriority.high:
        return 'عالية';
      case TaskPriority.urgent:
        return 'عاجلة';
    }
  }

  int get rank {
    switch (this) {
      case TaskPriority.urgent:
        return 3;
      case TaskPriority.high:
        return 2;
      case TaskPriority.normal:
        return 1;
      case TaskPriority.low:
        return 0;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskTag tag;
  final TaskStatus status;
  final TaskPriority priority;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.tag,
    required this.status,
    this.priority = TaskPriority.normal,
    this.pinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskTag? tag,
    TaskStatus? status,
    TaskPriority? priority,
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate?.millisecondsSinceEpoch,
        'tag': tag.name,
        'status': status.name,
        'priority': priority.name,
        'pinned': pinned ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'],
        title: m['title'],
        description: m['description'],
        dueDate: m['due_date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(m['due_date'])
            : null,
        tag: TaskTag.values.firstWhere(
          (e) => e.name == (m['tag'] ?? 'general'),
          orElse: () => TaskTag.general,
        ),
        status: TaskStatus.values.firstWhere(
          (e) => e.name == (m['status'] ?? 'open'),
          orElse: () => TaskStatus.open,
        ),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == (m['priority'] ?? 'normal'),
          orElse: () => TaskPriority.normal,
        ),
        pinned: (m['pinned'] ?? 0) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updated_at']),
      );

  @override
  bool operator ==(Object other) => other is Task && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// ========================= DATABASE SERVICE ==========================

class SimpleDatabaseService {
  static Database? _db;
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = p.join(await getDatabasesPath(), 'simple_todo.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            due_date INTEGER,
            tag TEXT NOT NULL DEFAULT 'general',
            status TEXT NOT NULL DEFAULT 'open',
            priority TEXT NOT NULL DEFAULT 'normal',
            pinned INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        // ترقية كسولة لو الحقول ناقصة
        final cols = await db.rawQuery("PRAGMA table_info('tasks')");
        final names = cols.map((e) => e['name']).toSet();
        if (!names.contains('priority')) {
          await db.execute(
              "ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT 'normal'");
        }
        if (!names.contains('pinned')) {
          await db.execute(
              "ALTER TABLE tasks ADD COLUMN pinned INTEGER NOT NULL DEFAULT 0");
        }
      },
    );
  }
}

/// ============================ PROVIDER ===============================

enum SortMode { newest, oldest, nearestDue, priority }

class SimpleTaskProvider extends ChangeNotifier {
  final List<Task> _all = [];
  List<Task> _view = [];
  bool _loading = false;

  TaskStatus? _status;
  TaskTag? _tag;
  String _query = '';
  SortMode _sort = SortMode.newest;

  bool get isLoading => _loading;
  List<Task> get tasks => _view;
  TaskStatus? get statusFilter => _status;
  TaskTag? get tagFilter => _tag;
  SortMode get sortMode => _sort;

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();
    try {
      final db = await SimpleDatabaseService.database;
      final rows = await db.query('tasks', orderBy: 'created_at DESC');
      _all
        ..clear()
        ..addAll(rows.map(Task.fromMap));
      _apply();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    required TaskTag tag,
    TaskPriority priority = TaskPriority.normal,
    bool pinned = false,
  }) async {
    final t = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      tag: tag,
      status: TaskStatus.open,
      priority: priority,
      pinned: pinned,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final db = await SimpleDatabaseService.database;
    await db.insert('tasks', t.toMap());
    _all.insert(0, t);
    _apply();
    notifyListeners();
  }

  Future<void> updateTask(Task t) async {
    final u = t.copyWith(updatedAt: DateTime.now());
    final db = await SimpleDatabaseService.database;
    await db.update('tasks', u.toMap(), where: 'id=?', whereArgs: [u.id]);
    final i = _all.indexWhere((x) => x.id == u.id);
    if (i != -1) _all[i] = u;
    _apply();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final db = await SimpleDatabaseService.database;
    await db.delete('tasks', where: 'id=?', whereArgs: [id]);
    _all.removeWhere((x) => x.id == id);
    _apply();
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String id) async {
    final i = _all.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final curr = _all[i];
    final next =
        curr.status == TaskStatus.completed ? TaskStatus.open : TaskStatus.completed;
    await updateTask(curr.copyWith(status: next));
  }

  Future<void> togglePin(String id) async {
    final i = _all.indexWhere((e) => e.id == id);
    if (i == -1) return;
    await updateTask(_all[i].copyWith(pinned: !_all[i].pinned));
  }

  Future<void> postponeOneDay(String id) async {
    final i = _all.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final cur = _all[i];
    final base = cur.dueDate ?? DateTime.now();
    await updateTask(cur.copyWith(dueDate: base.add(const Duration(days: 1))));
  }

  Future<void> clearCompleted() async {
    final db = await SimpleDatabaseService.database;
    final done = _all.where((e) => e.status == TaskStatus.completed).toList();
    final batch = db.batch();
    for (final t in done) {
      batch.delete('tasks', where: 'id=?', whereArgs: [t.id]);
    }
    await batch.commit(noResult: true);
    _all.removeWhere((e) => e.status == TaskStatus.completed);
    _apply();
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? s) {
    _status = s;
    _apply();
    notifyListeners();
  }

  void setTagFilter(TaskTag? t) {
    _tag = t;
    _apply();
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _query = q;
    _apply();
    notifyListeners();
  }

  void setSort(SortMode m) {
    _sort = m;
    _apply();
    notifyListeners();
  }

  Map<String, int> get stats => {
        'total': _all.length,
        'completed': _all.where((t) => t.status == TaskStatus.completed).length,
        'open': _all.where((t) => t.status == TaskStatus.open).length,
        'postponed': _all.where((t) => t.status == TaskStatus.postponed).length,
        'today': _all.where(_isDueToday).length,
        'overdue': _all.where(_isOverdue).length,
      };

  void _apply() {
    _view = _all.where((t) {
      if (_status != null && t.status != _status) return false;
      if (_tag != null && t.tag != _tag) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        return t.title.toLowerCase().contains(q) ||
            (t.description ?? '').toLowerCase().contains(q);
      }
      return true;
    }).toList();

    _view.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      switch (_sort) {
        case SortMode.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case SortMode.nearestDue:
          return (a.dueDate ?? DateTime(9999))
              .compareTo(b.dueDate ?? DateTime(9999));
        case SortMode.priority:
          final r = b.priority.rank - a.priority.rank;
          return r != 0
              ? r
              : (a.dueDate ?? DateTime(9999))
                  .compareTo(b.dueDate ?? DateTime(9999));
        case SortMode.newest:
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
  }

  bool _isDueToday(Task t) {
    if (t.dueDate == null) return false;
    final d = t.dueDate!;
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isOverdue(Task t) {
    if (t.dueDate == null) return false;
    return t.dueDate!.isBefore(DateTime.now()) && t.status != TaskStatus.completed;
  }
}

/// =============================== SCREEN ==============================

class SimpleTodoScreen extends StatefulWidget {
  const SimpleTodoScreen({super.key});
  @override
  State<SimpleTodoScreen> createState() => _SimpleTodoScreenState();
}

class _SimpleTodoScreenState extends State<SimpleTodoScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SimpleTaskProvider>().loadTasks(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme ناعم وأنيق
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D57)),
        cardTheme: CardThemeData(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المذكرة'),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.sort), onPressed: _showSortSheet),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'clear_completed') {
                  context.read<SimpleTaskProvider>().clearCompleted();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'clear_completed',
                    child: Text('مسح المهام المنجَزة')),
              ],
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('مهمة جديدة'),
          onPressed: _addNewTask,
        ),
        body: Consumer<SimpleTaskProvider>(
          builder: (context, tp, _) {
            if (tp.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                _StatsRow(tp: tp),
                _QuickAddCard(), // إضافة سريعة
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _search,
                    onChanged: tp.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مهمة…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                _FiltersBar(tp: tp),
                const SizedBox(height: 6),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: tp.tasks.isEmpty
                        ? _Empty()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: tp.tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _TaskCard(task: tp.tasks[i]).animate().fade(duration: 300.ms).slideY(begin: 0.5, curve: Curves.easeIn),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addNewTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _EditSheet(),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final tp = context.read<SimpleTaskProvider>();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('فرز المهام',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              for (final m in SortMode.values)
                RadioListTile<SortMode>(
                  value: m,
                  groupValue: tp.sortMode,
                  title: Text({
                    SortMode.newest: 'الأحدث أولاً',
                    SortMode.oldest: 'الأقدم أولاً',
                    SortMode.nearestDue: 'الأقرب موعدًا',
                    SortMode.priority: 'الأولوية الأعلى',
                  }[m]!),
                  onChanged: (v) {
                    if (v != null) tp.setSort(v);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================ HEADER WIDGETS ==========================

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.tp});
  final SimpleTaskProvider tp;

  @override
  Widget build(BuildContext context) {
    final s = tp.stats;
    Widget card(String t, int v, IconData i, Color c) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(i, color: c),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(v.toString(),
                        style: TextStyle(
                            color: c,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(t),
                  ],
                )
              ],
            ),
          ),
        );
    return SizedBox(
      height: 92,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        scrollDirection: Axis.horizontal,
        children: [
          card('المجموع', s['total']!, Icons.inbox, Colors.blue),
          card('اليوم', s['today']!, Icons.today, Colors.teal),
          card('منجزة', s['completed']!, Icons.check_circle, Colors.green),
          card('متأخرة', s['overdue']!, Icons.warning_amber, Colors.red),
        ].animate(interval: 100.ms).fade(duration: 200.ms).slideX(begin: -0.5, curve: Curves.easeOut),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({required this.tp});
  final SimpleTaskProvider tp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: tp.statusFilter == null,
                onSelected: (_) => tp.setStatusFilter(null),
              ),
              ...TaskStatus.values.map((s) => ChoiceChip(
                    label: Text(s.ar),
                    selected: tp.statusFilter == s,
                    onSelected: (b) => tp.setStatusFilter(b ? s : null),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('جميع التصنيفات'),
                selected: tp.tagFilter == null,
                onSelected: (_) => tp.setTagFilter(null),
              ),
              ...TaskTag.values.map((t) => ChoiceChip(
                    label: Text(t.ar),
                    selected: tp.tagFilter == t,
                    onSelected: (b) => tp.setTagFilter(b ? t : null),
                  )),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}

/// ============================== QUICK ADD =============================

class _QuickAddCard extends StatefulWidget {
  @override
  State<_QuickAddCard> createState() => _QuickAddCardState();
}

class _QuickAddCardState extends State<_QuickAddCard> {
  final _title = TextEditingController();
  TaskTag _tag = TaskTag.general;
  TaskPriority _priority = TaskPriority.normal;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      hintText: 'أضف مهمة بسرعة…',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskTag>(
                    initialValue: _tag,
                    decoration: const InputDecoration(
                      labelText: 'تصنيف',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskTag.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.ar)))
                        .toList(),
                    onChanged: (v) => setState(() => _tag = v ?? _tag),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'الأولوية',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskPriority.values
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.ar)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _priority = v ?? _priority),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_date == null
                        ? 'اختر التاريخ'
                        : DateFormat('yyyy/MM/dd').format(_date!)),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(
                        _time == null ? 'اختر الوقت' : _time!.format(context)),
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                      );
                      if (t != null) setState(() => _time = t);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'مسح',
                  onPressed: () => setState(() {
                    _date = null;
                    _time = null;
                  }),
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms);
  }

  Future<void> _add() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    DateTime? due;
    if (_date != null) {
      due = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time?.hour ?? 0,
        _time?.minute ?? 0,
      );
    }
    await context.read<SimpleTaskProvider>().addTask(
          title: title,
          tag: _tag,
          priority: _priority,
          dueDate: due,
        );
    _title.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تمت الإضافة السريعة'),
        backgroundColor: Colors.green,
      ));
    }
  }
}

/// ============================== TASK CARD ============================

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final Task task;

  Color _tagColor(TaskTag tag) {
    switch (tag) {
      case TaskTag.worship:
        return Colors.purple;
      case TaskTag.study:
        return Colors.blue;
      case TaskTag.dhikr:
        return Colors.green;
      case TaskTag.dua:
        return Colors.orange;
      case TaskTag.general:
      default:
        return Colors.grey;
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.normal:
        return Colors.teal;
      case TaskPriority.low:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.read<SimpleTaskProvider>();
    final overdue = tp._isOverdue(task);
    final today = tp._isDueToday(task);

    return Dismissible(
      key: Key(task.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.endToStart) {
          return await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تأكيد الحذف'),
                  content: const Text('هل تريد حذف هذه المهمة؟'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف')),
                  ],
                ),
              ) ??
              false;
        }
        return true;
      },
      onDismissed: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          await tp.toggleTaskStatus(task.id);
        } else {
          await tp.deleteTask(task.id);
        }
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetails(context, task),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان + تثبيت + قائمة
                Row(
                  children: [
                    Icon(
                      task.status == TaskStatus.completed
                          ? Icons.check_circle
                          : task.status == TaskStatus.postponed
                              ? Icons.schedule
                              : Icons.radio_button_unchecked,
                      color: task.status == TaskStatus.completed
                          ? Colors.green
                          : task.status == TaskStatus.postponed
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: task.pinned ? 'إلغاء التثبيت' : 'تثبيت',
                      icon: Icon(
                        task.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: task.pinned
                            ? Colors.amber[800]
                            : Colors.grey[600],
                      ),
                      onPressed: () => tp.togglePin(task.id),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        switch (v) {
                          case 'edit':
                            _openEdit(context, task);
                            break;
                          case 'done':
                            await tp.toggleTaskStatus(task.id);
                            break;
                          case 'postpone':
                            await tp.postponeOneDay(task.id);
                            break;
                          case 'delete':
                            final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content:
                                        const Text('هل تريد حذف هذه المهمة؟'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('إلغاء')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('حذف')),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (ok) await tp.deleteTask(task.id);
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('تعديل')),
                        PopupMenuItem(value: 'done', child: Text('إنجاز/إلغاء')),
                        PopupMenuItem(
                            value: 'postpone', child: Text('تأجيل يوم')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),

                if ((task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),
                // شارات
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(task.tag.ar, _tagColor(task.tag)),
                    _chip(task.priority.ar, _priorityColor(task.priority)),
                    if (task.dueDate != null)
                      _chip(
                        DateFormat('yyyy/MM/dd HH:mm').format(task.dueDate!),
                        Colors.blue,
                        icon: Icons.schedule,
                      ),
                    if (today) _chip('اليوم', Colors.teal, icon: Icons.today),
                    if (overdue)
                      _chip('متأخرة', Colors.red, icon: Icons.warning_amber),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color, {IconData? icon}) => Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(text, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        backgroundColor: color.withOpacity(.12),
        shape: StadiumBorder(side: BorderSide(color: color.withOpacity(.25))),
      );

  void _openEdit(BuildContext context, Task t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditSheet(task: t),
    );
  }

  void _openDetails(BuildContext context, Task t) {
    // قراءة تفاصيل + أزرار أفعال
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final tp = context.read<SimpleTaskProvider>();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(t.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if ((t.description ?? '').isNotEmpty)
                Text(t.description!,
                    style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(t.tag.ar, _tagColor(t.tag)),
                  _chip(t.priority.ar, _priorityColor(t.priority)),
                  if (t.dueDate != null)
                    _chip(
                        DateFormat('yyyy/MM/dd HH:mm').format(t.dueDate!),
                        Colors.blue,
                        icon: Icons.schedule),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openEdit(context, t);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await tp.toggleTaskStatus(t.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.done_all),
                      label: Text(t.status == TaskStatus.completed
                          ? 'إلغاء الإنجاز'
                          : 'وضع كمُنجَز'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await tp.postponeOneDay(t.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.snooze),
                      label: const Text('تأجيل يوم'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: const Text('هل تريد حذف هذه المهمة؟'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('إلغاء')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('حذف')),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) {
                          await tp.deleteTask(t.id);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('حذف',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('تثبيت'),
                value: t.pinned,
                onChanged: (_) => tp.togglePin(t.id),
                secondary: const Icon(Icons.push_pin_outlined),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================== EDIT SHEET ===========================

class _EditSheet extends StatefulWidget {
  const _EditSheet({this.task});
  final Task? task;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  TaskTag _tag = TaskTag.general;
  TaskStatus _status = TaskStatus.open;
  TaskPriority _priority = TaskPriority.normal;
  bool _pinned = false;

  bool get _edit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_edit) {
      final t = widget.task!;
      _title.text = t.title;
      _desc.text = t.description ?? '';
      _date = t.dueDate;
      _time = t.dueDate != null ? TimeOfDay.fromDateTime(t.dueDate!) : null;
      _tag = t.tag;
      _status = t.status;
      _priority = t.priority;
      _pinned = t.pinned;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_edit ? 'تعديل المهمة' : 'مهمة جديدة',
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'العنوان *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل عنوانًا' : null,
                  maxLength: 100,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(
                    labelText: 'الوصف (اختياري)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskTag>(
                        initialValue: _tag,
                        items: TaskTag.values
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t.ar)))
                            .toList(),
                        onChanged: (v) => setState(() => _tag = v ?? _tag),
                        decoration: const InputDecoration(
                          labelText: 'التصنيف',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        initialValue: _priority,
                        items: TaskPriority.values
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p.ar)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _priority = v ?? _priority),
                        decoration: const InputDecoration(
                          labelText: 'الأولوية',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.priority_high),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_edit) ...[
                  DropdownButtonFormField<TaskStatus>(
                    initialValue: _status,
                    items: TaskStatus.values
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.ar)))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SwitchListTile(
                  title: const Text('تثبيت'),
                  value: _pinned,
                  onChanged: (v) => setState(() => _pinned = v),
                  secondary: const Icon(Icons.push_pin_outlined),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _date != null
                              ? DateFormat('yyyy/MM/dd').format(_date!)
                              : 'اختر التاريخ',
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (d != null) setState(() => _date = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _time != null
                              ? _time!.format(context)
                              : 'اختر الوقت',
                        ),
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _time ?? TimeOfDay.now(),
                          );
                          if (t != null) setState(() => _time = t);
                        },
                      ),
                    ),
                  ],
                ),
                if (_date != null || _time != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _date = null;
                        _time = null;
                      }),
                      icon: const Icon(Icons.clear),
                      label: const Text('مسح التاريخ/الوقت'),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(_edit ? 'تحديث' : 'حفظ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final tp = context.read<SimpleTaskProvider>();
    DateTime? due;
    if (_date != null) {
      due = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time?.hour ?? 0,
        _time?.minute ?? 0,
      );
    }

    if (_edit) {
      final u = widget.task!.copyWith(
        title: _title.text.trim(),
        description: _desc.text.trim().isNotEmpty ? _desc.text.trim() : null,
        dueDate: due,
        tag: _tag,
        status: _status,
        priority: _priority,
        pinned: _pinned,
      );
      await tp.updateTask(u);
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم التحديث'), backgroundColor: Colors.green),
      );
    } else {
      await tp.addTask(
        title: _title.text.trim(),
        description: _desc.text.trim().isNotEmpty ? _desc.text.trim() : null,
        dueDate: due,
        tag: _tag,
        priority: _priority,
        pinned: _pinned,
      );
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تمت الإضافة'), backgroundColor: Colors.green),
      );
    }
  }
}

/// ============================== EMPTY ================================

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 90, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('لا توجد مهام بعد',
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text('اضغط على زر “مهمة جديدة” أو استخدم الإضافة السريعة',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

/// ======================= Islamic helpers (unchanged+) =======================

class SimpleTodoHelper {
  static Future<void> addDhikrReminder({
    required BuildContext context,
    required String dhikrTitle,
    String? description,
    DateTime? reminderTime,
  }) async {
    final tp = Provider.of<SimpleTaskProvider>(context, listen: false);
    await tp.addTask(
      title: 'تذكير: $dhikrTitle',
      description: description ?? 'تذكير بقراءة $dhikrTitle',
      dueDate: reminderTime,
      tag: TaskTag.dhikr,
      priority: TaskPriority.high,
      pinned: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم إضافة التذكير'),
      backgroundColor: Colors.green,
    ));
  }

  static Future<void> addDuaReminder({
    required BuildContext context,
    required String duaTitle,
    String? description,
    DateTime? reminderTime,
  }) async {
    final tp = Provider.of<SimpleTaskProvider>(context, listen: false);
    await tp.addTask(
      title: 'تذكير: $duaTitle',
      description: description ?? 'تذكير بقراءة $duaTitle',
      dueDate: reminderTime,
      tag: TaskTag.dua,
      pinned: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم إضافة التذكير'),
      backgroundColor: Colors.green,
    ));
  }

  static Future<void> addWorshipReminder({
    required BuildContext context,
    required String title,
    String? description,
    DateTime? reminderTime,
  }) async {
    final tp = Provider.of<SimpleTaskProvider>(context, listen: false);
    await tp.addTask(
      title: title,
      description: description,
      dueDate: reminderTime,
      tag: TaskTag.worship,
      priority: TaskPriority.high,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم إضافة التذكير'),
      backgroundColor: Colors.green,
    ));
  }

  static void openTodoScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SimpleTodoScreen()));
  }
}
