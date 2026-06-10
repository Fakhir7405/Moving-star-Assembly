[org 0x0100]

jmp start

; Game variables
player_pos: dw 0           ; Current player position
player_dir: dw 6           ; Direction: 2=up, 4=left, 6=right, 8=down (initial: right)
goal_pos: dw 0             ; Goal position red one on top left
timer_count: db 0          ; TIC
old_timer: dd 0            ; Original timer ISR
old_keyboard: dd 0         ; Original keyboard ISR
game_over: db 0            ; Game status flag 0,1 or 2


; Messages to print on the screen
msg_win: db 'Game Win!', 0
msg_lost: db 'Game Lost!', 0




; Input: ax = frequency in Hz, cx = duration (approximately loops)
toneplay:
    push ax
    push cx
    push dx
    push bx
    push si

    ; Calculate PIT divisor: divisor = 1193 / frequency
    mov bx, 1193           ; warning for bounds , if i put a larger number
    xor dx, dx
    div ax               ; dx:ax / ax-> ax = quotient = divisor
                         ; for 16-bit, we can approximate:
    mov bx, ax           ; store divisor in bx

    ; Program PIT channel 2 for square wave
    mov al, 0xB6         ; channel 2, square wave, lsb/msb
    out 0x43, al
    mov ax, bx           ; divisor
    out 0x42, al         ; lsb
    mov al, ah
    out 0x42, al         ; msb

    ; Turn on speaker
    in al, 0x61               ; 61 port is for the speaker
    or al, 3
    out 0x61, al

; delay loop = duration

delay1:
    loop delay1

    ; Turn off speaker as well
    in al, 0x61
    and al, 0xFC         ; clear  the bits 0 and 1
    out 0x61, al

    pop si
    pop bx
    pop dx
    pop cx
    pop ax
    ret



; Collision Sound
collision_sound:
    mov ax, 800       ; frequency= 800 Hz
    mov cx, 50000     ; duration (tune as needed)
    call toneplay
    ret

; Win sound
win_sound:

    mov ax,1491    ; frequency set to 1491 by chance
    mov cx,15000
    call toneplay
    ret

; routine to clear the screen
clear_screen:
    push ax
    push cx
    push di
    push es
    
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0720          
    mov cx, 2000            ; 80*25 = 2000 characters  (2 bytes per)
    cld
    rep stosw
    
    pop es
    pop di
    pop cx
    pop ax
    ret


;*******************
; PLACE obstacles
; Using: DI = row*160 + col*2

place_obstacles:
    push ax
    push bx
    push cx
    push di
    push es

    mov ax, 0xB800
    mov es, ax


;******************************
; HORIZONTAL OBSTACLES
;******************************
; Row = 14, Columns = 22->35
    mov bx, 22            ; start column
obs_h1
    cmp bx, 36           ; end col + 1
    jge obs_h1done

    ; DI = row*160
    mov ax, 14            ; row = 10
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += column*2
    mov ax, bx
    mov cx, 2
    mul cx                ; ax = col * 2
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_h1

obs_h1done:

; Row = 7, Columns = 20->33
    mov bx, 20           ; start column
obs_h2
    cmp bx, 34          ; end col + 1
    jge obs_h2done

    ; DI = row*160
    mov ax, 7           ; row = 10
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += column*2
    mov ax, bx
    mov cx, 2
    mul cx                ; ax = col * 2
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_h2

obs_h2done:


; Row = 8, Columns = 60->73
    mov bx, 60       ; start column
obs_h3
    cmp bx, 74          ; end col + 1
    jge obs_h3done

    ; DI = row*160
    mov ax, 8         ; row = 10
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += column*2
    mov ax, bx
    mov cx, 2
    mul cx                ; ax = col * 2
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_h3

obs_h3done:



;********************************
; VERTICAL OBSTACLES
;********************************
; Column = 79, Rows = 0-24

    mov bx, 0           ; start row
