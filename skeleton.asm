###############################################################  
# Super Mario Demo (MIPS Assembly)  
# --------------------------------  
# 20x24 Mario AABB Collision Demo with objects and inertia.  
#  
# This version includes:  
# - Full English comments  
# - Inertia + air friction horizontal movement  
# - AABB collision handling for all objects  
# - Enemy movement + camera follow  
# - Background music and on-screen HUD  
###############################################################  

###############################################################  
# .DATA SECTION  
###############################################################  
.data  
###############################################################
# Resource Paths  
###############################################################
imgpath:    .asciiz "./img/level_1_1.jpeg"       # Background image  
imgpath_1:  .asciiz "./img/level_1_2.png"        # Alternate background  
mario_r:    .asciiz "./img/mario_right.png"      # Mario sprite facing right  
mario_l:    .asciiz "./img/mario_left.png"       # Mario sprite facing left  

current_bg_path: .word imgpath   # Default background for Map 1

###############################################################
# Sprite Image Paths  
###############################################################
img2_path:  .asciiz "./img/brick.png"             # id=2: Brick  
img3_path:  .asciiz "./img/star.png"              # id=3: Star  
img4_path:  .asciiz "./img/coin.png"              # id=4: Coin  
img5_path:  .asciiz "./img/enemies_1.png"         # id=5: Enemy 1  
img6_path:  .asciiz "./img/enemies_2.png"         # id=6: Enemy 2  
img7_path:  .asciiz "./img/flag.png"              # id=7: Flag  
img8_path:  .asciiz ""                             # id=8: Blank (disabled)

###############################################################
# Image Table (id path mapping)  
###############################################################
img_tbl:  
    .word 0           # 0: Door  
    .word 0           # 1: Platform (no image)  
    .word img2_path   # 2: Brick  
    .word img3_path   # 3: Star  
    .word img4_path   # 4: Coin  
    .word img5_path   # 5: Enemy1  
    .word img6_path   # 6: Enemy2  
    .word img7_path   # 7: Flag  
    .word 0           # 8: Blank  
    .word 0           # 9: Ground  
img_tbl_end:  
img_tbl_n: .word 10  

###############################################################
# Object Arrays (original + runtime) for Map 1 and Map 2  
###############################################################
# Each entry = (x, y, width, height, id)  
# id defines sprite and logic  
# 0=door, 1=solid, 2=brick, 3=star, 4=coin,  
# 5=enemy1, 6=enemy2, 7=flag, 8=blank(disabled)  
###############################################################

###############################################################
# Map 1  
###############################################################
obj_arr_1_orig:  	# copy of obj_arr_1: ensuring item call back 
    # Platforms (id=1)  
    .word 192,184,16,16,1  
    .word 208,168,16,32,1  
    .word 224,152,16,48,1  
    .word 240,136,16,64,1  
    .word 288,136,16,64,1  
    .word 304,152,16,48,1  
    .word 320,168,16,32,1  
    .word 336,184,16,16,1  
    .word 416,184,16,16,1  
    .word 432,168,16,32,1  
    .word 448,152,16,48,1  
    .word 464,136,16,64,1  
    .word 480,136,16,64,1  
    .word 528,136,16,64,1  
    .word 544,152,16,48,1  
    .word 560,168,16,32,1  
    .word 576,184,16,16,1  
    .word 944,184,16,16,1  
    .word 960,168,16,32,1  
    .word 976,152,16,48,1  
    .word 992,136,16,64,1  
    .word 1008,120,16,80,1  
    .word 1024,104,16,96,1  
    .word 1040,88,16,112,1  
    .word 1056,72,16,128,1  
    .word 1072,72,16,128,1  
    .word 1216,184,16,16,1  
    # Water blocks  
    .word 656,168,32,32,1  
    .word 912,168,32,32,1  
    # Ground layer  
    .word 0,202,496,22,9  
    .word 528,202,968,22,9  

    # Items  
    # Bricks (id=2)  
    .word 64,145,16,16,2  
    .word 80,145,16,16,2  
    .word 96,145,16,16,2  
    .word 112,145,16,16,2  
    # Star (id=3)  
    .word 88,125,16,16,3  
    # Coins (id=4)  
    .word 738,182,16,16,4  
    .word 754,182,16,16,4  
    .word 770,182,16,16,4  
    .word 786,182,16,16,4  
    .word 802,182,16,16,4  
    .word 818,182,16,16,4  
    .word 264,112,16,16,4  
    # Enemies  
    .word 665,154,16,16,5  
    .word 368,185,16,16,6  
    # Door (id=0)  
    .word 1308,180,16,16,0  
    # Flag (id=7)  
    .word 1216,150,16,16,7  

obj_n_1_orig: .word 47  
###############################################################
# Cloned array for runtime use  
###############################################################
obj_arr_1:  
    # identical to obj_arr_1_orig  
    .word 192,184,16,16,1  
    .word 208,168,16,32,1  
    .word 224,152,16,48,1  
    .word 240,136,16,64,1  
    .word 288,136,16,64,1  
    .word 304,152,16,48,1  
    .word 320,168,16,32,1  
    .word 336,184,16,16,1  
    .word 416,184,16,16,1  
    .word 432,168,16,32,1  
    .word 448,152,16,48,1  
    .word 464,136,16,64,1  
    .word 480,136,16,64,1  
    .word 528,136,16,64,1  
    .word 544,152,16,48,1  
    .word 560,168,16,32,1  
    .word 576,184,16,16,1  
    .word 944,184,16,16,1  
    .word 960,168,16,32,1  
    .word 976,152,16,48,1  
    .word 992,136,16,64,1  
    .word 1008,120,16,80,1  
    .word 1024,104,16,96,1  
    .word 1040,88,16,112,1  
    .word 1056,72,16,128,1  
    .word 1072,72,16,128,1  
    .word 1216,184,16,16,1  
    # Water blocks  
    .word 656,168,32,32,1  
    .word 912,168,32,32,1  
    # Ground  
    .word 0,202,496,22,9  
    .word 528,202,968,22,9  
    # Items and enemies  
    .word 64,145,16,16,2  
    .word 80,145,16,16,2  
    .word 96,145,16,16,2  
    .word 112,145,16,16,2  
    .word 88,125,16,16,3  
    .word 738,182,16,16,4  
    .word 754,182,16,16,4  
    .word 770,182,16,16,4  
    .word 786,182,16,16,4  
    .word 802,182,16,16,4  
    .word 818,182,16,16,4  
    .word 264,112,16,16,4  
    .word 665,154,16,16,5  
    .word 368,185,16,16,6  
    .word 1308,180,16,16,0  
    .word 1216,150,16,16,7  

obj_n_1: .word 47  

###############################################################
# Map 2  
###############################################################
obj_arr_2_orig:  
##################### Begin: Add your own objects #####################



##################### End:   Add your own objects #####################
    # Ground blocks  
    .word 0,202,814,22,9  
    .word 850,202,234,22,9  
    .word 1120,202,319,22,9  

obj_n_2_orig: .word 3  

obj_arr_2:  

##################### Begin: Add your own objects #####################



##################### End:   Add your own objects #####################
    # Ground blocks  
    .word 0,202,814,22,9  
    .word 850,202,234,22,9  
    .word 1120,202,319,22,9  
    
obj_n_2: .word 3  

###############################################################
# Enemy runtime data  
###############################################################
enemy_dir:      .space 200   # movement direction per enemy  
enemy_origin_x: .space 200   # original X per enemy  

###############################################################
# Background music  
###############################################################
bgm_path: .asciiz "./music/bgm.wav"  

###############################################################
# Camera / screen constants  
###############################################################
VIEW_W: .word 512  
VIEW_H: .word 224  
BG_W:   .word 1439  
GROUND_Y:.word 202  
CENTER_X:.word 256  
RIGHT_LIM:.word 927  

###############################################################
# Object and Mario dimensions  
###############################################################
MARIO_W: .word 20  
MARIO_H: .word 24  
OBS_W:   .word 16  
OBS_H:   .word 16  

###############################################################
# Score & Life values  
###############################################################
score: .word 0  
life:  .word 1  

