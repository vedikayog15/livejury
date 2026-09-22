import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

/// Builds a case from ordinary form fields and sends it as the JSON payload the
/// database expects, so nobody has to hand-write the nested structure.
///
/// Pass a [CaseFile] to edit; pass nothing to create. The server validates the
/// result again regardless of what this form allows.
class CaseEditorScreen extends StatefulWidget {
  const CaseEditorScreen({super.key, this.existing});
  final CaseFile? existing;
  @override
  State<CaseEditorScreen> createState() => _CaseEditorScreenState();
}

class _CaseEditorScreenState extends State<CaseEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _id,
      _number,
      _title,
      _subtitle,
      _minutes,
      _difficulty,
      _summary,
      _question,
      _parties,
      _debrief;
  late String _category;
  late List<_TimelineDraft> _timeline;
  late List<_ExhibitDraft> _evidence;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _id = TextEditingController(text: c?.id ?? '');
    _number = TextEditingController(text: c?.number ?? '');
    _title = TextEditingController(text: c?.title ?? '');
    _subtitle = TextEditingController(text: c?.subtitle ?? '');
    _minutes = TextEditingController(text: '${c?.minutes ?? 18}');
    _difficulty = TextEditingController(
      text: c?.difficulty ?? 'A good first case',
    );
    _summary = TextEditingController(text: c?.summary ?? '');
    _question = TextEditingController(text: c?.question ?? '');
    _parties = TextEditingController(text: c?.parties ?? '');
    _debrief = TextEditingController(text: c?.debrief ?? '');
    _category = c?.category ?? 'Criminal';
    _timeline = (c?.timeline ?? const <Map<String, String>>[])
        .map(_TimelineDraft.from)
        .toList();
    _evidence = (c?.evidence ?? const <Exhibit>[])
        .map(_ExhibitDraft.from)
        .toList();
    if (_timeline.isEmpty) _timeline.add(_TimelineDraft.empty());
    if (_evidence.isEmpty) _evidence.add(_ExhibitDraft.empty('E1'));
  }

  @override
  void dispose() {
    for (final c in [
      _id,
      _number,
      _title,
      _subtitle,
      _minutes,
      _difficulty,
      _summary,
      _question,
      _parties,
      _debrief,
    ]) {
      c.dispose();
    }
    for (final t in _timeline) {
      t.dispose();
    }
    for (final e in _evidence) {
      e.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _payload() => {
    'id': _id.text.trim(),
    'number': _number.text.trim(),
    'title': _title.text.trim(),
    'subtitle': _subtitle.text.trim(),
    'category': _category,
    'minutes': int.tryParse(_minutes.text.trim()) ?? 18,
    'difficulty': _difficulty.text.trim(),
    'summary': _summary.text.trim(),
    'question': _question.text.trim(),
    'parties': _parties.text.trim(),
    'timeline': _timeline.map((t) => t.toJson()).toList(),
    'evidence': _evidence.map((e) => e.toJson()).toList(),
    'debrief': _debrief.text.trim(),
  };

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      toast(context, 'Some fields still need attention.');
      return;
    }
    final s = JuryScope.of(context);
    final ok = await s.adminAction(
      (a) => a.saveCase(_id.text.trim(), _payload()),
    );
    if (!mounted) return;
    if (ok) {
      toast(context, 'Saved “${_title.text.trim()}”.');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final expanded = JSpace.isExpanded(context);
    final editing = widget.existing != null;
    final action = PrimaryButton(
      editing ? 'Save changes' : 'Create case',
      icon: Icons.check_rounded,
      loading: s.busy,
      onPressed: _save,
    );
    return JuryPage(
      title: editing ? 'Edit case' : 'New case',
      eyebrow: editing ? widget.existing!.title : 'Administration',
      wide: expanded,
      scroll: !expanded,
      bottom: expanded ? null : action,
      child: Form(
        key: _form,
        child: expanded
            ? SplitLayout(
                mainFlex: 6,
                asideFlex: 5,
                main: [..._details(), const SizedBox(height: 30), ..._story()],
                aside: [
                  ..._timelineSection(),
                  const SizedBox(height: 30),
                  ..._evidenceSection(),
                  const SizedBox(height: 28),
                  action,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  ..._details(),
                  const SizedBox(height: 30),
                  ..._story(),
                  const SizedBox(height: 30),
                  ..._timelineSection(),
                  const SizedBox(height: 30),
                  ..._evidenceSection(),
                ],
              ),
      ),
    );
  }

  List<Widget> _details() => [
    const SectionHeading('The file'),
    const SizedBox(height: 16),
    TextFormField(
      controller: _id,
      enabled: widget.existing == null,
      decoration: const InputDecoration(
        labelText: 'Case id',
        helperText:
            'Lowercase letters, digits and hyphens. Cannot change later.',
      ),
      validator: (v) => RegExp(r'^[a-z0-9-]{3,40}$').hasMatch(v?.trim() ?? '')
          ? null
          : '3–40 characters: a–z, 0–9 and hyphens.',
    ),
    const SizedBox(height: 14),
    Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _number,
            decoration: const InputDecoration(
              labelText: 'File number',
              hintText: '004',
            ),
            validator: _required,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutes'),
            validator: (v) {
              final n = int.tryParse(v?.trim() ?? '');
              return n == null || n < 1 ? 'A whole number.' : null;
            },
          ),
        ),
      ],
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _title,
      decoration: const InputDecoration(labelText: 'Title'),
      validator: _required,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _subtitle,
      decoration: const InputDecoration(
        labelText: 'Subtitle',
        hintText: 'A missing sculpture. An eleven-minute silence.',
      ),
      validator: _required,
    ),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(
      initialValue: _category,
      decoration: const InputDecoration(labelText: 'Category'),
      items: const [
        DropdownMenuItem(value: 'Criminal', child: Text('Criminal')),
        DropdownMenuItem(value: 'Civil', child: Text('Civil')),
      ],
      onChanged: (v) => setState(() => _category = v ?? 'Criminal'),
    ),
    const SizedBox(height: 8),
    Text(
      _category == 'Civil'
          ? 'Jurors decide whether responsibility is more likely than not.'
          : 'Jurors decide whether the evidence leaves no reasonable doubt.',
      style: const TextStyle(fontSize: 11, color: JColors.muted, height: 1.5),
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _difficulty,
      decoration: const InputDecoration(
        labelText: 'Difficulty note',
        hintText: 'A good first case',
      ),
      validator: _required,
    ),
  ];

  List<Widget> _story() => [
    const SectionHeading('The narrative'),
    const SizedBox(height: 16),
    TextFormField(
      controller: _summary,
      maxLines: 6,
      minLines: 4,
      decoration: const InputDecoration(
        labelText: 'Summary',
        alignLabelWithHint: true,
        helperText: 'Shown as “The matter before you”.',
      ),
      validator: _required,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _question,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'The question to resolve',
        alignLabelWithHint: true,
      ),
      validator: _required,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _parties,
      decoration: const InputDecoration(
        labelText: 'Parties',
        hintText: 'The fictional state v. Alex Vale · Alleged gallery theft',
      ),
      validator: _required,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _debrief,
      maxLines: 6,
      minLines: 4,
      decoration: const InputDecoration(
        labelText: 'Debrief',
        alignLabelWithHint: true,
        helperText: 'Shown after the verdict, explaining the ambiguity.',
      ),
      validator: _required,
    ),
  ];

  List<Widget> _timelineSection() => [
    Row(
      children: [
        const Expanded(child: SectionHeading('Timeline')),
        TextButton.icon(
          onPressed: () =>
              setState(() => _timeline.add(_TimelineDraft.empty())),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add moment'),
        ),
      ],
    ),
    const SizedBox(height: 10),
    for (var i = 0; i < _timeline.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Panel(
          padding: 16,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Moment ${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: JColors.muted,
                      ),
                    ),
                  ),
                  if (_timeline.length > 1)
                    IconButton(
                      tooltip: 'Remove moment ${i + 1}',
                      onPressed: () => setState(() {
                        _timeline.removeAt(i).dispose();
                      }),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: TextFormField(
                      controller: _timeline[i].time,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: '21:32',
                      ),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeline[i].title,
                      decoration: const InputDecoration(labelText: 'Heading'),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeline[i].body,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'What happened',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
            ],
          ),
        ),
      ),
  ];

  List<Widget> _evidenceSection() => [
    Row(
      children: [
        const Expanded(child: SectionHeading('Exhibits')),
        TextButton.icon(
          onPressed: () => setState(
            () =>
                _evidence.add(_ExhibitDraft.empty('E${_evidence.length + 1}')),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add exhibit'),
        ),
      ],
    ),
    const SizedBox(height: 6),
    const Text(
      'Jurors must review every exhibit before voting, so each one should carry '
      'something the others do not.',
      style: TextStyle(fontSize: 11, color: JColors.muted, height: 1.5),
    ),
    const SizedBox(height: 12),
    for (var i = 0; i < _evidence.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Panel(
          padding: 16,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Exhibit ${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: JColors.muted,
                      ),
                    ),
                  ),
                  if (_evidence.length > 1)
                    IconButton(
                      tooltip: 'Remove exhibit ${i + 1}',
                      onPressed: () => setState(() {
                        _evidence.removeAt(i).dispose();
                      }),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      controller: _evidence[i].id,
                      decoration: const InputDecoration(
                        labelText: 'Ref',
                        hintText: 'E1',
                      ),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<EvidenceKind>(
                      initialValue: _evidence[i].kind,
                      decoration: const InputDecoration(labelText: 'Kind'),
                      items: [
                        for (final k in EvidenceKind.values)
                          DropdownMenuItem(value: k, child: Text(k.name)),
                      ],
                      onChanged: (v) => setState(
                        () => _evidence[i].kind = v ?? EvidenceKind.document,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidence[i].title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidence[i].source,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  hintText: 'Gallery security · export 04',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidence[i].summary,
                decoration: const InputDecoration(
                  labelText: 'One-line summary',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidence[i].content,
                maxLines: 6,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidence[i].caution,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  labelText: 'What it does not establish',
                  alignLabelWithHint: true,
                  helperText: 'The limitation shown beside the exhibit.',
                ),
                validator: _required,
              ),
            ],
          ),
        ),
      ),
  ];

  static String? _required(String? v) =>
      (v?.trim().isEmpty ?? true) ? 'This is needed.' : null;
}

