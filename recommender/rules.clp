;; --------------------------------------------------------
;; ARCHIVO: rules.clp
;; --------------------------------------------------------

(defrule R00a_calcular_subtotal_item
   "Calcula el total sumando cada item de la orden."
   (declare (salience 10))
   ?orden <- (orden-compra (orden-id ?oid) (estado "procesando") (total-compra ?total))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "procesando"))
   (producto (item-id ?iid) (precio ?p))
   =>
   (modify ?orden (total-compra (+ ?total (* ?q ?p))))
   (modify ?item (estado "calculado"))
)

(defrule R00b_marcar_orden_calculada
   "Cuando ya no hay items por procesar, marca la orden como 'calculada'."
   (declare (salience 9))
   ?orden <- (orden-compra (orden-id ?oid) (estado "procesando") (total-compra ?total & :(> ?total 0)))
   (not (item-orden (orden-id ?oid) (estado "procesando")))
   =>
   (modify ?orden (estado "calculada"))
   (printout t "--- Orden " ?oid " ---" crlf)
   (printout t "Total calculado: $" ?total crlf)
)

(defrule actualizar_stock_por_item
   "Actualiza el stock de un item vendido y lo retira."
   (declare (salience -10))
   (orden-compra (orden-id ?oid) (estado "calculada"))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "calculado"))
   ?prod <- (producto (item-id ?iid) (modelo ?m) (stock ?s & :(>= ?s ?q)))
   =>
   (modify ?prod (stock (- ?s ?q)))
   (printout t "Stock Actualizado: " ?m " (Quedan: " (- ?s ?q) ")" crlf)
   (retract ?item)
)