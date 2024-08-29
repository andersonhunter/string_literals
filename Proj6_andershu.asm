TITLE Project 6     (Proj6_andershu.asm)

; Author: Hunter Anderson
; Last Modified: 12/9/2023
; OSU email address: andershu@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/10/2023
; Description: 
; Asks user for a signed, 32-bit integer, and receives that integer as a string. 
; Converts the string to an integer, then stores the integer in memory.
; Currently configured to ask the user for 10 integers, put them through the abovementioned process, and also calculate their sum and truncated average, and convert those numbers to strings as well.

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------------------
; Name: mGetString
;
; Gets a 32-bit signed integer from the user as a string and stores it in an array in memory.
;
; Preconditions: The array is a SDWORD.
;
; Postconditions: None.
;
; Receives: 
;	promptOff = the offset of the prompt string
;	userStringOff = the offset of the array for storing the user's string
;
; Returns: 
;	User input stored in the location indicated by userStringOff.
;	Count of characters entered stored in charReadVal.
; --------------------------------------------------------------------------------------------
mGetString MACRO promptOff, userStringOff, charReadOff

	; Preserve register states
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX
	
	; Prompt the user for data entry
	MOV		EDX, promptOff
	CALL	WriteString
	MOV		EDX, userStringOff
	MOV		ECX, 13
	CALL	ReadString
	MOV		ECX, charReadOff
	MOV		[ECX], EAX

	; Return register states
	POP		EDX
	POP		ECX
	POP		EAX

ENDM

; --------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description: Print the user-entered string from memory.
;
; Preconditions: userString is an array of BYTEs, and stringLength is the length of userString.
;
; Postconditions: None.
;
; Receives: userStringOff is the address of userString
;
; Returns: None.
;
; -------------------------------------------------------------------------------------------
mDisplayString MACRO userStringOff, stringLength
	LOCAL _stringPrint

	; Preserve register states
	PUSH	EAX
	PUSH	ECX
	PUSH	ESI
	PUSHFD

	MOV		ESI, userStringOff
	CLD
	MOV		ECX, stringLength

	_stringPrint:
	LODSB
	CALL	WriteChar
	LOOP	_stringPrint

	; Restore register states
	POPFD
	POP		ESI
	POP		ECX
	POP		EAX

ENDM

HI	  = 57			; The upper ASCII limit for an input being an integer
LO    = 48			; The lower ASCII limit for an input being an integer

.data

header		BYTE	"Fun With Macros and String Primitives! by Hunter Anderson",13,10,0
headLen		DWORD	LENGTHOF header
header2		BYTE	"Please enter 10 signed decimal integers.",13,10,0
head2Len	DWORD	LENGTHOF header2
rules		BYTE	"Each unsigned integer must fit into a 32-bit register. Then, I'll print your list and give you the sum and truncated average :)",13,10,0
rulesLen	DWORD	LENGTHOF rules
prompt		BYTE	"Please enter a signed, decimal integer: ",0
userString	BYTE	13 DUP(?)
charRead	DWORD	?
strLen		DWORD	LENGTHOF userString

errorRep	BYTE	"Yikes, the input you gave was invalid... Please check the rules and try again!",13,10,0
errorLen	DWORD	LENGTHOF errorRep

userInt		SDWORD	?
ints		BYTE	"The integers you entered are:",13,10,0
intsLen		DWORD	LENGTHOF ints

avg			BYTE	"The average of your numbers is: ",0
sum			BYTE	"The sum of your numbers is: ",0

intArr		SDWORD	12 DUP(?)			; Hold the integer versions of each input 
strArr		BYTE	12 DUP(?)			; Hold the string version of each integer
numChaArr	DWORD	12 DUP(?)			; Hold the number of characters for each input
strArLen	DWORD	LENGTHOF strArr

intSum		SDWORD	?					; Hold the integer version of the sum
sumStr		BYTE	13 DUP(?)			; Hold the string version of the sum
sumLen		DWORD	?					; Hold the length of the sum string
sumRev		BYTE	12 DUP(?)