###############################################################
# HUD strings  
###############################################################
scroll_msg: .asciiz "scrollX: "  
pos_x_msg:  .asciiz " | Mario X: "  
pos_y_msg:  .asciiz " | Mario Y: "  
newline:    .asciiz "\n"  

###############################################################
# Physics constants  
###############################################################
fps_delay:   .word 10000   
vx_walk_c:   .word 1       
vx_run_c:    .word 2       
gravity_c:   .word 1       
jump_imp:    .word -16     
camera_lag:  .word 2       
BOUNCE_DOWN: .word 2       

###############################################################
# Runtime flags  
###############################################################
onGround: .word 0          
current_map: .word 1 	##### you can change the defult map for debug       
current_obj_arr:   .word obj_arr_1  
current_obj_n:     .word obj_n_1  
map_switched:  .word 0  
flag_landed: .word 0        

.text
.globl main
main:
    ###############################################################
    # Load game constants  
    ###############################################################
    la      $t0, CENTER_X     
    lw      $s0, 0($t0)
    la      $t0, RIGHT_LIM    
    lw      $s1, 0($t0)
    la      $t0, GROUND_Y     
    lw      $t7, 0($t0)
    la      $t0, vx_walk_c    
    lw      $t1, 0($t0)
    la      $t0, vx_run_c     
    lw      $t2, 0($t0)
    la      $t0, gravity_c    
    lw      $t3, 0($t0)
    la      $t0, jump_imp     
    lw      $t4, 0($t0)
    la      $t0, fps_delay    
    lw      $t5, 0($t0)
    la      $t0, BG_W         
    lw      $t9, 0($t0)
    la      $t0, camera_lag   
    lw      $t8, 0($t0)

    ###############################################################
    # Initialize game state  
    ###############################################################
    li      $s3, 0              
    li      $s4, 32             
    la      $t0, MARIO_H
    lw      $t0, 0($t0)
    sub     $s5, $t7, $t0       
    li      $s6, 0              
    li      $s7, 1              
    li      $t6, 0              
    li      $t1, 1
    la      $t2, onGround
    sw      $t1, 0($t2)        

    ###############################################################
    # Initialize UI  
    ###############################################################
    li      $a0, 0
    li      $v0, 5107           
    syscall

    li      $a0, 1
    li      $v0, 5108           
    syscall

    ###############################################################
    # Load Mario sprite  
    ###############################################################
    la      $a0, mario_r
    li      $a1, 0
    li      $v0, 5104
    syscall

    ###############################################################
    # Dynamic map initialization  
    ###############################################################
    la      $t0, current_map
    lw      $t1, 0($t0)         

    li      $t2, 1
    beq     $t1, $t2, init_map_stage1
    li      $t2, 2
    beq     $t1, $t2, init_map_stage2
    j       init_map_stage1     

###############################################################
# Stage 1 setup  
###############################################################
init_map_stage1:
    la      $t0, current_obj_arr
    la      $t1, obj_arr_1
    sw      $t1, 0($t0)

    la      $t0, current_obj_n
    la      $t1, obj_n_1
    sw      $t1, 0($t0)

    la      $t0, current_bg_path
    la      $t1, imgpath
    sw      $t1, 0($t0)

    j       init_current_map

###############################################################
# Stage 2 setup  
###############################################################
init_map_stage2:
    la      $t0, current_obj_arr
    la      $t1, obj_arr_2
    sw      $t1, 0($t0)

    la      $t0, current_obj_n
    la      $t1, obj_n_2
    sw      $t1, 0($t0)

    la      $t0, current_bg_path
    la      $t1, imgpath_1
    sw      $t1, 0($t0)

    j       init_current_map

###############################################################
# Initialize current object array & background  
###############################################################
init_current_map:
    la      $t0, current_bg_path
    lw      $a0, 0($t0)
    li      $v0, 5100
    syscall                     

    la      $t0, current_obj_arr
    lw      $a0, 0($t0)

    la      $t0, current_obj_n
    lw      $t1, 0($t0)
    lw      $a1, 0($t1)

    la      $a2, img_tbl
    lw      $a3, img_tbl_n
    li      $v0, 5102
    syscall

    la      $a0, bgm_path
    li      $a1, 1
    li      $a2, 0
    li      $v0, 5120
    syscall

    j loop


###############################################################
# clear_and_reload_map
# Purpose: Switch maps (Map1 ? Map2) and reset Mario to spawn
# Call:    jal clear_and_reload_map
# Behavior:
#   If current_map = 1 �� load Map2
#   If current_map = 2 �� load Map1
#   Mario position �� X = 32, Y = (GROUND_Y - MARIO_H)
###############################################################
clear_and_reload_map:
    ###############################################################
    # Expand stack and save registers
    # (also preserve Mario's X coordinate for later restore)
    ###############################################################
    addiu $sp, $sp, -44
    sw $ra, 40($sp)       # return address
    sw $s4, 36($sp)       # save Mario X
    sw $t0, 32($sp)
    sw $t1, 28($sp)
    sw $t2, 24($sp)
    sw $t3, 20($sp)
    sw $t4, 16($sp)
    sw $t5, 12($sp)
    sw $t6, 8($sp)
    sw $t7, 4($sp)

###############################################################
# (1) Determine next map based on current_map
###############################################################
    la   $t7, current_map
    lw   $t6, 0($t7)
    beq  $t6, 1, switch_to_map2   # if current = 1 -> switch to 2
    beq  $t6, 2, switch_to_map1   # if current = 2 -> switch to 1
    li   $t6, 1                   # default: load map1
    sw   $t6, 0($t7)
    j  do_clear_and_load

switch_to_map2:
    li   $t6, 2
    sw   $t6, 0($t7)
    j  do_clear_and_load

switch_to_map1:
    li   $t6, 1
    sw   $t6, 0($t7)
    j  do_clear_and_load

###############################################################
# (2) Load specific object arrays and background based on map ID
###############################################################
do_clear_and_load:
    beq  $t6, 1, load_map1
    beq  $t6, 2, load_map2
    j done_clear

###############################################################
# --- Load Map 1 ---
###############################################################
load_map1:
    # Clear previous scene (objects from map2)
    la   $a0, obj_arr_2
    la   $a1, obj_n_2
    li   $v0, 5109
    syscall

    # Draw new background
    la   $a0, imgpath
    li   $v0, 5100
    syscall

    # Copy original object array to active array (obj_arr_1_orig �� obj_arr_1)
    la   $t0, obj_arr_1
    la   $t1, obj_arr_1_orig
    lw   $t3, obj_n_1_orig
    la   $t2, obj_n_1
    sw   $t3, 0($t2)

copy_loop_map1:
    blez $t3, redraw_map1
    lw   $t4, 0($t1)
    sw   $t4, 0($t0)
    lw   $t4, 4($t1)
    sw   $t4, 4($t0)
    lw   $t4, 8($t1)
    sw   $t4, 8($t0)
    lw   $t4, 12($t1)
    sw   $t4, 12($t0)
    lw   $t4, 16($t1)
    sw   $t4, 16($t0)
    addiu $t1, $t1, 20
    addiu $t0, $t0, 20
    addi  $t3, $t3, -1
    j copy_loop_map1

redraw_map1:
    # Draw all objects for map1
    la   $a0, obj_arr_1
    la   $t0, obj_n_1
    lw   $a1, 0($t0)
    la   $a2, img_tbl
    lw   $a3, img_tbl_n
    li   $v0, 5102
    syscall

    # Update current object pointers
    la $t0, current_obj_arr
    la $t1, obj_arr_1
    sw $t1, 0($t0)
    la $t0, current_obj_n
    la $t1, obj_n_1
    sw $t1, 0($t0)
    j reset_mario_spawn

###############################################################
# --- Load Map 2 ---
###############################################################
load_map2:
    # Clear objects from map1
    la   $a0, obj_arr_1
    la   $a1, obj_n_1
    li   $v0, 5109
    syscall

    # Draw new background
    la   $a0, imgpath_1
    li   $v0, 5100
    syscall

    # Copy original map2 object array to active array
    la   $t0, obj_arr_2
    la   $t1, obj_arr_2_orig
    lw   $t3, obj_n_2_orig
    la   $t2, obj_n_2
    sw   $t3, 0($t2)

