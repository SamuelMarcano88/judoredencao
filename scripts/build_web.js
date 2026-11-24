const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('SUPABASE_URL and SUPABASE_ANON_KEY must be configured.');
}

const parsedSupabaseUrl = new URL(supabaseUrl);
if (parsedSupabaseUrl.protocol !== 'https:' || supabaseUrl.includes('$')) {
  throw new Error('SUPABASE_URL must be a valid HTTPS URL.');
}

console.log(`Building Flutter Web for Supabase project ${parsedSupabaseUrl.host}.`);

const flutterArgs = [
  'build',
  'web',
  '--release',
  `--dart-define=SUPABASE_URL=${supabaseUrl}`,
  `--dart-define=SUPABASE_ANON_KEY=${supabaseAnonKey}`,
];

const isWindows = process.platform === 'win32';
const result = isWindows
  ? spawnSync(
      process.env.ComSpec || 'cmd.exe',
      [
        '/d',
        '/c',
        `flutter build web --release --dart-define=SUPABASE_URL=${supabaseUrl} --dart-define=SUPABASE_ANON_KEY=${supabaseAnonKey}`,
      ],
      { stdio: 'inherit' },
    )
  : spawnSync('flutter', flutterArgs, { stdio: 'inherit' });

if (result.error) throw result.error;
if (result.status !== 0) {
  process.exitCode = result.status ?? 1;
} else {
  const bundle = fs.readFileSync(
    path.join(process.cwd(), 'build', 'web', 'main.dart.js'),
    'utf8',
  );
  if (!bundle.includes(supabaseUrl)) {
    throw new Error('The configured Supabase URL was not embedded in the web build.');
  }
}
