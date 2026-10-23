App mobile di educazione ambientale con un cucciolo virtuale. Il giocatore cura un pet che parte come uovo e cresce man mano che impara: quiz e mini-giochi danno XP e monete, l'XP fa salire di livello, e i livelli fanno schiudere e crescere il pet e rendono la stanza più viva.
In una frase: imparare la sostenibilità fa crescere il tuo pet.
Il messaggio
L'obiettivo principale è la sostenibilità. Molti giovani conoscono i problemi ambientali ma faticano a trasformarli in gesti quotidiani. EcoQuest prova a colmare questo divario con un percorso semplice: imparare con i quiz, provare le scelte giuste con i mini-giochi, e vedere subito il risultato nella crescita del proprio pet.
Principi di design:
Tono positivo e senza punizioni: un errore insegna (l'app mostra il bidone giusto e spiega perché).
Il pet non muore mai e la cura è gratuita, quindi non si può "farmare" XP o monete.
Ogni contenuto cita una fonte reale, con link e data di verifica, per evitare il greenwashing.
Come funziona
L'app ha quattro schede in basso.
Home: livello e XP, monete e biglietti, la stanza con il pet, le tre barre dei bisogni e le scorciatoie ("Quiz del giorno", "Pulisci la stanza").
Impara: un quiz personalizzato in base agli interessi e un quiz per ognuno dei 10 temi.
Cucciolo: la stanza animata, le cure e la schiusa dell'uovo.
Profilo: nickname, fascia d'età e interessi, modificabili in qualsiasi momento senza ricominciare.
Al primo avvio c'è un onboarding in 3 passi: benvenuto con nota sulla privacy, scelta degli interessi (almeno uno), nickname ed età facoltativi.
I 10 temi sono: raccolta differenziata, acqua, energia, mobilità, clima, cibo e sprechi, plastica e mari, biodiversità, riuso e consumo, città sostenibili.
Feature implementate
Quiz a tema
5 domande a difficoltà crescente, con opzioni mescolate.
Dopo ogni risposta: esito, spiegazione breve e fonte consultabile (nome, link, data).
50 domande in italiano, 5 per tema.
Il quiz personale dà priorità agli interessi dell'utente ed evita le ultime domande già viste.
XP: 10 per ogni prima risposta corretta, 2 per una domanda già imparata, bonus per le risposte corrette consecutive.
Ogni quiz completato rende il pet un po' più felice.
Pulizia della stanza (riciclo)
8 oggetti per round da smistare in 5 bidoni: plastica e metalli, carta e cartone, organico, vetro, indifferenziato.
Si tocca l'oggetto e poi il bidone, oppure lo si trascina direttamente.
Dopo ogni oggetto: bidone giusto, motivo, fonte e, dove serve, una nota sul fatto che le regole cambiano da Comune a Comune.
Combo per le risposte consecutive, almeno un oggetto "difficile" in ogni round.
Ricompense: monete per ogni oggetto e XP bonus con almeno il 75% di risposte corrette. Alla fine il pet è anche più pulito.
24 oggetti con fonti da consorzi nazionali (COREPLA, CIAL, Comieco, CoReVe, CIC).
Il pet
Quattro fasi di crescita: uovo, cucciolo, giovane, adulto (schiusa al livello 2, crescita ai livelli 5 e 10).
Tre bisogni (fame, felicità, pulizia) che calano col tempo ma non scendono mai sotto il 20.
Cure gratuite: dare da mangiare, giocare, fare il bagno.
L'espressione del pet cambia con l'umore e il pet si sporca quando la pulizia è bassa.
Le piante nella stanza aumentano con i livelli (fino a 4).
Uovo con indicatore di progresso verso la schiusa, possibilità di accarezzarlo e di dare un nome al pet.
Progressione
Livello calcolato dall'XP totale: 100 XP per il livello 2, poi +50 XP per ogni livello successivo.
Monete e biglietti come valute di gioco.
Audio
25 effetti sonori (Kenney, licenza CC0) più il suono del mare nella scheda Cucciolo.
Tre canali separati (musica, effetti, pet) con volumi indipendenti e mute generale.
Gli effetti importanti abbassano per un istante la musica (ducking).
Nel quiz le risposte corrette consecutive salgono di nota lungo una scala pentatonica.
Ogni suono è breve e mai punitivo: l'errore ha un suono morbido e neutro.
Accessibilità
Etichette per screen reader (TalkBack e VoiceOver) su schermate, valori e pulsanti.
Alternativa al trascinamento: tocco sull'oggetto e poi sul bidone.
Testo ingrandibile fino al 200% senza perdere funzioni.
Contrasti dei colori a norma WCAG AA.
Animazioni disattivate se il telefono ha l'impostazione "riduci animazioni".
Dettagli tecnici
Stack: Flutter e Dart, un'unica codebase per Android e iOS.
Stato e navigazione: Riverpod 3 e go_router, con schede a barra inferiore.
Architettura: le regole di gioco sono in Dart puro, separate dall'interfaccia e testate senza UI. Ogni modifica allo stato passa da un unico GameController.
Salvataggio: file JSON versionato nella cartella dell'app, con scrittura sicura (file temporaneo, backup, rinomina atomica). Gestisce file corrotti e versioni più recenti. Non c'è un server: i dati restano sul telefono.
Ricompense: ogni premio ha un identificativo univoco e viene pagato una sola volta, anche dopo un riavvio.
Livello: si salva solo l'XP totale e il livello viene sempre calcolato, così i due valori non possono disallinearsi.
Contenuti come dati: quiz e oggetti da riciclare sono in file JSON con fonte, link e data di verifica, controllati da test automatici.
Lingua: interfaccia in italiano tramite gen-l10n.
Bilanciamento: tutti i numeri dell'economia di gioco sono in un'unica configurazione, modificabile dopo i test di gioco.
Qualità: 225 test automatici superati e analisi statica senza problemi. Provata su emulatore Android; iOS non ancora testato.