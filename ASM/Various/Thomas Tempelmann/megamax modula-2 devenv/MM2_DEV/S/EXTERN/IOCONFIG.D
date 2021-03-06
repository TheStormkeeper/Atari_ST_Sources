DEFINITION MODULE IOConfig;


FROM SysTypes IMPORT CHARSET;

VAR

(*
 * F�r die Funktionen aus InOut, Text und NumberIO:
 * ------------------------------------------------
 *)

  EchoCR: BOOLEAN;
   (*
    * Wirken auf ReadLine, ReadToken (und deren Aufrufer) bei Eingabe
    * von der Tastatur (Console):
    *
    * TRUE:  Nach Eingabe der Return- oder Enter-Taste wird WriteLn
    *        aufgerufen, um den Cursor in die n�chste Zeile zu setzen.
    * FALSE: Eingabe von Return oder Enter bewirkt kein Echo dieser Taste.
    *)

  ReadStringByLine: BOOLEAN;
   (*
    * TRUE:  ReadString ruft ReadLine, Read ruft ReadDirChar
    * FALSE: ReadString ruft ReadToken, Read ruft ReadBufChar
    *
    * Diese Variable ist f�r die NumberIO-Funktionen nicht relevant.
    *)

  LengthOfBufferedLine: CARDINAL;
   (*
    * Hiermit kann die Maximall�nge der Eingabezeile f. ReadToken
    * bestimmt werden.
    *
    * Standardwert: 80, Maximalwert: 255
    *)

  Separators: CHARSET;
   (*
    * Trennzeichen f�r ReadToken und die Read-Funktionen aus NumberIO.
    * Beim Lesen werden f�hrende Trennzeichen ignoriert (ausgefiltert),
    * soda� ein mit ReadToken gelesener String nie ein Trennzeichen
    * enthalten kann.
    *
    * Standardwert:  CHARSET {0C..' '};
    *   (das sind alle Control-Zeichen sowie das Leerzeichen)
    *)

(*
 * Nur f�r InOut-Modul:
 * --------------------
 *)

  WriteLnAfterReadString: BOOLEAN;
    (*
     * TRUE: InOut.ReadString ruft nach der Eingabe WriteLn auf.
     *   (jedoch nicht InOut.ReadLine!)
     * Ist ebenfalls 'EchoCR' TRUE, wird selbstverst�ndlich
     * insgesamt nur einmal WriteLn aufgerufen.
     *)


PROCEDURE Wirth;
  (*
   * EchoCR:= FALSE;
   * ReadStringByLine:= FALSE;
   * WriteLnAfterReadString:= FALSE;
   *
   *  SPC
   *)

PROCEDURE Terminal;
  (*
   * EchoCR:= TRUE;
   * ReadStringByLine:= TRUE;
   * WriteLnAfterReadString:= FALSE; (ist egal, da 'EchoCR' schon TRUE ist)
   *
   *  TopSpeed
   *)

PROCEDURE Megamax;
  (*
   * EchoCR:= FALSE;
   * ReadStringByLine:= TRUE;
   * WriteLnAfterReadString:= TRUE;
   *
   *  Megamax
   *)

END IOConfig.
