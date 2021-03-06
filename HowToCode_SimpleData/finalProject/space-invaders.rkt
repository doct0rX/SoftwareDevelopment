;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;
;; This Game needs some fixes with code syntax. and finish the rest of functions and good to GO;
;; Delete first 3 lines after finishing the game implementation.
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))



;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))



(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; =================
;; Functions:

;; Game -> Game
;; start the world with (main empty)
;; 
(define (main g)
  (big-bang g                    ; Game
    (on-tick   tock)     ; Game -> Game
    (to-draw   render)   ; Game -> Image
    (stop-when ...)      ; Game -> Boolean
    (on-mouse  ...)      ; Game Integer Integer MouseEvent -> WS
    (on-key    ...)))    ; Game KeyEvent -> Game


;; Game -> Game
;; produce the next invader and update the current invaders position

(check-expect (tock G0) (make-game (cons (make-invader (+ INVADER-X-SPEED 0) (+ INVADER-Y-SPEED 0)  11) empty) empty T0))
(check-expect (tock G1) (make-game (cons (make-invader (+ INVADER-X-SPEED 0) (+ INVADER-Y-SPEED 0) -11) empty) empty T1))
(check-expect (tock G2)
              (make-game (cons (make-invader (+ INVADER-X-SPEED 150) (+ INVADER-Y-SPEED 100) 12) (cons (make-invader (+ INVADER-X-SPEED 0) (+ INVADER-Y-SPEED 0)  11) empty))
                         (list (make-missile 150 (- MISSILE-SPEED 300))) T1))
(check-expect (tock G3)
              (make-game (cons (make-invader (+ INVADER-X-SPEED 150) (+ INVADER-Y-SPEED 100) 12) (cons (make-invader (+ INVADER-X-SPEED 150) (+ INVADER-Y-SPEED HEIGHT) -10) (cons (make-invader (+ INVADER-X-SPEED 0) (+ INVADER-Y-SPEED 0)  11) empty)))
                         (list (make-missile 150 (- MISSILE-SPEED 300))) T1))

;(define (tock g) (make-game empty empty T0))  ;stub

;<templates from Game constract
(define (tock g)
  (make-game (move-invaders (bounce-invader (increase-invader (game-invaders g))))
             (lunch-missile (game-missiles g))
             (game-tank g)))


;; ListOfInvaders -> ListOfInvaders
;; produce one more invader to current state of the game

(check-expect (increase-invader empty) (cons (make-invader INVADER-X-SPEED INVADER-X-SPEED 11) empty))
(check-expect (increase-invader (list I1)) (cons I1 (cons (make-invader INVADER-X-SPEED INVADER-X-SPEED 11) empty)))
(check-expect (increase-invader (list I1)) (append (list I1) (list (make-invader INVADER-X-SPEED INVADER-X-SPEED 11))))

;(define (increase-invader loi) loi)  ;stub

;<template from invader

(define (increase-invader invader)
  (append invader (list (make-invader INVADER-X-SPEED INVADER-X-SPEED 11))))


(define (lunch-missile lom) lom) ;; will be removed ; stub


;; ListOfInvaders -> ListOfInvaders
;; keep track of invaders in the width of screen
;;     bounce the invader if hit the side of MTS

;(check-expect (bounce-invader empty) empty)
;(check-expect (bounce-invader (list (make-invader WIDTH 100 12))) (list (make-invader WIDTH 100 12)))
;(check-expect (bounce-invader (list (make-invader (+ WIDTH INVADER-X-SPEED) 100 12))) (list (make-invader WIDTH 100 -12)))
;(check-expect (bounce-invader (list I1 (make-invader (+ WIDTH INVADER-X-SPEED) 100 12))) (list I1 (make-invader WIDTH 100 -12)))

;; This Function Still not implemented

(define (bounce-invader loi) loi)  ;stub

#;
(define (bounce-invader loi)
  (cond [(empty? loi) empty]
        [cond 
          [(> (invader-x (first loi)) WIDTH) (make-invader (invader-x (first loi)) (invader-y (first loi)) (- (invader-dx (first loi))))]
          [(< (invader-x (first loi))     0) (make-invader (invader-x (first loi)) (invader-y (first loi)) (- (invader-dx (first loi))))]
          [(<= (invader-x (first loi)) WIDTH) (make-invader (invader-x (first loi)) (invader-y (first loi)) (invader-dx (first loi)))]]
        (bounce-invader (rest loi))))
#;
(define (bounce-invader loi)
  (cond [(empty? loi) empty]
        [else
         (> (invader-x (first loi)) WIDTH) (make-invader (invader-x (first loi)) (invader-y (first loi)) (- (invader-dx (first loi))))
         (make-invader (invader-x (first loi)) (invader-y (first loi)) (- (invader-dx (first loi))))
         (bounce-invader (rest loi))]))


;; ListOfInvaders -> ListOfInvaders
;; produce next invaders x, y position

(check-expect (move-invaders empty) empty)
(check-expect (move-invaders (list I1)) (list (make-invader (+ INVADER-X-SPEED 150) (+ INVADER-Y-SPEED 100) 12)))
(check-expect (move-invaders (list I1 I2)) (list (make-invader (+ INVADER-X-SPEED 150) (+ INVADER-Y-SPEED 100) 12) (make-invader (+ INVADER-X-SPEED 150) (+ INVADER-Y-SPEED HEIGHT) -10)))

;(define (move-invaders loi) loi)  ;stub

(define (move-invaders loi)
  (cond [(empty? loi) empty]
        [else
         (make-invader (+ (invader-x (first loi)) INVADER-X-SPEED) (+ (invader-y (first loi)) INVADER-Y-SPEED) (invader-dx (first loi)))
              (move-invaders (rest loi))]))


;; Game -> Image
;; render current state of the game on MTS at proper x, y position 
;; !!!
(define (render g) ...)


;; Game KeyEvent -> Game
;; Space bar for lunching the missle
;; Left  arrow -- Move  left
;; Right arrow -- move right
;; !!!
(define (handle-key g ke)
  (cond [(key=? ke " ") (... g)]
        [else 
         (... g)]))