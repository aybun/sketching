#lang sketching
; https://github.com/processing/processing-docs/blob/master/content/examples/Basics/Transform/Rotate/Rotate.pde
; Rotate. 

;  Rotating a square around the Z axis. To get the results
;  you expect, send the rotate function angle parameters that are
;  values between 0 and PI*2 (TWO_PI which is roughly 6.28). If you prefer to 
;  think about angles as degrees (0-360), you can use the radians() 
;  method to convert your values. For example: scale(radians(90))
;  is identical to the statement scale(PI/2). 


(define angle  0.0)
(define jitter 0.0)

(define (setup)
  (size 640 360)
  (frame-rate 60)
  (no-stroke)
  (fill 255)
  (rect-mode 'center))

(define (draw)
  (background 51)

  ; during even-numbered seconds (0, 2, 4, 6...)
  (when (even? (second))
    (:= jitter (random -0.1 0.1)))
  (:= angle (+ angle jitter))
  
  (define c (cos angle))
  (translate (* 1/2 width) (* 1/2 height))
  (rotate c)
  (rect 0 0 180 180))
