
Il presente file fa riferimento al programma lisp, costituito da "LMC.lisp".

Il programma è costituito da un unico file, contenente le funzioni di parse e
di esecuzione del programma.

La parte di parsing del programma, legge il file riga per riga, rimuovendo da
queste commenti e risolvendo le etichette. Le istruzioni generate da ogni riga
vengono inserite all'interno di una lista.
Lo "state" del programma viene generato come una lista, all'interno del quale è
contenuta anche la lista precedentemente generata dal parser e utilizzata come
memoria.
Per spostarsi all'interno della lista viene utilizzata la funzione "nth", spesso
sostituita da metodi di accesso costruiti con la sopra citata (si fa riferimento
alle funzioni nominate "get-...").
La scelta dell'operazione corretta da eseguire viene effettuata all'interno
della "one-instruction".

Per eseguire il programma si necessita unicamente del file "LMC.lisp".
Per lanciare l'esecuzione del programma utilizzare la funzione
"lmc-run", inserendo il nome di un file di testo contentente codice assembly 
ed eventualmente una coda di input.
