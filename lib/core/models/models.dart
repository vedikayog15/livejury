enum RoundStage {
  waiting,
  briefing,
  initialVote,
  deliberation,
  finalVote,
  complete,
  cancelled,
}

enum Decision { responsible, notResponsible }

enum EvidenceKind { document, witness, diagram, audio }

class Exhibit {
  const Exhibit({
    required this.id,
    required this.title,
    required this.kind,
    required this.source,
    required this.summary,
    required this.content,
    required this.caution,
  });
  final String id, title, source, summary, content, caution;
  final EvidenceKind kind;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'kind': kind.name,
    'source': source,
    'summary': summary,
    'content': content,
    'caution': caution,
  };
  factory Exhibit.fromJson(Map<String, dynamic> j) => Exhibit(
    id: j['id'],
    title: j['title'],
    kind: EvidenceKind.values.byName(j['kind']),
    source: j['source'],
    summary: j['summary'],
    content: j['content'],
    caution: j['caution'],
  );
}

class CaseFile {
  const CaseFile({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.minutes,
    required this.difficulty,
    required this.summary,
    required this.question,
    required this.parties,
    required this.timeline,
    required this.evidence,
    required this.debrief,
  });
  final String id,
      number,
      title,
      subtitle,
      category,
      difficulty,
      summary,
      question,
      parties,
      debrief;
  final int minutes;
  final List<Map<String, String>> timeline;
  final List<Exhibit> evidence;
  bool get isCivil => category == 'Civil';
  String label(Decision d) => isCivil
      ? (d == Decision.responsible ? 'Liable' : 'Not liable')
      : (d == Decision.responsible ? 'Guilty' : 'Not guilty');
  String get standard => isCivil
      ? 'In this fictional game, decide whether responsibility is more likely than not.'
      : 'In this fictional game, a guilty vote requires the evidence to leave no reasonable doubt.';
  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'title': title,
    'subtitle': subtitle,
    'category': category,
    'minutes': minutes,
    'difficulty': difficulty,
    'summary': summary,
    'question': question,
    'parties': parties,
    'timeline': timeline,
    'evidence': evidence.map((e) => e.toJson()).toList(),
    'debrief': debrief,
  };
  factory CaseFile.fromJson(Map<String, dynamic> j) => CaseFile(
    id: j['id'],
    number: j['number'],
    title: j['title'],
    subtitle: j['subtitle'],
    category: j['category'],
    minutes: j['minutes'],
    difficulty: j['difficulty'],
    summary: j['summary'],
    question: j['question'],
    parties: j['parties'],
    timeline: (j['timeline'] as List)
        .map((e) => Map<String, String>.from(e))
        .toList(),
    evidence: (j['evidence'] as List)
        .map((e) => Exhibit.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    debrief: j['debrief'],
  );
}

class Juror {
  const Juror(this.id, this.name, {this.isDemo = false});
  final String id, name;
  final bool isDemo;
  String get initials => name
      .split(' ')
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0])
      .join()
      .toUpperCase();
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'is_demo': isDemo};
  factory Juror.fromJson(Map<String, dynamic> j) =>
      Juror(j['id'], j['name'], isDemo: j['is_demo'] ?? false);
}

class RoomMessage {
  const RoomMessage({
    required this.id,
    required this.senderId,
    required this.name,
    required this.body,
    this.exhibitId,
    this.system = false,
  });
  final String id, senderId, name, body;
  final String? exhibitId;
  final bool system;
  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'name': name,
    'body': body,
    'exhibit_id': exhibitId,
    'system': system,
  };
  factory RoomMessage.fromJson(Map<String, dynamic> j) => RoomMessage(
    id: j['id'],
    senderId: j['sender_id'],
    name: j['name'],
    body: j['body'],
    exhibitId: j['exhibit_id'],
    system: j['system'] ?? false,
  );
}

