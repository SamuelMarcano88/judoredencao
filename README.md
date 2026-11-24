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
2. No Supabase, abra **SQL Editor** e localize a conta que realmente usará para
   entrar (Google e senha podem ter IDs diferentes):

   ```sql
   select id, email, raw_app_meta_data->>'provider' as provider
   from auth.users
   where lower(email) = lower('seu-email@exemplo.com')
   order by created_at desc;
   ```

3. Promova somente o UUID correto:

   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'UUID_DA_CONTA_CORRETA';
   ```

4. Confirme que exatamente um perfil foi atualizado. Depois, saia e entre novamente.

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

## Etapa 2: responsáveis e alunos

Depois de atualizar o código, aplique a migração de acesso aos alunos e publique
a Edge Function que cria as contas individuais:

```powershell
supabase login
supabase link --project-ref epvgcwdudhwuchbhhykl
supabase db push
supabase functions deploy create-student-account
```

O cadastro cria uma conta Supabase individual por aluno com nome de usuário e
senha. A função usa a chave privilegiada somente no servidor Supabase; nunca
configure `service_role` ou `SUPABASE_SERVICE_ROLE_KEY` no Flutter, Netlify ou
GitHub.

## Etapa 3: passaportes, ciclos e checklists

O administrador pode criar ciclos, definir os alunos participantes e configurar
as atividades em português e espanhol. Responsáveis acompanham o passaporte dos
filhos; cada aluno pode marcar suas próprias atividades como concluídas. As
permissões são aplicadas por RLS no Supabase.

Para publicar o esquema da Etapa 3 no Supabase:

```powershell
supabase db push
```

Faixas são opcionais no cadastro do ciclo. Elas só aparecem como opções depois
que houver registros na tabela `belts`.

## Build de produção

```powershell
flutter build web --release --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON
```

O build do Netlify usa `scripts/build_web.js`, que passa as variáveis de ambiente
ao Flutter sem depender da sintaxe de expansão do shell do sistema operacional.

Para fazer um deploy manual a partir do Windows, use os valores públicos do
projeto Supabase e evite que o CLI local tente reconstruir com variáveis
mascaradas:

```powershell
$env:SUPABASE_URL = "https://SEU-PROJETO.supabase.co"
$env:SUPABASE_ANON_KEY = "SUA_CHAVE_PUBLICA"
node scripts/build_web.js
netlify deploy --prod --dir=build/web --no-build
```
