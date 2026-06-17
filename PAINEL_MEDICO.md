# Glicare — Painel Clínico do Médico (Web)

Painel web read-only onde o **médico** acompanha os dados que o **paciente**
compartilhou pelo app (glicemia, adesão à medicação e registro alimentar).

## Como funciona

1. No app, o paciente abre **Minha Equipe**, cadastra UBS/médico e mantém o
   **Compartilhamento de dados** ligado.
2. O paciente copia o **Código de acesso do médico** (é o `uid` dele) e envia
   para o médico.
3. O médico abre o painel web, faz login automático (anônimo) e digita o código.
4. O painel carrega os dados respeitando as permissões marcadas pelo paciente
   (glicemia / medicamentos / alimentação).

## Rodar localmente

```bash
flutter run -d chrome -t lib/doctor_main.dart
```

## Gerar build de produção

```bash
flutter build web -t lib/doctor_main.dart
# saída em build/web — pode ser publicada (Firebase Hosting, etc.)
```

> O app do paciente (mobile) continua sendo `lib/main.dart`. O painel é um
> segundo entry point (`lib/doctor_main.dart`) no mesmo projeto.

## Configuração necessária no Firebase Console (uma vez)

### 1. Habilitar login anônimo
Authentication → Sign-in method → **Anônimo** → Ativar.
O painel usa sessão anônima só para satisfazer as regras de segurança do RTDB.

### 2. Regras do Realtime Database
As regras recomendadas estão em [`database.rules.json`](database.rules.json):

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && (auth.uid === $uid || data.child('care_team/shareEnabled').val() === true)",
        ".write": "auth != null && auth.uid === $uid"
      }
    }
  }
}
```

- O paciente só escreve nos próprios dados.
- O médico (autenticado) lê os dados de um paciente **apenas** quando aquele
  paciente está com `shareEnabled = true`.

Publicar via CLI:
```bash
firebase deploy --only database
```
Ou cole o conteúdo em Realtime Database → Regras → Publicar.

## Limitações / próximos passos (produção)

- O código de acesso é o `uid` do paciente. Para produção, o ideal é um
  **token de compartilhamento** revogável (em vez do uid direto) e uma
  **lista de médicos autorizados**, em vez de permitir qualquer sessão
  autenticada que conheça o código.
- As permissões por categoria (glicemia/medicação/alimentação) são aplicadas
  no cliente do painel. Para reforço server-side, dá para refinar as regras
  por subnó.
