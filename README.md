# n8n in aula — il tuo n8n personale su GitHub Codespaces

Con questo repository hai un **n8n tutto tuo**, nel cloud, gratis, senza
installare niente sul computer. Funziona anche **dal browser del telefono**.

---

## 1. Crea il tuo n8n (una volta sola)

1. In alto su questa pagina premi **Use this template → Open in a codespace**.
   (Dal telefono: apri questa pagina nel **browser**, non nell'app GitHub.
   Se non vedi il pulsante, scegli "Versione desktop" nel menu del browser.)
2. Aspetta: la **prima volta** ci vogliono alcuni minuti, perché installa n8n.
   Le volte successive si accende in meno di un minuto.
3. Quando n8n è pronto si apre una nuova scheda. Se non si apre:
   in basso apri il pannello **PORTE** (Ports), riga **n8n (5678)**,
   e clicca l'icona del **globo** 🌐.
4. Alla prima apertura n8n ti chiede di creare l'**account proprietario**
   (email + password). È solo tuo, sta dentro il tuo Codespace.
   Usa una password nuova, non quella di GitHub.

## 2. Riaprirlo le volte successive

- Vai su **github.com/codespaces**, clicca il tuo Codespace: n8n riparte da solo.
- Poi pannello **PORTE** → globo 🌐 sulla riga 5678.
- I tuoi flussi restano salvati anche se il Codespace si spegne.

## 3. Prima prova: importa un flusso già fatto

1. Nel Codespace apri il file `esempi/01-ciao-webhook.json`, seleziona tutto
   e copialo.
2. In n8n: **Create workflow**, clicca sulla tela vuota e incolla (Ctrl+V):
   compaiono i due nodi. Salva.
3. Clicca il nodo **Webhook** → **Listen for test event**, poi apri l'indirizzo
   **Test URL** che compare, aggiungendo in fondo `?nome=TuoNome`.
4. Il browser risponde con un saluto e l'ora. Hai appena fatto il tuo primo
   flusso: *arriva una richiesta → n8n la elabora → risponde*.

## 4. Esercizi

Fate un esercizio alla volta. Ognuno parte da un flusso vuoto.

| # | Esercizio | Nodi da usare |
|---|-----------|---------------|
| 1 | Modifica il saluto: rispondi in inglese se aggiungo `&lingua=en` | Webhook, **If**, Respond to Webhook |
| 2 | Un modulo web che chiede nome e domanda, e mostra la risposta di un modello AI | **n8n Form Trigger**, **AI Agent** + modello, Form Ending |
| 3 | Dai all'agente uno strumento: "che ore sono" o "calcolatrice" | AI Agent, **Tool** (Calculator / Code Tool) |
| 4 | Fai chiamare il tuo webhook dal sito statico che hai pubblicato su Render | Webhook (porta resa pubblica, vedi sotto) |

Per gli esercizi con l'AI il docente vi indica quale modello usare e come
ottenere la chiave.

## 5. Regole di sicurezza (importanti)

- **Le chiavi API si mettono solo in n8n**, in *Credentials*. Mai nei file di
  questo repository, mai in un commit, mai in chat.
- La porta 5678 è **privata**: la vedi solo tu, quando sei entrato con il tuo
  account GitHub. Per l'esercizio 4 (un sito esterno che chiama il tuo webhook)
  serve renderla **pubblica**: pannello PORTE → tasto destro sulla riga 5678 →
  **Port Visibility → Public**. Da quel momento chiunque abbia l'indirizzo può
  aprire la pagina di login di n8n: per questo serve una password robusta.
  Finito l'esercizio, rimettila **Private**.
- Non importare flussi trovati in giro senza leggerli: un flusso può contenere
  codice che manda i tuoi dati altrove.

## 6. Quote gratuite: non sprecarle

GitHub Codespaces è gratis fino a circa **60 ore al mese** (macchina base) e
15 GB di spazio. Per non consumarle:

- quando hai finito: **github.com/codespaces** → **⋯** → **Stop codespace**
  (comunque si spegne da solo dopo 30 minuti di inattività);
- tieni **un solo** Codespace; quelli che non usi più cancellali.

## 7. Se qualcosa non va

Apri il **Terminale** del Codespace (menu ☰ → Terminal → New Terminal):

```bash
tail -f /workspaces/n8n.log               # cosa sta facendo n8n (Ctrl+C per uscire)
bash .devcontainer/start-n8n.sh restart   # riavvia n8n
```

| Problema | Soluzione |
|----------|-----------|
| La pagina dice "502" o non si carica | n8n si sta ancora avviando: aspetta 30 secondi e ricarica |
| "Connection lost" nell'editor | ricarica la pagina; se resta, riavvia n8n con il comando sopra |
| Il webhook non risponde da un sito esterno | la porta è ancora privata (vedi sezione 5) |
| Password di n8n dimenticata | nel terminale: `bash .devcontainer/start-n8n.sh reset`, poi ricrea l'account (i flussi restano) |

---

## Note per il docente

- **Rendere il repository un modello:** Settings → General → spunta
  **Template repository**. Il repository deve essere pubblico (o gli studenti
  devono avere accesso).
- **Versione fissata:** n8n `2.43.8` in `.devcontainer/devcontainer.json`.
  Per aggiornare cambia il numero lì e nello script.
- **Configurazione Codespaces** (`.devcontainer/start-n8n.sh`): imposta
  `N8N_EDITOR_BASE_URL` e `WEBHOOK_URL` sull'indirizzo del Codespace, e usa
  `N8N_PUSH_BACKEND=sse` per evitare l'errore "Origin header does NOT match"
  del WebSocket dietro il proxy di Codespaces.
- **Dati:** in `/workspaces/.n8n`, fuori dalla cartella del repository,
  quindi non finiscono mai in un commit e sopravvivono al "Rebuild".
- **Licenza:** n8n self-hosted è sotto *Sustainable Use License*: uso interno
  e didattico consentito.