copy_loop_map2:
    blez $t3, redraw_map2
    lw   $t4, 0($t1)
    sw   $t4, 0($t0)
    lw   $t4, 4($t1)
    sw   $t4, 4($t0)
    lw   $t4, 8($t1)
    sw   $t4, 8($t0)
    lw   $t4, 12($t1)
    sw   $t4, 12($t0)
    lw   $t4, 16($t1)
    sw   $t4, 16($t0)
    addiu $t1, $t1, 20
    addiu $t0, $t0, 20
    addi  $t3, $t3, -1
    j copy_loop_map2

redraw_map2:
    # Draw all objects for map2
    la   $a0, obj_arr_2
    la   $t0, obj_n_2
    lw   $a1, 0($t0)
    la   $a2, img_tbl
    lw   $a3, img_tbl_n
    li   $v0, 5102
    syscall

    # Update current object pointers
    la   $t0, current_obj_arr
    la   $t1, obj_arr_2
    sw   $t1, 0($t0)
    la   $t0, current_obj_n
    la   $t1, obj_n_2
    sw   $t1, 0($t0)
    j reset_mario_spawn

###############################################################
# Reset Mario position and movement states
###############################################################
reset_mario_spawn:
    li   $s4, 32               # Mario X = 32
    la   $t0, GROUND_Y
    lw   $t1, 0($t0)
    la   $t0, MARIO_H
    lw   $t2, 0($t0)
    sub  $s5, $t1, $t2         # Mario Y = ground - sprite height

    li   $s3, 0                # scrollX = 0
    li   $s6, 0                # vy (vertical speed) = 0
    li   $s7, 1                # facing right

    # Render Mario's initial frame on the new map
    move $a0, $s3
    move $a1, $s4
    move $a2, $s5
    li   $a3, 0
    move $v1, $s7
    li   $v0, 5101
    syscall

    # Mark that map has been switched (used by update loop)
    la   $t0, map_switched
    li   $t1, 1
    sw   $t1, 0($t0)
    j done_clear

###############################################################
# (End) Restore registers and return
###############################################################
done_clear:
    lw $t7, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t4, 16($sp)
    lw $t3, 20($sp)
    lw $t2, 24($sp)
    lw $t1, 28($sp)
    lw $t0, 32($sp)
    lw $s4, 36($sp)       # restore Mario X
    lw $ra, 40($sp)
    addiu $sp, $sp, 44    # restore stack
    jr $ra
###############################################################




   

###############################################################
# Main Loop
# -------------------------------------------------------------
# Controls input, movement, physics, collisions, camera updates,
# and frame rendering for each game iteration.
###############################################################
loop:
    ###############################################################
    # Check if map was just switched �C skip one input frame
    ###############################################################
    la   $t0, map_switched       # address of global flag
    lw   $t1, 0($t0)             # load flag value
    beqz $t1, normal_input_frame # flag == 0 �� proceed normally
    sw   $zero, 0($t0)           # clear flag for next frame
    move $t7, $zero              # clear current key state
    move $t6, $zero              # clear previous key state
    j    do_reset                # jump to reset handler

###############################################################
# Read input when not skipping frame
###############################################################
normal_input_frame:
    li      $v0, 5103            # syscall 5103: read keyboard input
    syscall
    move    $t7, $v0             # t7 = current key state bitmap

    ###############################################################
    # X key pressed or Mario fell below screen �� reset or death
    ###############################################################
    andi    $t0, $t7, 0x0020     # check "X" key bit
    bnez    $t0, do_reset        # if pressed �� reset
    li      $t1, 250
    bgt     $s5, $t1, fall_die   # if Y > 250 �� fall off screen
    j       no_reset

###############################################################
# Mario falls below screen �� lose 1 life
###############################################################
fall_die:
    la      $t0, life
    lw      $t1, 0($t0)
    addi    $t1, $t1, -1         # life -= 1
    sw      $t1, 0($t0)

    move    $a0, $t1
    li      $v0, 5108            # syscall 5108: update life UI
    syscall

    bltz    $t1, call_full_reset # if life < 0 �� full reset
    j       do_reset

###############################################################
# Full game reset when life <= 0
###############################################################
call_full_reset:
    jal     full_reset
    j       post_frame_delay

###############################################################
# Soft reset: Reposition Mario after death or map skip frame
###############################################################
do_reset:
    move    $s3, $zero           # scrollX = 0
    li      $s4, 32              # Mario X = 32
    la      $t1, GROUND_Y
    lw      $t1, 0($t1)
    la      $t2, MARIO_H
    lw      $t2, 0($t2)
    sub     $s5, $t1, $t2        # Y = GROUND_Y - MARIO_H
    move    $s6, $zero           # vy = 0
    li      $s7, 1               # facing right
    la      $t3, onGround
    li      $t4, 1
    sw      $t4, 0($t3)          # set onGround = 1
    move    $t6, $zero           # clear previous key state

    # Redraw stage frame
    move    $a0, $s3             # scrollX
    move    $a1, $s4             # posX
    move    $a2, $s5             # posY
    li      $a3, 0
    move    $v1, $s7             # facing direction
    li      $v0, 5101            # syscall 5101: redraw frame
    syscall

    j       post_frame_delay

###############################################################
# Horizontal Movement Control
# -------------------------------------------------------------
# Implements inertia, acceleration and friction-based movement.
# Initialize $s2 = 0 (Mario current horizontal velocity)
###############################################################


##############################################################################################################################
# Task_1: Mario move
# Target: Leftward and rightward Move Mario leftwards and rightwards based on keyboard input.
##############################################################################################################################
no_reset:

    ###############################################################
    # --- Pseudocode: Read individual directional keys ---
    ###############################################################
    # $t0 �� ($t7 & 0x0001)          # Left key
    andi  $t0, $t7, 0x0001
    # $t1 �� ($t7 & 0x0002)          # Right key
    andi  $t1, $t7, 0x0002
    # $t2 �� ($t7 & 0x0004)          # Up key (Jump)
    andi  $t2, $t7, 0x0004
    # $t3 �� ($t7 & 0x0010)          # Z key (Run)
    andi  $t3, $t7, 0x0010
    # (Keyboard reading disabled in this pseudocode version)
    

    ###############################################################
    # --- 1. Determine base target speed (walk or run) ---
    ###############################################################
    # load $a2 �� vx_walk_c           # default: walk speed
    la    $t8, vx_walk_c
    lw    $a2, 0($t8)
    # if ($t3 != 0):                 # Run key pressed
    #     load $a2 �� vx_run_c        # use run speed instead
    beqz  $t3, speed_done
    la    $t8, vx_run_c
    lw    $a2, 0($t8)
speed_done:

    ###############################################################
    # --- 2. Set target velocity direction ---
    ###############################################################
    # $t4 �� ($t0 OR $t1)
    or    $t4, $t0, $t1
    # if ($t4 == 0):
    #     goto set_target_stop
    beqz  $t4, set_target_stop
    #
    # if ($t0 != 0):                 # Left key pressed
    #     $a2 �� -$a2                 # moving left �� negative velocity
    #     goto have_target
    beqz  $t0, not_left
    subu  $a2, $zero, $a2
    j     have_target
not_left:
    # if ($t1 != 0):                 # Right key pressed
    #     # keep $a2 positive �� moving right
    #     goto have_target
    
    beqz    $t1,                    set_target_stop
    j       have_target

##############################################################################################################################
# Task_1 End
##############################################################################################################################


set_target_stop:
    move    $a2, $zero           # no horizontal input �� stop
have_target:

    ###############################################################
    # 3. Acceleration and inertia control
    ###############################################################
    beq     $s2, $a2, inertia_calc_done
    blt     $s2, $a2, inertia_accel_right
    bgt     $s2, $a2, inertia_accel_left
    j       inertia_calc_done

inertia_accel_right:
    addi    $s2, $s2, 1          # accelerate right (+1)
    ble     $s2, $a2, inertia_calc_done
    move    $s2, $a2
    j       inertia_calc_done

inertia_accel_left:
    addi    $s2, $s2, -1         # accelerate left (-1)
    bge     $s2, $a2, inertia_calc_done
    move    $s2, $a2
inertia_calc_done:

    ###############################################################
    # 4. Air resistance - sliding deceleration when keys released
    ###############################################################
    beqz    $a2, apply_friction
    j       friction_done

