.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "DX-Ball",0
area_width EQU 1200
area_height EQU 600
area DD 0
buttom_x EQU 5
buttom_y EQU 5
buttom_size EQU 590
buttom_sizey EQU 800
dimensiune_patrat EQU 40
coloana_max EQU 19
linie_max EQU 14
x0 EQU 0
y0 EQU 0
symbol_width EQU 10
symbol_height EQU 20
simbol_width EQU 40
simbol_height EQU 40
sageti_width EQU 40
sageti_height EQU 40
x_paleta DD 320
x_minge DD 360
y_minge DD 520
stangasaudreapta DD 0
stangadreaptacazut DD 0
bloc11_vizibilitate DD 0
bloc12_vizibilitate DD 0
bloc21_vizibilitate DD 0
bloc22_vizibilitate DD 0
bloc23_vizibilitate DD 0
bloc24_vizibilitate DD 0
bloc31_vizibilitate DD 0
bloc32_vizibilitate DD 0
bloc33_vizibilitate DD 0
bloc34_vizibilitate DD 0
bloc35_vizibilitate DD 0
bloc36_vizibilitate DD 0
bloc41_vizibilitate DD 0
bloc42_vizibilitate DD 0
bloc43_vizibilitate DD 0
bloc44_vizibilitate DD 0
bloc45_vizibilitate DD 0
bloc46_vizibilitate DD 0

scor DD 0
upordown DD 0
nr_jump EQU 20

map DD 3, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 3 
	DD 3, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 3
	DD 3, 3, 3, 3, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 1, 1, 4, 1, 1, 4, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	DD 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20


include digits.inc
include letters.inc
include symbols.inc
include sageti.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_sageti proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	sub eax,'0'
	lea esi, sageti
	mov ebx, sageti_width
	mul ebx
	mov ebx, sageti_height
	mul ebx
	add esi, eax
	mov ecx, sageti_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, sageti_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, sageti_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_negru
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_negru:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret

make_sageti endp

make_simbol proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	lea esi, symbols
	sub eax, 0

draw_text:
	mov ebx, simbol_width
	mul ebx
	mov ebx, simbol_height
	mul ebx
	add esi, eax
	mov ecx, simbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, simbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, simbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_albastru
	cmp byte ptr [esi], 3
	je simbol_pixel_negru
	cmp byte ptr [esi], 2
	je simbol_pixel_rosu
	cmp byte ptr [esi], 1
	je simbol_pixel_albastru_bila
	
simbol_pixel_albastru:
	mov dword ptr [edi], 00077b3h
	jmp simbol_pixel_next
	simbol_pixel_negru:
	mov dword ptr [edi], 000264dh
	jmp simbol_pixel_next
	simbol_pixel_albastru_bila:
	mov dword ptr [edi], 0e6e600h
	jmp simbol_pixel_next
	simbol_pixel_rosu:
	mov dword ptr [edi], 00FF0000h
	jmp simbol_pixel_next
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_simbol endp

make_simbol_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_simbol
	add esp, 16
endm


; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_sageti_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_sageti
	add esp, 16
endm

linie_verticala macro x, y, len, color
local bucla_linie_ver
	mov eax,y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax, ebx
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_linie_ver:
	mov dword ptr[eax], color
	add eax,4*area_width
	loop bucla_linie_ver
endm

linie_orizontala macro x, y, len, color
local bucla_linie_oz
	mov eax,y
	mov ebx, area_width
	mul ebx
	mov ebx, x
	add eax, ebx
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_linie_oz:
	mov dword ptr[eax], color
	add eax,4
	loop bucla_linie_oz
endm

build_map macro x0, y0
	xor  ecx, ecx
	xor  ebp, ebp
	xor  edi, edi
	xor  esi, esi
compare:
cmp ecx, linie_max
jg final
cmp ebp, coloana_max
jg initializare
mov eax, ecx
mov ebx, nr_jump
mul ebx
add eax, ebp
mov ebx, 4
mul ebx
mov ebx, eax
mov eax, ebp
mov esi, dimensiune_patrat
mul esi
add eax, x0
mov esi, eax
mov eax, ecx
mov edi, dimensiune_patrat
mul edi
add eax, y0
mov edi, eax
make_simbol_macro map[ebx],area,esi,edi
add ebp,1
jmp compare

