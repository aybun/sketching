#lang racket/base

(provide Shape
         create-shape)

(require racket/class
         sketching/graphics
         sketching/transform)

; Shape class to represent storable shapes.
(define Shape
  (class object%
    (define-values (shape-struct
                    finalized
                    visible
                    children
                    child-count
                    vertex-count
                    fill-args
                    stroke-args
                    transformation-matrix) (values  #f ; shape-struct
                                                    #f ; finalized
                                                    #t ; visible
                                                    '() ; children
                                                    0 ; child-count
                                                    0 ; vertex-count
                                                    #f; fill-args
                                                    #f; stroke-args
                                                    (new-matrix 1 0 0 1 0 0) ;transformation
                                        ))
    (define/public (begin-shape [kind 'default])
      (set! finalized #f)
      (set! shape-struct (new-shape kind)))
    (define/public (end-shape [closed? #t])
      (set! shape-struct (finish-shape shape-struct 'end-shape closed?))
      (set! finalized #t))
    (define/public (vertex x y)
      (if (not finalized)
          (begin
            (set! vertex-count (add1 vertex-count))
            (set-shape-rev-points! shape-struct
                                   (cons (cons x y) (shape-rev-points shape-struct))))
          (error 'vertex "vertex can't be added to a finalized shape.")))
    (define/public (get-vertex-count)
      vertex-count)
    (define/public (draw [x 0] [y 0])
      (when (and finalized visible)
        (draw-shape shape-struct x y fill-args stroke-args transformation-matrix)
        (for ([c children])
          (send c draw x y))))
    (define/public (visible?)
      visible)
    (define/public (set-visible v)
      (set! visible v))
    (define/public (get-child-count)
      child-count)
    (define/public (add-child child)
      (set! child-count (add1 child-count))
      (set! children (cons child children)))
    (define/public (get-child index)
      (if (>= index child-count)
          (error 'get-child "index is greater or equal than the number of children: index: ~a, child-count: ~a" index child-count)
          (list-ref children index)))
    (define/public (remove-children)
      (set! child-count 0)
      (set! children '()))
    (define/public (set-fill . args)
      (set! fill-args args))
    (define/public (set-stroke . args)
      (set! stroke-args args))
    (define/public (translate dx dy)
      ; Note: The cairo `multiply` flips the order of a normal multiply.
      (define tra (translation-matrix dx dy))
      (send transformation-matrix multiply transformation-matrix tra))
    (define/public scale
      ; Note: The cairo `multiply` flips the order of a normal multiply.
      (case-lambda
        [(s)     (define sca (scaling-matrix s s))
                 (send transformation-matrix multiply transformation-matrix sca)]
        [(sx sy) (define sca (scaling-matrix sx sy))
                 (send transformation-matrix multiply transformation-matrix sca)]
        [else (error 'scale "incorrect arguments")]))
    (define/public (rotate angle)
      ; Note: The cairo `multiply` flips the order of a normal multiply.
      (define rot (rotation-matrix angle))
      (send transformation-matrix multiply transformation-matrix rot))
    (define/public (reset-matrix)
      (set! transformation-matrix (new-matrix 1 0 0 1 0 0)))
    (super-new)))

(define (create-shape)
  (new Shape))