apply_friction:
    sra   $t0, $s2, 2            # vx/4
    sub   $s2, $s2, $t0          # vx -= vx/4
    abs   $t1, $s2
    blez  $t1, zero_speed
    blt   $t1, 1, zero_speed
    j     friction_done
zero_speed:
    move  $s2, $zero
friction_done:

    ###############################################################
    # 5. Horizontal collision detection and position update
    ###############################################################
    move    $a0, $s4             # X position
    move    $a1, $s5             # Y position
    move    $a2, $s2             # horizontal velocity
    jal     resolve_horizontal
    move    $s4, $v0             # update X after collision resolution
    move    $t4, $v1             # v1 = returned vx_out

    ###############################################################
    # 6. Update Mario facing direction
    ###############################################################
    bgez    $t4, face_right_check
    li      $s7, -1              # left facing
    j       face_done
face_right_check:
    beqz    $t4, face_done
    li      $s7, 1               # right facing
face_done:

    ###############################################################
    # 7. Jump logic (UP key press edge detection)
    ###############################################################
    nor     $t5, $t6, $zero      # ~prev
    and     $t5, $t5, $t7        # (~prev & curr)
    andi    $t5, $t5, 0x0004     # isolate UP bit
    beqz    $t5, skip_jump

    # Jump only allowed when on ground
    la      $t9, onGround
    lw      $t8, 0($t9)
    beqz    $t8, skip_jump

    la      $t3, jump_imp
    lw      $s6, 0($t3)          # set jump impulse (vy)
skip_jump:

    ###############################################################
    # 8. Vertical motion update (apply gravity)
    ###############################################################
    la      $t3, gravity_c
    lw      $t3, 0($t3)
    add     $s6, $s6, $t3        # vy += gravity

    ###############################################################
    # 9. Vertical collision detection
    ###############################################################
    move    $a0, $s4
    move    $a1, $s5
    move    $a2, $s6
    jal     resolve_vertical
    move    $s5, $v0
    move    $s6, $v1

    ###############################################################
    # 10. Object collision check (items / coins / enemies)
    ###############################################################
    jal     check_obj_collision
    bnez    $v0, do_reset        # if collision triggers reset

    ###############################################################
    # 11. Enemy position updates
    ###############################################################
    jal     update_enemy_positions

    ###############################################################
    # 12. Camera boundary clamping
    ###############################################################
    move    $t0, $s3             # scrollX start
    la      $t1, VIEW_W
    lw      $t1, 0($t1)
    la      $t2, MARIO_W
    lw      $t2, 0($t2)
    sub     $t1, $t1, $t2
    add     $t1, $t1, $s3
    blt     $s4, $t0, clamp_to_left
    j       check_right_bound
clamp_to_left:
    move    $s4, $t0
    j       after_cam_bounds
check_right_bound:
    bgt     $s4, $t1, clamp_to_right
    j       after_cam_bounds
clamp_to_right:
    move    $s4, $t1
after_cam_bounds:
    jal     update_camera

    ###############################################################
    # 13. Console debug information (scrollX, X, Y)
    ###############################################################
    la      $a0, scroll_msg
    li      $v0, 4
    syscall
    move    $a0, $s3
    li      $v0, 1
    syscall
    la      $a0, pos_x_msg
    li      $v0, 4
    syscall
    move    $a0, $s4
    li      $v0, 1
    syscall
    la      $a0, pos_y_msg
    li      $v0, 4
    syscall
    move    $a0, $s5
    li      $v0, 1
    syscall
    la      $a0, newline
    li      $v0, 4
    syscall

    ###############################################################
    # 14. Render frame (5101)
    ###############################################################
    move    $a0, $s3
    move    $a1, $s4
    move    $a2, $s5
    li      $a3, 0
    la      $t9, onGround
    lw      $t8, 0($t9)
    beqz    $t8, set_state_runjump
    or      $t0, $t4, $zero
    beqz    $t0, set_state_done
set_state_runjump:
    li      $a3, 1              # set animation state: run/jump
set_state_done:
    move    $v1, $s7
    li      $v0, 5101
    syscall

    ###############################################################
    # Save current key state for next frame
    ###############################################################
    move    $t6, $t7

###############################################################
# Frame delay (simulate FPS control)
###############################################################
post_frame_delay:
    la      $t0, fps_delay
    lw      $t0, 0($t0)
delay_loop:
    addi    $t0, $t0, -1
    bgtz    $t0, delay_loop

    j       loop                # repeat next frame
###############################################################






###############################################################
# check_obj_collision �� Full Revised Version
# -------------------------------------------------------------
# Collision detection logic:
#   This function iterates through all valid objects in the 
#   current map array, performs an AABB (axis-aligned bounding 
#   box) collision check between Mario and each object, and 
#   then executes different behaviors according to the object ID:
#     id=0 �� Door:   Switch map if flag landed
#     id=3 �� Star:   +1 life and remove star
#     id=4 �� Coin:   +10 score and remove coin
#     id=5 �� Enemy1: Lose life upon touch
#     id=6 �� Enemy2: Stomp �� +30 score or lose life
#     id=7 �� Flag:   Flag fall and landing logic
# The function returns with $v0 = 1 if Mario should reset, 
# otherwise $v0 = 0.
###############################################################
check_obj_collision:
    ###############################################################
    # Preserve registers on stack
    ###############################################################
    addiu $sp,$sp,-64
    sw $ra,60($sp)
    sw $s0,56($sp)
    sw $s1,52($sp)
    sw $s2,48($sp)
    sw $s3,44($sp)
    sw $s4,40($sp)
    sw $t0,36($sp)
    sw $t1,32($sp)
    sw $t2,28($sp)
    sw $t3,24($sp)
    sw $t4,20($sp)
    sw $t5,16($sp)
    sw $t6,12($sp)
    sw $t7,8($sp)
    sw $t8,4($sp)
    sw $t9,0($sp)

    ###############################################################
    # Load Mario position and dimensions
    ###############################################################
    move $s0,$s4           # Mario X
    move $s1,$s5           # Mario Y
    la   $t0,MARIO_W
    lw   $s2,0($t0)        # Mario width
    la   $t0,MARIO_H
    lw   $s3,0($t0)        # Mario height

    ###############################################################
    # Get current object array and object count dynamically
    ###############################################################
    la $t9, current_obj_arr
    lw $t0, 0($t9)         # current object array base
    la $t9, current_obj_n
    lw $t1, 0($t9)         # pointer to object count
    lw $t1, 0($t1)         # actual number of objects
    move $t2,$zero         # i = 0 (loop index)

##############################################################################################################################
# Task_2: check objects collision
# Target: Loop collision detection with different objects.
##############################################################################################################################
loop_objs:
    ###############################################################
    # --- Pseudocode: Object iteration loop ---
    ###############################################################
    # while ($t2 != $t1):                  # loop over all objects
    beq   $t2, $t1, nohit
    #     calculate current object entry address:
    #         each object = 5 words (x, y, w, h, id)
    #         offset = $t2 * 20 bytes
    #         $t4 = base address ($t0) + offset
    #
    sll   $t3, $t2, 4
    sll   $t4, $t2, 2
    addu  $t3, $t3, $t4
    addu  $t4, $t0, $t3

    #     read object data:
    #         $t5 = ox  (object X)
    #         $t6 = oy  (object Y)
    #         $t7 = ow  (object width)
    #         $t8 = oh  (object height)
    #         $t9 = id  (object ID)
    
    lw    $t5, 0($t4)
    lw    $t6, 4($t4)
    lw    $t7, 8($t4)
    lw    $t8, 12($t4)
    lw    $t9, 16($t4)
    #     if (id == 8):
    #         skip this object �� goto next_obj   # inactive object
    li    $t3, 8
    beq   $t9, $t3, next_obj

    ###############################################################
    # --- Pseudocode: AABB Collision Check (2D bounding boxes) ---
    ###############################################################
    # Check if Mario and object overlap horizontally and vertically:
    #
    # if (Mario.right < Obj.left)   �� goto next_obj
    addu  $a0, $s0, $s2
    blt   $a0, $t5, next_obj
    # if (Mario.left  > Obj.right)  �� goto next_obj
    addu  $a1, $t5, $t7
    bgt   $s0, $a1, next_obj
    # if (Mario.bottom < Obj.top)   �� goto next_obj
    addu  $a2, $s1, $s3
    blt   $a2, $t6, next_obj

    # if (Mario.top    > Obj.bottom)�� goto next_obj
    
    addu  $a3, $t6, $t8
    bgt   $s1, $a3, next_obj
    #
    # Otherwise �� collision detected
    # goto handle_obj
    j     handle_obj

    ###############################################################
    # --- Object behavior dispatch ---
    ###############################################################