initializare:
mov ebp,0
add ecx,1
jmp compare
final:
xor ecx,ecx
xor ebp,ebp
xor eax,eax
xor edi,edi
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0ffffffh
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
verificare_left:
	mov eax, [ebp+arg2]
	cmp eax,950
	jl verificare_dreapta
	cmp eax,990
	jg verificare_dreapta
	mov eax, [ebp+arg3]
	cmp eax,520
	jl verificare_dreapta
	cmp eax,560
	jg verificare_dreapta
	cmp x_paleta, 0
	je apare_dreapta
	mov eax, x_paleta
	make_simbol_macro 3,area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	sub x_paleta, 40
	mov eax, x_paleta
	make_simbol_macro 2,area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	jmp verificare_dreapta
	
apare_dreapta:
mov eax, x_paleta
	make_simbol_macro 3,area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	mov x_paleta, 680
	mov eax, x_paleta
	make_simbol_macro 2,area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	
verificare_dreapta:
	mov eax, [ebp+arg2]
	cmp eax, 1010
	jl evt_timer
	cmp eax, 1050
	jg evt_timer
	mov eax, [ebp+arg3]
	cmp eax, 520
	jl evt_timer
	cmp eax,560
	jg evt_timer
	cmp x_paleta, 680
	je apare_stanga
	mov eax, x_paleta
	make_simbol_macro 3,area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	add x_paleta, 40
	mov eax, x_paleta
	make_simbol_macro 2,area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	jmp evt_timer
	
apare_stanga:
mov eax, x_paleta
	make_simbol_macro 3,area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	add eax, 40
	make_simbol_macro 3, area, eax, 560
	mov x_paleta, 0
	mov eax, x_paleta
	make_simbol_macro 2,area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	add eax, 40
	make_simbol_macro 2, area, eax, 560
	
