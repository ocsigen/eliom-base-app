(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

[%%shared
  open Eliom_content.Html.D
]

(* drawer / demo welcome page ***********************************************)

let%shared handler myid_o () () =
  %%%MODULE_NAME%%%_container.page
    ~a:[ a_class ["os-page-demo"] ]
    myid_o
    [ p [pcdata "This page contains some demos for some widgets \
                 from ocsigen-toolkit."]
    ; p [pcdata "The different demos are accessible through the drawer \
                 menu. To open it click the top left button on the screen."]
    ; p [pcdata "Feel free to modify the generated code and use it \
                 or redistribute it as you want."]
    ]


let%shared () =
  let registerDemo (module D : Demo_tools.Page) =
    %%%MODULE_NAME%%%_base.App.register
      ~service:D.service
      (%%%MODULE_NAME%%%_page.Opt.connected_page @@ fun myid_o () () ->
        let%lwt p = D.page () in
        %%%MODULE_NAME%%%_container.page
          ~a:[a_class [D.page_class]]
          myid_o p)
  in
  List.iter registerDemo Demo_tools.demos;
  %%%MODULE_NAME%%%_base.App.register
    ~service:%%%MODULE_NAME%%%_services.demo_service
    (%%%MODULE_NAME%%%_page.Opt.connected_page handler)