handle_obj:
    # Initialize return values
    # $v0 = 0
    # $a0 = 0
    
    li    $v0, 0
    move  $a0, $zero
    
    # Dispatch by object ID:
    # if (id == 0): goto handle_door
    beq   $t9, $zero, handle_door
    # if (id == 3): goto handle_star
    li    $t3, 3
    beq   $t9, $t3, handle_star
    # if (id == 4): goto handle_coin
    li    $t3, 4
    beq   $t9, $t3, handle_coin
    # if (id == 5): goto handle_enemy1
    li    $t3, 5
    beq   $t9, $t3, handle_enemy1
    # if (id == 6): goto handle_enemy2
    li    $t3, 6
    beq   $t9, $t3, handle_enemy2
    # if (id == 7): goto handle_flag
    li    $t3, 7
    beq   $t9, $t3, handle_flag
    #
    # If none matched �� goto next_obj
    j     next_obj
##############################################################################################################################
# Task_2 End
##############################################################################################################################


    ###############################################################
    # Door (id=0): Block or switch maps when flag has landed
    ###############################################################
handle_door:
    addiu $sp, $sp, -4
    sw $t0, 0($sp)

    la  $t0, flag_landed
    lw  $t1, 0($t0)
    beqz $t1, door_skip         # Skip if flag_landed == 0
    jal clear_and_reload_map    # Switch map
    sw  $zero, 0($t0)           # Reset flag

door_skip:
    li $v0,0
    lw $t0, 0($sp)
    addiu $sp,$sp,4
    j endfunc

    ###############################################################
    # Star (id=3): +1 life and remove star
    ###############################################################
handle_star:
    li   $t0,8
    sw   $t0,16($t4)            # Disable object (id=8)
    la   $a0,life
    lw   $a1,0($a0)
    addi $a1,$a1,1
    sw   $a1,0($a0)
    move $a0,$a1
    li   $v0,5108               # Update life display
    syscall
    li $v0,0
    j endfunc

    ###############################################################
    # Coin (id=4): +10 points and remove coin
    ###############################################################
handle_coin:
    li   $t0,8
    sw   $t0,16($t4)
    la   $a0,score
    lw   $a1,0($a0)
    addi $a1,$a1,10
    sw   $a1,0($a0)
    move $a0,$a1
    li   $v0,5107               # Update score display
    syscall
    li $v0,0
    j endfunc

    ###############################################################
    # Enemy type 1 (id=5): Touch �� lose 1 life
    ###############################################################
handle_enemy1:
    la   $a0,life
    lw   $a1,0($a0)
    addi $a1,$a1,-1
    sw   $a1,0($a0)
    move $a0,$a1
    li   $v0,5108               # Update life display
    syscall
    bltz  $a1,call_full_reset_enemy
    li $v0,1                    # Return 1 �� reset state
    j endfunc

    ###############################################################
    # Enemy type 2 (id=6): Stomp detection logic
    ###############################################################
handle_enemy2:
    addu $a0,$s1,$s3            # Mario bottom
    addi $a1,$t6,16             # Enemy top + offset
    ble  $a0,$a1,stomp_ok       # Stomp from top
    j handle_enemy1             # Otherwise �� hurt Mario

stomp_ok:
    li   $t0,8
    sw   $t0,16($t4)            # Remove enemy
    la   $a0,score
    lw   $a1,0($a0)
    addi $a1,$a1,30
    sw   $a1,0($a0)
    move $a0,$a1
    li   $v0,5107               # Update score
    syscall
    li $t0,-12
    move $s6,$t0                # Mario bounces upward
    li $v0,0
    j endfunc

    ###############################################################
    # Flag (id=7): Animate flag fall, set flag_landed when done
    ###############################################################
    
   
##############################################################################################################################
# Task_5: Drop the flagpole
# Continuous collision detection with the flagpole to drop the flag
##############################################################################################################################
handle_flag:
    ###############################################################
    # Registers used:
    #   $t0 : flag Y?threshold (a constant, e.g., 170)
    #   $t1 : current flag Y position
    #   $t4 : pointer to current object entry (flag object)
    #   $t9 : temporary pointer during redraw
    #   $a0�C$a3 : arguments for draw syscall (5102)
    #   $v0 : syscall code / return value
    ###############################################################
    
    li      $t0, 170
    lw      $t1, 4($t4)

    # Compare current flag Y ($t1) with threshold ($t0)
    # if flag_y < threshold �� flag is still above ground, keep falling
    # else �� reached bottom, stop flag
    # branch accordingly
    # if ($t1 < $t0) �� goto flag_fall
    # else �� goto flag_stop
    
    blt     $t1, $t0, flag_fall
    nop
    j       flag_stop
    nop
	
flag_fall:
    ###############################################################
    # Behavior:
    # - Increase flag Y position by a small amount each frame
    # - Store updated Y back into object memory
    # - Trigger redraw of flag (syscall 5102)
    ###############################################################
    # $t1 �� $t1 + 1
    # sw $t1 �� 4($t4)                     # update flag Y
    #
    # Redraw:
    #   $t9 �� current object array base
    #   $a0�C$a3 �� image / object parameters
    #   $v0 = 5102 �� syscall              # draw flag at new position
    #
    # After redraw, jump to flag_end
    # goto flag_end
    
    
    addi    $t1, $t1, 1
    sw      $t1, 4($t4)
    la      $t9, current_obj_arr
    lw      $a0, 0($t9)

    la      $t9, current_obj_n
    lw      $t9, 0($t9)
    lw      $a1, 0($t9)

    la      $a2, img_tbl
    lw      $a3, img_tbl_n
    li      $v0, 5102
    syscall

    j       flag_end
    nop

flag_stop:
    ###############################################################
    # Behavior:
    # - Flag has landed, mark state variable flag_landed = 1
    ###############################################################
    # $t2 �� &flag_landed
    # $t3 �� 1
    # sw $t3 �� 0($t2)                     # record landing
    # goto flag_end
    
    la      $t2, flag_landed
    li      $t3, 1
    sw      $t3, 0($t2)

    j       flag_end
    nop

flag_end:
    ###############################################################
    # Cleanup / return
    # $v0 �� 0
    # goto endfunc
    li      $v0, 0
    j       endfunc
    nop
    ###############################################################
    
##############################################################################################################################
# Task_5: End
##############################################################################################################################


    ###############################################################
    # Hard reset when life < 0
    ###############################################################
call_full_reset_enemy:
    jal  full_reset
    li   $v0,1
    j endfunc

    ###############################################################
    # Loop continuation �� move to next object
    ###############################################################
next_obj:
    addi $t2,$t2,1
    j loop_objs

nohit:
    li $v0,0

    ###############################################################
    # Restore registers and return
    ###############################################################
endfunc:
    lw $t9,0($sp)
    lw $t8,4($sp)
    lw $t7,8($sp)
    lw $t6,12($sp)
    lw $t5,16($sp)
    lw $t4,20($sp)
    lw $t3,24($sp)
    lw $t2,28($sp)
    lw $t1,32($sp)
    lw $t0,36($sp)
    lw $s4,40($sp)
    lw $s3,44($sp)
    lw $s2,48($sp)
    lw $s1,52($sp)
    lw $s0,56($sp)
    lw $ra,60($sp)
    addiu $sp,$sp,64
    jr $ra
###############################################################