evt_timer:
    cmp counter, 0
	je build_themap
	inc counter
	cmp stangadreaptacazut, 0
	je cade_minge
	cmp stangadreaptacazut, 1
	je cade_minge_stanga
	cmp stangadreaptacazut, 2
	je cade_minge_dreapta
	cmp stangasaudreapta, 0
	je urca_minge
	cmp stangasaudreapta, 1
	je urca_minge_stanga
	cmp stangasaudreapta, 2
	je urca_minge_dreapta
	
	
	cade_minge:
	cmp y_minge, 520
	jne mingeaejosdarnupepaleta
	mov eax, x_paleta
	cmp x_minge, eax
	je urca_minge_stanga
	add eax, 40
	cmp x_minge, eax
	je urca_minge
	add eax, 40
	cmp x_minge, eax
	je urca_minge_dreapta
	mingeaejosdarnupepaleta:
	mov upordown, 0
	mov stangasaudreapta, 4
	make_simbol_macro 3, area, x_minge, y_minge
	add y_minge, 40
	make_simbol_macro 0, area, x_minge, y_minge
	cmp y_minge, 560
	je you_lost
	; cmp y_minge, 120
	; je bloc11
	; cmp y_minge, 80
	; je bloc21
	; cmp y_minge, 40
	; je bloc31
	; cmp y_minge, 0
    ; je bloc41
	jmp afisare_litere
	
	urca_minge:
	cmp stangasaudreapta, 1
	je urca_minge_stanga
	cmp stangasaudreapta, 2
	je urca_minge_dreapta
	mov stangasaudreapta, 0 
	mov stangadreaptacazut, 4
	
	cmp y_minge, 0
	je cade_minge
	mov upordown, 1
	mov stangasaudreapta, 0
	
	make_simbol_macro 3, area, x_minge, y_minge
	sub y_minge, 40
	make_simbol_macro 0, area, x_minge, y_minge
	cmp y_minge, 160
	je bloc11
	cmp y_minge, 120
	je bloc21
	cmp y_minge, 80
	je bloc31
	cmp y_minge, 40
    je bloc41
	jmp afisare_litere

	
	bloc11:
	cmp bloc11_vizibilitate, 1
	je bloc12
	mov eax, 280
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg urca_minge
	make_simbol_macro 3, area, 280, 120
	make_simbol_macro 3, area, 320, 120
	make_simbol_macro 3, area, 360, 120
	inc scor
	mov bloc11_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc12:
	cmp bloc12_vizibilitate, 1
	je urca_minge
	mov eax, 400
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg urca_minge
	make_simbol_macro 3, area, 400, 120
	make_simbol_macro 3, area, 440, 120
	make_simbol_macro 3, area, 480, 120
	inc scor
	mov bloc12_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc21:
	cmp bloc21_vizibilitate, 1
	je bloc22
	mov eax, 160
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc22
	make_simbol_macro 3, area, 160, 80
	make_simbol_macro 3, area, 200, 80
	make_simbol_macro 3, area, 240, 80
	inc scor
	mov bloc21_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc22:
	cmp bloc22_vizibilitate, 1
	je bloc23
	mov eax, 280
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc23
	make_simbol_macro 3, area, 280, 80
	make_simbol_macro 3, area, 320, 80
	make_simbol_macro 3, area, 360, 80
	inc scor
	mov bloc22_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc23:
	cmp bloc23_vizibilitate, 1
	je bloc24
	mov eax, 400
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc24
	make_simbol_macro 3, area, 400, 80
	make_simbol_macro 3, area, 440, 80
	make_simbol_macro 3, area, 480, 80
	inc scor
	mov bloc23_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc24:
	cmp bloc24_vizibilitate, 1
	je urca_minge
	mov eax, 520
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg urca_minge
	make_simbol_macro 3, area, 520, 80
	make_simbol_macro 3, area, 560, 80
	make_simbol_macro 3, area, 600, 80
	inc scor
	mov bloc24_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc31:
	cmp bloc31_vizibilitate, 1
	je bloc32
	mov eax, 40
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc32
	make_simbol_macro 3, area, 40, 40
	make_simbol_macro 3, area, 80, 40
	make_simbol_macro 3, area, 120, 40
	inc scor
	mov bloc31_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc32:
	cmp bloc32_vizibilitate, 1
	je bloc33
	mov eax, 160
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc33
	make_simbol_macro 3, area, 160, 40
	make_simbol_macro 3, area, 200, 40
	make_simbol_macro 3, area, 240, 40
	inc scor
	mov bloc32_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc33:
	cmp bloc33_vizibilitate, 1
	je bloc34
	mov eax, 280
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc34
	make_simbol_macro 3, area, 280, 40
	make_simbol_macro 3, area, 320, 40
	make_simbol_macro 3, area, 360, 40
	inc scor
	mov bloc33_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc34:
	cmp bloc34_vizibilitate, 1
	je bloc35
	mov eax, 400
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc35
	make_simbol_macro 3, area, 400, 40
	make_simbol_macro 3, area, 440, 40
	make_simbol_macro 3, area, 480, 40
	inc scor
	mov bloc34_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc35:
	cmp bloc35_vizibilitate, 1
	je bloc36
	mov eax, 520
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc36
	make_simbol_macro 3, area, 520, 40
	make_simbol_macro 3, area, 560, 40
	make_simbol_macro 3, area, 600, 40
	inc scor
	mov bloc35_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc36:
	cmp bloc36_vizibilitate, 1
	je urca_minge
	mov eax, 640
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg urca_minge
	make_simbol_macro 3, area, 640, 40
	make_simbol_macro 3, area, 680, 40
	make_simbol_macro 3, area, 720, 40
	inc scor
	mov bloc36_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc41:
	cmp bloc41_vizibilitate, 1
	je bloc42
	mov eax, 40
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc42
	make_simbol_macro 3, area, 40, 0
	make_simbol_macro 3, area, 80, 0
	make_simbol_macro 3, area, 120, 0
	inc scor
	mov bloc41_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc42:
	cmp bloc42_vizibilitate, 1
	je bloc43
	mov eax, 160
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc43
	make_simbol_macro 3, area, 160, 0
	make_simbol_macro 3, area, 200, 0
	make_simbol_macro 3, area, 240, 0
	inc scor
	mov bloc42_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc43:
	cmp bloc43_vizibilitate, 1
	je bloc44
	mov eax, 280
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc44
	make_simbol_macro 3, area, 280, 0
	make_simbol_macro 3, area, 320, 0
	make_simbol_macro 3, area, 360, 0
	inc scor
	mov bloc43_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc44:
	cmp bloc44_vizibilitate, 1
	je bloc45
	mov eax, 400
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc45
	make_simbol_macro 3, area, 400, 0
	make_simbol_macro 3, area, 440, 0
	make_simbol_macro 3, area, 480, 0
	inc scor
	mov bloc44_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc45:
	cmp bloc45_vizibilitate, 1
	je bloc46
	mov eax, 520
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg bloc46
	make_simbol_macro 3, area, 520, 0
	make_simbol_macro 3, area, 560, 0
	make_simbol_macro 3, area, 600, 0
	inc scor
	mov bloc45_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	bloc46:
	cmp bloc46_vizibilitate, 1
	je urca_minge
	mov eax, 640
	cmp x_minge, eax
	jl urca_minge
	add eax, 80
	cmp x_minge, eax
	jg urca_minge
	make_simbol_macro 3, area, 640, 0
	make_simbol_macro 3, area, 680, 0
	make_simbol_macro 3, area, 720, 0
	inc scor
	mov bloc46_vizibilitate, 1
	cmp stangasaudreapta, 0
	je cade_minge
	cmp stangasaudreapta, 1
	je cade_minge_stanga
	cmp stangasaudreapta, 2
	je cade_minge_dreapta
	
	urca_minge_stanga:
	cmp y_minge, 0
	je cade_minge_stanga
	cmp x_minge, 0
	je urca_minge_dreapta
	mov stangasaudreapta, 1
	mov upordown, 1
	mov stangadreaptacazut, 4
	make_simbol_macro 3, area, x_minge, y_minge
	sub y_minge, 40
	sub x_minge, 40
	make_simbol_macro 0, area, x_minge, y_minge
	cmp y_minge, 160
	je bloc11
	cmp y_minge, 120
	je bloc21
	cmp y_minge, 80
	je bloc31
	cmp y_minge, 40
    je bloc41
	jmp afisare_litere
	
	urca_minge_dreapta:
	cmp y_minge, 0
	je cade_minge_dreapta
	cmp x_minge, 760
	je urca_minge_stanga
	mov stangasaudreapta, 2
	mov upordown, 1
	mov stangadreaptacazut, 4
	make_simbol_macro 3, area, x_minge, y_minge
	sub y_minge, 40
	add x_minge, 40
	make_simbol_macro 0, area, x_minge, y_minge
	cmp y_minge, 160
	je bloc11
	cmp y_minge, 120
	je bloc21
	cmp y_minge, 80
	je bloc31
	cmp y_minge, 40
    je bloc41
	jmp afisare_litere
	
	cade_minge_stanga:
	mov stangadreaptacazut, 1
	mov stangasaudreapta, 4
	cmp x_minge, 0
	je cade_minge_dreapta
	cmp y_minge, 520
	jne mingeinaer
	cmp x_minge, 0
	je cade_minge_dreapta
	mov eax, x_paleta
	cmp x_minge, eax
	je urca_minge_stanga
	add eax, 40
	cmp x_minge, eax
	je urca_minge
	add eax, 40
	cmp x_minge, eax
	je urca_minge_dreapta
	mingeinaer:
    make_simbol_macro 3, area, x_minge, y_minge
	add y_minge, 40
	sub x_minge, 40
	make_simbol_macro 0, area, x_minge, y_minge
	cmp y_minge, 560
	je you_lost
	; cmp y_minge, 120
	; je bloc11
	; cmp y_minge, 80
	; je bloc21
	; cmp y_minge, 40
	; je bloc31
	; cmp y_minge, 0
    ; je bloc41
	jmp afisare_litere

	
	cade_minge_dreapta:
	mov stangadreaptacazut, 2
	mov stangasaudreapta, 4
	cmp x_minge, 760
	je cade_minge_stanga
	cmp x_minge, 760
	je cade_minge_stanga
	cmp y_minge, 520
	jne mingeinaer2
	mov eax, x_paleta
	cmp x_minge, eax
	je urca_minge_stanga
	add eax, 40
	cmp x_minge, eax
	je urca_minge
	add eax, 40
	cmp x_minge, eax
	je urca_minge_dreapta
	mingeinaer2:
	make_simbol_macro 3, area, x_minge, y_minge
	add y_minge, 40
	add x_minge, 40
	make_simbol_macro 0, area, x_minge, y_minge
	cmp y_minge, 560
	je you_lost
	jmp afisare_litere
	build_themap:
	build_map 0, 0
	make_sageti_macro '0', area, 950, 520
	make_sageti_macro '1', area, 1010, 520
	inc counter
	; cmp y_minge, 120
	; je bloc11
	; cmp y_minge, 80
	; je bloc21
	; cmp y_minge, 40
	; je bloc31
	; cmp y_minge, 0
    ; je bloc41
	jmp evt_timer
	
