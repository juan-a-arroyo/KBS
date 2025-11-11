;; -----------------------------------------------------------------
;; Archivo: rules.clp
;; Reglas que definen las acciones y la meta
;; -----------------------------------------------------------------

(defrule meta-conseguida
   "Regla para detener la simulación cuando se alcanza el objetivo"
   (declare (salience -10))
   ?s <- (estado (has-bananas yes))
   =>
   (printout t crlf "¡ÉXITO! El mono ha conseguido los plátanos." crlf)
   (halt)
)

;; --- REGLAS DE ACCIÓN ---

(defrule agarrar-platanos
   "Acción: Agarrar los plátanos"
   (declare (salience 5))
   ?s <- (estado (monkey-horizontal centro)
                (monkey-vertical sobre-caja)
                (box-position centro)
                (has-bananas no))
   =>
   (printout t "PASO 4: Agarrar los plátanos" crlf)
   (modify ?s (has-bananas yes))
)

(defrule trepar-caja
   "Acción: Subirse a la caja"
   (declare (salience 4))
   ?s <- (estado (monkey-horizontal centro)
                (monkey-vertical en-piso)
                (box-position centro)
                (has-bananas no))
   =>
   (printout t "PASO 3: Subir a la caja" crlf)
   (modify ?s (monkey-vertical sobre-caja))
)

(defrule empujar-caja-al-centro
   "Acción: Empujar la caja hacia el centro"
   (declare (salience 3))
   ?s <- (estado (monkey-horizontal ?pos&~centro)
                (monkey-vertical en-piso)
                (box-position ?pos)
                (has-bananas no))
   =>
   (printout t "PASO 2: Empujar la caja desde " ?pos " hasta centro" crlf)
   (modify ?s (monkey-horizontal centro)
              (box-position centro))
)

(defrule caminar-a-la-caja
   "Acción: Caminar hacia la caja"
   (declare (salience 2))
   ?s <- (estado (monkey-horizontal ?mPos)
                (monkey-vertical en-piso)
                (box-position ?bPos&~?mPos)
                (has-bananas no))
   =>
   (printout t "PASO 1: Caminar desde " ?mPos " hasta " ?bPos crlf)
   (modify ?s (monkey-horizontal ?bPos))
)
