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
   (bind ?subtotal (* ?q ?p))
   (modify ?orden (total-compra (+ ?total ?subtotal)))
   (modify ?item (subtotal ?subtotal) (estado "procesada"))
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

;; --- Reglas de Negocio ---

(defrule descuento_asus_mastercard
   "Aplica 5% de descuento al comprar un portátil Asus con tarjeta Mastercard."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (grupo mastercard)) 
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (tipo-producto computador) (marca asus) (precio ?p) (modelo ?m))
   =>
   (bind ?descuento (* (* ?q ?p) 0.05))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento Aplicado (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Asus " ?m crlf)
   (printout t "Descuento del 5% aplicado: $" ?descuento crlf)
   (printout t "Subtotal actualizado a: $" ?subtotal_con_desc crlf)
)