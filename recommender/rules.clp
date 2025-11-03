;; --------------------------------------------------------
;; ARCHIVO: rules.clp (Corregido v3)
;; --------------------------------------------------------

(defrule R00a_calcular_subtotal_item
   "Calcula el total sumando cada item de la orden."
   (declare (salience 10)) ; Prioridad alta
   ?orden <- (orden-compra (orden-id ?oid) (estado "procesando") (total-compra ?total))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "procesando"))
   (producto (item-id ?iid) (precio ?p))
   =>
   (modify ?orden (total-compra (+ ?total (* ?q ?p))))
   (modify ?item (estado "calculado")) ; Marca el item como calculado
)

(defrule R00b_marcar_orden_calculada
   "Cuando ya no hay items por procesar, marca la orden como 'calculada'."
   (declare (salience 9))
   ?orden <- (orden-compra (orden-id ?oid) (estado "procesando") (total-compra ?total & :(> ?total 0)))
   (not (item-orden (orden-id ?oid) (estado "procesando"))) ; No quedan items
   =>
   (modify ?orden (estado "calculada"))
   (printout t "--- Orden " ?oid " ---" crlf)
   (printout t "Total calculado: $" ?total crlf)
)

(defrule actualizar_stock_por_item
   "Actualiza el stock de un item vendido y lo retira."
   (declare (salience -10)) ; Prioridad baja
   (orden-compra (orden-id ?oid) (estado "calculada"))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "calculado"))
   ?prod <- (producto (item-id ?iid) (modelo ?m) (stock ?s & :(>= ?s ?q)))
   =>
   (modify ?prod (stock (- ?s ?q)))
   (printout t "Stock Actualizado: " ?m " (Quedan: " (- ?s ?q) ")" crlf)
   (retract ?item) ; Retira el item de la memoria
)

(defrule limpiar_orden_procesada
   "Retira la orden de la memoria una vez que no tiene items."
   (declare (salience -11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "calculada"))
   (not (item-orden (orden-id ?oid))) ; No hay items de esa orden
   =>
   (printout t "--- Orden " ?oid " Procesada y Cerrada ---" crlf crlf)
   (retract ?orden)
)

(defrule error_falta_de_stock
   "Cancela la orden si no hay stock suficiente para un item."
   (declare (salience 5))
   ?orden <- (orden-compra (orden-id ?oid))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q))
   (producto (item-id ?iid) (modelo ?m) (stock ?s & :(< ?s ?q)))
   =>
   (printout t "ERROR: Compra cancelada. No hay stock para " ?q " " ?m " (Solo hay " ?s ")" crlf)
   (retract ?item) ; Retira los items y la orden
   (retract ?orden)
)

;; --------------------------------------------------------
;; Reglas de Promociones (Sintaxis CORREGIDA)
;; --------------------------------------------------------

(defrule R01_promo_iphone16_banamex
   "iPhone 16 con tarjetas Banamex: 24 MSI"
   (orden-compra (orden-id ?oid) (estado "calculada") (metodo-pago $? tipo tarjeta id-tarjeta ?tid $?))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (marca apple) (modelo iPhone16))
   (tarjetacred (tarjeta-id ?tid) (banco banamex))
   =>
   (printout t "Oferta Aplicada: 24 Meses Sin Intereses en tu iPhone 16 con Banamex." crlf)
)

(defrule R02_promo_note21_liverpool
   "Samsung Note 21 con Liverpool VISA: 12 MSI"
   (orden-compra (orden-id ?oid) (estado "calculada") (metodo-pago $? tipo tarjeta id-tarjeta ?tid $?))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (marca samsung) (modelo "Note 21"))
   (tarjetacred (tarjeta-id ?tid) (banco liverpool) (grupo visa))
   =>
   (printout t "Oferta Aplicada: 12 Meses Sin Intereses en tu Samsung Note 21 con Liverpool VISA." crlf)
)

