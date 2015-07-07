MODULE RA8875_b;

IMPORT Timer, SPI, SYSTEM, MCU;

CONST


	(*//initialization parameters---------------------------------------------------------------------
	const static uint8_t initStrings[3][15] = {
	//{0x07,0x03,0x03,0x27,0x00,0x05,0x04,0x03,0xEF,0x00,0x05,0x00,0x0E,0x00,0x02},//0 -> 320x240 (0A)
	{0x07,0x03,0x82,0x3B,0x00,0x01,0x00,0x05,0x0F,0x01,0x02,0x00,0x07,0x00,0x09},//1 -> 480x272 (10)   -> 0
	//{0x07,0x03,0x01,0x4F,0x05,0x0F,0x01,0x00,0xDF,0x01,0x0A,0x00,0x0E,0x00,0x01},//2 -> 640x480
	{0x07,0x03,0x81,0x63,0x00,0x03,0x03,0x0B,0xDF,0x01,0x1F,0x00,0x16,0x00,0x01},//3 -> 800x480        -> 1
	{0x07,0x03,0x81,0x63,0x00,0x03,0x03,0x0B,0xDF,0x01,0x1F,0x00,0x16,0x00,0x01} //4 -> 800x480_ALT    -> 2
	//0    1    2    3    4    5    6    7    8    9    10   11   12   13   14
	};
	/*
  
	0: - sys clock -
	1: - sys clock -
	2: - sys clock -
	3:LCD Horizontal Display Width
	4:Horizontal Non-Display Period Fine Tuning Option
	5:LCD Horizontal Non-Display Period
	6:HSYNC Start Position
	7:HSYNC Pulse Width
	8:LCD Vertical Display Height 1
	9:LCD Vertical Display Height 2
	10:LCD Vertical Non-Display Period 1
	11:LCD Vertical Non-Display Period 2
	12:VSYNC Start Position Register 1
	13:VSYNC Start Position Register 2
	14:VSYNC Pulse Width Register
	
	//PostBurner PLL parameters --------------------------------------------------------------
	const static uint8_t sysClockPar[3][2] = {
	//{0x0B,0x01},//0 -> 320x240		->
	{0x0B,0x01},//1 -> 480x272		    -> 0
	//{0x0B,0x01},//2 -> 640x480			
	{0x0B,0x01},//3 -> 800x480			-> 1
	{0x0B,0x01} //4 -> 800x480_ALT		-> 2
	};
	
*)
 

 DISPLAY_WIDTH = 800; 

(* 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            System & Configuration Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* Power and Display Control Register [0x01]
----- Bit 7 (LCD Display Off)
0:off, 1:on
----- Bit 6,5,4,3,2, (na)
----- Bit 1 (Sleep Mode)
0:normal, 1:sleep
----- Bit 0 (Software Reset)
0:no action, 1:reset */*)

 RA8875_PWRR =            010H; (*Power and Display Control Register*)
 RA8875_PWRR_DISPON =     080H;
 RA8875_PWRR_DISPOFF =    000H;
 RA8875_PWRR_SLEEP =      002H;
 RA8875_PWRR_NORMAL =     000H;
 RA8875_PWRR_SOFTRESET =  001H;
 
(* REG[02h] Memory Read/Write Command (MRWC)
Data to write in memory corresponding to the setting of
MWCR1[3:2]. Continuous data write cycle can be accepted in
bulk data write case.
*)

 RA8875_MRWC =            	002H; (*Memory Read/Write Command*)
 RA8875_CMDWRITE =        	080H;
 RA8875_CMDREAD =         	0C0H; (* 0xC0 !!! ??? !!!*)
 RA8875_DATAWRITE =       	000H;
 RA8875_DATAREAD =        	040H;
 RA8875_STATREG	=			      040H;
 