class _TimelineDraft {
  _TimelineDraft(this.time, this.title, this.body);
  final TextEditingController time, title, body;

  factory _TimelineDraft.from(Map<String, String> m) => _TimelineDraft(
    TextEditingController(text: m['time'] ?? ''),
    TextEditingController(text: m['title'] ?? ''),
    TextEditingController(text: m['body'] ?? ''),
  );
  factory _TimelineDraft.empty() => _TimelineDraft(
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  );

  Map<String, String> toJson() => {
    'time': time.text.trim(),
    'title': title.text.trim(),
    'body': body.text.trim(),
  };
  void dispose() {
    time.dispose();
    title.dispose();
    body.dispose();
  }
}

class _ExhibitDraft {
  _ExhibitDraft({
    required this.id,
    required this.title,
    required this.kind,
    required this.source,
    required this.summary,
    required this.content,
    required this.caution,
  });
  final TextEditingController id, title, source, summary, content, caution;
  EvidenceKind kind;

  factory _ExhibitDraft.from(Exhibit e) => _ExhibitDraft(
    id: TextEditingController(text: e.id),
    title: TextEditingController(text: e.title),
    kind: e.kind,
    source: TextEditingController(text: e.source),
    summary: TextEditingController(text: e.summary),
    content: TextEditingController(text: e.content),
    caution: TextEditingController(text: e.caution),
  );
  factory _ExhibitDraft.empty(String ref) => _ExhibitDraft(
    id: TextEditingController(text: ref),
    title: TextEditingController(),
    kind: EvidenceKind.document,
    source: TextEditingController(),
    summary: TextEditingController(),
    content: TextEditingController(),
    caution: TextEditingController(),
  );

  Map<String, dynamic> toJson() => {
    'id': id.text.trim(),
    'title': title.text.trim(),
    'kind': kind.name,
    'source': source.text.trim(),
    'summary': summary.text.trim(),
    'content': content.text.trim(),
    'caution': caution.text.trim(),
  };
  void dispose() {
    id.dispose();
    title.dispose();
    source.dispose();
    summary.dispose();
    content.dispose();
    caution.dispose();
  }
}
