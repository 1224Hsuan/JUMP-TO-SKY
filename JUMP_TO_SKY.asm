TITLE JUMP_TO_SKY of ASM              (JUMP_TO_SKY.ASM)

INCLUDE Irvine32.inc
INCLUDE Macros.inc
 
.data
;consoleHandle    DWORD ?
outHandle HANDLE ?
cellsWritten DWORD ?
xyBound COORD <80,25>
xyPos COORD <56,10>

buffer BYTE " ",13,13,13,13," "," "," "," "," "," "," "," ",13,13,13,13				;17個字元
	BYTE " "," "," "," "," "," "," "," "," "," ",14,14,14,14,14," "," "," "," "," "," "," "," "," "," "	;25個字元
	BYTE 13,13,13,13," "," "," "," "," "," "," "," ",14,14,14,14,14," "			;18個字元，用以表示音符的字串
bufSize DWORD ($-buffer)
attributes WORD 0dh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,4,4,4,4,4,4,4
	WORD 4,4,4,4,4,4,4,4,4,4,0bh,0bh,0bh,0bh,0bh,0bh,0bh,0bh,4,4,4,4,4,4,4,4,4,4,4,4;設定音符字串的顏色
ClearCloud BYTE " "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "
	BYTE " "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "
	BYTE " "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "		;清空音符的字串
Monster1 BYTE " "," "," ",4," "," "," "," "," ",4," "," "," "
Monster2 BYTE " "," ",4,4,4," "," "," ",4,4,4," "," "
Monster3 BYTE " ",4,4,3, 4,4," ",4,4,4, 4,4," "
Monster4 BYTE 4,4,4,4,4,4,4,4,4,4,4,4,4
Monster5 BYTE " ",4,4,4,4,4,4,4,4,4, 4,4," "
Monster6 BYTE " "," ",4,4,4,4,4,4,4,4,4," "," "
Monster7 BYTE " "," "," ",4,4,4,4,4,4,4," "," "," "					;跳躍失敗時，出現小怪獸的圖
Monsterc WORD 0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah
Monstere WORD 0ah,0ah,0ah,0dh,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah			;設定小怪獸的顏色
Lives BYTE 3," "," ",3," "," ",3							;以愛心代表生命值(生命值全滿時)
Lives1 BYTE 3," "," ",3," "," "," "							;生命值剩兩顆愛心時
Lives2 BYTE 3," "," "," "," "," "," "						;生命值剩三顆愛心時
Livesc WORD 4,4,4,4,4,4,4							;設定愛心的顏色為紅色
Back BYTE 7								;設定圓點符號，作為背景圖案
Backc1 WORD 0bh								;淺藍色
Backc2 WORD 0ch								;紅色
Backc3 WORD 0ah								;綠色
Backc4 WORD 0eh								;黃色
Backc5 WORD 0dh								;紫色

personch1 BYTE 2								;設定遊戲人物的人頭
personch2 BYTE 17,6,16							;設定遊戲人物的身體
personco1 WORD 0eh
personco2 WORD 0eh,0eh,0eh							;設定遊戲人物的顏色為黃色
erase BYTE " "," "," "								;作為遊戲人物移動時，清空人物的字串

Score BYTE "    Score", 0							;遊戲畫面計分區字串
ScoreSpace BYTE "      ", 0							;輸出分數前的空白字串，用以對齊
TotalScore DWORD ?							;以TotalScore作為計分的變數

personcoordx WORD ?
personcoordy WORD ?							;以personcoordx,personcoordy記錄遊戲人物人頭初始座標
RecordMove BYTE ?								;以RecordMove記錄遊戲人物是否跳躍成功
CloudDownx WORD ?								;以CloudDownx記錄人物跳至音符上時，音符的輸出起始x座標
Count WORD ?								;以Count記錄跳躍次數
LeftLives BYTE ?								;以LeftLives記錄生命值

GameName BYTE "                                		JUMP TO SKY", 0
Rule BYTE "					Game Rules", 0
Rule1 BYTE "					1. Red Note : -20 points", 0
Rule2 BYTE "					2. Blue Note : +10 points", 0
Rule3 BYTE "					3. Purple Note : +50 points", 0
Rule4 BYTE "					4. Press 'Shift' to jump", 0
Rule5 BYTE "					5. When the jump fails, the game is over", 0
Mention BYTE "					Now, press 'Up' to start the game !", 0		;設定起始畫面輸出字串