(* Pixel Clock Setting Register 	[0x04]
----- Bit 7 (PCLK Inversion)
0:PDAT at PLCK rising , 1:PDAT at PLCK falling
----- Bit 6,5,4,3,2 (na)
----- Bit 1,0 (PCLK Period Setting)
00: PCLK period = System Clock period.
01: PCLK period = 2 times of System Clock period
10: PCLK period = 4 times of System Clock period
11: PCLK period = 8 times of System Clock period *)
 RA8875_PCSR =            	 004H;  (*0x04//Pixel Clock Setting Register *)

(*
 Serial Flash/ROM Configuration 	 [0x05]
----- Bit 7 (Serial Flash/ROM I/F # Select)
0:Serial Flash/ROM 0 , 1:Serial Flash/ROM 1
----- Bit 6 (Serial Flash/ROM Address Mode)
0: 24 bits address mode
----- Bit 5 (Serial Flash/ROM Waveform Mode)
----- Bit 4,3 (Serial Flash /ROM Read Cycle)
00: 4 bus -> no dummy cycle
01: 5 bus -> 1 byte dummy cycle
1x: 6 bus -> 2 byte dummy cycle
----- Bit 2 (Serial Flash /ROM Access Mode)
0:Font mode, 1:DMA mode
----- Bit 1,0 (Serial Flash /ROM I/F Data Latch Mode Select)
0x: Single Mode
10: Dual Mode 0
11: Dual Mode 1*)

 RA8875_SROC =        	 005H; (*Serial Flash/ROM Configuration*)
 
(* Serial Flash/ROM CLK			     [0x06]
----- Bit 7,6,5,4,3,2 (na) 
----- Bit 1,0 (Serial Flash/ROM Clock Frequency Setting) 
0x: SFCL frequency = System clock frequency(DMA on and 256 clr)
10: SFCL frequency = System clock frequency / 2
11: SFCL frequency = System clock frequency / 4 *)

 RA8875_SFCLR =         006H; (*Serial Flash/ROM CLK*)
 (*EXTROM_SFCLSPEED	=         ;  0b00000011// /4 0b00000010 /2     !!!!!!!!!!!!!!!*)

(* System Configuration Register		 [0x10]
----- Bit 7,6,5,4 (na) 
----- Bit 3,2 (Color Depth Setting) 
00: 8-bpp generic TFT, i.e. 256 colors
1x: 16-bpp generic TFT, i.e. 65K colors
----- Bit 1,0 (MCUIF Selection) 
00: 8-bit MCU Interface
1x: 16-bit MCU Interface *)

 RA8875_SYSR =          010H;  (*//System Configuration Register *)

(* LCD Horizontal Display Width Register [0x14]
----- Bit 7 (na)
----- Bit 6,5,4,3,2,1,0 (Horizontal Display Width Setting Bit)
no more than 0x64( max with = 800)
note: Horizontal display width(pixels) = (HDWR + 1) * 8 *)

 RA8875_HDWR =          014H;  	 (* 0x14//LCD Horizontal Display Width Register*)
(* Horizontal Non-Display Period Fine Tuning Option Register [0x15]
----- Bit 7 (DE polarity)
0:High, 1:Low
----- Bit 6,5,4 (na)
----- Bit 3,2,1,0 (Horizontal Non-Display Period Fine Tuning(HNDFT)) *)

 RA8875_HNDFTR =        015H;  	 (* 0x15//Horizontal Non-Display Period Fine Tuning Option Register*)
(* LCD Horizontal Non-Display Period Register [0x16]
----- Bit 7,6,5 (na)
----- Bit 4,0 (HSYNC Start Position)
note: HSYNC Start Position(pixels) = (HSTR + 1) * 8 *)

 RA8875_HNDR =         016H;	  (*0x16//LCD Horizontal Non-Display Period Register*)
 
(* HSYNC Start Position Register	 [0x17]
----- Bit 7,6,5 (na)
----- Bit 4,0 (HSYNC Start Position)
note: HSYNC Start Position(pixels) = (HSTR + 1) * 8 */*)

 RA8875_HSTR =          017H; (* 0x17//HSYNC Start Position Register*)
 
(* HSYNC Pulse Width Register		 [0x18]
----- Bit 7 (HSYNC Polarity)
0:Low, 1:High
----- Bit 6,5 (na)
----- Bit 4,0 (HSYNC Pulse Width(HPW))
note: HSYNC Pulse Width(pixels) = (HPW + 1) * 8 *)

 RA8875_HPWR =          018H;  	(*  0x18//HSYNC Pulse Width Register *)
 RA8875_VDHR0 =         019H;  	(*  0x19//LCD Vertical Display Height Register 0 *)
 RA8875_VDHR1 =         01AH;    (*  0x1A//LCD Vertical Display Height Register 1 *)
 RA8875_VNDR0 =         01BH;    (*  0x1B//LCD Vertical Non-Display Period Register 0*)
 RA8875_VNDR1 =         01CH;    (*	0x1C//LCD Vertical Non-Display Period Register 1*)
 RA8875_VSTR0 =         01DH;  	(*  0x1D//VSYNC Start Position Register 0*)
 RA8875_VSTR1 =         01EH;  	(*  0x1E//VSYNC Start Position Register 1 *)
 RA8875_VPWR  =         01FH;  	(*  0x1F//VSYNC Pulse Width Register *)
(* 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                           LCD Display Control Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* Display Configuration Register	  [0x20]
----- Bit 7 (Layer Setting Control)
0:one Layer, 1:two Layers
----- Bit 6,5,4 (na)
----- Bit 3 (Horizontal Scan Direction, for n = SEG number)
0: SEG0 to SEG(n-1), 1: SEG(n-1) to SEG0
----- Bit 2 (Vertical Scan direction, for n = COM number)
0: COM0 to COM(n-1), 1: COM(n-1) to COM0
----- Bit 1,0 (na) *)

 RA8875_DPCR	=			       020H; (* 0x20//Display Configuration Register *)
(* Font Control Register 0			  [0x21]
----- Bit 7 (CGRAM/CGROM Font Selection Bit in Text Mode)
0:CGROM font, 1:CGRAM font
----- Bit 6 (na)
----- Bit 5 (External/Internal CGROM)
0:Internal CGROM (RA8875_SFRSET=0), 1:External CGROM(RA8875_FWTSET bit6,7 = 0)
----- Bit 4,3,2 (na)
----- Bit 1,0 (Font Selection for internal CGROM)
00: ISO/IEC 8859-1
01: ISO/IEC 8859-2
10: ISO/IEC 8859-3
11: ISO/IEC 8859-4 *)

 RA8875_FNCR0	=			      021H; (*0x21//Font Control Register 0*)
(* Font Control Register 1			 [0x22]
----- Bit 7 (Full Alignment)
0:disabled, 1:enabled
----- Bit 6 (Font Transparency)
0:disabled, 1:enabled
----- Bit 5 (na)
----- Bit 4 (Font Rotation)
0:normal, 1:90 degrees
----- Bit 3,2 (Horizontal Font Enlargement)
00:normal, 01:x2, 10:x3, 11:x4
----- Bit 1,0 (Vertical Font Enlargement)
00:normal, 01:x2, 10:x3, 11:x4 *)

 RA8875_FNCR1	=			      022H; (* 0x22//Font Control Register 1 *)
(* CGRAM Select Register			  [0x23]
----- Bit 7,6,5,4,3,2,1,0 ------------- *)
 RA8875_CGSR =				       023H; (* 0x23//CGRAM Select Register *)
(* Horizontal Scroll Offset Register 0 [0x24]
----- Bit 7,6,5,4,3,2,1,0 ------------- *)
 RA8875_HOFS0	=			      024H;  (* 0x24//Horizontal Scroll Offset Register 0 *)
(* Horizontal Scroll Offset Register 1 [0x25]
----- Bit 7,6,5,4,3 (na) ------------- 
----- Bit 2,0 (Horizontal Display Scroll Offset) *)
 RA8875_HOFS1	=			      025H;  (* 0x25//Horizontal Scroll Offset Register 1 *)
(* Vertical Scroll Offset Register 0 [0x26]
----- Bit 7,6,5,4,3,2,1,0 ------------- *)
 RA8875_VOFS0	=			      026H;  (* 0x26//Vertical Scroll Offset Register 0 *)
(* Vertical Scroll Offset Register 1 [0x27]
----- Bit 7,6,5,4,3,2 (na) ------------- 
----- Bit 1,0 (Vertical Display Scroll Offset) ------------- *)
 RA8875_VOFS1	=			      027H;  (* 0x27//Vertical Scroll Offset Register 1 *)
(* Font Line Distance Setting Register[0x29]
----- Bit 7,6,5 (na) ------------- 
----- Bit 4,0 (Font Line Distance Setting) *)
 RA8875_FLDR	=			  	  029H;  (* 0x29//Font Line Distance Setting Register *)

(* Font Write Cursor Horizontal Position Register 0 [0x2A]
----- Bit 7,6,5,4,3,2,1,0 ------------- *)
 RA8875_F_CURXL =				  02AH;  (* 0x2A//Font Write Cursor Horizontal Position Register 0 *)
(* Font Write Cursor Horizontal Position Register 1 [0x2B]
----- Bit 7,2 (na) ------------- 
----- Bit 1,0 (Font Write Cursor Horizontal Position) *)
 RA8875_F_CURXH	=			    02BH;  (* 0x2B//Font Write Cursor Horizontal Position Register 1 *)
(* Font Write Cursor Vertical Position Register 0 [0x2C]
----- Bit 7,6,5,4,3,2,1,0 ------------- *)
 RA8875_F_CURYL	=			    02CH;  (* 0x2C//Font Write Cursor Vertical Position Register 0 *)
(* Font Write Cursor Vertical Position Register 1 [0x2D]
----- Bit 7,1 (na) ------------- 
----- Bit 0 (Font Write Cursor Vertical Position Register 1) *)
 RA8875_F_CURYH	=			    02DH;  (* 0x2D//Font Write Cursor Vertical Position Register 1 *)
(* Font Write Type Setting Register [0x2E]
----- Bit 7,6 -------------
00: 16x16(full) - 8x16(half) - nX16(var)
01: 24x24(full) - 12x24(half) - nX24(var)
1x: 32x32(full) - 16x32(half) - nX32(var)
----- Bit 5,0 -------------
Font to Font Width Setting
00 --> 3F (0 to 63 pixels) *)
 RA8875_FWTSET =        		02EH;  (* 0x2E//Font Write Type Setting Register *)
(* Serial Font ROM Setting 			 [0x2F]
----- Bit 7,6,5 -------------
000: GT21L16TW / GT21H16T1W
001: GT30L16U2W
010: GT30L24T3Y / GT30H24T3Y
011: GT30L24M1Z
100: GT30L32S4W / GT30H32S4W
----- Bit 4,3,2 -------------
000: GB2312
001: GB12345/GB18030
010: BIG5
011: UNICODE
100: ASCII
101: UNI-Japanese
110: JIS0208
111: Latin/Greek/ Cyrillic / Arabic
----- Bit 1,0 -------------
00: normal(ASCII) - normal(LGC) -    na(arabic)
01: Arial(ASCII) -  var width(LGC) - PresFormA(arabic)
10: Roman(ASCII) -  na(LGC) -        na(arabic) *)
 RA8875_SFRSET =        02FH; (* 0x2F//Serial Font ROM Setting *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Active Window & Scroll Window Setting Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)
 RA8875_HSAW0 =           	  030H;  (* 0x30//Horizontal Start Point 0 of Active Window *)
 RA8875_HSAW1 =           	  031H;  (* 0x31//Horizontal Start Point 1 of Active Window *)
 RA8875_VSAW0 =           	  032H;  (* 0x32//Vertical   Start Point 0 of Active Window *)
 RA8875_VSAW1 =           	  033H;  (*0x33//Vertical   Start Point 1 of Active Window *)
 RA8875_HEAW0 =           	  034H;  (*0x34//Horizontal End   Point 0 of Active Window *)
 RA8875_HEAW1 =           	  035H;  (*0x35//Horizontal End   Point 1 of Active Window  *)
 RA8875_VEAW0 =          	  	036H;  (* 0x36//Vertical   End   Point of Active Window 0 *)
 RA8875_VEAW1 =           	  037H;  (*0x37//Vertical   End   Point of Active Window 1 *)
 
 RA8875_HSSW0 =           	  038H;  (*0x38//Horizontal Start Point 0 of Scroll Window *)
 RA8875_HSSW1 =           	  039H;  (*0x39//Horizontal Start Point 1 of Scroll Window *)
 RA8875_VSSW0 =           	  03AH;  (*0x3A//Vertical 	 Start Point 0 of Scroll Window *)
 RA8875_VSSW1 =           	  03BH;  (*0x3B//Vertical 	 Start Point 1 of Scroll Window *)
 RA8875_HESW0 =           	  03CH;  (*0x3C//Horizontal End   Point 0 of Scroll Window *)
 RA8875_HESW1 =           	  03DH;  (*0x3D//Horizontal End   Point 1 of Scroll Window *)
 RA8875_VESW0 =           	  03EH;  (*0x3E//Vertical 	 End   Point 0 of Scroll Window *)
 RA8875_VESW1 =           	  03FH;  (*0x3F//Vertical 	 End   Point 1 of Scroll Window *)
(* 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Cursor Setting Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* Memory Write Control Register 0   [0x40]
----- Bit 7 (Select Mode)
0: Graphic Mode
1: Text Mode
----- Bit 6 (Font Write Cursor/ Memory Write Cursor Enable)
0: Font write cursor/ Memory Write Cursor is not visible
1: Font write cursor/ Memory Write Cursor is visible
----- Bit 5 (Font Write Cursor/ Memory Write Cursor Blink Enable)
0: Normal display
1: Blink display
----- Bit 4 (na)
----- Bit 3,2 (Memory Write Direction (Only for Graphic Mode)
00: Left -> Right then Top -> Down
01: Right -> Left then Top -> Down
10: Top -> Down then Left -> Right
11: Down -> Top then Left -> Right
----- Bit 1 (Memory Write Cursor Auto-Increase Disable)
0: Cursor auto-increases when memory write
1: Cursor doesn’t auto-increases when memory write
----- Bit 0(Memory Read Cursor Auto-Increase Disable) 
0: Cursor auto-increases when memory read
1: Cursor doesn’t auto-increases when memory read *)
 RA8875_MWCR0 =           	  040H;  (*0x40//Memory Write Control Register 0 *)

(* Memory Write Control Register 1   [0x41]
----- Bit 7 (Graphic Cursor Enable)
0:disable, 1:enable
----- Bit 6,5,4 (Graphic Cursor Selection)
000: Graphic Cursor Set 1
...
111: Graphic Cursor Set 8
----- Bit 3,2 (Write Destination Selection)
00: Layer 1~2
01: CGRAM
10: Graphic Cursor
11: Pattern
Note : When CGRAM is selected , RA8875_FNCR0 bit 7 must be set as 0.
----- Bit 1 (na)
----- Bit 0 (Layer No. for Read/Write Selection)
When resolution =< 480x400 or color depth = 8bpp:
0: Layer 1
1: Layer 2
When resolution > 480x400 and color depth > 8bpp:
na *)

 RA8875_MWCR1 =            	  041H;  (* 0x41//Memory Write Control Register 1 *)
(*
from 0 to 255
*)
 RA8875_BTCR =           	  	044H;  (* 0x44//Blink Time Control Register *)

 (* Memory Read Cursor Direction      [0x45]
----- Bit 7,6,5,4,3,2(na)
----- Bit 1,0(Memory Read Direction (Only for Graphic Mode))
00: Left -> Right then Top -> Down
01: Right -> Left then Top -> Down
10: Top -> Down then Left -> Right
11: Down -> Top then Left -> Right *)
 RA8875_MRCD =           	  	045H; (* 0x45//Memory Read Cursor Direction *)
 RA8875_CURH0 =            	  046H;  (*0x46//Memory Write Cursor Horizontal Position Register 0 *)
 RA8875_CURH1 =           	  047H;  (*0x47//Memory Write Cursor Horizontal Position Register 1 *)
 RA8875_CURV0 =           	  048H;  (*0x48//Memory Write Cursor Vertical Position Register 0 *)
 RA8875_CURV1 =            	  049H;  (*0x49//Memory Write Cursor Vertical Position Register 1 *)

 RA8875_RCURH0 =          	  04AH;  (*0x4A//Memory Read Cursor Horizontal Position Register 0 *)
 RA8875_RCURH1 =          	  04BH;  (*0x4B//Memory Read Cursor Horizontal Position Register 1 *)
 RA8875_RCURV0 =          	  04CH;  (*0x4C//Memory Read Cursor Vertical Position Register 0 *)
 RA8875_RCURV1 =            	04DH;  (*0x4D//Memory Read Cursor Vertical Position Register 1 *)


(* Font Write Cursor and Memory Write Cursor Horizontal Size  [0x4E]
----- Bit 7,6,5 (na)
----- Bit 4,0(Font Write Cursor Horizontal Size in pixels) *)
 RA8875_CURHS =            	  04EH;  (*0x4E//Font Write Cursor and Memory Write Cursor Horizontal Size Register *)
(* Font Write Cursor Vertical Size Register   [0x4F]
----- Bit 7,6,5 (na)
----- Bit 4,0(Font Write Cursor Vertical Size in pixels) *)
 RA8875_CURVS =            	  04FH;  (*0x4F//Font Write Cursor Vertical Size Register *)
(* 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//              Block Transfer Engine(BTE) Control Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_BECR0 =           	  050H;  (*0x50//BTE Function Control Register 0 *)
 RA8875_BECR1 =           	  051H;  (*0x51//BTE Function Control Register 1 *)
(* Layer Transparency Register 0     [0x52]
----- Bit 7,6 (Layer1/2 Scroll Mode)
00: Layer 1/2 scroll simultaneously
01: Only Layer 1 scroll
10: Only Layer 2 scroll
11: Buffer scroll (using Layer 2 as scroll buffer)
----- Bit 5 (Floating Windows Transparency Display With BGTR)
0:disable, 1:enable
----- Bit 4,3 (na)
----- Bit 2,1,0(Layer1/2 Display Mode) 
000: Only Layer 1 is visible
001: Only Layer 2 is visible
010: Lighten-overlay mode
011: Transparent mode
100: Boolean OR
101: Boolean AND
110: Floating window mode
111: Reserve *)

 RA8875_LTPR0 =           	  052H;  (*0x52//Layer Transparency Register 0 *)
(* Layer Transparency Register 1     [0x53]
----- Bit 7,6,5,4 (Layer Transparency Setting for Layer 2)
0000: Total display
0001: 7/8 display
0010: 3/4 display
0011: 5/8 display
0100: 1/2 display
0101: 3/8 display
0110: 1/4 display
0111: 1/8 display
1000: Display disable
----- Bit 3,2,1,0 (Layer Transparency Setting for Layer 1)
0000: Total display
0001: 7/8 display
0010: 3/4 display
0011: 5/8 display
0100: 1/2 display
0101: 3/8 display
0110: 1/4 display
0111: 1/8 display
1000: Display disable *)

 RA8875_LTPR1 =           	  053H;  (*0x53//Layer Transparency Register 1*)
 RA8875_HSBE0	=			          054H;  (*0x54//Horizontal Source Point 0 of BTE *)
 RA8875_HSBE1	=			          055H;  (*0x55//Horizontal Source Point 1 of BTE *)
 RA8875_VSBE0	=			          056H;  (*0x56//Vertical Source Point 0 of BTE *)
 RA8875_VSBE1	=			          057H;  (*0x57//Vertical Source Point 1 of BTE *)
 RA8875_HDBE0	=			          058H;  (*0x58//Horizontal Destination Point 0 of BTE *0 *)
 RA8875_HDBE1	=			          059H;  (*0x59//Horizontal Destination Point 1 of BTE *)
 RA8875_VDBE0	=			          05AH;  (*0x5A//Vertical Destination Point 0 of BTE *)
 RA8875_VDBE1	=			          05BH;  (*0x5B//Vertical Destination Point 1 of BTE *)
 RA8875_BEWR0	=			          05CH;  (*0x5C//BTE Width Register 0 *)
 RA8875_BEWR1	=			          05DH;  (*0x5D//BTE Width Register 1 *)
 RA8875_BEHR0	=			          05EH;  (*0x5E//BTE Height Register 0 *)
 RA8875_BEHR1	=			          05FH;  (*0x5F//BTE Height Register 1 *)

(* Pattern Set No for BTE            [0x66]
----- Bit 7 (Pattern Format)
0: 8x8
1: 16x16
----- Bit 6,5,4 (na)
----- Bit 3,2,1,0 (Pattern Set No)
If pattern Format = 8x8 then Pattern Set [3:0]
If pattern Format = 16x16 then Pattern Set [1:0] is valid *)
 RA8875_PTNO =		      066H; (* 0x66//Pattern Set No for BTE *)

(*BTE Raster OPerations - there's 16 possible operations but these are the main ones likely to be useful *)

 RA8875_BTEROP_SOURCE = 0C0H;  (*	0xC0	//Overwrite dest with source (no mixing) *****THIS IS THE DEFAULT OPTION**** *)
 RA8875_BTEROP_BLACK	= 000H;  (*	0xo0	//all black *)
 RA8875_BTEROP_WHITE	= 0F0H;  (*	0xf0	//all white *)
 RA8875_BTEROP_DEST	  = 0A0H;  (*0xA0    //destination unchanged *)
 RA8875_BTEROP_ADD		= 0E0H;  (*0xE0    //ADD (brighter) *)
 RA8875_BTEROP_SUBTRACT = 020H;  (*	0x20	//SUBTRACT (darker) *)
(* 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            Color Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_BGCR0 =			060H;  (*0x60//Background Color Register 0 (R) *)
 RA8875_BGCR1	=			061H;  (*0x61//Background Color Register 1 (G) *)
 RA8875_BGCR2	=			062H;  (*0x62//Background Color Register 2 (B) *)
 RA8875_FGCR0	= 		063H;  (*0x63//Foreground Color Register 0 (R) *)
 RA8875_FGCR1	= 		064H;  (*0x64//Foreground Color Register 1 (G) *)
 RA8875_FGCR2	=			065H;  (*0x65//Foreground Color Register 2 (B) *)
 RA8875_BGTR0	=			067H;  (*0x67//Background Color Register for Transparent 0 (R) *)
 RA8875_BGTR1	=			068H;  (*0x68//Background Color Register for Transparent 1 (G) *)
 RA8875_BGTR2	=			069H;  (*0x69//Background Color Register for Transparent 2 (B) *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            TOUCH SCREEN REGISTERS
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

(*#if !defined(USE_EXTERNALTOUCH)*)

 RA8875_TPCR0 =                070H;  (*0x70//Touch Panel Control Register 0 *)
 RA8875_TPCR0_ENABLE =         080H;  (* 0x80 *)
 RA8875_TPCR0_DISABLE =        000H;  (* 0x00 *)
 RA8875_TPCR0_WAIT_512CLK =    000H;  (*0x00 *)
 RA8875_TPCR0_WAIT_1024CLK =   010H;  (*0x10 *)
 RA8875_TPCR0_WAIT_2048CLK =   020H;  (*0x20 *)
 RA8875_TPCR0_WAIT_4096CLK =   030H;  (*0x30 *)
 RA8875_TPCR0_WAIT_8192CLK =   040H;  (*0x40 *)
 RA8875_TPCR0_WAIT_16384CLK =  050H;  (*0x50 *)
 RA8875_TPCR0_WAIT_32768CLK =  060H;  (*0x60 *)
 RA8875_TPCR0_WAIT_65536CLK =  070H;  (*0x70 *)
 RA8875_TPCR0_WAKEENABLE =     008H;  (*0x08 *)
 RA8875_TPCR0_WAKEDISABLE =    000H;  (*0x00 *)
 RA8875_TPCR0_ADCCLK_DIV1 =    000H;  (*0x00 *)
 RA8875_TPCR0_ADCCLK_DIV2 =    001H;  (*0x01 *)
 RA8875_TPCR0_ADCCLK_DIV4 =    002H;  (*0x02 *)
 RA8875_TPCR0_ADCCLK_DIV8 =    003H;  (*0x03 *)
 RA8875_TPCR0_ADCCLK_DIV16 =   004H;  (*0x04 *)
 RA8875_TPCR0_ADCCLK_DIV32 =   005H;  (*0x05 *)
 RA8875_TPCR0_ADCCLK_DIV64 =   006H;  (*0x06 *)
 RA8875_TPCR0_ADCCLK_DIV128 =  007H;  (*0x07 *)

 RA8875_TPCR1 =           	  071H;  (*0x71//Touch Panel Control Register 1 *)
   RA8875_TPCR1_AUTO =        000H;  (*0x00 *)
   RA8875_TPCR1_MANUAL =      040H;  (*0x40 *)
	 RA8875_TPCR1_VREFINT =     000H;  (*0x00 *)
   RA8875_TPCR1_VREFEXT =     020H;  (*0x20 *)
   RA8875_TPCR1_DEBOUNCE =    004H;  (*0x04 *)
	 RA8875_TPCR1_NODEBOUNCE =  000H;  (*0x00 *)
	 RA8875_TPCR1_IDLE =        000H;  (*0x00 *)
	 RA8875_TPCR1_WAIT =        001H;  (*0x01 *)
	 RA8875_TPCR1_LATCHX =      002H;  (*0x02 *)
	 RA8875_TPCR1_LATCHY =      003H;  (*0x03 *)

 RA8875_TPXH =            	  072H;  (*0x72//Touch Panel X High Byte Data Register *)
 RA8875_TPYH =            	  073H;  (*0x73//Touch Panel Y High Byte Data Register *)
 RA8875_TPXYL =           	  074H;  (*0x74//Touch Panel X/Y Low Byte Data Register *)

 (*#endif*)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            Graphic Cursor Setting Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_GCHP0 =            	  080H;  (*0x80//Graphic Cursor Horizontal Position Register 0*)
 RA8875_GCHP1 =           	  081H;  (*0x81//Graphic Cursor Horizontal Position Register 1*)
 RA8875_GCVP0 =           	  082H;  (*0x82//Graphic Cursor Vertical Position Register 0*)
 RA8875_GCVP1 =           	  083H;  (*0x83//Graphic Cursor Vertical Position Register 0*)
 RA8875_GCC0 =           	    084H;  (*0x84//Graphic Cursor Color 0*)
 RA8875_GCC1 =           	    085H;  (*0x85//Graphic Cursor Color 1 *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            PLL Setting Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_PLLC1 =            	  088H;  (*0x88//PLL Control Register 1*)
 RA8875_PLLC2 =           	  089H;  (*0x89//PLL Control Register 2*)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            PWM Control Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_P1CR =            	    08AH;  (*0x8A//PWM1 Control Register *)
 RA8875_P1DCR =           	    08BH;  (*0x8B//PWM1 Duty Cycle Register *)

 RA8875_P2CR =             	    08CH;  (*0x8C//PWM2 Control Register *)
 RA8875_P2DCR =            	    08DH;  (*0x8D//PWM2 Control Register *)

	RA8875_PxCR_ENABLE =           080H;  (*0x80 *)
	RA8875_PxCR_DISABLE =          000H;  (*0x00 *)
	RA8875_PxCR_CLKOUT =           010H;  (*0x10 *)
	RA8875_PxCR_PWMOUT =           000H;  (*0x00 *)



 	RA8875_PWM_CLK_DIV1 =          000H;  (*0x00 *)
	RA8875_PWM_CLK_DIV2 =          001H;  (*0x01 *)
	RA8875_PWM_CLK_DIV4 =          002H;  (*0x02 *)
	RA8875_PWM_CLK_DIV8 =          003H;  (*0x03 *)
	RA8875_PWM_CLK_DIV16 =         004H;  (*0x04 *)
	RA8875_PWM_CLK_DIV32 =         005H;  (*0x05 *)
	RA8875_PWM_CLK_DIV64 =         006H;  (*0x06 *)
	RA8875_PWM_CLK_DIV128 =        007H;  (*0x07 *)
	RA8875_PWM_CLK_DIV256 =        008H;  (*0x08 *)
	RA8875_PWM_CLK_DIV512 =        009H;  (*0x09 *)
	RA8875_PWM_CLK_DIV1024 =       00AH;  (*0x0A *)
	RA8875_PWM_CLK_DIV2048 =       00BH;  (*0x0B *)
	RA8875_PWM_CLK_DIV4096 =       00CH;  (*0x0C *)
	RA8875_PWM_CLK_DIV8192 =       00DH;  (*0x0D *)
	RA8875_PWM_CLK_DIV16384 =      00EH;  (*0x0E *)
	RA8875_PWM_CLK_DIV32768 =      00FH;  (*0x0F *) 
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            Memory Clear
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/* Memory Clear Control Register     [0x8E]
----- Bit 7 (Memory Clear Function)
0: End or Stop (if read this bit and it's 0, clear completed)
1: Start the memory clear function
----- Bit 6 (Memory Clear Area Setting)
0: Clear the full window (ref. RA8875_HDWR,RA8875_VDHR0,RA8875_VDHR0ì1)
1: Clear the active window
----- Bit 5,4,3,2,1,0 (na)  *)

 RA8875_MCLR =             	  08EH;  (*0x8E//Memory Clear Control Register *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            Drawing Control Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_DCR =                   090H;  (*0x90//Draw Line/Circle/Square Control Register *)
	RA8875_DCR_LINESQUTRI_START =  080H;  (*0x80 *)
	RA8875_DCR_LINESQUTRI_STOP =   000H;  (*0x00 *)
	RA8875_DCR_LINESQUTRI_STATUS = 080H;  (*0x80 *)
	RA8875_DCR_CIRCLE_START =      040H;  (*0x40 *)
	RA8875_DCR_CIRCLE_STATUS =     040H;  (*0x40 *)
	RA8875_DCR_CIRCLE_STOP =       000H;  (*0x00 *)
	RA8875_DCR_FILL =              020H;  (*0x20 *)
	RA8875_DCR_NOFILL =            000H;  (*0x00 *)
	RA8875_DCR_DRAWLINE =          000H;  (*0x00 *)
	RA8875_DCR_DRAWTRIANGLE =      001H;  (*0x01 *)
	RA8875_DCR_DRAWSQUARE =        010H;  (*0x10 *)

 RA8875_DLHSR0 =         		  091H;  (*0x91//Draw Line/Square Horizontal Start Address Register0 *)
 RA8875_DLHSR1 =        		  092H;  (*0x92//Draw Line/Square Horizontal Start Address Register1 *)
 RA8875_DLVSR0 =        		  093H;  (*0x93//Draw Line/Square Vertical Start Address Register0 *)
 RA8875_DLVSR1 =         		  094H;  (*0x94//Draw Line/Square Vertical Start Address Register1 *)
 RA8875_DLHER0 =        		  095H;  (*0x95//Draw Line/Square Horizontal End Address Register0 *)
 RA8875_DLHER1 =         		  096H;  (*0x96//Draw Line/Square Horizontal End Address Register1 *)
 RA8875_DLVER0 =        		  097H;  (*0x97//Draw Line/Square Vertical End Address Register0 *)
 RA8875_DLVER1 =        		  098H;  (*0x98//Draw Line/Square Vertical End Address Register0 *)

 RA8875_DCHR0 =        		    099H;  (*0x99//Draw Circle Center Horizontal Address Register0 *)
 RA8875_DCHR1 =          		  09AH;  (*0x9A//Draw Circle Center Horizontal Address Register1 *)
 RA8875_DCVR0 =        		    09BH;  (*0x9B//Draw Circle Center Vertical Address Register0 *)
 RA8875_DCVR1 =        		    09CH;  (*0x9C//Draw Circle Center Vertical Address Register1 *)
 RA8875_DCRR  =       		    09DH;  (*0x9D//Draw Circle Radius Register *)

 RA8875_ELLIPSE =             0A0H;  (*0xA0//Draw Ellipse/Ellipse Curve/Circle Square Control Register *)
 RA8875_ELLIPSE_STATUS =      080H;  (*0x80 *)

 RA8875_ELL_A0 =        		  0A1H;  (*0xA1//Draw Ellipse/Circle Square Long axis Setting Register0 *)
 RA8875_ELL_A1 =         		  0A2H;  (*0xA2//Draw Ellipse/Circle Square Long axis Setting Register1 *)
 RA8875_ELL_B0 =        		  0A3H;  (*0xA3//Draw Ellipse/Circle Square Short axis Setting Register0 *)
 RA8875_ELL_B1 =         		  0A4H;  (*0xA4//Draw Ellipse/Circle Square Short axis Setting Register1 *)

 RA8875_DEHR0 =         		  0A5H;  (*0xA5//Draw Ellipse/Circle Square Center Horizontal Address Register0 *)
 RA8875_DEHR1 =        		    0A6H;  (*0xA6//Draw Ellipse/Circle Square Center Horizontal Address Register1 *)
 RA8875_DEVR0 =        		    0A7H;  (*0xA7//Draw Ellipse/Circle Square Center Vertical Address Register0 *)
 RA8875_DEVR1 =         		  0A8H;  (*0xA8//Draw Ellipse/Circle Square Center Vertical Address Register1 *)

 RA8875_DTPH0 =        		    0A9H;  (*0xA9//Draw Triangle Point 2 Horizontal Address Register0 *)
 RA8875_DTPH1 =        		    0AAH;  (*0xAA//Draw Triangle Point 2 Horizontal Address Register1 *)
 RA8875_DTPV0 =         		  0ABH;  (*0xAB//Draw Triangle Point 2 Vertical Address Register0 *)
 RA8875_DTPV1 =        		    0ACH;  (*0xAC//Draw Triangle Point 2 Vertical Address Register1 *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            DMA REGISTERS
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)

 RA8875_SSAR0 =				        0B0H;  (*0xB0//Source Starting Address REG 0 *)
 RA8875_SSAR1	=			          0B1H;  (*0xB1//Source Starting Address REG 1 *)
 RA8875_SSAR2	= 			        0B2H;  (*0xB2//Source Starting Address REG 2 *)
 (*RA8875_????	=				        0B3H;  0xB3//??????????? *)

 RA8875_DTNR0	=			          0B4H;  (*0xB4//Block Width REG 0(BWR0) / DMA Transfer Number REG 0 *)
 RA8875_BWR1	=				        0B5H;  (*0xB5//Block Width REG 1 *)
 RA8875_DTNR1	=			          0B6H;  (*0xB6//Block Height REG 0(BHR0) /DMA Transfer Number REG 1 *)
 RA8875_BHR1	=				        0B7H;  (*0xB7//Block Height REG 1 *)
 RA8875_DTNR2	= 			        0B8H;  (*0xB8//Source Picture Width REG 0(SPWR0) / DMA Transfer Number REG 2 *)
 RA8875_SPWR1	=			          0B9H;  (*0xB9//Source Picture Width REG 1 *)
 RA8875_DMACR	=			          0BFH;  (*0xBF//DMA Configuration REG *)

(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            GPIO
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)
 RA8875_GPIOX =           	  0C7H;  (*0xC7 *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                            KEY-MATRIX
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)
 RA8875_KSCR1 =            	  0C0H;  (*0xC0 //Key-Scan Control Register 1 (KSCR1) *)
 RA8875_KSCR2 =           	  0C1H;  (*0xC1 //Key-Scan Controller Register 2 (KSCR2) *)
 RA8875_KSDR0 =           	  0C2H;  (*0xC2 //Key-Scan Data Register (KSDR0) *)
 RA8875_KSDR1 =           	  0C3H;  (*0xC3 //Key-Scan Data Register (KSDR1) *)
 RA8875_KSDR2 =           	  0C4H;  (*0xC4 //Key-Scan Data Register (KSDR2) *)
(*
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                         Interrupt Control Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)
 RA8875_INTC1 =           	  0F0H;  (*0xF0//Interrupt Control Register1 *)
 RA8875_INTC2 =           	  0F1H;  (*0xF1//Interrupt Control Register2 *)
	RA8875_INTCx_KEY =        	  010H;
	RA8875_INTCx_DMA =       	    008H;  (*0x08 *)
	RA8875_INTCx_TP  =       	    004H;  (*0x04 *)
	RA8875_INTCx_BTE =       	    002H;  (*0x02 *)
  
 A0 = {6};    (* P0.6  = mbed P8 *)
 CS = {18};   (* P0.18 = mbed P11 *)
 Reset = {8}; (* P0.8  = mbed P6 *)
  
  
PROCEDURE SendData*(data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0SET, A0);(* mBed P8*)
    SYSTEM.PUT(MCU.FIO0CLR, CS);(* mBed P11*)
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS);
  END SendData;
  
   
  PROCEDURE SendCommand*(data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0CLR, A0);(* mBed P8*)
    SYSTEM.PUT(MCU.FIO0CLR, CS);(* mBed P11*)
    SPI.SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS)
  END SendCommand;
  
  PROCEDURE SendComData*(comm, data: INTEGER);
  BEGIN
    SYSTEM.PUT(MCU.FIO0CLR, A0);
    SYSTEM.PUT(MCU.FIO0SET, CS);
    SendCommand(comm);
    SendData(data);
    SYSTEM.PUT(MCU.FIO0SET, CS)
  END SendComData; 
  
  PROCEDURE ConfigureSPI1Pins;
  VAR
    s: SET;
  BEGIN 
    (* SPI1 *)
    (* Setup    SCK1, SSEL1, MISO1, MOSI1, no SSEL *)
    (* PS0 bits 15:14 12:13  17:16, 19:18 := 10B *) 
    SYSTEM.GET(MCU.PINSEL0, s);
    s := s + {15, 17, 19} - {14, 16, 18};
    SYSTEM.PUT(MCU.PINSEL0, s)
  END ConfigureSPI1Pins;

  PROCEDURE ConfigureGPIOPins;
  VAR
    s: SET;
  BEGIN
    (* P0.6, P0.8 are GPIO ports *)
    SYSTEM.GET(MCU.PINSEL0, s);
    s := s - {12, 13, 16, 17};
    SYSTEM.PUT(MCU.PINSEL0, s);

    (* P0.18 is GPIO port *)
    SYSTEM.GET(MCU.PINSEL1, s);
    s := s - {4, 5};
    SYSTEM.PUT(MCU.PINSEL1, s);

    (* P0.6, 0.8 and 0.18 are outputs *)
    SYSTEM.GET(MCU.FIO0DIR, s);
    SYSTEM.PUT(MCU.FIO0DIR, s + A0 + CS + Reset)
  END ConfigureGPIOPins;

  PROCEDURE Init*;
  CONST
    nBits = 8;      
    
  BEGIN    
    
    SPI.Init(SPI.SPI1, nBits, ConfigureSPI1Pins);
    
    ConfigureGPIOPins();   
    
    SYSTEM.PUT(MCU.FIO0CLR, A0); 
    SYSTEM.PUT(MCU.FIO0SET, CS); 
    SYSTEM.PUT(MCU.FIO0CLR, Reset); 
    Timer.uSecDelay(100);
    SYSTEM.PUT(MCU.FIO0SET, Reset); 
    Timer.uSecDelay(100);
    
    (* backlight_command (0). To do *)
    
    (*// System Config Register (SYSR) *)
    SendComData(RA8875_SYSR, 00CH); (*  16-bpp (65K colors) color depth, 8-bit interface *)
    (*// Pixel Clock Setting Register (PCSR) *)
    SendComData(RA8875_PCSR, RA8875_GCVP0); (*// PDAT on PCLK falling edge, PCLK = 4 x System Clock *)
    Timer.uSecDelay(100);
    
    (*// Horizontal Settings  *)
    SendComData(RA8875_HDWR, (DISPLAY_WIDTH/8 - 1));
    SendCommand(081H);    
    SendComData(05DH, 080H); 
    SendComData(0A8H, 03FH);    
    SendComData(3D0H, 000H);
    SendComData(040H, 000H); 
    SendComData(08DH, 014H);  
    SendCommand(140H);
    SendComData(020H, 000H); 
    SendCommand(000H);    
    SendComData(0A0H, 001H);    
    SendCommand(08CH);    
    SendComData(0ADH, 012H);      
    SendComData(081H, 0FCH);    
    
  END Init;

END RA8875_b.
