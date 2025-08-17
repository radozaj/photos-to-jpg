#!/usr/bin/env gimp-script-fu-interpreter-3.0
;; smaller-photos.scm – GIMP 3 / Script-Fu v3

(define (last lst)
  (if (null? (cdr lst))
      (car lst)
      (last (cdr lst))
  )
)


;; -------------------------------------------------------------------
;;  Zmenšenie jednej fotky
;; -------------------------------------------------------------------
(define (Smaller-photo photo-source file-name folder-source different-target folder-target scale-photos longer-side idx total)
  (let*
    (
      (photo-source-name "")
      (photo-source-width 0)
      (photo-source-height 0)
      (photo-target-path "")
      (photo-target-width 0)
      (photo-target-height 0)
    )
    
    ; zisti meno fotky bez koncovky
    (set! photo-source-name (last (strbreakup file-name "/"))) ; "image.JPG"
    (set! photo-source-name (car (strbreakup photo-source-name "."))) ; "image"

    ; cesta k cielu
    (if (= different-target 1)
      (set! photo-target-path (string-append folder-target "/" photo-source-name ".jpg"))
      (set! photo-target-path (string-append folder-source "/" photo-source-name "_e.jpg"))
    )

    (gimp-message (string-append ">> [" (number->string idx) "/" (number->string total) "] " photo-source-name ".jpg"))


    (if (= scale-photos 1)
      (begin

        ; zistí rozmery fotky
        (set! photo-source-width (gimp-image-get-width photo-source))
        (set! photo-source-height (gimp-image-get-height photo-source))

        ; upravi rozmery fotky
        (if (>= photo-source-width photo-source-height)
          (if (> photo-source-width longer-side)
            (begin
              (set! photo-target-width longer-side)
              (set! photo-target-height
                (inexact->exact
                  (round (/ (* 1.0 photo-source-height) (/ (* 1.0 photo-source-width) longer-side)))))

              ; zmensi fotku
              (gimp-image-scale photo-source photo-target-width photo-target-height)
            )
          )
          (if (> photo-source-height longer-side)
            (begin
              (set! photo-target-height longer-side)
              (set! photo-target-width
                (inexact->exact
                  (round (/ (* 1.0 photo-source-width) (/ (* 1.0 photo-source-height) longer-side)))))

              ; zmensi fotku
              (gimp-image-scale photo-source photo-target-width photo-target-height)
            )
          )
        )
      )
    )

    ; ulozi ciel
    (gimp-image-flatten photo-source)
    (gimp-file-save RUN-NONINTERACTIVE photo-source photo-target-path #f)

    ; zavrie fotku
    (gimp-image-delete photo-source)
  )
)


;; -------------------------------------------------------------------
;;  Spracovať celý priečinok
;; -------------------------------------------------------------------
(define (Smaller-photos folder-source different-target folder-target scale-photos longer-side)
  (script-fu-use-v3)
  (gimp-message (string-append ">> Running Smaller-photos"))

  (let*
    (
      (jpg-files (file-glob #:pattern (string-append folder-source "/*.[jJ][pP]*[gG]") #:filename-encoding TRUE))
      (heic-files (file-glob #:pattern (string-append folder-source "/*.[hH][eE][iI][cC]") #:filename-encoding TRUE))
      (total (+ (length jpg-files) (length heic-files)))
      (i 0)
    )
    (for-each
      (lambda (file-name)
        (set! i (+ i 1))
        (let
          (
            (image (file-jpeg-load #:run-mode RUN-NONINTERACTIVE #:file file-name))
          )
          (Smaller-photo image file-name folder-source different-target folder-target scale-photos longer-side i total)
        )
      ) jpg-files)

    (for-each
      (lambda (file-name)
        (set! i (+ i 1))  
        (let
          (
            (image (file-heif-load #:run-mode RUN-NONINTERACTIVE #:file file-name))
          )
          (Smaller-photo image file-name folder-source different-target folder-target scale-photos longer-side i total)
        )
      ) heic-files)
  )
)



;; -------------------------------------------------------------------
;;  Registrácia
;; -------------------------------------------------------------------
(script-fu-register-procedure
 "Smaller-photos"
 "Smaller photos…"
 "Batch-resizes all JPG/HEIC files in a folder; optional separate target folder and scaling."
 "RadoZaj"
 "© 2025 RadoZaj"
 SF-DIRNAME "Source folder" "~"
 SF-TOGGLE "Save target to different folder" 1
 SF-DIRNAME "Target folder" "~"
 SF-TOGGLE "Scale photos to maximal longer side" 1
 SF-ADJUSTMENT "Longer side (px)" '(3648 1 100000 1 10 0 1)  ; 3648px, other numbers are for UX
)

(script-fu-menu-register "Smaller-photos" "<Image>/File/Batch")
