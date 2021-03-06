MODULE InitPathList;

(*
 * Dieses Modul zeigt, wie Pfadlisten f�r 'Paths.SearchFile'
 * initialisiert werden.
 *)

FROM Storage IMPORT ALLOCATE;

IMPORT Lists, PathCtrl, Strings, MOSGlobals;


VAR     paths: PathCtrl.PathList; (* diese Var. k�nnte exportiert werden *)

        ok, err: BOOLEAN;

PROCEDURE append (REF name: ARRAY OF CHAR);

  VAR  onePath: POINTER TO MOSGlobals.PathStr;

  BEGIN
    NEW (onePath);
    Strings.Assign (name, onePath^, ok);
    Lists.AppendEntry (paths, onePath, err)
  END append;

BEGIN
  Lists.CreateList (paths, err);

  (* -- Hier k�nnen die gew�nschten Pfade zugewiesen werden. -- *)
  (*    Beispiele:                                              *)
  append ('*\');   (* HomePath (siehe PathEnv-Modul)  *)
  append ('.\');   (* der jeweils aktuelle Pfad  *)
  append ('C:');   (* "C:\" (das "\" f�gt SearchFile autom. an *)
  append ('?');    (* Aufruf des File-Selectors (s. Module PathEnv & Paths) *)

  (*
   * Nun kann SearchFile, wie im Paths-Modul beschrieben, mit 'paths'
   * als Pfadliste aufgerufen werden.
   *)
END InitPathList.
