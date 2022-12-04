; zmensi fotku, ale vyzaduje uz otvoreny zdroj fotky
(define (Smaller-photo photo-source folder-source different-target folder-target scale-photos larger-length)
    (let*
		(
			(photo-source-name "")
			(photo-source-width "")
			(photo-source-height "")
			(photo-target-path "")
			(photo-target-width "")
			(photo-target-height "")
		)
		
		; zisti meno fotky bez koncovky
		(set! photo-source-name (car (gimp-image-get-name photo-source)))
		(set! photo-source-name (car (strbreakup photo-source-name ".")))

		; cesta k cielu
		(if (= different-target 1)
			(set! photo-target-path (string-append folder-target "/" photo-source-name ".jpg"))
			(set! photo-target-path (string-append folder-source "/" photo-source-name "_e.jpg"))
		)


		(if (= scale-photos 1)
			(begin

				; zistí rozmery fotky
				(set! photo-source-width (car (gimp-image-width photo-source)))
				(set! photo-source-height (car (gimp-image-height photo-source)))

				; upravi rozmery fotky
				(if (>= photo-source-width photo-source-height)
					(if (> photo-source-width larger-length)
						(begin
							(set! photo-target-width larger-length)
							(set! photo-target-height (/ photo-source-height (/ photo-source-width larger-length)))

							; zmensi fotku
							(gimp-image-scale photo-source photo-target-width photo-target-height)
						)
					)
					(if (> photo-source-height larger-length)
						(begin
							(set! photo-target-height larger-length)
							(set! photo-target-width (/ photo-source-width (/ photo-source-height larger-length)))

							; zmensi fotku
							(gimp-image-scale photo-source photo-target-width photo-target-height)
						)
					)
				)
			)
		)

		; ulozi ciel
		(file-jpeg-save 1 photo-source (car (gimp-image-flatten photo-source)) photo-target-path photo-target-path 0.9 0 1 0 "" 2 1 0 1)

		; zavrie fotku
		(gimp-image-delete photo-source)
	)
)


; Vytvara zmensene fotky
(define (Smaller-photos folder-source different-target folder-target scale-photos larger-length)
	(let*
		(
			(file-names-list (cadr (file-glob (string-append folder-source "/*.[jJ][pP]*[gG]") 1)))
		)
		(map
			; pre kazdu najdenu fotku
			(lambda (file-name)
    			; otvori fotku a zavola funkciu na zmensenie
    			(Smaller-photo (car (file-jpeg-load 1 file-name file-name)) folder-source different-target folder-target scale-photos larger-length)
			)
			file-names-list
		)
	)
	(let*
		(
            (file-names-list (cadr (file-glob (string-append folder-source "/*.[hH][eE][iI][cC]") 1)))
		)
		(map
			 ; pre kazdu najdenu fotku
			(lambda (file-name)
    			; otvori fotku a zavola funkciu na zmensenie
    			(Smaller-photo (car (file-heif-load 1 file-name file-name)) folder-source different-target folder-target scale-photos larger-length)
			)
			file-names-list
		)
	)
)

; Okienko v GIMPe.
(script-fu-register
	"Smaller-photos"
	"<Toolbox>/Xtns/Smaller photos"
	"Creates smaller photos from source folder for every jpg photo.\
	 version 0.5"
	"RadoZaj"
	"copyright 2021, RadoZaj"
	"August 22, 2021"
	""
	SF-DIRNAME "Source folder" "~"
	SF-TOGGLE "Save target to differnet folder." 1
	SF-DIRNAME "Target folder" "~"
	SF-TOGGLE "Scale photos to maximal larger length." 1
	SF-VALUE "Larger length" "3648"
)
