(import (datatype (1)))

(include "smips0.ss")

;; parse-code : listof-command -> listof-inst
(define parse-code
  (lambda (code)
    (if (eqv? code '())
      '()
      (cons (parse-command (car code))
            (parse-code (cdr code))))))

;; parse-command : command -> inst
(define parse-command
  (lambda (cmd)
    (let ([op (car cmd)]
          [rands (cdr cmd)])
      (cond 
        [(eqv? op 'set)
         (inst-set (regname->regidx (car rands)) (cadr rands))]
        [(eqv? op 'st)
         (inst-st (regname->regidx (car rands))
                  (regname->regidx (cadr rands))
                  (caddr rands))]
        [(eqv? op 'ld)
         (inst-ld (regname->regidx (car rands))
                  (regname->regidx (cadr rands))
                  (caddr rands))]
        [(eqv? op 'add)
         (inst-add (regname->regidx (car rands))
                   (regname->regidx (cadr rands))
                   (regname->regidx (caddr rands)))]
        [(eqv? op 'sub)
         (inst-sub (regname->regidx (car rands))
                   (regname->regidx (cadr rands))
                   (regname->regidx (caddr rands)))]
        [(eqv? op 'addi)
         (inst-addi (regname->regidx (car rands))
                    (regname->regidx (cadr rands))
                    (caddr rands))]
        [(eqv? op 'b)
         (inst-b (regname->regidx (car rands))
                 (cadr rands))]
        [(eqv? op 'beq)
         (inst-beq (regname->regidx (car rands))
                   (regname->regidx (cadr rands))
                   (regname->regidx (caddr rands))
                   (cadddr rands))]
        [(eqv? op 'bne)
         (inst-bne (regname->regidx (car rands))
                   (regname->regidx (cadr rands))
                   (regname->regidx (caddr rands))
                   (cadddr rands))]
        [(eqv? op 'j)
         (inst-j (regname->regidx (car rands))
                 (cadr rands))]
        [(eqv? op 'jal)
         (inst-jal (regname->regidx (car rands))
                   (cadr rands))]
        [(eqv? op 'exit)
         (inst-exit)]))))

;; regname->regidx : symbol -> number
(define regname->regidx
  (lambda (name)
    (cond 
      [(eqv? name 'r0) 0]
      [(eqv? name 'r1) 1]
      [(eqv? name 'r2) 2]
      [(eqv? name 'r3) 3]
      [(eqv? name 'r4) 4]
      [(eqv? name 'r5) 5]
      [(eqv? name 'r6) 6]
      [(eqv? name 'r7) 7])))

(define left-map
  (lambda (f l)
    (if (eqv? l '())
        '()
        (cons (f (car l))
              (left-map f (cdr l))))))

(define show-result 
  (lambda ()
    (define show-data-mem
      (lambda (addr)
          (printf "~s: ~s\n" addr (data-mem-ref addr))))
    (left-map 
      (lambda (offset)
        (show-data-mem (+ offset 120)))
      (iota 8))))

(define file (read))

(execute-program 
  (program-prog (parse-code file)))

(show-result)
