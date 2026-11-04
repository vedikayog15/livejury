#!/usr/bin/env bash
# Release web build for Firebase Hosting. Reads the ignored config/supabase.json
# so the public client key never lands in git.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter build web --release --dart-define-from-file=config/supabase.json
python3 - <<'PY'
import json
c = json.load(open('config/supabase.json'))
site = {'supabaseUrl': c['SUPABASE_URL'], 'supabaseKey': c['SUPABASE_PUBLISHABLE_KEY']}
open('build/web/site-config.js', 'w').write('window.JURY_SITE_CONFIG = %s;\n' % json.dumps(site))
PY
echo "Built build/web. Deploy with: firebase deploy --only hosting"
