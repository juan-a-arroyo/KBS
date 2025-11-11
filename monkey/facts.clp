;; -----------------------------------------------------------------
;; Archivo: facts.clp
;; Definición de los hechos iniciales (el estado inicial)
;; -----------------------------------------------------------------

(deffacts estado-inicial
   "Define el escenario inicial del problema"
   (estado (monkey-horizontal en-puerta)
          (monkey-vertical en-piso)
          (box-position en-ventana)
          (has-bananas no))
)