GameOver BYTE "						Game Over",0
Points1 BYTE "					Score : ", 0
Points2 BYTE " points", 0
Question1 BYTE "					Press 'Up' to try again.", 0
Question2 BYTE "					Press 'Down' to exit.", 0			;設定遊戲結束畫面輸出字串

main          EQU start@0

.code
Monster PROC									;設定小怪獸出現畫面
	push xyPos.y
	push xyPos.x								;因會改變xyPos.y,xyPos.x的值，故先將其放入堆疊
	mov xyPos.x, 50
	mov xyPos.y, 20								;設定小怪獸第一排字串的起始輸出位置
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monsterc,
		LENGTHOF Monster1, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster1, LENGTHOF Monster1, xyPos, ADDR cellsWritten
	inc xyPos.y								;依序向下輸出小怪獸的字串
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monsterc,
		LENGTHOF Monster2, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster2, LENGTHOF Monster2, xyPos, ADDR cellsWritten
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monstere,
		LENGTHOF Monster3, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster3, LENGTHOF Monster3, xyPos, ADDR cellsWritten
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monsterc,
		LENGTHOF Monster4, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster4, LENGTHOF Monster4, xyPos, ADDR cellsWritten
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monsterc,
		LENGTHOF Monster5, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster5, LENGTHOF Monster5, xyPos, ADDR cellsWritten
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monsterc,
		LENGTHOF Monster6, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster6, LENGTHOF Monster6, xyPos, ADDR cellsWritten
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Monsterc,
		LENGTHOF Monster7, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Monster7, LENGTHOF Monster7, xyPos, ADDR cellsWritten
	pop xyPos.x
	pop xyPos.y								;復原xyPos.x,xyPos.y的初始值
	ret									;return
Monster ENDP
main PROC	
INVOKE  GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax
mov ecx, 10
mov bx, 0
Background1:								;設定起始畫面及背景
	call Crlf
	dec ecx
	.IF ecx > 0
		jmp Background1
	.ENDIF								;以jump指令先進行多次換行，將字串於較接近中間的位置輸出
	mov eax, 14
	call SetTextColor							;將eax值設為14，將欲輸出的字串顏色設為黃色
	mov edx, OFFSET GameName
	call WriteString							;輸出遊戲名稱
	call Crlf
	call Crlf
	mov eax, 0dh
	call SetTextColor							;將eax值設為0dh，將欲輸出的字串顏色設為紫色
	mov edx, OFFSET Rule
	call WriteString							;輸出"Game Rules"字串
	call Crlf
	mov eax, 15
	call SetTextColor							;將eax值設為15，將欲輸出的字串顏色設為白色
	mov edx, OFFSET Rule1
	call WriteString							;逐行輸出遊戲規則
	call Crlf
	mov edx, OFFSET Rule2
	call WriteString
	call Crlf
	mov edx, OFFSET Rule3
	call WriteString
	call Crlf
	mov edx, OFFSET Rule4
	call WriteString
	call Crlf
	mov edx, OFFSET Rule5
	call WriteString
	call Crlf
	call Crlf
	mov eax, 3	
	call SetTextColor							;將eax值設為3，將欲輸出的字串顏色設為藍色
	mov edx, OFFSET Mention
	call WriteString							;輸出提醒玩家開始遊戲的字串
	push xyPos.x
	push xyPos.y							;因後續會改變xyPos.x,xyPos.y的值，故先以堆疊記錄
	mov xyPos.x, 5
	mov xyPos.y, 7
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten	;於特定座標輸出特定字串(圓點)，作為背景
	mov xyPos.x, 100
	mov xyPos.y, 20
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc3,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 96
	mov xyPos.y, 13
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 11
	mov xyPos.y, 20
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 30
	mov xyPos.y, 23
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc3,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 113
	mov xyPos.y, 8
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc4,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 80
	mov xyPos.y, 3
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 50
	mov xyPos.y, 5
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 30
	mov xyPos.y, 10
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc4,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 70
	mov xyPos.y, 25
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	pop xyPos.y
	pop xyPos.x							;復原xyPos.x,xyPos.y的初始值
