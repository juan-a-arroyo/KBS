;; -----------------------------------------------------------------
;; Archivo: templates.clp
;; Definición de las plantillas (estructuras de datos)
;; -----------------------------------------------------------------

(deftemplate state
   "Representa el estado actual del mundo del mono"
   (slot monkey-horizontal (type SYMBOL)) ; Posición horizontal: atdoor, atwindow, middle
   (slot monkey-vertical (type SYMBOL))   ; Posición vertical: onfloor, onbox
   (slot box-position (type SYMBOL))      ; Posición de la caja: atdoor, atwindow, middle
   (slot has-bananas (type SYMBOL))     ; Si el mono tiene los plátanos: yes, no
)