###############################################################
# update_enemy_positions �� Multi?Map Compatible Version
# -------------------------------------------------------------
# Purpose:
#   Iterates through all objects in the current map and updates 
#   the horizontal position of moving enemies (id=6). 
#   Each enemy moves left ? right between a fixed range (352�C400).  
#   The direction and original X position of each enemy are stored 
#   in shared arrays (enemy_dir, enemy_origin_x).  
#   The function automatically adapts to whichever map is active 
#   using `current_obj_arr` and `current_obj_n`.
#
# Behavior Summary:
#   ? Load current map object array dynamically
#   ? Identify enemies with id=6
#   ? Assign default direction if not yet initialized
#   ? Update their X position each frame
#   ? Flip direction when boundary is reached
#   ? Redraw updated objects after movement
###############################################################
update_enemy_positions:
    ###############################################################
    # Preserve registers on stack
    ###############################################################
    addiu   $sp, $sp, -32
    sw      $ra, 28($sp)
    sw      $t0, 24($sp)
    sw      $t1, 20($sp)
    sw      $t2, 16($sp)
    sw      $t3, 12($sp)
    sw      $t4, 8($sp)
    sw      $t5, 4($sp)
    sw      $t6, 0($sp)

    ###############################################################
    # Load current map's object array and object count dynamically
    ###############################################################
    la      $t0, current_obj_arr
    lw      $t0, 0($t0)         # t0 = pointer to current object array
    la      $t1, current_obj_n
    lw      $t1, 0($t1)
    lw      $t1, 0($t1)         # t1 = object count
    li      $t2, 0              # i = 0 (object index)

###############################################################
# Enemy iteration loop
###############################################################
enemy_loop:
    beq     $t2, $t1, enemy_done   # if i >= count �� done

    # compute base address for obj[i]: offset = i * 20 bytes
    li      $t3, 20
    mult    $t2, $t3
    mflo    $t3
    addu    $t4, $t0, $t3          # t4 = &obj_arr[i]

    lw      $t5, 16($t4)           # read object id
    li      $t3, 6                 # target id = 6 (enemy2)
    bne     $t5, $t3, next_enemy   # skip non-enemy objects

###############################################################
# Process enemy movement for this object
###############################################################
##############################################################################################################################
# Task_4: Move the Goomba
# Just Make Goomba move horizontally!!!
##############################################################################################################################
do_move:
    ###############################################################
    # Load or initialize enemy direction
    la      $t5, enemy_dir
    sll     $t7, $t2, 2
    addu    $t5, $t5, $t7
    ###############################################################
    # direction_ptr = &enemy_dir[i]
    # direction = *direction_ptr
    #
    lw      $t6, 0($t5)
    # if direction == 0:
    #     direction = +1                     # default: move right
    #     *direction_ptr = +1
    li      $t7, 1
    movz    $t6, $t7, $t6            # default to +1 if direction is zero
    sw      $t6, 0($t5)              # persist default when applied
    
    
    ###############################################################
    # Store initial X position if first run
    ###############################################################
    # if enemy_origin_x[i] not set:
    #     enemy_origin_x[i] = 352            # starting X coordinate
    la      $t5, enemy_origin_x
    sll     $t7, $t2, 2
    addu    $t5, $t5, $t7
    lw      $t3, 0($t5)
    bnez    $t3, has_direction
    nop
    li      $t3, 352
    sw      $t3, 0($t5)

has_direction:
    ###############################################################
    # Apply horizontal movement
    ###############################################################
    # obj.x = obj.x + direction              # move enemy horizontally
    # store obj.x back to memory
    
    lw      $t3, 0($t4)              # let $t3 = obj.x
    addu    $t3, $t3, $t6            # obj.x + direction = t3
    sw      $t3, 0($t4)

    ###############################################################
    # Boundary detection and direction reversal
    ###############################################################
    # boundaries: left = 352, right = 400
    #
    # if obj.x > 400:
    #     direction = -1                     # flip to move left
    li      $t5, 400
    bgt     $t3, $t5, flip_to_left
    nop
    # elif obj.x < 352:
    #     direction = +1                     # flip to move right
    li      $t5, 352
    blt     $t3, $t5, flip_to_right
    nop
    # *direction_ptr = direction
    j       save_direction
    nop
    # goto next_enemy
##############################################################################################################################
# Task_4 End
##############################################################################################################################

flip_to_left:
    li      $t6, -1
    j       save_direction

flip_to_right:
    li      $t6, 1

###############################################################
# Save reversed direction state into enemy_dir
###############################################################
save_direction:
    la      $t5, enemy_dir
    sll     $t7, $t2, 2
    addu    $t5, $t5, $t7
    sw      $t6, 0($t5)

###############################################################
# Proceed to next object
###############################################################
next_enemy:
    addi    $t2, $t2, 1
    j       enemy_loop

###############################################################
# End of enemy loop �� redraw all objects on the current map
###############################################################
enemy_done:
    la   $a0, current_obj_arr
    lw   $a0, 0($a0)
    la   $t0, current_obj_n
    lw   $t0, 0($t0)
    lw   $a1, 0($t0)
    la   $a2, img_tbl
    lw   $a3, img_tbl_n
    li   $v0, 5102                # syscall: draw objects
    syscall

    ###############################################################
    # Restore registers and return
    ###############################################################
    lw      $t6, 0($sp)
    lw      $t5, 4($sp)
    lw      $t4, 8($sp)
    lw      $t3, 12($sp)
    lw      $t2, 16($sp)
    lw      $t1, 20($sp)
    lw      $t0, 24($sp)
    lw      $ra, 28($sp)
    addiu   $sp, $sp, 32
    jr      $ra
###############################################################



###############################################################
# update_camera �� Smooth Camera Follow & Boundary Limits
# -------------------------------------------------------------
# Purpose:
#   Smoothly follows Mario��s position with lag constraint while
#   keeping the camera scrollX value within screen boundaries.
#
# Behavior Summary:
#   ? Calculate target scroll position = MarioX - CENTER_X
#   ? Clamp left at 0 to avoid negative scrolling
#   ? Smoothly move camera toward target by a small lag step
#   ? Clamp scroll value when reaching the right world limit
###############################################################
update_camera:
    addiu   $sp, $sp, -24
    sw      $ra, 20($sp)
    sw      $t0, 16($sp)
    sw      $t1, 12($sp)
    sw      $t2, 8($sp)
    sw      $t3, 4($sp)
    sw      $t4, 0($sp)

    ###############################################################
    # Compute target scrollX = MarioX - CENTER_X
    ###############################################################
    sub     $t0, $s4, $s0
    bltz    $t0, uc_force_zero     # Clamp scroll to minimum (0)
    j       uc_target_ok
uc_force_zero:
    li      $t0, 0
uc_target_ok:

    ###############################################################
    # Compute difference between target and current scroll
    ###############################################################
    sub     $t1, $t0, $s3
    beqz    $t1, uc_done           # No change needed
    bltz    $t1, uc_done           # Prevent scrolling backward

    ###############################################################
    # Apply smooth camera motion using camera_lag
    ###############################################################
    la      $t2, camera_lag
    lw      $t2, 0($t2)
    bgt     $t1, $t2, uc_use_lag
    move    $t2, $t1
uc_use_lag:
    add     $s3, $s3, $t2          # Move scrollX forward by small step

    ###############################################################
    # Apply right boundary clamp
    ###############################################################
    bgt     $s3, $s1, uc_clamp_right
    j       uc_done
uc_clamp_right:
    move    $s3, $s1

uc_done:
    ###############################################################
    # Restore registers and return
    ###############################################################
    lw      $t4, 0($sp)
    lw      $t3, 4($sp)
    lw      $t2, 8($sp)
    lw      $t1, 12($sp)
    lw      $t0, 16($sp)
    lw      $ra, 20($sp)
    addiu   $sp, $sp, 24
    jr      $ra