Continue:									;等待玩家開始遊戲(按向上按鍵)
	call ReadChar							;以ReadChar讀取鍵盤輸入
	.IF ax == 4800h
		call Clrscr							;若按下向上按鍵，則清空畫面，準備進行下一場景的設定
	.ELSE
		jmp Continue						;若非向上按鍵，則重複執行call ReadChar，直到讀取到向上按鍵
	.ENDIF
	mov ebx, 0							;以ebx記錄分數，故先將其歸零
	mov al, 3								;以al記錄生命值個數，故先將其設為3
Start:									;設定遊戲起始分數、生命值，以及場景
	mov LeftLives, al							;將記錄生命值的變數(LeftLives)設為al的值
	mov xyPos.x, 56
	mov xyPos.y, 10							;設定音符起始座標
	push xyPos.x
	push xyPos.y							;以堆疊記錄音符初始x,y座標
	mov xyPos.x, 11
	mov xyPos.y, 5							;設定顯示生命值的座標
	.IF LeftLives == 3							;依據LeftLives的值，判斷輸出不同愛心個數的字串
		INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Livesc,
			LENGTHOF Lives, xyPos, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter,
			outHandle, ADDR Lives, LENGTHOF Lives, xyPos, ADDR cellsWritten
	.ENDIF
	.IF LeftLives == 2
		INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Livesc,
			LENGTHOF Lives1, xyPos, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter,
			outHandle, ADDR Lives1, LENGTHOF Lives1, xyPos, ADDR cellsWritten
	.ENDIF
	.IF LeftLives == 1
		INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Livesc,
			LENGTHOF Lives2, xyPos, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter,
			outHandle, ADDR Lives2, LENGTHOF Lives2, xyPos, ADDR cellsWritten
	.ENDIF
	mov xyPos.x, 80
	mov xyPos.y, 25							;於特定座標輸出特定字串(圓點)，作為背景
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc5,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 40
	mov xyPos.y, 23
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc3,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 10
	mov xyPos.y, 24
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 23
	mov xyPos.y, 26
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 30
	mov xyPos.y, 22
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc4,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 75
	mov xyPos.y, 21
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 95
	mov xyPos.y, 27
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc4,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 110
	mov xyPos.y, 23
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	pop xyPos.y
	pop xyPos.x							;復原xyPos.x,xyPos.y的值
	mov RecordMove, 3							;以RecordMove記錄跳躍成功與否(0、1)，故先將其設為1與0以外的數
	mov Count, 0							;以Count記錄跳躍次數，故先將其歸零
	call Crlf
	mov eax, 3
	call SetTextColor							;將eax值設為3，將欲輸出的字串顏色設為藍色
	mov edx, OFFSET Score
	call WriteString							;輸出"Score"字串
	call Crlf
	mov edx, OFFSET ScoreSpace
	call WriteString							;換行後輸出分數前的空白字串，藉此將分數與上方"Score"字串對齊
	mov TotalScore, ebx							;將TotalScore設為ebx的值
	mov eax, TotalScore
	call WriteDec							;以十進位形式將TotalScore輸出
Person:
	push xyPos.y
	push xyPos.x							;以堆疊記錄xyPos.x,xyPos.y初始值
	add xyPos.y, 7							;設定遊戲人物的人頭座標，並於後續輸出
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco1,		;輸出遊戲人物的人頭
		LENGTHOF personch1, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch1, LENGTHOF personch1, xyPos, ADDR cellsWritten
	mov bx, xyPos.x
	mov personcoordx, bx
	mov bx, xyPos.y
	mov personcoordy, bx						;以personcoordx,personcoordy記錄遊戲人物初始座標
	add xyPos.y, 1
	sub xyPos.x, 1
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco2,		;輸出遊戲人物的身體
		LENGTHOF personch2, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch2, LENGTHOF personch2, xyPos, ADDR cellsWritten
	pop xyPos.x
	pop xyPos.y							;復原xyPos.x,xyPos.y起始值
Cloud:									;輸出音符字串，依據是否跳躍成功跳至不同區塊的程式碼
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR buffer, BufSize, xyPos, ADDR cellsWritten		;輸出音符字串
		mov ecx, 9							;將ecx設為9，作為後續記錄人物或人物與音符向下移動一單位的次數
	.IF RecordMove == 1							;若人物有成功跳上音符
		push xyPos.x
		push xyPos.y						;以堆疊記錄目前座標
		mov RecordMove, 3						;將RecordMove設為非0與1的數
		jmp MoveDown						;跳至控制人物與音符一同向下移動的程式區塊
	.ENDIF
	.IF RecordMove == 0							;若跳躍失敗
		push xyPos.x
		push xyPos.y						;以堆疊記錄目前座標
		mov RecordMove, 3						;將RecordMove設為非0與1的數
		mov dx, personcoordx
		mov xyPos.x, dx
		sub xyPos.y, 2						;將座標移置目前人物的所在座標
		call Monster						;顯示小怪獸
		jmp PersonDown						;跳至控制人物向下移動的程式區塊
	.ENDIF
