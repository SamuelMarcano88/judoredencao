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

## Criar o primeiro usuário

Na tela de login, escolha **Criar conta de responsável**. O cadastro público
sempre cria um perfil de responsável; não é possível escolher ou conceder o
papel de administrador pela aplicação.

Para configurar a conta do professor:

1. Crie a conta com seu e-mail e confirme o endereço, se solicitado.
2. No Supabase, abra **SQL Editor** e execute, substituindo pelo e-mail usado:

   ```sql
   update public.profiles
   set role = 'admin'
   where email = 'seu-email@exemplo.com';
   ```

3. Confirme que exatamente um perfil foi atualizado. Depois, entre novamente.

Em **Authentication → URL Configuration**, configure
`https://judoredencao.netlify.app` como Site URL e permita essa URL em Redirect
URLs para que os links de confirmação retornem à aplicação.

## Login com Google

O botão **Continuar com Google** usa OAuth do Supabase. Configure antes:

1. No Google Cloud Console, crie um OAuth Client ID do tipo **Web application**.
2. Em **Authorized redirect URIs**, adicione o callback indicado pelo Supabase:
   `https://epvgcwdudhwuchbhhykl.supabase.co/auth/v1/callback`.
3. No Supabase, abra **Authentication → Providers → Google**, habilite o provedor
   e informe o Client ID e Client Secret do Google.
4. Em **Authentication → URL Configuration → Redirect URLs**, permita
   `https://judoredencao.netlify.app/**`.
5. Salve e teste o botão. O Google Secret fica somente nas configurações do
   Supabase; nunca o adicione ao Flutter, Netlify ou GitHub.

## Build de produção

```powershell
flutter build web --release --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON
```
