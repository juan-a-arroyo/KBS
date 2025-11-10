;; --------------------------------------------------------
;; ARCHIVO: rules.clp
;; --------------------------------------------------------

(defrule calcular_subtotal_item
   "Calcula el total sumando cada item de la orden."
   (declare (salience 10))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (precio ?p))
   =>
   (modify ?orden (total-compra (+ ?total (* ?q ?p))))
   (modify ?item (estado "procesada"))
)

(defrule marcar_orden_procesada
   "Cuando ya no hay items por procesar, marca la orden como 'procesada'."
   (declare (salience 9))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total & :(> ?total 0)))
   (not (item-orden (orden-id ?oid) (estado "pendiente")))
   =>
   (modify ?orden (estado "procesada"))
   (printout t "--- Orden " ?oid " ---" crlf)
   (printout t "Total calculado: $" ?total crlf)
)

(defrule actualizar_stock_por_item
   "Actualiza el stock de un item vendido y lo retira."
   (declare (salience 8))
   (orden-compra (orden-id ?oid) (estado "procesada"))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "procesada"))
   ?prod <- (producto (item-id ?iid) (modelo ?m) (stock ?s & :(>= ?s ?q)))
   =>
   (modify ?prod (stock (- ?s ?q)))
   (printout t "Stock Actualizado: " ?m " (Quedan: " (- ?s ?q) ")" crlf)
   (retract ?item)
)