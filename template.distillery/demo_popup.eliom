(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(** popup button demo ********************************************************)

[%%shared
  open Eliom_content.Html
  open Eliom_content.Html.D
]

let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-popup"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let%client service = ~%service

let%shared name = "Popup Button"

let%shared page () =
  let button =
    D.Form.input
      ~a:[a_class ["button"]]
      ~input_type:`Submit
      ~value:"Click for a popup!"
      (Form.string)
  in
  ignore
    [%client
      (Lwt.async (fun () ->
         Lwt_js_events.clicks
           (To_dom.of_element ~%button)
           (fun _ _ ->
              let%lwt _ =
                Ot_popup.popup
                  ~close_button:[pcdata "close"]
                  (fun _ -> Lwt.return @@ p [pcdata "Popup message"])
              in
              Lwt.return ()))
       : _)
    ];
  Lwt.return
    [
      p [pcdata "Here is a button showing a simple popup window when \
                 clicked:"];
      p [button]
    ]