class JuryRound {
  JuryRound({
    required this.id,
    required this.code,
    required this.caseId,
    required this.hostId,
    required this.isPrivate,
    this.stage = RoundStage.waiting,
    List<Juror>? jurors,
    Set<String>? reviewed,
    List<RoomMessage>? messages,
    this.initial,
    this.finalDecision,
    this.reason = '',
    this.responsibleCount,
    this.finalCount = 0,
  }) : jurors = jurors ?? [],
       reviewed = reviewed ?? {},
       messages = messages ?? [];
  final String id, code, caseId, hostId;
  final bool isPrivate;
  RoundStage stage;
  List<Juror> jurors;
  Set<String> reviewed;
  List<RoomMessage> messages;
  Decision? initial, finalDecision;
  String reason;
  int? responsibleCount;
  int finalCount;
  // Constructor field defaults stay independently allocated for each round.
  JuryRound._({
    required this.id,
    required this.code,
    required this.caseId,
    required this.hostId,
    required this.isPrivate,
    required this.stage,
    required this.jurors,
    required this.reviewed,
    required this.messages,
    this.initial,
    this.finalDecision,
    required this.reason,
    this.responsibleCount,
    required this.finalCount,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'case_id': caseId,
    'host_id': hostId,
    'is_private': isPrivate,
    'stage': stage.name,
    'jurors': jurors.map((e) => e.toJson()).toList(),
    'reviewed': reviewed.toList(),
    'messages': messages.map((e) => e.toJson()).toList(),
    'initial': initial?.name,
    'final_decision': finalDecision?.name,
    'reason': reason,
    'responsible_count': responsibleCount,
    'final_count': finalCount,
  };
  factory JuryRound.fromJson(Map<String, dynamic> j) => JuryRound._(
    id: j['id'],
    code: j['code'],
    caseId: j['case_id'],
    hostId: j['host_id'] ?? '',
    isPrivate: j['is_private'],
    stage: RoundStage.values.byName(j['stage']),
    jurors: (j['jurors'] as List? ?? [])
        .map((e) => Juror.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    reviewed: Set<String>.from(j['reviewed'] ?? []),
    messages: (j['messages'] as List? ?? [])
        .map((e) => RoomMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    initial: j['initial'] == null ? null : Decision.values.byName(j['initial']),
    finalDecision: j['final_decision'] == null
        ? null
        : Decision.values.byName(j['final_decision']),
    reason: j['reason'] ?? '',
    responsibleCount: j['responsible_count'],
    finalCount: j['final_count'] ?? 0,
  );
}

class CaseRecord {
  const CaseRecord({
    required this.roomId,
    required this.caseId,
    required this.title,
    required this.outcome,
    required this.reason,
    required this.points,
    required this.reviewed,
    required this.citations,
    required this.date,
    required this.changedMind,
  });
  final String roomId, caseId, title, outcome, reason;
  final int points, reviewed, citations;
  final DateTime date;
  final bool changedMind;
  Map<String, dynamic> toJson() => {
    'room_id': roomId,
    'case_id': caseId,
    'title': title,
    'outcome': outcome,
    'reason': reason,
    'points': points,
    'reviewed': reviewed,
    'citations': citations,
    'date': date.toIso8601String(),
    'changed_mind': changedMind,
  };
  factory CaseRecord.fromJson(Map<String, dynamic> j) => CaseRecord(
    roomId: j['room_id'],
    caseId: j['case_id'],
    title: j['title'],
    outcome: j['outcome'],
    reason: j['reason'],
    points: j['points'],
    reviewed: j['reviewed'],
    citations: j['citations'],
    date: DateTime.parse(j['date']),
    changedMind: j['changed_mind'],
  );
}

class JuryNotice {
  JuryNotice({
    required this.id,
    required this.title,
    required this.body,
    this.read = false,
  });
  final String id, title, body;
  bool read;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'read': read,
  };
  factory JuryNotice.fromJson(Map<String, dynamic> j) => JuryNotice(
    id: j['id'],
    title: j['title'],
    body: j['body'],
    read: j['read'] ?? false,
  );
}

class PlayerData {
  PlayerData({
    required this.id,
    required this.name,
    List<CaseRecord>? history,
    List<JuryNotice>? notices,
    this.haptics = true,
    this.notifications = true,
    this.isAdmin = false,
    this.suspended = false,
    this.round,
  }) : history = history ?? [],
       notices = notices ?? [];
  final String id;
  String name;
  List<CaseRecord> history;
  List<JuryNotice> notices;
  bool haptics, notifications;

  /// Both are decided by the server and are read-only to the client. The app
  /// only uses them to decide what to show; every admin action is re-checked in
  /// the database.
  final bool isAdmin, suspended;
  JuryRound? round;
  int get points => history.fold(0, (sum, r) => sum + r.points);
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'history': history.map((e) => e.toJson()).toList(),
    'notices': notices.map((e) => e.toJson()).toList(),
    'haptics': haptics,
    'notifications': notifications,
    'is_admin': isAdmin,
    'suspended': suspended,
    'round': round?.toJson(),
  };
  factory PlayerData.fromJson(Map<String, dynamic> j) => PlayerData(
    id: j['id'],
    name: j['name'],
    history: (j['history'] as List? ?? [])
        .map((e) => CaseRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    notices: (j['notices'] as List? ?? [])
        .map((e) => JuryNotice.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    haptics: j['haptics'] ?? true,
    notifications: j['notifications'] ?? true,
    isAdmin: j['is_admin'] ?? false,
    suspended: j['suspended'] ?? false,
    round: j['round'] == null
        ? null
        : JuryRound.fromJson(Map<String, dynamic>.from(j['round'])),
  );
}

class RankingEntry {
  const RankingEntry(this.name, this.points, this.cases);
  final String name;
  final int points, cases;
}

class JuryException implements Exception {
  const JuryException(this.message);
  final String message;
  @override
  String toString() => message;
}
