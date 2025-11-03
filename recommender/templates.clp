;; --------------------------------------------------------
;; ARCHIVO: templates.clp (Corregido)
;; --------------------------------------------------------

(deftemplate producto
   (slot item-id (default (gensym*))) ; ID Unico de producto
   (slot tipo-producto) ; smartphone, computador, accesorio
   (slot marca)
   (slot modelo)
   (slot color (default NA))
   (slot precio)
   (slot stock (default 0))
   (slot para-modelo (default NA)) ; Para accesorios
)

(deftemplate cliente
   (slot cliente-id (default (gensym*)))
   (slot nombre)
)

(deftemplate tarjetacred
   (slot tarjeta-id (default (gensym*)))
   (slot cliente-id) ; ID del cliente al que pertenece
   (slot banco) ; banamex, bbva, liverpool, amex
   (slot grupo) ; visa, mastercard
   (slot tipo) ; oro, clasica, platino
   (slot exp-date) ; formato "MM-YY"
)

(deftemplate vale
   (slot vale-id (default (gensym*)))
   (slot cliente-id)
   (slot monto (default 0.0))
)

;; --- INICIO DE CAMBIOS ---

(deftemplate item-orden
   ;; Este ahora es un HECHO (fact) por sí mismo
   (slot orden-id) ; ID de la orden a la que pertenece
   (slot item-id)
   (slot qty)
   (slot estado (default "procesando")) ; Para control interno
)

(deftemplate orden-compra
   (slot orden-id (default (gensym*)))
   (slot cliente-id)
   ;; (multislot items) <-- ELIMINADO
   (multislot metodo-pago) ; <-- CORREGIDO de 'slot' a 'multislot'
   (slot total-compra (default 0.0))
   (slot estado (default "procesando")) ; Para control de fases
)

;; --- FIN DE CAMBIOS ---