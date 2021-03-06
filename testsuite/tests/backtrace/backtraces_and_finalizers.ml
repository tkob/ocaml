(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*                   Mark Shinwell, Jane Street Europe                 *)
(*                                                                     *)
(*  Copyright 2014 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

let () = Printexc.record_backtrace true

let finaliser _ = try raise Exit with _ -> ()

let create () =
  let x = ref () in
  Gc.finalise finaliser x;
  x

let f () = raise Exit

let () =
  let minor_size = (Gc.get ()).Gc.minor_heap_size in
  for i = 1 to 100 do
    Gc.minor ();
    try
      ignore (create () : unit ref);
      f ()
    with _ ->
      for i = 1 to minor_size / 2 - 1 do
        ignore (ref ())
      done;
      ignore (Printexc.get_backtrace () : string)
  done;
  Printf.printf "ok\n"
