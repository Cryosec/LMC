
Il presente file fa riferimento al programma prolog, costituito da "parser.pl" e
"lmc.pl".

Il programma "parser.pl" esegue il parsing del file di testo.
Il file viene letto dal programma una riga alla volta, eliminando da queste i
commenti e spazi bianchi e poi gestendo le etichette tramite la funzione
parse_string.
Istruzioni e valori (o etichette) vengono restituite come una lista e risolte
alla fine, per essere date al programma "lmc.pl" come codice macchina. Queste
vengono passate al programma come una lista di 100 elementi che andrà a
costruire la memoria dello "state". In caso le istruzioni siano meno di 100
la memoria viene riepita tramite random_seq

Il programma "lmc.pl" risolve il codice macchina ricevuto da "parser.pl".
Ogni istruzione viene letta da one_instruction che selezionerà l'operazione di
exec_instruction corretta in base alla cella di memoria indicata dal program
counter (Pc) in quel momento. Per spostarsi all'interno della memoria si sfrutta
la funzione nth0. L'esecuzione del programma termina quando si incontra una
istruzione di "HALT", restituendo la coda di output.

Per eseguire l'intero programma si necessita di entrambi i file "lmc.pl" e
"parser.pl". Per lanciare l'esecuzione del programma utilizzare la funzione
"lmc_run" (contenuta in "lmc.pl"), inserendo il nome di un file di testo 
contentente codice assembly, un'eventuale coda di input e la variabile 
rappresentante l'output del programma.
