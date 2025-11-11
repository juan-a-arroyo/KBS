;; --------------------------------------------------------
;; ARCHIVO: run.clp
;; --------------------------------------------------------

(reset)

;; Aplicar vale
(assert
   (orden-compra (orden-id o1) (cliente-id c1) (metodo-pago vale-id v3))
   (item-orden (orden-id o1) (item-id p101) (qty 1))
)

(run)

;; Stock insuficiente
(assert
   (orden-compra (orden-id o2) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o2) (item-id p102) (qty 8))
)

(run)

;; 12 MSI en Apple con Banorte
(assert
   (orden-compra (orden-id o3) (cliente-id c5) (metodo-pago tarjeta-id t7))
   (item-orden (orden-id o3) (item-id p103) (qty 1))
)

(run)

;; 24 MSI en iPhone con Banamex
(assert
   (orden-compra (orden-id o4) (cliente-id c1) (metodo-pago tarjeta-id t1))
   (item-orden (orden-id o4) (item-id p104) (qty 1))
)

(run)

;; 12 MSI en Samsung Galaxy con Liverpool VISA
(assert
   (tarjetacred (tarjeta-id t-test1) (cliente-id c1) (banco liverpool) (grupo visa))
   (orden-compra (orden-id o5) (cliente-id c1) (metodo-pago tarjeta-id t-test1))
   (item-orden (orden-id o5) (item-id p101) (qty 1))
)

(run)

;; 18 MSI en DELL con American Express
(assert
   (orden-compra (orden-id o6) (cliente-id c2) (metodo-pago tarjeta-id t4))
   (item-orden (orden-id o6) (item-id p203) (qty 1))
)

(run)

;; 6 MSI en Google Pixel con BBVA
(assert
   (orden-compra (orden-id o7) (cliente-id c2) (metodo-pago tarjeta-id t3))
   (item-orden (orden-id o7) (item-id p105) (qty 1))
)

(run)

;; 5% de descuento en Laptops Asus con MasterCard
(assert
   (orden-compra (orden-id o8) (cliente-id c1) (metodo-pago tarjeta-id t2))
   (item-orden (orden-id o8) (item-id p209) (qty 1))
)

(run)

;; 10% de descuento en Lenovo Thinkpad con Santander
(assert
   (orden-compra (orden-id o9) (cliente-id c3) (metodo-pago tarjeta-id t5))
   (item-orden (orden-id o9) (item-id p207) (qty 1))
)

(run)

;; 15% de descuento en Razer con HSBC
(assert
   (orden-compra (orden-id o10) (cliente-id c4) (metodo-pago tarjeta-id t6))
   (item-orden (orden-id o10) (item-id p213) (qty 1))
)

(run)

;; 5% de descuento en Samsung con BBVA Platino
(assert
   (orden-compra (orden-id o11) (cliente-id c2) (metodo-pago tarjeta-id t3))
   (item-orden (orden-id o11) (item-id p101) (qty 1))
)

(run)

;; 10% de descuento en plegables con MasterCard
(assert
   (orden-compra (orden-id o12) (cliente-id c1) (metodo-pago tarjeta-id t2))
   (item-orden (orden-id o12) (item-id p102) (qty 1))
)

(run)

;; 20% de descuento en Surface de contado
(assert
   (orden-compra (orden-id o13) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o13) (item-id p211) (qty 1))
)

(run)

;; 15% de descuento en la funda y mica en la compra de un celular
(assert
   (orden-compra (orden-id o14) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o14) (item-id p101) (qty 1))
   (item-orden (orden-id o14) (item-id p301) (qty 1))
)

(run)

;; 50% de descuento en el adaptador de energía de 140w en la compra de una MacBook Pro
(assert
   (orden-compra (orden-id o15) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o15) (item-id p201) (qty 1))
   (item-orden (orden-id o15) (item-id p342) (qty 1))
)

(run)

;; 20% de descuento en accesorios Razer en la compra de una laptop Razer
(assert
   (orden-compra (orden-id o16) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o16) (item-id p213) (qty 1))
   (item-orden (orden-id o16) (item-id p348) (qty 1))
)

(run)

;; Funda de regalo en la compra de una laptop de $40,000 o más
(assert
   (orden-compra (orden-id o17) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o17) (item-id p201) (qty 1))
   (item-orden (orden-id o17) (item-id p301) (qty 1))
)

(run)

;; 25% de descuento en la Surface Pen Pro en la compra de una Surface Laptop Studio 2
(assert
   (orden-compra (orden-id o18) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o18) (item-id p211) (qty 1))
   (item-orden (orden-id o18) (item-id p351) (qty 1))
)

(run)

;; 10% de descuento en el monitor portatil OLED 17 en la compra de la MSI Creator Z17 HX
(assert
   (orden-compra (orden-id o19) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o19) (item-id p216) (qty 1))
   (item-orden (orden-id o19) (item-id p356) (qty 1))
)

(run)

;; En la compra al contado de una MacBook y un iPhone, 100 pesos en vale por cada 1000 de compra
(assert
   (orden-compra (orden-id o20) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o20) (item-id p201) (qty 1))
   (item-orden (orden-id o20) (item-id p103) (qty 1))
)

(run)

;; Al comprar un computador de más de 50,000, genera vale de 1000
(assert
   (orden-compra (orden-id o21) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o21) (item-id p201) (qty 1))
)

(run)

;; Al comprar un combo de laptop y accesorio gaming, genera vale de 500
(assert
   (orden-compra (orden-id o22) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o22) (item-id p208) (qty 1))
   (item-orden (orden-id o22) (item-id p346) (qty 1))
)

(run)

;; Consulta sin promoción
(assert
   (orden-compra (orden-id o23) (cliente-id c3) (metodo-pago tarjeta-id t5))
   (item-orden (orden-id o23) (item-id p107) (qty 1))
   (item-orden (orden-id o23) (item-id p343) (qty 1))
)

(run)