MOVEL:									;控制音符向左移動
	mov bl, 0								;以bl記錄音符移動方向(0向左，1向右)
	.IF xyPos.x == 0h							;(設定x座標0為左邊界)若到達邊界
		mov bl, 1
		jmp MOVER						;跳至音符向右移動程式區塊
	.ENDIF
	sub xyPos.x, 1							;若尚未到邊界(繼續向左移)，將當前x座標減1
	jmp Cloud2
MOVER:									;控制音符向右移動
	.IF xyPos.x == 39h							;若音符字串起始座標為39h
		mov bl, 0
		jmp MOVEL						;跳至音符向左移動程式區塊
	.ENDIF
	add xyPos.x, 1							;若尚未到邊界(繼續向右移)，將當前x座標加1
	jmp Cloud2
Cloud2:									;進行音符的移動，並判斷Shift是否被按下
	INVOKE Sleep, 60							;時間延遲0.06秒執行
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR buffer, BufSize, xyPos, ADDR cellsWritten		;將音符輸出至新的座標
	INVOKE GetKeyState, VK_RShift					;讀取右Shift鍵狀態
	test eax, 8000h							;若右Shift被按下，則eax值為8000h
	.IF !Zero?								;若被按下
		inc Count							;將記錄跳躍次數Count遞增
		jmp PersonMove1						;跳至人向上移動的程式碼區塊
	.ENDIF
	INVOKE GetKeyState, VK_LShift					;讀取左Shift鍵狀態
	test eax, 8000h							;若左Shift被按下，則eax值為8000h
	.IF !Zero?								;若被按下
		inc Count							;將記錄跳躍次數Count遞增
		jmp PersonMove1						;跳至人向上移動的程式碼區塊
	.ENDIF
	cmp bl, 0								;若未按下Shift鍵，則依據bl的值，判斷向左或向右移
	je MOVEL
	jne MOVER
PersonMove1:								;進行人物跳躍相關座標及暫存器設定
	mov ecx, 9								;預計向上移動9單位，故將ecx值設為9
	push xyPos.y
	push xyPos.x							;以堆疊記錄xyPos.x,xyPos.y的值(音符輸出起始座標)
	mov dx, personcoordy
	mov xyPos.y, dx
	mov dx, personcoordx
	mov xyPos.x, dx							;將座標設為遊戲人物初始人頭座標
