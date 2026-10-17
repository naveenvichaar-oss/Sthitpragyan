/// Model representing an imported offline HTML tool or standalone dashboard.
class LocalHtmlTool {
  final String id;
  final String title;
  final String localFilePath;
  final String? htmlContent;
  final DateTime addedDate;
  final String category;
  final String fileName;
  final String? description;
  final int? fileSizeBytes;

  const LocalHtmlTool({
    required this.id,
    required this.title,
    required this.localFilePath,
    this.htmlContent,
    required this.addedDate,
    required this.category,
    required this.fileName,
    this.description,
    this.fileSizeBytes,
  });

  LocalHtmlTool copyWith({
    String? id,
    String? title,
    String? localFilePath,
    String? htmlContent,
    DateTime? addedDate,
    String? category,
    String? fileName,
    String? description,
    int? fileSizeBytes,
  }) {
    return LocalHtmlTool(
      id: id ?? this.id,
      title: title ?? this.title,
      localFilePath: localFilePath ?? this.localFilePath,
      htmlContent: htmlContent ?? this.htmlContent,
      addedDate: addedDate ?? this.addedDate,
      category: category ?? this.category,
      fileName: fileName ?? this.fileName,
      description: description ?? this.description,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'localFilePath': localFilePath,
      'htmlContent': htmlContent,
      'addedDate': addedDate.toIso8601String(),
      'category': category,
      'fileName': fileName,
      'description': description,
      'fileSizeBytes': fileSizeBytes,
    };
  }

