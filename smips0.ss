(import (datatype (1)))

(define-datatype program
  [prog listof-insts])

(define-datatype inst 
  [set reg num]
  [st reg1 reg2 offset]
  [ld reg1 reg2 offset]
  [add reg1 reg2 reg3]
  [sub reg1 reg2 reg3]
  [addi reg1 reg2 num]
  [b reg offset]
  [beq reg1 reg2 reg3 offset]
  [bne reg1 reg2 reg3 offset]
  [j reg offset]
  [jal reg offset]
  [exit])

(define-values (data-mem-ref data-mem-set!)
  (let* ([data-mem (make-vector 128)]
         [data-mem-ref 
           (lambda (addr)
             (vector-ref data-mem addr))]
         [data-mem-set! 
           (lambda (addr val)
             (vector-set! data-mem addr val))])
    (values data-mem-ref data-mem-set!)))

(define-values (inst-mem-ref inst-mem-set!)
  (let* ([inst-mem (make-vector 128)]
         [inst-mem-ref 
           (lambda (addr)
             (vector-ref inst-mem addr))]
         [inst-mem-set! 
           (lambda (addr val)
             (vector-set! inst-mem addr val))])
    (values inst-mem-ref inst-mem-set!)))

(define-values (reg-ref reg-set!)
  (let* ([regs (make-vector 8)]
         [reg-ref 
           (lambda (idx)
             (vector-ref regs idx))]
         [reg-set! 
           (lambda (idx val)
             (vector-set! regs idx val))])
    (values reg-ref reg-set!)))

;; load-program : inst-list -> 'over | error
(define load-program
  (lambda (insts line)
    (if (eq? insts '())
        'over
        (if (< line 128)
            (begin 
              (inst-mem-set! line (car insts))
              (load-program (cdr insts) (+ line 1)))))))

;; execute-program : program -> 'over
(define execute-program 
  (lambda (pgm) 
    (program-case pgm 
      [prog (insts) 
        (begin 
          (load-program insts 0)
          (execute-inst 0))])))

;; reg-addressing : number x number -> number
(define reg-addressing
  (lambda (reg offset)
    (+ (reg-ref reg)
       offset)))

;; execute-inst : number -> 'over
(define execute-inst
  (lambda (pc)
    (let ([inst (inst-mem-ref pc)])
      (inst-case inst 
        [set (reg num)
          (begin 
            (reg-set! reg num)
            (execute-inst (+ pc 1)))]
        [st (reg1 reg2 offset)
          (begin 
            (data-mem-set! (reg-addressing reg2 offset)
                           (reg-ref reg1))
            (execute-inst (+ pc 1)))]
        [ld (reg1 reg2 offset)
          (begin
            (reg-set! reg1 
              (data-mem-ref (reg-addressing reg2 offset)))
            (execute-inst (+ pc 1)))]
        [add (reg1 reg2 reg3)
          (begin 
            (reg-set! reg1 
              (+ (reg-ref reg2)
                 (reg-ref reg3)))
            (execute-inst (+ pc 1)))]
        [sub (reg1 reg2 reg3)
          (begin 
            (reg-set! reg1
              (- (reg-ref reg2)
                 (reg-ref reg3)))
            (execute-inst (+ pc 1)))]
        [addi (reg1 reg2 num)
          (begin 
            (reg-set! reg1 
              (+ (reg-ref reg2)
                 num))
            (execute-inst (+ pc 1)))]
        [b (reg offset)
          (execute-inst (+ pc (reg-addressing reg offset)))]
        [beq (reg1 reg2 reg3 offset)
          (if (= (reg-ref reg1)
                 (reg-ref reg2))
              (execute-inst (+ pc (reg-addressing reg3 offset)))
              (execute-inst (+ pc 1)))]
        [bne (reg1 reg2 reg3 offset)
          (if (= (reg-ref reg1)
                 (reg-ref reg2))
              (execute-inst (+ pc 1))
              (execute-inst (+ pc (reg-addressing reg3 offset))))]
        [j (reg offset)
          (execute-inst (reg-addressing reg offset))]
        [jal (reg offset)
          (begin 
            (reg-set! 7 pc)
            (execute-inst (reg-addressing reg offset)))]
        [exit () 
          'over]))))