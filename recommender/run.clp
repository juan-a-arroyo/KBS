;; --------------------------------------------------------
;; ARCHIVO: run.clp
;; --------------------------------------------------------

(reset)

;; Dispara: aplicar_vale_a_orden
(assert
   (orden-compra (orden-id o1) (cliente-id c1) (metodo-pago vale-id v3))
   (item-orden (orden-id o1) (item-id p101) (qty 1))
)

(run)

;; Dispara: advertencia_stock_insuficiente
(assert
   (orden-compra (orden-id o2) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o2) (item-id p102) (qty 8))
)

(run)

;; Dispara: 12_msi_apple_banorte
(assert
   (orden-compra (orden-id o3) (cliente-id c5) (metodo-pago tarjeta-id t7))
   (item-orden (orden-id o3) (item-id p103) (qty 1))
)

(run)

;; Dispara: msi_24_iphone_banamex
(assert
   (orden-compra (orden-id o4) (cliente-id c1) (metodo-pago tarjeta-id t1))
   (item-orden (orden-id o4) (item-id p104) (qty 1))
)

(run)

;; Dispara: msi_12_galaxy_liverpool_visa
(assert
   (tarjetacred (tarjeta-id t-test1) (cliente-id c1) (banco liverpool) (grupo visa))
   (orden-compra (orden-id o5) (cliente-id c1) (metodo-pago tarjeta-id t-test1))
   (item-orden (orden-id o5) (item-id p101) (qty 1))
)

(run)

;; Dispara: msi_18_dell_amex
(assert
   (orden-compra (orden-id o6) (cliente-id c2) (metodo-pago tarjeta-id t4))
   (item-orden (orden-id o6) (item-id p203) (qty 1))
)

(run)

;; Dispara: msi_6_pixel_bbva
(assert
   (orden-compra (orden-id o7) (cliente-id c2) (metodo-pago tarjeta-id t3))
   (item-orden (orden-id o7) (item-id p105) (qty 1))
)

(run)

;; Dispara: descuento_asus_mastercard
(assert
   (orden-compra (orden-id o8) (cliente-id c1) (metodo-pago tarjeta-id t2))
   (item-orden (orden-id o8) (item-id p209) (qty 1))
)

(run)

;; Dispara: descuento_10_thinkpad_santander
(assert
   (orden-compra (orden-id o9) (cliente-id c3) (metodo-pago tarjeta-id t5))
   (item-orden (orden-id o9) (item-id p207) (qty 1))
)

(run)

;; Dispara: descuento_15_razer_hsbc
(assert
   (orden-compra (orden-id o10) (cliente-id c4) (metodo-pago tarjeta-id t6))
   (item-orden (orden-id o10) (item-id p213) (qty 1))
)

(run)

;; Dispara: descuento_5_samsung_bbva_platino
(assert
   (orden-compra (orden-id o11) (cliente-id c2) (metodo-pago tarjeta-id t3))
   (item-orden (orden-id o11) (item-id p101) (qty 1))
)

(run)

;; Dispara: descuento_10_plegables_mastercard
(assert
   (orden-compra (orden-id o12) (cliente-id c1) (metodo-pago tarjeta-id t2))
   (item-orden (orden-id o12) (item-id p102) (qty 1))
)

(run)

;; Dispara: descuento_20_surface_contado
(assert
   (orden-compra (orden-id o13) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o13) (item-id p211) (qty 1))
)

(run)

;; Dispara: descuento_15_accesorio_con_smartphone
(assert
   (orden-compra (orden-id o14) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o14) (item-id p101) (qty 1))
   (item-orden (orden-id o14) (item-id p301) (qty 1))
)

(run)

;; Dispara: descuento_50_adaptador_macbook
(assert
   (orden-compra (orden-id o15) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o15) (item-id p201) (qty 1))
   (item-orden (orden-id o15) (item-id p342) (qty 1))
)

(run)

;; Dispara: descuento_20_accesorio_razer_con_laptop
(assert
   (orden-compra (orden-id o16) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o16) (item-id p213) (qty 1))
   (item-orden (orden-id o16) (item-id p348) (qty 1))
)

(run)

;; Dispara: regalo_funda_laptop_premium
(assert
   (orden-compra (orden-id o17) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o17) (item-id p201) (qty 1))
   (item-orden (orden-id o17) (item-id p301) (qty 1))
)

(run)

;; Dispara: descuento_25_surface_pen_combo
(assert
   (orden-compra (orden-id o18) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o18) (item-id p211) (qty 1))
   (item-orden (orden-id o18) (item-id p351) (qty 1))
)

(run)

;; Dispara: descuento_10_monitor_portatil_msi
(assert
   (orden-compra (orden-id o19) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o19) (item-id p216) (qty 1))
   (item-orden (orden-id o19) (item-id p356) (qty 1))
)

(run)

;; Dispara: generar_vale_combo_apple_contado (después de procesar)
(assert
   (orden-compra (orden-id o20) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o20) (item-id p201) (qty 1))
   (item-orden (orden-id o20) (item-id p103) (qty 1))
)

(run)

;; Dispara: generar_vale_computador_caro (después de procesar)
(assert
   (orden-compra (orden-id o21) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o21) (item-id p201) (qty 1))
)

(run)

;; Dispara: generar_vale_combo_gaming (después de procesar)
(assert
   (orden-compra (orden-id o22) (cliente-id c1) (metodo-pago "efectivo"))
   (item-orden (orden-id o22) (item-id p208) (qty 1))
   (item-orden (orden-id o22) (item-id p346) (qty 1))
)

(run)

;; Dispara: NINGUNA regla de promoción.
(assert
   (orden-compra (orden-id o23) (cliente-id c3) (metodo-pago tarjeta-id t5))
   (item-orden (orden-id o23) (item-id p107) (qty 1))
   (item-orden (orden-id o23) (item-id p343) (qty 1))
)

(run)
