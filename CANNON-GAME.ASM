;*******************************************************************************************************************************
;* Name of work: Cannon Game                                                                                                   *
;*                                                                                                                             *
;* Student: Micha Yagdanov                                                                                                     *
;* Yoana Jabotinsky High School,    Yud 7                                                                                      *
;*                                                                                                                             *
;* Laboratory experience unit: Computer organization and threshold language                                                    *
;* Development environment: TASM compiler                                                                                      *
;*                                                                                                                             *
;*Subject: There is a cannon and a target that you should hit using the cannon ball. For every hit you get 1 point.            *
;          You got 6 points? Congratulations! You just won the cannon game! :)                                                 *
;*                                                                                                                             *
;* User guide:  First choose the power of the cannon using a number (1-9) and shoot the targets using the space_bar! That's it!*
;*******************************************************************************************************************************

.model small

.data
;Variables
  ui_power db "Enter power (1-9)$"
  ui_str db   "Press space_bar to shoot$"
  empty_str db "                                $"
  
  win_str db "You Win!$"
  
  points_str db "Points: $"
  
  power db 0
  adr dw 0
  trg dw 1
  
  x db 77
  y db 23
  vy db 0
  vx db 0
  a db 0
  
  trg_x db 0
  points db 0

.stack 100h

.code

start:
  mov ax,@data
  mov ds,ax
  ;Commands
  
  ;Screen preparation
  call clear
  call hide_cursor
  call points_strF
  call out_points_strF
  call pointsF
  call out_points
  
  ;Check if user has 6 points / won the game
  cmp points, 1
  je win
  
  ;Create a random number for the x value of the target
  jmp create_random_num2
  
;if user win so:
win:
  call win_msg      ;Print the win message
  call out_win_msg  ;^^^^^^^^^^^^^^^^^^^^^
  call wait_key
  cmp al, 27        ;If user press ESC
  je btw            ;End the program
  jmp win

;the main game 
next:
  call ui
  call out_ui
  call target
  call out_target
  call cannon
  call out_cannon
  call move_ball
  call ball
  call out_ball
  call delay
  call wait_key

  ;Inputes
  cmp al, 27
  je btw
  cmp al, " "
  je shoot
  
  ;Get power if power = 0
  cmp power, 0
  je get_power
  
  ;If the cannon ball is moving
  cmp vx, 0
  jg check_floor
  
  jmp next

;Middle station
btw:
  jmp fin
next2:
  jmp next
create_random_num2:
  jmp create_random_num

;Get power  
get_power:
  sub al, 30h
  cmp al, 9
  jg next
  cmp al, 0
  jl next
  mov power, al
  jmp enter_ui

;Check if the cannon ball has riched the floor
check_floor:
  cmp y, 23
  je floor
  jmp next

;Changes the UI
enter_ui:
  mov adr, 18
  jmp next

;Shoot the cannon ball
shoot:
  cmp power, 0
  je next2

  mov cl, power
  neg cl
  mov vy, cl
  
  mov vx, 4
  
  mov cl, 1
  mov a, cl
  
  mov adr, 50
  jmp next

;Generate a random number for the x value of the target
create_random_num:
  mov ah, 0
  int 1ah
  
  mov bl, 0

  divv:
    sub dx, 61
    cmp dx, 61
    jae divv
  rest:
    cmp dx, 0
    jle xx
    sub dx, 1
    add bl, 1
    jmp rest
    
  xx:
    mov trg_x, bl
  jmp next

;If riched the floor so:
floor:
  ;Reset all Variables
  mov vy, 0
  mov vx, 0
  mov a, 0
  mov power, 0
  mov adr, 0
  mov y, 23
  
  ;Check if the cannon ball is near the target
  mov cl, x
  sub cl, trg_x
  mov x, 77
  mov trg_x, 0
  cmp cl, 3
  jle jj
  jmp start
  jj:
    cmp cl, -3
    jge kk
    jmp start
  kk:
    ;Near the target. Get 1 point
    add points, 1
    add trg, 1
  jmp start ;Start the game again
    
;The exit 
fin:
  mov ah,4ch 
  int 21h 

;clears the screen
clear	proc
  mov ah, 6
  mov al, 25
  mov ch, 0
  mov cl, 0
  mov dh, 24
  mov dl, 79
  mov bh, 0001101b
  int 10h
  
  ret
clear endp

hide_cursor proc
  mov ah, 1
  mov ch, 1
  mov cl, 0
  int 10h
  
  ret
hide_cursor endp

win_msg	proc
  mov ah, 2
  mov bx, 0
  mov dh, 0
  mov dl, 0
  ret
win_msg	endp

out_win_msg	proc
  mov ah, 9
  mov dx, offset win_str
  int 21h
  ret
out_win_msg	endp

pointsF	proc
  mov ah, 2
  mov bx, 0
  mov dh, 0
  mov dl, 62
  ret
pointsF	endp

out_points	proc
  mov ah, 2
  mov bl, points
  add bl, 30h
  mov dx, bx
  int 21h
  ret
out_points	endp

points_strF	proc
  mov ah, 2
  mov bx, 0
  mov dh, 0
  mov dl, 60
  int 10h
  ret
points_strF	endp

out_points_strF	proc
  mov ah, 9
  mov dx, offset points_str
  int 21h
  ret
out_points_strF	endp


target	proc
  mov ah, 2
  mov bx, 0
  mov dh, 23
  
  mov dl, trg_x
  int 10h
  ret
target	endp

out_target	proc
  mov ah, 2
  mov dx, trg
  int 21h
  ret
out_target	endp

cannon	proc
  mov ah, 2
  mov bx, 0
  mov dh, 24	;line
  mov dl, 78	;column
  int 10h
  
  ret
cannon	endp

out_cannon	proc
  mov ah, 2
  mov dx, '\'
  int 21h
  
  ret
out_cannon endp

ui	proc
  mov ah, 2
  mov bx, 0
  mov dh, 0
  mov dl, 0
  int 10h
  
  ret
ui	endp

out_ui	proc
  mov ah, 9
  mov dx, adr
  int 21h
  ret
out_ui	endp

ball	proc
  mov ah, 2
  mov bx, 0
  mov dh, y
  mov dl, x
  int 10h
  
  ret
ball	endp

out_ball	proc
  mov ah, 2
  mov dx, '0'
  int 21h
  ret
out_ball	endp
  
  
wait_key	proc
  mov ah, 6
  mov dl, 0ffh
  int 21h
  ret
wait_key	endp

wait_key2	proc
  mov ah, 7
  mov dl, 0ffh
  int 21h
  ret
wait_key2	endp

move_ball 	proc
  mov dh, y
  add dh, vy
  mov y, dh
  
  mov dl, x
  sub dl, vx
  mov x, dl
  mov cl, a 
  add vy, cl
  ret
move_ball	endp
  
delay	proc
  mov ah,0
  int 1ah	;dx<-ticks
  mov bx,dx	;save old tick
  add bl, 8	;set bx/18 sec of delay
repeat:
  int 1ah
  cmp dx,bx
  jl repeat
  
  ret
delay	endp
  
end start
