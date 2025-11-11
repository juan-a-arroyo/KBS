;; -----------------------------------------------------------------
;; Archivo: templates.clp
;; Definición de las plantillas (estructuras de datos)
;; -----------------------------------------------------------------

(deftemplate estado
   "Representa el estado actual del mundo del mono"
   (slot monkey-horizontal (type SYMBOL))
   (slot monkey-vertical (type SYMBOL))
   (slot box-position (type SYMBOL))
   (slot has-bananas (type SYMBOL))
)