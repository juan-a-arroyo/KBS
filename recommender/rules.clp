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
   (printout t "--- Orden " ?oid " ---" crlf)
)

(defrule marcar_orden_procesada
   "Cuando ya no hay items por procesar, marca la orden como 'procesada'."
   (declare (salience 9))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total & :(> ?total 0)))
   (not (item-orden (orden-id ?oid) (estado "pendiente")))
   =>
   (modify ?orden (estado "procesada"))
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

(defrule aplicar_vale_a_orden
   "Aplica un vale de descuento existente al total de la orden y lo consume."
   (declare (salience 13)) ; Prioridad alta para aplicar antes del cálculo total
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago $?m vale-id ?vid $?) (estado "pendiente") (total-compra ?total))
   ?vale <- (vale (vale-id ?vid) (cliente-id ?cid) (monto ?monto_vale))
   =>
   (modify ?orden (total-compra (- ?total ?monto_vale)))
   (retract ?vale)
   (printout t "--- Vale Aplicado (Orden " ?oid ") ---" crlf)
   (printout t "Descuento de $" ?monto_vale " aplicado. Vale " ?vid " consumido." crlf)
)

(defrule advertencia_stock_insuficiente
   "Advierte si un item en una orden pendiente tiene stock insuficiente y la detiene."
   (declare (salience 20)) ; Prioridad muy alta para detener el procesamiento
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente"))
   (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (modelo ?m) (stock ?s &:(< ?s ?q)))
   =>
   (printout t "--- ALERTA DE STOCK (Orden " ?oid ") ---" crlf)
   (printout t "El producto '" ?m "' (ID: " ?iid ") tiene stock insuficiente (" ?s ") para la cantidad pedida (" ?q ")." crlf)
   (modify ?orden (estado "revision_stock"))
)

;; --- Reglas de Negocio ---
;; --- Reglas de Meses Sin Intereses (MSI) ---

(defrule 12_msi_apple_banorte
   "Ofrece 12 MSI al comprar cualquier dispositipo de la marca Apple con tarjetas Banorte"
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco banorte))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca apple) (modelo ?m) (precio ?p))
   =>
   (bind ?subtotal (* ?q ?p))
   (bind ?mensualidad (/ ?subtotal 12))
   (modify ?orden (total-compra (+ ?total ?subtotal)))
   (modify ?item (subtotal ?subtotal) (estado "msi-procesada"))
   (printout t "--- 12 Meses Sin Intereses (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Apple " ?m crlf)
   (printout t "Subtotal Aplicado: $" ?subtotal crlf)
   (printout t "Mensualidad: $" ?mensualidad crlf)
)

(defrule msi_24_iphone_banamex
   "Ofrece 24 MSI al comprar un iPhone 16 (Pro/Max) con tarjetas Banamex."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco banamex))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca apple) (modelo ?m & "iPhone 16 Pro"|"iPhone 16 Pro Max") (precio ?p))
   =>
   (bind ?subtotal (* ?q ?p))
   (bind ?mensualidad (/ ?subtotal 24))
   (modify ?orden (total-compra (+ ?total ?subtotal)))
   (modify ?item (subtotal ?subtotal) (estado "msi-procesada"))
   (printout t "--- 24 Meses Sin Intereses (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Apple " ?m crlf)
   (printout t "Subtotal Aplicado: $" ?subtotal crlf)
   (printout t "24 Mensualidades de: $" ?mensualidad crlf)
)

(defrule msi_12_galaxy_liverpool_visa
   "Ofrece 12 MSI al comprar un Galaxy S25 Ultra con tarjeta Liverpool VISA."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco liverpool) (grupo visa))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca samsung) (modelo ?m & "Galaxy S25 Ultra") (precio ?p))
   =>
   (bind ?subtotal (* ?q ?p))
   (bind ?mensualidad (/ ?subtotal 12))
   (modify ?orden (total-compra (+ ?total ?subtotal)))
   (modify ?item (subtotal ?subtotal) (estado "msi-procesada"))
   (printout t "--- 12 Meses Sin Intereses (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Samsung " ?m crlf)
   (printout t "Subtotal Aplicado: $" ?subtotal crlf)
   (printout t "12 Mensualidades de: $" ?mensualidad crlf)
)