(defrule R03_promo_combo_mac_iphone_contado_vales
   "MacBook Air + iPhone 16 al contado: $100 en vales por cada $1000"
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (estado "calculada") (metodo-pago $? tipo contado $?) (total-compra ?total & :(> ?total 1000)))
   (item-orden (orden-id ?oid) (item-id ?idMac))
   (producto (item-id ?idMac) (tipo-producto computador) (marca apple) (modelo MacBookAir))
   (item-orden (orden-id ?oid) (item-id ?idIphone))
   (producto (item-id ?idIphone) (tipo-producto smartphone) (marca apple) (modelo iPhone16))
   =>
   ;; --- CORRECCIÓN AQUÍ: Se usa (div ?total 1000) en lugar de (floor (/ ?total 1000)) ---
   (bind ?monto-vale (* (div ?total 1000) 100))
   (printout t "Oferta Aplicada: Recibes un vale de $" ?monto-vale " por tu compra combo (Mac+iPhone) al contado." crlf)
   (assert (vale (cliente-id ?cid) (monto ?monto-vale)))
)

(defrule R04_reco_accesorios_con_smartphone
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (tipo-producto smartphone) (modelo ?modelo))
   (producto (tipo-producto accesorio) (para-modelo ?modelo) (modelo ?tipo) (precio ?p))
   =>
   (bind ?precio-desc (* ?p 0.85))
   (printout t "Recomendacion: Lleva una " ?tipo " para tu " ?modelo " con 15% OFF (Quedaria en: $" ?precio-desc ")" crlf)
)

(defrule R05_clasificar_cliente_mayorista
   (orden-compra (orden-id ?oid) (cliente-id ?cid) (estado "calculada"))
   (item-orden (orden-id ?oid) (qty ?q & :(> ?q 10)))
   =>
   (printout t "Info Cliente: Detectada compra de mayoreo (" ?q " unidades). Cliente " ?cid " es Mayorista." crlf)
)

(defrule R06_clasificar_cliente_menudista
   (orden-compra (orden-id ?oid) (cliente-id ?cid) (estado "calculada"))
   (item-orden (orden-id ?oid) (qty ?q & :(<= ?q 10)))
   (not (item-orden (orden-id ?oid) (qty ?q2 & :(> ?q 10))))
   =>
   (printout t "Info Cliente: Detectada compra de menudeo. Cliente " ?cid " es Menudista." crlf)
)

(defrule R07_reco_mouse_con_laptop
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (tipo-producto computador))
   (producto (item-id ?mid) (tipo-producto accesorio) (modelo "Mouse MX Master") (precio ?p))
   =>
   (printout t "Recomendacion: ¿No necesitas un mouse para tu nueva computadora? (Logitech MX Master por $" ?p ")" crlf)
)

(defrule R08_reco_hub_con_macbook
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (modelo MacBookAir))
   (producto (item-id ?hid) (para-modelo MacBookAir) (modelo "Hub USB-C") (precio ?p))
   =>
   (printout t "Recomendacion: Expande los puertos de tu MacBook Air con un Hub USB-C por $" ?p crlf)
)

(defrule R09_promo_descuento_contado_5mil
   (orden-compra (estado "calculada") (metodo-pago $? tipo contado $?) (total-compra ?total & :(> ?total 5000)))
   =>
   (bind ?descuento (* ?total 0.05)) ;; Solo calculamos el descuento
   (printout t "Descuento Aplicado: 5% por pago de contado en compras mayores a $5000 (Ahorro: $" ?descuento ")" crlf)
   ;; ¡YA NO SE MODIFICA LA ORDEN!
)

(defrule R10_promo_envio_gratis_10mil
   (orden-compra (estado "calculada") (total-compra ?total & :(> ?total 10000)))
   =>
   (printout t "Oferta Aplicada: ¡Tu envío es GRATIS!" crlf)
)