you_lost:
	mov counter, 0
	mov x_paleta, 320
	mov y_minge, 520
	mov x_minge, 360
	mov scor, 0
	mov stangadreaptacazut, 4
	mov stangasaudreapta, 0
	mov bloc11_vizibilitate, 0
	mov bloc12_vizibilitate, 0
	mov bloc21_vizibilitate, 0
	mov bloc22_vizibilitate, 0
	mov bloc23_vizibilitate, 0
	mov bloc24_vizibilitate, 0
	mov bloc31_vizibilitate, 0
	mov bloc32_vizibilitate, 0
	mov bloc33_vizibilitate, 0
	mov bloc34_vizibilitate, 0
	mov bloc35_vizibilitate, 0
	mov bloc36_vizibilitate, 0
	mov bloc41_vizibilitate, 0
	mov bloc42_vizibilitate, 0
	mov bloc43_vizibilitate, 0
	mov bloc44_vizibilitate, 0
	mov bloc45_vizibilitate, 0
	mov bloc46_vizibilitate, 0
	cmp scor, 18
	je won
	cmp scor, 18
	jl lost

won:
	make_text_macro 'A', area, 920, 90
	make_text_macro 'I', area, 930, 90
	make_text_macro 'C', area, 950, 90
	make_text_macro 'A', area, 960, 90
	make_text_macro 'S', area, 970, 90
	make_text_macro 'T', area, 980, 90
	make_text_macro 'I', area, 990, 90
	make_text_macro 'G', area, 1000, 90
	make_text_macro 'A', area, 1010, 90
	make_text_macro 'T', area, 1020, 90