(defrule msi_18_dell_amex
   "Ofrece 18 MSI en computadoras Dell XPS con AMEX."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco amex))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca dell) (modelo ?m & "XPS 15 (2024)" | "XPS 17 (2024)") (precio ?p))
   =>
   (bind ?subtotal (* ?q ?p))
   (bind ?mensualidad (/ ?subtotal 18))
   (modify ?orden (total-compra (+ ?total ?subtotal)))
   (modify ?item (subtotal ?subtotal) (estado "msi-procesada"))
   (printout t "--- 18 Meses Sin Intereses (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Dell " ?m crlf)
   (printout t "Subtotal Aplicado: $" ?subtotal crlf)
   (printout t "18 Mensualidades de: $" ?mensualidad crlf)
)

(defrule msi_6_pixel_bbva
   "Ofrece 6 MSI en cualquier Google Pixel con tarjetas BBVA."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco bbva))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca google) (tipo-producto smartphone) (modelo ?m) (precio ?p))
   =>
   (bind ?subtotal (* ?q ?p))
   (bind ?mensualidad (/ ?subtotal 6))
   (modify ?orden (total-compra (+ ?total ?subtotal)))
   (modify ?item (subtotal ?subtotal) (estado "msi-procesada"))
   (printout t "--- 6 Meses Sin Intereses (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Google " ?m crlf)
   (printout t "Subtotal Aplicado: $" ?subtotal crlf)
   (printout t "6 Mensualidades de: $" ?mensualidad crlf)
)

;; --- Reglas de Descuento Directo ---

(defrule descuento_asus_mastercard
   "Aplica 5% de descuento al comprar un portátil Asus con tarjeta Mastercard."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (grupo mastercard)) 
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (tipo-producto computador) (marca asus) (modelo ?m) (precio ?p))
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

(defrule descuento_10_thinkpad_santander
   "Aplica 10% de descuento en portátiles Lenovo ThinkPad con Santander."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco santander))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca lenovo) (modelo ?m & "ThinkPad X1 Carbon Gen 11" | "Thinkpad P1 Gen7") (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.10))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 10% Aplicado (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Lenovo " ?m crlf)
   (printout t "Descuento del 10%: $" ?descuento crlf)
   (printout t "Subtotal actualizado a: $" ?subtotal_con_desc crlf)
)

(defrule descuento_15_razer_hsbc
   "Aplica 15% de descuento en portátiles Razer Blade con HSBC."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco hsbc))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca razer) (tipo-producto computador) (modelo ?m) (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.15))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 15% Aplicado (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Razer " ?m crlf)
   (printout t "Descuento del 15%: $" ?descuento crlf)
   (printout t "Subtotal actualizado a: $" ?subtotal_con_desc crlf)
)

(defrule descuento_5_samsung_bbva_platino
   "Aplica 5% de descuento en productos Samsung (computador o smartphone) con BBVA Platino."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (banco bbva) (tipo platino))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca samsung) (tipo-producto "smartphone" | "computador") (modelo ?m) (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.05))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 5% Samsung (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Samsung " ?m crlf)
   (printout t "Descuento del 5%: $" ?descuento crlf)
   (printout t "Subtotal actualizado a: $" ?subtotal_con_desc crlf)
)

(defrule descuento_10_plegables_mastercard
   "Aplica 10% de descuento en smartphones plegables con Mastercard."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago tarjeta-id ?tid) (estado "pendiente") (total-compra ?total))
   (tarjetacred (tarjeta-id ?tid) (cliente-id ?cid) (grupo mastercard))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (tipo-producto smartphone) (modelo ?m & "Galaxy Z Fold6" | "Pixel Fold 2" | "OnePlus Open 2" | "Find N4") (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.10))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 10% Plegable (Orden " ?oid ") ---" crlf)
   (printout t "Producto: " ?m crlf)
   (printout t "Descuento del 10%: $" ?descuento crlf)
)

(defrule descuento_20_surface_contado
   "Aplica 20% de descuento en productos Microsoft Surface en pago de contado."
   (declare (salience 12))
   ?orden <- (orden-compra (orden-id ?oid) (metodo-pago "efectivo") (estado "pendiente") (total-compra ?total))
   ?item <- (item-orden (orden-id ?oid) (item-id ?iid) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid) (marca microsoft) (tipo-producto computador) (modelo ?m) (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.20))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 20% Contado (Orden " ?oid ") ---" crlf)
   (printout t "Producto: Microsoft " ?m crlf)
   (printout t "Descuento del 20%: $" ?descuento crlf)
   (printout t "Subtotal actualizado a: $" ?subtotal_con_desc crlf)
)

