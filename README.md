# MISSÃO PRÓXIMA FAIXA

Aplicação Flutter Web para acompanhamento da evolução de alunos de judô.

## Requisitos

- Flutter 3.41 ou superior.
- Projeto Supabase.
- Conta Netlify para publicação.

## Configuração local

```powershell
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON
```

Não forneça `service_role` no frontend.

## Build de produção

```powershell
flutter build web --release --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON
```