###############################################################
# resolve_horizontal �� Horizontal Collision (Dynamic Map)
# -------------------------------------------------------------
# Purpose:
#   Checks predicted horizontal movement against all objects in 
#   the current map. Adjusts Mario��s X position and velocity if 
#   a collision occurs with a solid object.
#
# Behavior Summary:
#   ? Predict next X position with vx
#   ? Skip non-collidable objects (id = 3,4,5,6,7,8)
#   ? Perform AABB intersection test
#   ? Stop Mario movement when collision detected
###############################################################
resolve_horizontal:
    addiu   $sp, $sp, -52
    sw      $ra, 48($sp)
    sw      $s0, 44($sp)
    sw      $s1, 40($sp)
    sw      $s2, 36($sp)
    sw      $t0, 32($sp)
    sw      $t1, 28($sp)
    sw      $t2, 24($sp)
    sw      $t3, 20($sp)
    sw      $t4, 16($sp)
    sw      $t5, 12($sp)
    sw      $t6, 8($sp)
    sw      $t7, 4($sp)
    sw      $t8, 0($sp)

    ###############################################################
    # Predict Mario next X position
    ###############################################################
    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    add     $s0, $s0, $s2

    la      $t0, MARIO_W
    lw      $t0, 0($t0)
    la      $t1, MARIO_H
    lw      $t1, 0($t1)

    ###############################################################
    # Load current map object array dynamically
    ###############################################################
    la      $t7, current_obj_arr
    lw      $t4, 0($t7)
    la      $t7, current_obj_n
    lw      $t5, 0($t7)
    lw      $t5, 0($t5)
    move    $t6, $zero

##############################################################################################################################
# Task_3: Wall collision
# Collision detection with solid objects which will stop the mario.
##############################################################################################################################

rh_loop:
    ###############################################################
    # if (loop_index == total_objects) �� done
    ###############################################################
    beq $t6, $t5, rh_done

    # Compute pointer to current object:
    #   offset = i * 20  # (5 words per object)
    #   objPtr = objBase + offset
    
    sll     $t2, $t6, 4
    sll     $t3, $t6, 2
    addu    $t2, $t2, $t3
    addu    $t3, $t4, $t2
    
    # Load from object table:
    #   obj.x  = [0]
    #   obj.y  = [4]
    #   obj.w  = [8]
    #   obj.h  = [12]
    #   obj.id = [16]
    
    lw      $t7, 0($t3) #base, [0], 4 bytes per unit
    lw      $t8, 4($t3)
    lw      $a2, 8($t3)
    lw      $a3, 12($t3)
    lw      $t9, 16($t3)

    ###############################################################
    # Skip objects that are non-collidable (id = 3,4,5,6,7,8)
    ###############################################################
    # if (obj.id in {3,4,5,6,7,8}) �� goto rh_next
    
    li      $t2, 3
    beq     $t9, $t2, rh_next
    li      $t2, 4
    beq     $t9, $t2, rh_next
    li      $t2, 5
    beq     $t9, $t2, rh_next
    li      $t2, 6
    beq     $t9, $t2, rh_next
    li      $t2, 7
    beq     $t9, $t2, rh_next
    li      $t2, 8
    beq     $t9, $t2, rh_next
    
    
    addu    $a2, $t7, $a2
    addu    $a3, $t8, $a3
    ###############################################################
    # Axis-Aligned Rectangle Overlap Test (AABB)
    ###############################################################
    # if (Mario.right <= Obj.left)   �� rh_next
    addu    $t2, $s0, $t0
    ble     $t2, $t7, rh_next
    # if (Mario.left  >= Obj.right)  �� rh_next
    bge     $s0, $a2, rh_next
    # if (Mario.bottom <= Obj.top)   �� rh_next
    addu    $t3, $s1, $t1
    ble     $t3, $t8, rh_next
    # if (Mario.top    >= Obj.bottom)�� rh_next
    bge     $s1, $a3, rh_next
   
    # Otherwise �� collision detected
    

    ###############################################################
    # Collision Response (horizontal)
    ###############################################################
    # if (Mario.velocityX > 0):          # moving right
    #     Mario.x = Obj.left - Mario.width
    #     Mario.velocityX = 0
    #     goto rh_done
    #
    # else (moving left):
    #     Mario.x = Obj.right
    #     Mario.velocityX = 0
    #     goto rh_done
    blez    $s2, rh_hit_left
    subu    $s0, $t7, $t0
    move    $s2, $zero
    j       rh_done
    
rh_hit_left:
    ###############################################################
    # Left collision branch (mirrors logic above)
    ###############################################################
    # Mario.x = Obj.right
    move    $s0, $a2
    # Mario.velocityX = 0
    move    $s2, $zero
    # goto rh_done
    j       rh_done

rh_next:
    ###############################################################
    # Next object iteration
    ###############################################################
    # loop_index += 1
    addiu   $t6, $t6, 1
    # goto rh_loop
    j       rh_loop

##############################################################################################################################
# Task_3: End
##############################################################################################################################

rh_done:
    move    $v0, $s0
    move    $v1, $s2

    ###############################################################
    # Restore registers
    ###############################################################
    lw      $t8, 0($sp)
    lw      $t7, 4($sp)
    lw      $t6, 8($sp)
    lw      $t5, 12($sp)
    lw      $t4, 16($sp)
    lw      $t3, 20($sp)
    lw      $t2, 24($sp)
    lw      $t1, 28($sp)
    lw      $t0, 32($sp)
    lw      $s2, 36($sp)
    lw      $s1, 40($sp)
    lw      $s0, 44($sp)
    lw      $ra, 48($sp)
    addiu   $sp, $sp, 52
    jr      $ra


###############################################################
# resolve_vertical �� Vertical Collision (Dynamic Map)
# -------------------------------------------------------------
# Purpose:
#   Checks predicted vertical movement for Mario and applies 
#   collision response to prevent passing through solid surfaces.
#
# Behavior Summary:
#   ? Predict next Y coordinate
#   ? Ignore non-solid objects
#   ? Detect ground or head hit using AABB
#   ? Adjust Y position, velocity and onGround flag accordingly
###############################################################
resolve_vertical:
    addiu   $sp, $sp, -52
    sw      $ra, 48($sp)
    sw      $s0, 44($sp)
    sw      $s1, 40($sp)
    sw      $s2, 36($sp)
    sw      $t0, 32($sp)
    sw      $t1, 28($sp)
    sw      $t2, 24($sp)
    sw      $t3, 20($sp)
    sw      $t4, 16($sp)
    sw      $t5, 12($sp)
    sw      $t6, 8($sp)
    sw      $t7, 4($sp)
    sw      $t8, 0($sp)

    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    add     $s1, $s1, $s2        # predict Y = y + vy

    la      $t0, MARIO_W
    lw      $t0, 0($t0)
    la      $t1, MARIO_H
    lw      $t1, 0($t1)
    la      $t4, BOUNCE_DOWN
    lw      $t4, 0($t4)

    la      $t9, onGround
    sw      $zero, 0($t9)

    ###############################################################
    # Dynamic object list iteration
    ###############################################################
    la      $t9, current_obj_arr
    lw      $t5, 0($t9)
    la      $t9, current_obj_n
    lw      $t6, 0($t9)
    lw      $t6, 0($t6)
    move    $t7, $zero

rv_loop:
    beq     $t7, $t6, rv_done
    sll     $a3, $t7, 4
    sll     $v0, $t7, 2
    addu    $a3, $a3, $v0
    addu    $a3, $t5, $a3

    lw      $v0, 0($a3)
    lw      $v1, 4($a3)
    lw      $t2, 8($a3)
    lw      $t3, 12($a3)
    lw      $t8, 16($a3)

    # Skip non-solid objects
    beq     $t8, 8, rv_next
    beq     $t8, 7, rv_next
    beq     $t8, 3, rv_next
    beq     $t8, 4, rv_next
    beq     $t8, 5, rv_next
    beq     $t8, 6, rv_next

    ###############################################################
    # AABB collision test
    ###############################################################
    addu    $t8, $v0, $t2
    bge     $s0, $t8, rv_next
    addu    $t8, $s0, $t0
    ble     $t8, $v0, rv_next
    addu    $t8, $v1, $t3
    bge     $s1, $t8, rv_next
    addu    $t8, $s1, $t1
    ble     $t8, $v1, rv_next

    ###############################################################
    # Collision response (ground or head hit)
    ###############################################################
    blez    $s2, rv_head          # upward motion: head collision
    sub     $s1, $v1, $t1         # align Mario on top of surface
    move    $s2, $zero
    la      $t9, onGround
    li      $t8, 1
    sw      $t8, 0($t9)
    j       rv_done

rv_head:
    addu    $s1, $v1, $t3         # push Mario below block
    addu    $s2, $s2, $t4         # small bounce down
    j       rv_done

rv_next:
    addiu   $t7, $t7, 1
    j       rv_loop