  factory LocalHtmlTool.fromMap(Map<String, dynamic> map) {
    return LocalHtmlTool(
      id: map['id'] as String? ?? 'tool_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title'] as String? ?? 'HTML Dashboard',
      localFilePath: map['localFilePath'] as String? ?? '',
      htmlContent: map['htmlContent'] as String?,
      addedDate: map['addedDate'] != null
          ? DateTime.tryParse(map['addedDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: map['category'] as String? ?? 'Personal Tool',
      fileName: map['fileName'] as String? ?? 'tool.html',
      description: map['description'] as String?,
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt(),
    );
  }

  /// Pre-seeded executive decision & equanimity matrix HTML tool
  static LocalHtmlTool starterDashboard() {
    const starterHtml = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Executive Equanimity & Decision Matrix</title>
<style>
  :root {
    --bg: #09090b;
    --card: #18181b;
    --card-hover: #27272a;
    --border: #3f3f46;
    --primary: #10b981;
    --accent: #38bdf8;
    --text: #f4f4f5;
    --muted: #a1a1aa;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    background-color: var(--bg);
    color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    padding: 16px;
    line-height: 1.5;
  }
  header {
    margin-bottom: 20px;
    border-bottom: 1px solid var(--border);
    padding-bottom: 14px;
  }
  .badge {
    display: inline-block;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    color: var(--primary);
    background: rgba(16, 185, 129, 0.12);
    border: 1px solid rgba(16, 185, 129, 0.3);
    padding: 4px 8px;
    border-radius: 12px;
    margin-bottom: 6px;
  }
  h1 { font-size: 20px; font-weight: 800; color: #fff; }
  .subtitle { font-size: 12px; color: var(--muted); margin-top: 2px; }
  .card {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 16px;
  }
  h2 { font-size: 14px; font-weight: 700; color: var(--primary); margin-bottom: 10px; }
  .checklist-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 0;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    font-size: 13px;
  }
  .checklist-item:last-child { border-bottom: none; }
  input[type="checkbox"] {
    width: 18px;
    height: 18px;
    accent-color: var(--primary);
    cursor: pointer;
  }
  .slider-container { margin: 12px 0; }
  .slider-labels { display: flex; justify-content: space-between; font-size: 11px; color: var(--muted); }
  input[type="range"] {
    width: 100%;
    margin: 8px 0;
    accent-color: var(--primary);
  }
  .score-badge {
    text-align: center;
    font-size: 28px;
    font-weight: 800;
    font-family: monospace;
    color: var(--primary);
    margin: 8px 0;
  }
  textarea {
    width: 100%;
    height: 80px;
    background: #000;
    border: 1px solid var(--border);
    border-radius: 8px;
    color: var(--text);
    padding: 10px;
    font-size: 12px;
    resize: none;
    margin-top: 8px;
  }
  button {
    background: var(--primary);
    color: #000;
    border: none;
    padding: 10px 16px;
    border-radius: 8px;
    font-weight: 800;
    font-size: 12px;
    cursor: pointer;
    width: 100%;
    margin-top: 10px;
    text-transform: uppercase;
    letter-spacing: 0.8px;
  }
</style>
</head>
<body>
  <header>
    <div class="badge">OFFLINE SOVEREIGN TOOL</div>
    <h1>Executive Equanimity & Decision Matrix</h1>
    <div class="subtitle">Evaluate critical crossroads under pressure with zero panic.</div>
  </header>

  <div class="card">
    <h2>1. Equanimity Gauge (Internal Calm)</h2>
    <div class="slider-container">
      <div class="slider-labels">
        <span>Reactive Agitation</span>
        <span>Equanimous Citadel</span>
      </div>
      <input type="range" id="calmSlider" min="0" max="100" value="85" oninput="updateCalm(this.value)">
      <div class="score-badge" id="calmScore">85%</div>
    </div>
  </div>

  <div class="card">
    <h2>2. Stoic Inversion Checklist</h2>
    <div class="checklist-item">
      <input type="checkbox" id="c1">
      <label for="c1">Is this fully within my circle of direct control?</label>
    </div>
    <div class="checklist-item">
      <input type="checkbox" id="c2">
      <label for="c2">Have I paused 4 seconds before answering the counterpart?</label>
    </div>
    <div class="checklist-item">
      <input type="checkbox" id="c3">
      <label for="c3">Will this decision matter in 36 months?</label>
    </div>
    <div class="checklist-item">
      <input type="checkbox" id="c4">
      <label for="c4">Am I acting out of vanity, indignation, or strategic rationale?</label>
    </div>
  </div>

  <div class="card">
    <h2>3. Premeditatio Malorum (Worst Case Antidote)</h2>
    <div class="subtitle">Define the absolute worst outcome. Can you survive it with honor?</div>
    <textarea id="worstCase" placeholder="If this negotiation falls through, what is the precise contingency plan?"></textarea>
    <button onclick="saveMatrix()">Seal Decision & Execute</button>
  </div>

  <script>
    function updateCalm(val) {
      document.getElementById('calmScore').innerText = val + '%';
      localStorage.setItem('sthitaprajna_calm_score', val);
    }
    function saveMatrix() {
      const worst = document.getElementById('worstCase').value;
      localStorage.setItem('sthitaprajna_matrix_worst', worst);
      alert('✓ Matrix Sealed with Equanimity. Proceed without hesitation.');
    }
    // Load saved values
    window.onload = function() {
      const savedCalm = localStorage.getItem('sthitaprajna_calm_score');
      if (savedCalm) {
        document.getElementById('calmSlider').value = savedCalm;
        document.getElementById('calmScore').innerText = savedCalm + '%';
      }
      const savedWorst = localStorage.getItem('sthitaprajna_matrix_worst');
      if (savedWorst) {
        document.getElementById('worstCase').value = savedWorst;
      }
    };
  </script>
</body>
</html>''';

    return LocalHtmlTool(
      id: 'tool_starter_decision_matrix',
      title: 'Executive Decision & Stillness Matrix',
      localFilePath: 'offline_tools/decision_matrix.html',
      htmlContent: starterHtml,
      addedDate: DateTime.now(),
      category: 'Decision Matrix',
      fileName: 'decision_matrix.html',
      description: 'Interactive offline checklist, equanimity gauge, and premeditatio malorum analyzer.',
      fileSizeBytes: starterHtml.length,
    );
  }
}