obs_v1
    cmp bx, 25            ; end row + 1
    jge obs_v1done

    ; DI = row * 160
    mov ax, bx            ; row value
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += col * 2
    mov ax, 79        ; column = 79
    mov cx, 2
    mul cx
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_v1

obs_v1done:


; Column = 10, Rows = 5-11

    mov bx, 5          ; start row
obs_v2
    cmp bx, 12       ; end row + 1
    jge obs_v2done

    ; DI = row * 160
    mov ax, bx            ; row value
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += col * 2
    mov ax, 10      ; column = 10
    mov cx, 2
    mul cx
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_v2

obs_v2done:


; Column = 43, Rows = 7-15

    mov bx, 7         ; start row
obs_v3
    cmp bx, 16       ; end row + 1
    jge obs_v3done

    ; DI = row * 160
    mov ax, bx            ; row value
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += col * 2
    mov ax, 43   ; column = 43
    mov cx, 2
    mul cx
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_v3

obs_v3done:

; Column = 50, Rows = 3-8

    mov bx, 3      ; start row
obs_v4
    cmp bx, 9    ; end row + 1
    jge obs_v4done

    ; DI = row * 160
    mov ax, bx            ; row value
    mov cx, 160
    mul cx                ; ax = row * 160
    mov di, ax

    ; DI += col * 2
    mov ax, 50  ; column = 50
    mov cx, 2
    mul cx
    add di, ax

    mov word [es:di], 0x2220  ; green block

    inc bx
    jmp obs_v4

obs_v4done:
    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret




;**********************
; place Goal Subroutine
place_goal:
    push ax
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    xor di, di                 ; Top left corner (0,0)
    mov word [es:di], 0x4420   ; Red background, space 
    mov word [goal_pos], 0
    
    pop es
    pop di
    pop ax
    ret



;****************
; Place Player Subroutine
place_player:
    push ax
    push di
    push es
    
    mov ax, 0xb800
    mov es, ax
    
    ; DI = row * 160
    mov ax, 24          ; last row
    mov cx, 160
    mul cx
    mov di, ax

    ; DI += column * 2
    mov ax, 40          ; center column
    mov cx, 2
    mul cx
    add di, ax
    
    mov word [es:di], 0x112A ; Blue asterisk (*)
    mov word [player_pos], di
    
    pop es
    pop di
    pop ax
    ret


;*****************
; Check Collision            ; the dot (.) symbol in start of the variable name is used for local variables within same routine or block

check_collision:
    push ax
    push di
    push es
    
    mov ax, 0xb800
    mov es, ax
    mov di, [player_pos]
    mov ax, [es:di]
    
    ; Check if green obstacle (0x2220) or empty with green background (0x22xx)
    cmp ah, 0x22
    je .collision
    
    ; Check if goal (0x4420)
    cmp ax, 0x4420
    je .win
    
    jmp .no_collision
    
.collision:
    call collision_sound                   ; calling collision sound
    mov byte [game_over], 2  ; Lost
    jmp .done
    
.win:
    call win_sound                             ; calling win sound
    mov byte [game_over], 1  ; Win
    jmp .done
    
.no_collision:
    mov byte [game_over], 0
    
   .done:
    pop es
    pop di
    pop ax
    ret

;*********************
; Move Player
move_player:
    push ax
    push bx
    push di
    push es
    
    cmp byte [game_over], 0
    jne .done
    
    mov ax, 0xB800
    mov es, ax
    
    ; Clear current position
    mov di, [player_pos]
    mov word [es:di], 0x0720
    
    ; Calculate new position based on direction
    mov di, [player_pos]
    mov bx, [player_dir]
    
    cmp bx, 2               ; Up
    je .move_up
    cmp bx, 8               ; Down
    je .move_down
    cmp bx, 4               ; Left
    je .move_left
    cmp bx, 6               ; Right
    je .move_right
    jmp .update_pos
    
.move_up:
    sub di, 160             ; Move up one row
    jmp .update_pos
    
.move_down:
    add di, 160             ; Move down one row
    jmp .update_pos
    
.move_left:
    sub di, 2               ; Move left one column
    jmp .update_pos
    
