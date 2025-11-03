;; --------------------------------------------------------
;; ARCHIVO: facts.clp
;; DEFINE: Los hechos iniciales (inventario, clientes)
;; --------------------------------------------------------

(deffacts inventario-y-productos
   ;; --- Smartphones ---
   (producto (item-id p101) (tipo-producto smartphone) (marca apple) (modelo iPhone16) (color rojo) (precio 27000) (stock 50))
   (producto (item-id p102) (tipo-producto smartphone) (marca samsung) (modelo "Note 21") (color negro) (precio 22000) (stock 30))
   (producto (item-id p103) (tipo-producto smartphone) (marca google) (modelo "Pixel 9") (color blanco) (precio 20000) (stock 25))

   ;; --- Computadoras ---
   (producto (item-id p201) (tipo-producto computador) (marca apple) (modelo MacBookAir) (color gris) (precio 47000) (stock 20))
   (producto (item-id p202) (tipo-producto computador) (marca dell) (modelo XPS15) (color plata) (precio 35000) (stock 15))

   ;; --- Accesorios ---
   (producto (item-id p301) (tipo-producto accesorio) (para-modelo iPhone16) (marca generica) (modelo "Funda de Silicon") (precio 500) (stock 100))
   (producto (item-id p302) (tipo-producto accesorio) (para-modelo iPhone16) (marca generica) (modelo "Mica de Cristal") (precio 300) (stock 100))
   (producto (item-id p303) (tipo-producto accesorio) (para-modelo "Note 21") (marca generica) (modelo "Funda de Piel") (precio 450) (stock 50))
   (producto (item-id p304) (tipo-producto accesorio) (para-modelo "MacBookAir") (marca generica) (modelo "Hub USB-C") (precio 800) (stock 40))
   (producto (item-id p305) (tipo-producto accesorio) (para-modelo NA) (marca logitech) (modelo "Mouse MX Master") (precio 1500) (stock 30))
)

(deffacts clientes-y-tarjetas
   ;; --- Clientes ---
   (cliente (cliente-id c1) (nombre "Juan Perez"))
   (cliente (cliente-id c2) (nombre "Maria Garcia"))

   ;; --- Tarjetas ---
   (tarjetacred (tarjeta-id t1) (cliente-id c1) (banco banamex) (grupo visa) (tipo oro) (exp-date "12-25"))
   (tarjetacred (tarjeta-id t2) (cliente-id c1) (banco liverpool) (grupo visa) (tipo clasica) (exp-date "06-26"))
   (tarjetacred (tarjeta-id t3) (cliente-id c2) (banco bbva) (grupo mastercard) (tipo platino) (exp-date "01-27"))
   (tarjetacred (tarjeta-id t4) (cliente-id c2) (banco amex) (grupo NA) (tipo oro) (exp-date "11-24"))

   ;; --- Vales ---
   (vale (vale-id v1) (cliente-id c2) (monto 250))
)