rv_done:
    move    $v0, $s1
    move    $v1, $s2

    ###############################################################
    # Restore registers and return
    ###############################################################
    lw      $t8, 0($sp)
    lw      $t7, 4($sp)
    lw      $t6, 8($sp)
    lw      $t5, 12($sp)
    lw      $t4, 16($sp)
    lw      $t3, 20($sp)
    lw      $t2, 24($sp)
    lw      $t1, 28($sp)
    lw      $t0, 32($sp)
    lw      $s2, 36($sp)
    lw      $s1, 40($sp)
    lw      $s0, 44($sp)
    lw      $ra, 48($sp)
    addiu   $sp, $sp, 52
    jr      $ra
###############################################################



###############################################################
# full_reset �� Dynamic Game Reset Based on Current Map
# -------------------------------------------------------------
# Purpose:
#   Performs a full level reset based on the value of `current_map`.
#   This includes resetting score and life values, refreshing HUD, 
#   restoring original object data for either Map 1 or Map 2, and 
#   repositioning Mario to his initial coordinates.
#
# Behavior Summary:
#   ? Reset life/score values and sync HUD display
#   ? Check which map is active (1 or 2)
#   ? Restore corresponding map objects and background
#   ? Reinitialize Mario��s state at default spawn
###############################################################
full_reset:
    ###############################################################
    # Initialize life/score and update UI displays
    ###############################################################
    la   $t0, life
    li   $t1, 1              # Set life to 1 (initial default)
    sw   $t1, 0($t0)

    la   $t0, score
    li   $t1, 0              # Reset score to zero
    sw   $t1, 0($t0)

    # Update life on HUD
    la   $a0, life
    lw   $a0, 0($a0)
    li   $v0, 5108           # Syscall: update life display
    syscall

    # Update score on HUD
    la   $a0, score
    lw   $a0, 0($a0)
    li   $v0, 5107           # Syscall: update score display
    syscall

    ###############################################################
    # Determine current map and jump to appropriate restore routine
    ###############################################################
    la   $t9, current_map
    lw   $t8, 0($t9)
    li   $t7, 1
    beq  $t8, $t7, restore_map1
    li   $t7, 2
    beq  $t8, $t7, restore_map2
    # Fallback �� restore Map 1 by default
    j restore_map1


###############################################################
# restore_map1 �� Restore and Redraw Map 1
# -------------------------------------------------------------
# Purpose:
#   Copies object data from original Map 1 array to runtime array,
#   redraws the background and objects, and updates global pointers.
###############################################################
restore_map1:
    la   $t0, obj_arr_1_orig
    la   $t1, obj_arr_1
    la   $t2, obj_n_1
    lw   $t2, 0($t2)
    li   $t3, 0

restore_loop_1:
    beq  $t3, $t2, redraw_stage
    li   $t4, 20
    mult $t3, $t4
    mflo $t4
    addu $t5, $t0, $t4
    addu $t6, $t1, $t4

    # Copy block of 5 words per object (x,y,w,h,id)
    lw   $t7, 0($t5)
    sw   $t7, 0($t6)
    lw   $t7, 4($t5)
    sw   $t7, 4($t6)
    lw   $t7, 8($t5)
    sw   $t7, 8($t6)
    lw   $t7, 12($t5)
    sw   $t7, 12($t6)
    lw   $t7, 16($t5)
    sw   $t7, 16($t6)

    addi $t3, $t3, 1
    j restore_loop_1

###############################################################
# Redraw background and objects for Map 1
###############################################################
redraw_stage:
    # Draw map background
    la $a0, imgpath
    li $v0, 5100
    syscall

    # Draw object layer
    la $a0, obj_arr_1
    la $t0, obj_n_1
    lw $a1, 0($t0)
    la $a2, img_tbl
    lw $a3, img_tbl_n
    li $v0, 5102
    syscall

    ###############################################################
    # Update current object pointers for runtime rendering
    ###############################################################
    la $t0, current_obj_arr
    la $t1, obj_arr_1
    sw $t1, 0($t0)
    la $t0, current_obj_n
    la $t1, obj_n_1
    sw $t1, 0($t0)
    la $t0, current_bg_path
    la $t1, imgpath
    sw $t1, 0($t0)

    ###############################################################
    # Reset Mario state at end of restoration
    ###############################################################
    j reset_player_state


###############################################################
# restore_map2 �� Restore and Redraw Map 2
# -------------------------------------------------------------
# Purpose:
#   Performs identical restoration as Map 1 but for Map 2 data.
#   Restores all object entries, redraws background and sprites,
#   updates global pointers, and resets Mario to initial position.
###############################################################
restore_map2:
    la   $t0, obj_arr_2_orig
    la   $t1, obj_arr_2
    la   $t2, obj_n_2
    lw   $t2, 0($t2)
    li   $t3, 0

restore_loop_2:
    beq  $t3, $t2, redraw_stage2
    li   $t4, 20
    mult $t3, $t4
    mflo $t4
    addu $t5, $t0, $t4
    addu $t6, $t1, $t4

    # Copy (x,y,w,h,id)
    lw   $t7, 0($t5)
    sw   $t7, 0($t6)
    lw   $t7, 4($t5)
    sw   $t7, 4($t6)
    lw   $t7, 8($t5)
    sw   $t7, 8($t6)
    lw   $t7, 12($t5)
    sw   $t7, 12($t6)
    lw   $t7, 16($t5)
    sw   $t7, 16($t6)

    addi $t3, $t3, 1
    j restore_loop_2

###############################################################
# Redraw Map 2 background and objects
###############################################################
redraw_stage2:
    # Draw background for Map 2
    la $a0, imgpath_1
    li $v0, 5100
    syscall

    # Draw object layer for Map 2
    la $a0, obj_arr_2
    la $t0, obj_n_2
    lw $a1, 0($t0)
    la $a2, img_tbl
    lw $a3, img_tbl_n
    li $v0, 5102
    syscall

    ###############################################################
    # Update current object references for Map 2
    ###############################################################
    la $t0, current_obj_arr
    la $t1, obj_arr_2
    sw $t1, 0($t0)
    la $t0, current_obj_n
    la $t1, obj_n_2
    sw $t1, 0($t0)
    la $t0, current_bg_path
    la $t1, imgpath_1
    sw $t1, 0($t0)

    ###############################################################
    # Reset and redraw player state after restoring Map 2
    ###############################################################
    j reset_player_state


###############################################################
# reset_player_state �� Reset Mario & UI State
# -------------------------------------------------------------
# Purpose:
#   Resets Mario��s state including position, scroll, velocity,
#   facing direction, and onGround flag. Draws one frame update
#   for visual refresh following a map reset.
###############################################################
reset_player_state:
    li $s3, 0           # scrollX reset
    li $s4, 32          # Mario X starting position
    la $t1, GROUND_Y
    lw $t1, 0($t1)
    la $t2, MARIO_H
    lw $t2, 0($t2)
    sub $s5, $t1, $t2    # Y = groundY - Mario height
    li $s6, 0            # vy = 0
    li $s7, 1            # facing right
    la $t3, onGround
    li $t4, 1
    sw $t4, 0($t3)

    ###############################################################
    # Draw a single updated frame
    ###############################################################
    move $a0, $s3
    move $a1, $s4
    move $a2, $s5
    li   $a3, 0
    move $v1, $s7
    li   $v0, 5101
    syscall
    jr $ra


###############################################################
# exit �� End Simulation / Clean Exit Routine
# -------------------------------------------------------------
# Purpose:
#   Stops background audio, resets score/life, refreshes HUD, 
#   and terminates the game simulation using syscall 10.
###############################################################
exit:
    ###############################################################
    # Stop any ongoing background music playback
    ###############################################################
    li      $v0, 5123
    syscall

    ###############################################################
    # Reset HUD parameters for exit state
    ###############################################################
    li      $t0, 1
    la      $t1, score
    sw      $t0, 0($t1)
    la      $t1, life
    sw      $t0, 0($t1)

    ###############################################################
    # Update on-screen HUD: Score + Life
    ###############################################################
    move    $a0, $t0
    li      $v0, 5107
    syscall
    move    $a0, $t0
    li      $v0, 5108
    syscall

    ###############################################################
    # Terminate program (syscall 10)
    ###############################################################
    li      $v0, 10
    syscall
###############################################################