PersonMove2:								;進行人物連續向上動作
	push xyPos.y
	push xyPos.x							;記錄人物頭的座標
	push ecx
	dec xyPos.y
	INVOKE Sleep, 50							;時間延遲0.05秒執行
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco1,		;輸出人頭字串
		LENGTHOF personch1, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch1, LENGTHOF personch1, xyPos, ADDR cellsWritten
	add xyPos.y, 1
	sub xyPos.x, 1
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco2,		;輸出身體字串
		LENGTHOF personch2, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch2, LENGTHOF personch2, xyPos, ADDR cellsWritten
	add xyPos.y, 1							;將原本身體所在位置的字串清除
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco2,
		LENGTHOF erase, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR erase, LENGTHOF erase, xyPos, ADDR cellsWritten
	pop ecx
	pop xyPos.x
	pop xyPos.y							;回復原先座標值(輸出人頭的位置)
	dec xyPos.y							;將座標設為下一次欲輸出人物頭的位置(向上一單位)
	dec ecx
	cmp ecx, 0	
	jne PersonMove2							;若尚未完成9單位的跳躍，則跳回PersonMove2，重複執行向上動作
	pop xyPos.x
	pop xyPos.y							;回復x,y座標值(即原先音符輸出的起始座標)
	.IF Count > 1							;若非第一次跳躍，則需將人物底下的音符清除
		push xyPos.x
		push xyPos.y						;以堆疊記錄音符輸出座標
		mov dx, CloudDownx
		mov xyPos.x, dx
		mov xyPos.y, 19						;將座標設為人物底下音符輸出的起始座標
		INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,	;清空原先人物底下的音符
		bufSize, xyPos, ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter,
			outHandle, ADDR ClearCloud, bufSize, xyPos, ADDR cellsWritten
		pop xyPos.y
		pop xyPos.x						;將座標回復為目前上方音符的輸出起始座標
	.ENDIF
	mov dx, xyPos.x
	mov CloudDownx, dx							;將CloudDownx設為上方音符輸出的起始座標
	mov RecordMove, 0							;以RecordMove記錄人物是否跳躍成功，故先將其預設為0(失敗)
	.IF (xyPos.x <= 55 && xyPos.x >= 52)||(xyPos.x <= 14 && xyPos.x >= 11)		;若跳上藍色音符
		mov RecordMove, 1						;將RecordMove設為1，表示跳躍成功
		add TotalScore, 10						;將分數加10分
	.ENDIF
	.IF (xyPos.x <= 29 && xyPos.x >= 25)||xyPos.x <= 2				;若跳上紅色音符
		mov RecordMove, 1
		.IF TotalScore <= 20						;若目前總分小於或等於20分
			mov TotalScore, 0					;將分數歸零
		.ELSE
			sub TotalScore, 20					;若大於20分，則將分數扣20分
		.ENDIF
	.ENDIF
	.IF xyPos.x <= 43 && xyPos.x >= 40					;若跳上紫色音符
		mov RecordMove, 1
		add TotalScore, 50						;將分數加50分
	.ENDIF
	mov eax, 0dh							;0dh為回車符
	call WriteChar							;返回輸出分數的起始位置
	mov edx, OFFSET ScoreSpace
	call WriteString							;輸出分數前的空白字串
	mov eax, TotalScore
	call WriteDec							;以十進位輸出新的分數
	mov eax, 20h
	call WriteChar							;於新分數後輸出一個空白字元，避免有殘留的數字
	jmp Cloud								;跳至Cloud區塊，進行後續的判斷
MoveDown:								;跳躍成功，將人物與音符向下移動
	push ecx
	push xyPos.y
	push xyPos.x							;以堆疊記錄音符每次移動的輸出起始座標
	INVOKE Sleep, 60							;時間延遲0.06秒執行
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,		;將現在位置的音符清空
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR ClearCloud, BufSize, xyPos, ADDR cellsWritten
	inc xyPos.y
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,		;向下輸出音符字串
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR buffer, BufSize, xyPos, ADDR cellsWritten
	sub xyPos.y, 3
	mov dx, personcoordx
	mov xyPos.x, dx
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,		;將原先人物人頭所在位置清空
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR ClearCloud, BufSize, xyPos, ADDR cellsWritten
	inc xyPos.y
	dec xyPos.x
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,		;將原先人物身體所在位置清空
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR ClearCloud, BufSize, xyPos, ADDR cellsWritten
	inc xyPos.x
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco1,		;輸出人物人頭字串
		LENGTHOF personch1, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch1, LENGTHOF personch1, xyPos, ADDR cellsWritten
	add xyPos.y, 1
	sub xyPos.x, 1
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco2,		;輸出人物身體字串
		LENGTHOF personch2, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch2, LENGTHOF personch2, xyPos, ADDR cellsWritten
	pop xyPos.x
	pop xyPos.y							;將x,y座標回復為原本音符輸出的起始座標
	inc xyPos.y							;將y座標設為改變後的音符輸出起始座標
	pop ecx
	dec ecx
	cmp ecx, 0	
	jne MoveDown							;若尚未完成9單位的向下移動，則跳回MoveDown，重複執行向下的動作
	pop xyPos.y
	pop xyPos.x							;若已完成9單位的移動，則回復x,y座標值(音符尚未移動的起始輸出座標)
	jmp Cloud								;跳回Cloud程式區域，以利進行音符的左右移動