sumAvg		SDWORD	?					; Hold the integer version of the average
avgStr		BYTE	13 DUP(?)			; Hold the string version of the average
avgLen		DWORD	?					; Hold the number of characters in the average's string
avgRev		BYTE	12 DUP(?)

.code
main PROC

	PUSH	headLen
	PUSH	head2Len
	PUSH	rulesLen
	PUSH	OFFSET header
	PUSH	OFFSET header2
	PUSH	OFFSET rules
	CALL	Greeting

	; Get 10 integers and store them in userString

	MOV		ECX, 10
	MOV		ESI, OFFSET userInt
	MOV		EDI, OFFSET intArr
	MOV		EAX, OFFSET numChaArr
	CLD

	_loopTen:
	PUSH	errorLen
	PUSH	OFFSET userInt
	PUSH	OFFSET errorRep
	PUSH	OFFSET prompt
	PUSH	OFFSET userString
	PUSH	OFFSET charRead
	CALL	ReadVal

	; Append the integer to the array, and move the number of characters into the numChaArr array
	MOV		ESI, OFFSET userInt
	MOVSD
	PUSH	EDI
	MOV		ESI, OFFSET charRead
	MOV		EDI, EAX
	MOVSD
	MOV		EAX, EDI
	POP		EDI
	LOOP	_loopTen

; Calculate the sum of the integers and store in memory
	
	MOV		EAX, 0
	MOV		EBX, 0
	MOV		ECX, 10
	MOV		EDX, 0

	_sumLoop:
	MOV		EAX, intArr[EDX]
	ADD		EBX, EAX
	ADD		EDX, 4
	LOOP	_sumLoop
	MOV		intSum, EBX

; Convert the sum into a string
	MOV		EAX, intSum
	MOV		EBX, 10
	MOV		ECX, 0
	MOV		EDX, 0
	MOV		EDI, OFFSET sumStr
	CLD

	CMP		EAX, 0
	JGE		_sumConvert
	NEG		EAX
	INC		ECX

	_sumConvert:
	MOV		EDX, 0
	DIV		EBX
	PUSH	EAX
	MOV		EAX, EDX
	ADD		EAX, 48
	STOSB
	INC		ECX
	POP		EAX
	CMP		EAX, 0
	JG		_sumConvert
	MOV		sumLen, ECX
	MOV		EAX, intSum
	CMP		EAX, 0
	JGE		_sumRevStart
	MOV		EAX, 45
	STOSB

	; Reverse the sum string 
	_sumRevStart:
	MOV		ESI, OFFSET sumStr
	ADD		ESI, sumLen
	DEC		ESI
	MOV		EDI, OFFSET sumRev
	MOV		EAX, 0
	MOV		ECX, sumLen
	CLD

	_sumRevLoop:
	PUSH	ESI
	MOVSB
	POP		ESI
	DEC		ESI
	LOOP _sumRevLoop

; Calculate the truncated average of the integers and store in memory
	MOV		EAX, intSum
	MOV		EBX, 10
	MOV		EDX, 0
	CDQ
	IDIV	EBX
	MOV		sumAvg, EAX

; Convert the truncated average into a string
	; Convert the sum into a string
	MOV		EAX, sumAvg
	MOV		EBX, 10
	MOV		ECX, 0
	MOV		EDX, 0
	MOV		EDI, OFFSET avgStr
	CLD

	CMP		EAX, 0
	JGE		_avgConvert
	NEG		EAX
	INC		ECX

	_avgConvert:
	MOV		EDX, 0
	DIV		EBX
	PUSH	EAX
	MOV		EAX, EDX
	ADD		EAX, 48
	STOSB
	INC		ECX
	POP		EAX
	CMP		EAX, 0
	JG		_avgConvert
	MOV		avgLen, ECX
	MOV		EAX, sumAvg
	CMP		EAX, 0
	JGE		_avgRevStart
	MOV		EAX, 45
	STOSB

