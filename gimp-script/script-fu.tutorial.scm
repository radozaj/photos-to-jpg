;inicializácia premennej
(premenna hodnota)

;priradenie
(set! premenna hodnota)

;lokálne premenné
(let* (init1 init2...) príkaz1 príkaz2...)

;podmienka
(if hodnota then_príkaz else_príkaz)

;while cyklus
(while hodnota príkaz1 príkaz2...)

;funkcia
(define (nazov param1 param2...) príkaz1 príkaz2...)

;zoznam = hodnota
(list hodnota1 hodnota2...)
;alebo
'(hodnota1 hodnota2...)

;prvý prvok zoznamu = head (dolezite je pismeno v strede)
(car zoznam)

;zoznam okrem prvého prvku = tail (dolezite je pismeno v strede)
(cdr zoznam)

; napr. 2. prvok zo zonamu
(cadr zoznam)
