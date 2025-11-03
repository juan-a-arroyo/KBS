;; -----------------------------------------------------------------
;; Archivo: facts.clp
;; Definición de los hechos iniciales (el estado inicial)
;; -----------------------------------------------------------------

(deffacts initial-state
   "Define el escenario inicial del problema"
   (state (monkey-horizontal atdoor)     ; Mono en la puerta
          (monkey-vertical onfloor)    ; Mono en el suelo
          (box-position atwindow)    ; Caja en la ventana
          (has-bananas no))            ; Mono no tiene los plátanos
)