; Reverse the average string
	_avgRevStart:
	MOV		ESI, OFFSET avgStr
	ADD		ESI, avgLen
	DEC		ESI
	MOV		EDI, OFFSET avgRev
	MOV		EAX, 0
	MOV		ECX, avgLen
	CLD

	_avgRevLoop:
	PUSH	ESI
	MOVSB
	POP		ESI
	DEC		ESI
	LOOP _avgRevLoop

; Display the string of numbers
	MOV		ECX, 9
	MOV		EBX, 0
	
	mDisplayString OFFSET ints, intsLen

	_displayLoop:
	PUSH	strArLen
	PUSH	numChaArr[EBX]
	PUSH	intArr[EBX]
	PUSH	OFFSET strArr
	CALL	WriteVal
	ADD		EBX, 4
	MOV		EAX, 0
	MOV		AL, ','
	CALL	WriteChar
	MOV		AL, ' '
	CALL	WriteChar
	LOOP	_displayLoop

	PUSH	strArLen
	PUSH	numChaArr[EBX]
	PUSH	intArr[EBX]
	PUSH	OFFSET strArr
	CALL	WriteVal
	CALL	Crlf

; Display the sum of the integers
	
	mDisplayString OFFSET sum, LENGTHOF sum
	CALL	Crlf
	mDisplayString OFFSET sumRev, sumLen
	CALL	Crlf

; Display the truncated average of the integers

	mDisplayString OFFSET avg, LENGTHOF avg
	CALL	Crlf
	mDisplayString OFFSET avgRev, avgLen

	CLD

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; --------------------------------------------------------------------------------------------
; Name: Greeting.
;
; Description: Display a greeting block which explains the rules.
; 
; Preconditions: All header block variables are strings.
;
; Postconditions: None.
;
; Receives: 
;	[EBP+8]		= address of rules
;	[EBP+12]	= address of the second line of the header
;	[EBP+16]	= address of the first line of the header
;	[EBP+20]	= value of the length of rules
;	[EBP+24]	= value of the length of the second line of the header
;	[EBP+28]	= value of the length of the first line of the header
;
; Returns: None.
; --------------------------------------------------------------------------------------------
Greeting PROC
	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP+16], [EBP+28]
	mDisplayString [EBP+12], [EBP+24]
	mDisplayString [EBP+8], [EBP+20]

	POP		EBP
	RET		24
Greeting ENDP

; --------------------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: Gets a integer from the user as a string, then converts the string to an integer.
; 
; Preconditions: 
;	userString is an empty array of 12 with size BYTE.
;	charRead is an uninitialized DWORD.
;	prompt and errorRep are strings.
;	userInt is an uninitialized SDWORD.
;
; Postconditions: None.
;
; Receives:
;	[EBP+8]		= the address of charRead
;	[EBP+12]	= the address of the array userString
;	[EBP+16]	= the address of the prompt string
;	[EBP+20]	= the address of the error string
;	[EBP+24]	= the address of userInt.
;	[EBP+28]	= value of the length of the error string
; 
; Returns: The converted user string is stored in userInt.
; --------------------------------------------------------------------------------------------
ReadVal	PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	; Ensure the string is empty
	MOV		EAX, 0
	MOV		EDI, [EBP+12]
	MOV		ECX, 13
	CLD
	REP		STOSB

_getString:
	mGetString [EBP+16], [EBP+12], [EBP+8]

	MOV		EAX, [EBP+8]
	MOV		ECX, [EAX]		; Set the counter to the number of characters in the string

	MOV		ESI, [EBP+12]
	MOV		EAX, 0
	MOV		AL, [ESI]
	PUSH	EAX				; Push the first character of the string to check if it's a negative number
	MOV		EBX, 0

	CMP		ECX, 11
	JG		_errorRepeat	; Check if the user entered more than 11 characters (the maximum number of places in a SDWORD)
	CMP		ECX, 0
	JE		_errorRepeat	; Check if the user entered no characters
	CLD

	; Check if the integer is negative, and retain the negative sign if so, and check for a plus sign being entered
	CMP		EAX, 43
	JE		_plusSign
	CMP		EAX, 45
	JNE		_convert
	ADD		ESI, 1
	DEC		ECX
	JMP		_convert

	; Remove a user-entered plus sign
	_plusSign:
	ADD		ESI, 1
	PUSH	EAX
	MOV		EAX, [EBP+8]
	MOV		ECX, [EAX]
	DEC		ECX
	MOV		[EAX], ECX
	POP		EAX

