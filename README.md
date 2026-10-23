

> Impara la sostenibilità, fai crescere il tuo pet.

**Scarica Laiqua per Android:** [Laiqua.apk](https://github.com/and-mazzaro/hackathon/raw/main/presentation%20material/Laiqua.apk) ·
**Video di gameplay (2 min):** [Laiqua_gameplay_trailer.mp4](presentation%20material/Laiqua_gameplay_trailer.mp4) ·
tutto il materiale per la presentazione è in [`presentation material/`](presentation%20material/)

un'app mobile di educazione ambientale pensata per un pubblico giovane. Il giocatore si prende cura di un cucciolo virtuale che parte come uovo e cresce man mano che impara: quiz e mini-giochi danno XP e monete, l'XP fa salire di livello, e i livelli fanno schiudere e crescere il pet e rendono la sua stanza più viva.

## Obiettivo

Molti giovani conoscono i problemi ambientali ma faticano a trasformarli in gesti quotidiani. l'app prova a colmare questo divario: si impara con i quiz, si provano le scelte giuste con i mini-giochi e si vede subito il risultato nella crescita del proprio pet.

Principi di design:

- **Nessuna punizione**: un errore insegna. L'app mostra la risposta giusta e spiega perché.
- **Il pet non muore mai** e le cure sono gratuite, quindi non si può "farmare" XP o monete.
- **Contenuti verificabili**: ogni domanda e ogni oggetto da riciclare citano una fonte reale, con link e data di verifica, per evitare il greenwashing.

## Funzionalità

### Schermate

| Scheda | Cosa contiene |
|---|---|
| Home | Livello e XP, monete e biglietti, stanza con il pet, barre dei bisogni, scorciatoie ("Quiz del giorno", "Pulisci la stanza") |
| Impara | Quiz personalizzato sugli interessi e un quiz per ognuno dei 10 temi |
| Cucciolo | Stanza animata, cure e schiusa dell'uovo |
| Profilo | Nickname, fascia d'età e interessi, modificabili in qualsiasi momento |

Al primo avvio c'è un onboarding in 3 passi: benvenuto con nota sulla privacy, scelta degli interessi (almeno uno), nickname ed età facoltativi.

### Temi

Raccolta differenziata, acqua, energia, mobilità, clima, cibo e sprechi, plastica e mari, biodiversità, riuso e consumo, città sostenibili.

### Quiz a tema

- 5 domande a difficoltà crescente, con opzioni mescolate.
- Dopo ogni risposta: esito, spiegazione breve e fonte consultabile.
- 50 domande in italiano, 5 per tema.
- Il quiz personale dà priorità agli interessi dell'utente ed evita le ultime domande già viste.
- XP: 10 per ogni prima risposta corretta, 2 per una domanda già imparata, bonus per le risposte corrette consecutive.

### Pulizia della stanza

- 8 oggetti per round da smistare in 5 bidoni: plastica e metalli, carta e cartone, organico, vetro, indifferenziato.
- Si tocca l'oggetto e poi il bidone, oppure lo si trascina.
- Dopo ogni oggetto: bidone giusto, motivo, fonte e, dove serve, una nota sul fatto che le regole cambiano da Comune a Comune.
- Combo per le risposte consecutive e almeno un oggetto "difficile" per round.
- Ricompense: monete per ogni oggetto e XP bonus con almeno il 75% di risposte corrette.
- 24 oggetti con fonti da consorzi nazionali (COREPLA, CIAL, Comieco, CoReVe, CIC).

### Il pet

- Quattro fasi: uovo, cucciolo, giovane, adulto (schiusa al livello 2, crescita ai livelli 5 e 10).
- Tre bisogni (fame, felicità, pulizia) che calano col tempo ma non scendono mai sotto il 20.
- Cure gratuite: dare da mangiare, giocare, fare il bagno.
- L'espressione cambia con l'umore e il pet si sporca quando la pulizia è bassa.
- Le piante nella stanza aumentano con i livelli (fino a 4).
- Uovo con indicatore di progresso verso la schiusa; si può accarezzare e si può dare un nome al pet.

### Progressione

- Livello calcolato dall'XP totale: 100 XP per il livello 2, poi +50 XP per ogni livello successivo.
- Monete e biglietti come valute di gioco.

### Audio

- 25 effetti sonori più il suono del mare nella scheda Cucciolo.
- Tre canali separati (musica, effetti, pet) con volumi indipendenti e mute generale.
- Gli effetti importanti abbassano per un istante la musica (ducking).
- Nel quiz le risposte corrette consecutive salgono di nota lungo una scala pentatonica.
- Suoni brevi e mai punitivi: l'errore ha un suono morbido e neutro.

### Accessibilità

- Etichette per screen reader (TalkBack e VoiceOver).
- Alternativa al trascinamento: tocco sull'oggetto e poi sul bidone.
- Testo ingrandibile fino al 200% senza perdere funzioni.
- Contrasti dei colori a norma WCAG AA.
- Animazioni disattivate con l'impostazione "riduci animazioni".

## Stack tecnico

- **Flutter e Dart**: un'unica codebase per Android e iOS.
- **Riverpod 3** per lo stato e **go_router** per la navigazione.
- **gen-l10n** per l'interfaccia in italiano.

### Architettura

- Le regole di gioco sono in Dart puro (`lib/domain/rules`), separate dall'interfaccia e testate senza UI.
- Ogni modifica allo stato passa da un unico `GameController`.
- Quiz e oggetti da riciclare sono dati in file JSON, con fonte, link e data di verifica, controllati da test automatici.
- Tutti i numeri dell'economia di gioco sono in un'unica configurazione (`EconomyConfig`).

### Salvataggio

- File JSON versionato nella cartella dell'app, con scrittura sicura (file temporaneo, backup, rinomina atomica).
- Gestione di file corrotti e di versioni più recenti.
- Nessun server: i dati restano sul telefono.
- Ogni premio ha un identificativo univoco e viene pagato una sola volta, anche dopo un riavvio.
- Si salva solo l'XP totale e il livello viene sempre calcolato, così i due valori non possono disallinearsi.

## Come avviare il progetto

Prerequisito: [Flutter](https://docs.flutter.dev/get-started/install) installato.

```bash
git clone https://github.com/and-mazzaro/hackathon.git
cd hackathon
flutter pub get
flutter run
```

Test e analisi statica:

```bash
flutter test
flutter analyze
```

## Stato dei test

- 225 test automatici superati e analisi statica senza problemi.
- Provata su emulatore Android.
- iOS non ancora testato.

## Confronto con Gruppo Hera

Hera è la multiutility che gestisce i rifiuti in molte zone dell'Emilia-Romagna e non solo. Il suo prodotto principale è **Il Rifiutologo**, un'app gratuita che fa da guida alla raccolta differenziata: indica le regole per ogni comune, strada e numero civico, permette di cercare un oggetto per sapere dove va, mostra calendari e stazioni ecologiche e consente di segnalare cassonetti pieni. Il suo database è cresciuto grazie agli utenti, da 140 a oltre 600 voci con circa 500 segnalazioni. Hera ha poi aggiunto gli **ECOgames**, giochi gratuiti per mettere alla prova la propria conoscenza della raccolta differenziata.

| Aspetto | Hera (Rifiutologo + ECOgames) | EcoQuest |
|---|---|---|
| Obiettivo | Servizio al cittadino: dove va ogni rifiuto, servizi sul territorio | Costruire conoscenza e abitudini sostenibili |
| Approccio | Informativo e di utilità, con giochi in aggiunta | Game-first: il gioco è il prodotto |
| Temi | Quasi solo rifiuti e raccolta | 10 temi ambientali |
| Regole locali | Precise, fino a strada e civico | Linee guida nazionali con nota "dipende dal Comune" |
| Fidelizzazione | Bisogno pratico (calendario, ritiri) | Pet, XP, livelli e monete |
| Contenuti | Crescono con le segnalazioni degli utenti | Fonte e data di verifica su ogni voce |
| Dati utente | Legati al territorio servito | Salvataggio locale, nessun server |

Dalle fonti consultate non risulta che le app Hera usino un pet virtuale o una progressione a livelli. Le due app sono complementari: il Rifiutologo risponde a "dove lo butto?", EcoQuest a "come divento più sostenibile ogni giorno?". Hera è molto più precisa sulle regole locali, mentre EcoQuest usa fonti nazionali con una nota sul Comune.

## Crediti

- Effetti sonori: [Kenney](https://kenney.nl) (licenza CC0).
- Fonti dei contenuti: consorzi nazionali del riciclo (COREPLA, CIAL, Comieco, CoReVe, CIC) e le altre fonti indicate in ogni voce dei file di contenuto.
