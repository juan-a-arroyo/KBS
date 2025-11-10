;; --------------------------------------------------------
;; ARCHIVO: templates.clp
;; --------------------------------------------------------

(deftemplate producto
  (slot item-id)
  (slot tipo-producto)
  (slot marca)
  (slot modelo)
  (slot color)
  (slot precio (type NUMBER))
  (slot stock (type INTEGER))
  (multislot para-modelo)
)

(deftemplate cliente
  (slot cliente-id)
  (slot nombre)
)

(deftemplate tarjetacred
  (slot tarjeta-id)
  (slot cliente-id)
  (slot banco)
  (slot grupo)
  (slot tipo)
  (slot exp-date)
)

(deftemplate vale
  (slot vale-id)
  (slot cliente-id)
  (slot monto (type NUMBER))
)

(deftemplate orden-compra
    (slot orden-id)
    (slot cliente-id)
    (slot total-compra (default 0.0) (type NUMBER))
    (slot estado (default "pendiente"))
)

(deftemplate item-orden
    (slot orden-id)
    (slot item-id)
    (slot qty (type INTEGER))
    (slot subtotal (default 0.0) (type NUMBER))
    (slot estado (default "pendiente"))
)