; Verify that each user-input ASCII character is an integer, and convert the valid input from a string of ASCII characters to an integer
_convert:
	LODSB

	; Validate that the current string variable being handled is an integer
	CMP		EAX, HI
	JG		_errorRepeat
	CMP		EAX, LO
	JL		_errorRepeat

	; Convert each ASCII character to an integer and check integer size to avoid overflow
	SUB		EAX, 48
	PUSH	EAX
	MOV		EAX, EBX
	MOV		EBX, 10
	MUL		EBX
	MOV		EBX, EAX
	POP		EAX
	JO		_errorRepeat
	ADD		EBX, EAX
	JO		_errorRepeat
	LOOP	_convert
	MOV		EAX, [EBP+24]
	MOV		[EAX], EBX
	JMP		_negCheck

; User input is invalid, clear the string and prompt reentry
_errorRepeat:
	MOV		EAX, 0
	MOV		EDI, [EBP+12]
	MOV		ECX, 12
	CLD
	REP		STOSB
	
	mDisplayString [EBP+20], [EBP+28]

	POP		EAX
	JMP		_getString

; Check if the user's input was negative, and negate the integer if so
_negCheck:
	POP		EAX
	CMP		EAX, 45
	JNE		_endRead
	MOV		EBX, [EBP+24]
	MOV		EAX, [EBX]
	NEG		EAX
	MOV		EBX, [EBP+24]
	MOV		[EBX], EAX

_endRead:
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		28
ReadVal ENDP

; --------------------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: Converts the user's integer into ASCII characters, stores the string in memory, and writes the string to the console.
; 
; Preconditions: 
;	userString is an empty array of BYTEs.
;	charRead is a DWORD and contains the number of characters within the integer.
;	userInt is an integer of size SDWORD.
;	strLen is an integer of size DWORD and contains the length of userString
;
; Postconditions: None.
;
; Receives: 
;	[EBP+8]		= the address of userString
;	[EBP+12]	= the value of userInt
;	[EBP+16]	= the value of charRead
;	[EBP+20]	= the value of strLen
;	
; 
; Returns: The integer is stored as a string at the location of userString.
; --------------------------------------------------------------------------------------------

; WriteVal
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI

	; Ensure userString is clear
	MOV		ECX, 12
	MOV		EAX, 0
	MOV		EDI, [EBP+8]
	CLD
	REP		STOSB

	; Prepare to convert the integer into ASCII characters
	MOV		EDI, [EBP+8]
	STD
	MOV		EDX, 0
	MOV		ECX, [EBP+16]
	ADD		EDI, ECX
	DEC		EDI
	MOV		EAX, [EBP+12]
	CDQ
	MOV		EBX, 10

	; Check if the integer is negative, and, if so, invert the integer and shift EDI
	CMP		EAX, 0
	JGE		_asciiConvert
	NEG		EAX
	INC		EDI
	PUSH	EDI
	PUSH	EAX
	MOV		EDI, [EBP+8]
	MOV		AL, 45
	STOSB
	POP		EAX
	POP		EDI
	MOV		EDX, 0
	CDQ
	DEC		ECX
	DEC		EDI

	; Convert each digit of the integer to an ASCII character
	_asciiConvert:
	; Divide the integer by 10
	IDIV	EBX

	; Add 48 to the remainder and prepend the converted digit to userString
	PUSH	EAX
	ADD		EDX, 48
	MOV		EAX, EDX
	STOSB
	POP		EAX
	MOV		EDX, 0
	CDQ
	LOOP	_asciiConvert
	
	mDisplayString [EBP+8], [EBP+20]
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16
WriteVal ENDP

END main