(defrule R11_promo_amex_buen_fin
   (orden-compra (estado "calculada") (metodo-pago $? tipo tarjeta id-tarjeta ?tid $?) (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (banco amex))
   =>
   (bind ?bonif (* ?total 0.10))
   (printout t "Oferta AMEX: Recibiras una bonificacion de $" ?bonif " en tu estado de cuenta." crlf)
)

(defrule R12_promo_paquete_dell_mouse
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?idDell))
   (producto (item-id ?idDell) (modelo XPS15))
   (item-orden (orden-id ?oid) (item-id ?idMouse))
   (producto (item-id ?idMouse) (modelo "Mouse MX Master") (precio ?pMouse))
   =>
   (bind ?desc (* ?pMouse 0.20))
   (printout t "Descuento Aplicado: 20% en tu Mouse MX Master por comprarlo con tu Dell XPS15 (Ahorro: $" ?desc ")" crlf)
)

(defrule R13_reco_garantia_extendida_computador
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (tipo-producto computador) (modelo ?m))
   =>
   (printout t "Recomendacion: Protege tu inversion. ¡Adquiere una Garantia Extendida para tu " ?m "!" crlf)
)

(defrule R14_alerta_stock_bajo
   (declare (salience -12))
   (producto (modelo ?m) (stock ?s & :(< ?s 10) & :(> ?s 0)))
   =>
   (printout t "ALERTA DE INVENTARIO: Stock bajo para " ?m " (Quedan " ?s ")" crlf)
)

(defrule R15_alerta_stock_agotado
   (declare (salience -12))
   (producto (modelo ?m) (stock 0))
   =>
   (printout t "ALERTA DE INVENTARIO: Producto AGOTADO: " ?m crlf)
)

(defrule R16_info_uso_vales
   (orden-compra (cliente-id ?cid) (estado "calculada"))
   (cliente (cliente-id ?cid) (nombre ?n))
   (vale (cliente-id ?cid) (monto ?m & :(> ?m 0)))
   =>
   (printout t "Info Cliente: Hola " ?n ", tienes un vale de $" ?m " disponible para tu proxima compra." crlf)
)

(defrule R17_error_tarjeta_expirada
   (declare (salience 5))
   ?orden <- (orden-compra (orden-id ?oid) (metodo-pago $? tipo tarjeta id-tarjeta ?tid $?))
   (tarjetacred (tarjeta-id ?tid) (banco ?b) (exp-date "11-24"))
   =>
   (printout t "ERROR: Pago Rechazado. La tarjeta del banco " ?b " esta expirada (11-24). Orden " ?oid " cancelada." crlf)
   (retract ?orden)
)

(defrule R18_promo_2x1_micas
   "Promo 2x1 en micas para iPhone 16."
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?pid) (qty ?q & :(>= ?q 2)))
   (producto (item-id ?pid) (modelo "Mica de Cristal") (para-modelo iPhone16) (precio ?p))
   =>
   (bind ?descuento (* (div ?q 2) ?p))
   (printout t "Descuento Aplicado: 2x1 en Micas iPhone 16 (Ahorro: $" ?descuento ")" crlf)
)

(defrule R19_reco_funda_con_mica
   (orden-compra (orden-id ?oid) (estado "calculada"))
   (item-orden (orden-id ?oid) (item-id ?idMica))
   (producto (item-id ?idMica) (modelo "Mica de Cristal") (para-modelo ?m))
   (not (and (item-orden (orden-id ?oid) (item-id ?idFunda))
             (producto (item-id ?idFunda) (modelo "Funda de Silicon") (para-modelo ?m))))
   (producto (item-id ?idFundaTarget) (modelo "Funda de Silicon") (para-modelo ?m))
   =>
   (printout t "Recomendacion: ¡Completa tu proteccion! Agrega una Funda de Silicon para tu " ?m crlf)
)

(defrule R20_promo_pixel_contado
   ?orden <- (orden-compra (orden-id ?oid) (estado "calculada") (metodo-pago $? tipo contado $?) (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id ?pid))
   (producto (item-id ?pid) (marca google) (modelo "Pixel 9") (precio ?p))
   =>
   (bind ?desc (* ?p 0.10))
   (printout t "Descuento Aplicado: 10% en tu Google Pixel por pago de contado (Ahorro: $" ?desc ")" crlf)
   (modify ?orden (total-compra (- ?total ?desc)))
)