PersonDown:								;若跳躍失敗，則單獨將人物向下移動
	push ecx
	push xyPos.x
	push xyPos.y							;以堆疊記錄移動前的人物人頭座標
	INVOKE Sleep, 60							;時間延遲0.06秒執行
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,		;將原先人物人頭位置清空
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR erase, LENGTHOF erase, xyPos, ADDR cellsWritten
	inc xyPos.y
	dec xyPos.x
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR attributes,		;將原先人物身體位置清空
		BufSize, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR erase, LENGTHOF erase, xyPos, ADDR cellsWritten
	inc xyPos.x
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco1,		;輸出人物人頭字串
		LENGTHOF personch1, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch1, LENGTHOF personch1, xyPos, ADDR cellsWritten
	add xyPos.y, 1
	sub xyPos.x, 1
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR personco2,		;輸出人物身體字串
		LENGTHOF personch2, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR personch2, LENGTHOF personch2, xyPos, ADDR cellsWritten
	pop xyPos.y
	pop xyPos.x							;回復x,y座標為移動前人頭位置
	inc xyPos.y							;將x,y改為移動後人頭位置
	pop ecx
	dec ecx
	cmp ecx, 0	
	jne PersonDown							;若尚未完成9單位的向下移動，則跳回PersonDown，繼續人物的向下移動
	INVOKE Sleep, 1000							;時間延遲1秒執行
	pop xyPos.y
	pop xyPos.x							;回復開始將人往下移動前的座標
	dec LeftLives							;因跳躍失敗，將生命值減1
	.IF LeftLives != 0							;若生命值不為0
		mov ebx, TotalScore						;以ebx暫存器記錄目前分數，以利後續遊戲分數的累計
		call Clrscr							;清空畫面
		mov al, LeftLives						;以al記錄所剩生命值，以利後續遊戲生命值的記錄
		jmp Start							;跳至Start區塊，進行遊戲開始的設定
	.ENDIF
Exit_Prog:									;若生命值為0，則進行遊戲結束畫面的設定
	call Clrscr								;將畫面清空
	mov ecx, 10							;將ecx設為10，以利後續進行10次換行
Exit_Prog2:
	call Crlf
	dec ecx
	.IF ecx > 0								;重複執行，直到完成10次換行
		jmp Exit_Prog2
	.ENDIF
	mov eax, 0dh							;將eax設為0dh(紫色)
	call SetTextColor
	mov edx, OFFSET GameOver
	call WriteString							;輸出"Game Over"字串
	call Crlf
	call Crlf
	mov eax, 15							;將eax設為15(白色)
	call SetTextColor
	mov edx, OFFSET Points1
	call WriteString							;輸出"Score : "字串
	mov eax, TotalScore
	call WriteDec							;以十進位形式輸出所得分數
	mov edx, OFFSET Points2
	call WriteString							;輸出" points"字串
	call Crlf
	call Crlf
	mov eax, 3								;將eax設為3(藍色)
	call SetTextColor
	mov edx, OFFSET Question1
	call WriteString							;輸出提示玩家選擇再玩一次，或是結束遊戲所需按下的按鍵
	call Crlf
	call Crlf
	mov edx, OFFSET Question2
	call WriteString
	push xyPos.x
	push xyPos.y							;因後續會改變x,y座標的值，故以堆疊記錄x,y座標的值
	mov xyPos.x, 5
	mov xyPos.y, 7
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,		;於特定座標輸出字串(圓點)，作為背景
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 100
	mov xyPos.y, 20
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc3,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 96
	mov xyPos.y, 13
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 11
	mov xyPos.y, 20
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 30
	mov xyPos.y, 23
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc3,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 113
	mov xyPos.y, 8
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc4,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 80
	mov xyPos.y, 3
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 50
	mov xyPos.y, 5
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc2,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 30
	mov xyPos.y, 10
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc4,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	mov xyPos.x, 70
	mov xyPos.y, 25
	INVOKE WriteConsoleOutputAttribute, outHandle, ADDR Backc1,
		LENGTHOF Back, xyPos, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,
		outHandle, ADDR Back, LENGTHOF Back, xyPos, ADDR cellsWritten
	pop xyPos.y
	pop xyPos.x							;回復x,y座標的值
Decide:									;讓玩家決定重玩遊戲，還是結束程式
	call ReadChar							;讀取字元
	.IF ax == 4800h							;若按下向上按鍵，為重玩遊戲
		call Clrscr
		mov al, 3							;將生命值設為3
		mov ebx, 0						;將分數設為0
		jmp Start							;跳回Start，進行遊戲的設定
	.ENDIF
	.IF ax == 5000h							;若按下向下按鍵
		exit							;結束程式
	.ENDIF
	jmp Decide							;若按下的按鍵並非兩者，則跳回Decide區域，直到玩家按向上或向下鍵
main ENDP
END main