lost:
	make_text_macro 'A', area, 940, 90
	make_text_macro 'I', area, 950, 90
	make_text_macro 'P', area, 970, 90
	make_text_macro 'I', area, 980, 90
	make_text_macro 'E', area, 990, 90
	make_text_macro 'R', area, 1000, 90
	make_text_macro 'D', area, 1010, 90
	make_text_macro 'U', area, 1020, 90
	make_text_macro 'T', area, 1030, 90

afisare_litere:
    mov ebx, 10
	mov eax, scor
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 890, 200
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 830, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 820, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 810, 10
	
	
	
	;scriem un mesaj
	make_text_macro 'D', area, 950, 20
	make_text_macro 'X', area, 960, 20
	make_text_macro '-', area, 970, 20
	make_text_macro 'B', area, 980, 20
	make_text_macro 'A', area, 990, 20
	make_text_macro 'L', area, 1000, 20
	make_text_macro 'L', area, 1010, 20
	make_text_macro 'S', area, 840, 200
	make_text_macro 'C', area, 850, 200
	make_text_macro 'O', area, 860, 200
	make_text_macro 'R', area, 870, 200
	
	
	
    ;linie_verticala buttom_x, buttom_y, buttom_size, 0
	;linie_verticala buttom_x, buttom_y, buttom_size, 0
	linie_verticala buttom_x + buttom_sizey, buttom_y, buttom_size, 0
	linie_verticala buttom_x + buttom_sizey+1, buttom_y, buttom_size, 0
	;linie_orizontala buttom_x, buttom_y, buttom_sizey, 0
	;linie_orizontala buttom_x, buttom_y + buttom_size, buttom_sizey, 0
	
	linie_orizontala buttom_x + buttom_sizey, buttom_y, 390, 0
	linie_orizontala buttom_x + buttom_sizey, buttom_y+1, 390, 0
	linie_orizontala buttom_x + buttom_sizey, buttom_y + buttom_size, 390, 0
	linie_orizontala buttom_x + buttom_sizey, buttom_y + buttom_size, 391, 0
	linie_verticala buttom_x + buttom_sizey + 390, buttom_y, buttom_size, 0
	linie_verticala buttom_x + buttom_sizey + 391, buttom_y, buttom_size, 0
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