;; --- Reglas de Paquetes y Combos (Accesorios) ---

(defrule descuento_15_accesorio_con_smartphone
   "Si el cliente compra un Smartphone, ofrece 15% de descuento en funda y mica para ese modelo."
   (declare (salience 11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id ?iid-smart))
   (producto (item-id ?iid-smart) (tipo-producto smartphone) (modelo ?m-smart))
   ?item-acc <- (item-orden (orden-id ?oid) (item-id ?iid-acc) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid-acc) (tipo-producto accesorio) (para-modelo ?m-smart) (modelo ?m-acc & "Funda de Silicón" | "Protector de Pantalla Templado") (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.15))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item-acc (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 15% en Accesorio (Orden " ?oid ") ---" crlf)
   (printout t "Accesorio: " ?m-acc " para " ?m-smart crlf)
   (printout t "Descuento del 15%: $" ?descuento crlf)
)

(defrule descuento_50_adaptador_macbook
   "En la compra de una MacBook Pro, ofrece 50% de descuento en el adaptador de 140W."
   (declare (salience 11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id ?iid-mac))
   (producto (item-id ?iid-mac) (marca apple) (tipo-producto computador) (modelo "MacBook Pro 14 (M5)" | "MacBook Pro 16 (M3 Max)"))
   ?item-acc <- (item-orden (orden-id ?oid) (item-id "p342") (qty ?q) (estado "pendiente"))
   (producto (item-id "p342") (modelo ?m-acc) (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.50))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item-acc (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 50% en Adaptador Apple (Orden " ?oid ") ---" crlf)
   (printout t "Accesorio: " ?m-acc crlf)
   (printout t "Descuento del 50%: $" ?descuento crlf)
)

(defrule descuento_20_accesorio_razer_con_laptop
   "En la compra de una laptop Razer, ofrece 20% de descuento en accesorios Razer."
   (declare (salience 11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id ?iid-laptop))
   (producto (item-id ?iid-laptop) (marca razer) (tipo-producto computador))
   ?item-acc <- (item-orden (orden-id ?oid) (item-id ?iid-acc) (qty ?q) (estado "pendiente"))
   (producto (item-id ?iid-acc) (tipo-producto accesorio) (marca razer) (modelo ?m-acc) (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.20))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item-acc (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 20% en Accesorio Razer (Orden " ?oid ") ---" crlf)
   (printout t "Accesorio: " ?m-acc crlf)
   (printout t "Descuento del 20%: $" ?descuento crlf)
)

(defrule regalo_funda_laptop_premium
   "Regala la funda de silicón genérica si está en la orden con una laptop de más de 40k."
   (declare (salience 11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id ?iid-laptop))
   (producto (item-id ?iid-laptop) (tipo-producto computador) (precio ?p-laptop & :(> ?p-laptop 40000)))
   ?item-acc <- (item-orden (orden-id ?oid) (item-id ?iid-acc) (qty 1) (estado "pendiente"))
   (producto (item-id ?iid-acc) (tipo-producto accesorio) (marca generica) (modelo "Funda de Silicón") (precio ?p-acc))
   =>
   (modify ?item-acc (subtotal 0.0) (estado "regalo"))
   (printout t "--- Regalo Aplicado (Orden " ?oid ") ---" crlf)
   (printout t "Se regala: Funda de Silicón (Valor: $" ?p-acc ")" crlf)
)

(defrule descuento_25_surface_pen_combo
   "Ofrece 25% de descuento en el Surface Pen Pro al comprar una Surface Laptop Studio 2."
   (declare (salience 11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id "p211"))
   (producto (item-id "p211") (modelo "Surface Laptop Studio 2"))
   ?item-acc <- (item-orden (orden-id ?oid) (item-id "p351") (qty ?q) (estado "pendiente"))
   (producto (item-id "p351") (modelo "Lápiz Óptico Surface Pen Pro") (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.25))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item-acc (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 25% en Surface Pen (Orden " ?oid ") ---" crlf)
   (printout t "Descuento del 25%: $" ?descuento crlf)
)

(defrule descuento_10_monitor_portatil_msi
   "Ofrece 10% de descuento en el Monitor Portátil OLED 17 al comprar la MSI Creator Z17 HX."
   (declare (salience 11))
   ?orden <- (orden-compra (orden-id ?oid) (estado "pendiente") (total-compra ?total))
   (item-orden (orden-id ?oid) (item-id "p216"))
   (producto (item-id "p216") (modelo "Creator Z17 HX"))
   ?item-acc <- (item-orden (orden-id ?oid) (item-id "p356") (qty ?q) (estado "pendiente"))
   (producto (item-id "p356") (modelo "Monitor Portátil OLED 17") (precio ?p))
   =>
   (bind ?descuento (* (* ?q ?p) 0.10))
   (bind ?subtotal_con_desc (- (* ?q ?p) ?descuento))
   (modify ?item-acc (subtotal ?subtotal_con_desc) (estado "descontado"))
   (modify ?orden (total-compra (+ ?total ?subtotal_con_desc)))
   (printout t "--- Descuento 10% en Monitor Portátil (Orden " ?oid ") ---" crlf)
   (printout t "Descuento del 10%: $" ?descuento " aplicado al monitor." crlf)
)

;; --- Reglas de Generación de Vales (Post-Venta) ---

(defrule generar_vale_combo_apple_contado
   "En la compra al contado de una MacBook y un iPhone, 100 pesos en vale por cada 1000 de compra."
   (declare (salience 1))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (metodo-pago "efectivo") (estado "procesada") (total-compra ?total & :(> ?total 1000)))
   (exists 
      (item-orden (orden-id ?oid) (item-id ?iid-mac))
      (producto (item-id ?iid-mac) (marca apple) (tipo-producto computador))
   )
   (exists 
      (item-orden (orden-id ?oid) (item-id ?iid-iphone))
      (producto (item-id ?iid-iphone) (marca apple) (tipo-producto smartphone))
   )
   (not (vale (vale-id =(str-cat "v-o" ?oid))))
   =>
   (bind ?monto_vale (* (round (/ ?total 1000)) 100))
   (if (> ?monto_vale 0) then
       (assert (vale (vale-id (str-cat "v-o" ?oid)) (cliente-id ?cid) (monto ?monto_vale)))
       (printout t "--- Vale Generado (Orden " ?oid ") ---" crlf)
       (printout t "Cliente " ?cid " recibe vale de $" ?monto_vale " por combo Apple al contado." crlf)
   )
)

(defrule generar_vale_computador_caro
   "Al comprar un computador de más de 50,000, genera vale de 1000."
   (declare (salience 1))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (estado "procesada"))
   (exists 
      (item-orden (orden-id ?oid) (item-id ?iid) (subtotal ?sub & :(> ?sub 50000)))
      (producto (item-id ?iid) (tipo-producto computador))
   )
   (not (vale (vale-id =(str-cat "v-c" ?oid))))
   =>
   (assert (vale (vale-id (str-cat "v-c" ?oid)) (cliente-id ?cid) (monto 1000)))
   (printout t "--- Vale Generado (Orden " ?oid ") ---" crlf)
   (printout t "Cliente " ?cid " recibe vale de $1000 por compra de computador premium." crlf)
)

(defrule generar_vale_combo_gaming
   "Al comprar un combo de laptop y accesorio gaming, genera vale de 500."
   (declare (salience 1))
   ?orden <- (orden-compra (orden-id ?oid) (cliente-id ?cid) (estado "procesada"))
   (exists 
      (item-orden (orden-id ?oid) (item-id ?iid-laptop))
      (producto (item-id ?iid-laptop) (marca asus|lenovo|hp|acer|razer) (modelo "ROG Zephyrus G16 (2024)" | "Legion Pro 7i" | "Omen 17" | "Predator Triton 17 X" | "Blade 16 (2024)" | "Blade 18 (2024)"))
   )
   (exists 
      (item-orden (orden-id ?oid) (item-id ?iid-acc))
      (producto (item-id ?iid-acc) (marca hyperx|razer|steelseries))
   )
   (not (vale (vale-id =(str-cat "v-g" ?oid))))
   =>
   (assert (vale (vale-id (str-cat "v-g" ?oid)) (cliente-id ?cid) (monto 500)))
   (printout t "--- Vale Generado (Orden " ?oid ") ---" crlf)
   (printout t "Cliente " ?cid " recibe vale de $500 por combo gaming." crlf)
)