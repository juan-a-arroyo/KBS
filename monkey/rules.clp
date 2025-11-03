;; -----------------------------------------------------------------
;; Archivo: rules.clp
;; Reglas que definen las acciones y la meta
;; -----------------------------------------------------------------

(defrule goal-achieved
   "Regla para detener la simulación cuando se alcanza el objetivo"
   (declare (salience -10)) ; Prioridad más baja, se ejecuta al final
   ?s <- (state (has-bananas yes))
   =>
   (printout t crlf "¡ÉXITO! El mono ha conseguido los plátanos." crlf)
   (halt)
)

;; --- REGLAS DE ACCIÓN ---
;; Usamos "salience" (prioridad) para guiar al sistema a tomar
;; la acción más lógica en cada paso, simulando la planificación.

(defrule grasp-bananas
   "Acción: Agarrar los plátanos"
   (declare (salience 5)) ; 1ra prioridad: si puede agarrar, que agarre
   ?s <- (state (monkey-horizontal middle)
                (monkey-vertical onbox)
                (box-position middle)
                (has-bananas no))
   =>
   (printout t "PASO 4: Agarrar los plátanos" crlf)
   (modify ?s (has-bananas yes))
)

(defrule climb-box
   "Acción: Subirse a la caja"
   (declare (salience 4)) ; 2da prioridad: si está en el medio, que se suba
   ?s <- (state (monkey-horizontal middle) ; Solo sube si la caja está en el medio
                (monkey-vertical onfloor)
                (box-position middle)
                (has-bananas no))
   =>
   (printout t "PASO 3: Subir a la caja" crlf)
   (modify ?s (monkey-vertical onbox))
)

(defrule push-box-to-middle
   "Acción: Empujar la caja hacia el centro"
   (declare (salience 3)) ; 3ra prioridad: si está junto a la caja, que la empuje al medio
   ?s <- (state (monkey-horizontal ?pos&~middle) ; Mono en ?pos (no es 'middle')
                (monkey-vertical onfloor)
                (box-position ?pos)           ; Caja en la misma posición ?pos
                (has-bananas no))
   =>
   (printout t "PASO 2: Empujar la caja desde " ?pos " hasta middle" crlf)
   (modify ?s (monkey-horizontal middle)
              (box-position middle))
)

(defrule walk-to-box
   "Acción: Caminar hacia la caja"
   (declare (salience 2)) ; 4ta prioridad: si no está junto a la caja, que camine
   ?s <- (state (monkey-horizontal ?mPos)
                (monkey-vertical onfloor)
                (box-position ?bPos&~?mPos) ; Caja en ?bPos, mono NO en ?bPos
                (has-bananas no))
   =>
   (printout t "PASO 1: Caminar desde " ?mPos " hasta " ?bPos crlf)
   (modify ?s (monkey-horizontal ?bPos))
)