.move_right:
    add di, 2               ; Move right one column
    
.update_pos:
    ; Check boundaries
    cmp di, 0
    jl .lost
    cmp di, 4000
    jge .lost

.boundary_ok:
    mov word [player_pos], di
    
    ; Check collision before drawing
    call check_collision
    cmp byte [game_over], 0
    jne .done
    
    ; Draw player at new position
    mov word [es:di], 0x192A
    jmp .done

.lost:
    mov byte [game_over], 2
    jmp .done

.done:
    pop es
    pop di
    pop bx
    pop ax
    ret

;*******************
; Timer ISR

timer_isr:
    push ax
    
    inc byte [timer_count]
    cmp byte [timer_count], 2   ; 2 timer interrupts functionality
    jl .call_old
    
    mov byte [timer_count], 0
    call move_player
    

.call_old:
    pop ax
    
    ; Call original timer ISR
    pushf
    call far [old_timer]
    iret



;*********************
; Keyboard ISR

keyboard_isr:
    push ax
    
    in al, 0x60             ; Read scan code
    
    cmp al, 0x48            ; Up arrow
    je .up
    cmp al, 0x50            ; Down arrow
    je .down
    cmp al, 0x4B            ; Left arrow
    je .left
    cmp al, 0x4D            ; Right arrow
    je .right
    jmp .call_old
    
.up:
    mov word [player_dir], 2
    jmp .done
    
.down:
    mov word [player_dir], 8
    jmp .done
    
.left:
    mov word [player_dir], 4
    jmp .done
    
.right:
    mov word [player_dir], 6
    
.done:
    mov al, 0x20
    out 0x20, al            ; send End of Interrupt service EOI
    pop ax
    iret
    
.call_old:
    pop ax
   ; jmp far [old_keyboard]
iret

;*********************
; Print String (for end messages)


print_string:
    push ax
    push bx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    mov di, 3590        ; Center of screen atleastttt
    
cloop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0xDF            ; Blinking White on Magenta
    stosw
    jmp cloop
    
.done:
    pop es
    pop di
    pop si
    pop bx
    pop ax
    ret


;************************************
; Main Program Start
;*************************************

start:

    ; Initialize screen
    call clear_screen
    call place_obstacles
    call place_goal
    call place_player
    
    ; Hook timer interrupt INT 08
    xor ax, ax
    mov es, ax
    mov ax, [es:0x08*4]
    mov word [old_timer], ax
    mov ax, [es:0x08*4+2]
    mov word [old_timer+2], ax
    
    cli                                      ; disable interrupts 
    mov word [es:0x08*4], timer_isr
    mov [es:0x08*4+2], cs
    sti                                       ; enable again
    
    ; Hook keyboard interrupt INT 09
    mov ax, [es:0x09*4]
    mov word [old_keyboard], ax
    mov ax, [es:0x09*4+2]
    mov word [old_keyboard+2], ax
    
    cli
    mov word [es:0x09*4], keyboard_isr
    mov [es:0x09*4+2], cs
    sti
    

;**********************
    ; Game loop

game_loop:
    cmp byte [game_over], 0
    je game_loop
    
    ; Restore interrupts
    xor ax, ax
    mov es, ax
    
    cli
    mov ax, word [old_timer]
    mov [es:0x08*4], ax            ; INT 8
    mov ax, word [old_timer+2]
    mov [es:0x08*4+2], ax
    
    mov ax, word [old_keyboard]               ; INT 9
    mov [es:0x09*4], ax
    mov ax, word [old_keyboard+2]
    mov [es:0x09*4+2], ax
    sti
    
    ; Display end message
    cmp byte [game_over], 1
    je winmsg
    
    ; Lost message
    mov si, msg_lost
    call print_string
    jmp exit
    
winmsg:
    mov si, msg_win
    call print_string

    
exit:
    ; Wait for key press service
    mov ah, 0x00
    int 0x16
    
    ; Restore screen
    call clear_screen
    
    ; simple termination
    mov ax, 0x4C00
    int 0x21