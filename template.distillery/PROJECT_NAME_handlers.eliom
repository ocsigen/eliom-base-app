(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

[%%shared
  open Eliom_content.Html.F
]

(* Upload user avatar *)
let upload_user_avatar_handler myid () ((), (cropping, photo)) =
  let avatar_dir =
    List.fold_left Filename.concat
      (List.hd !%%%MODULE_NAME%%%_config.avatar_dir)
      (List.tl !%%%MODULE_NAME%%%_config.avatar_dir) in
  let%lwt avatar =
    Os_uploader.record_image avatar_dir ~ratio:1. ?cropping photo in
  let%lwt user = Os_user.user_of_userid myid in
  let old_avatar = Os_user.avatar_of_user user in
  let%lwt () = Os_user.update_avatar ~userid:myid ~avatar in
  match old_avatar with
  | None -> Lwt.return ()
  | Some old_avatar ->
    Lwt_unix.unlink (Filename.concat avatar_dir old_avatar )

(* Set personal data *)
let%server set_personal_data_handler =
  Os_session.connected_fun Os_handlers.set_personal_data_handler

let%client set_personal_data_handler =
  let set_personal_data_rpc =
    ~%(Eliom_client.server_function
         [%derive.json : ((string * string) * (string * string))]
       @@ set_personal_data_handler ())
  in
  fun () -> set_personal_data_rpc

(* Forgot password *)
let%server forgot_password_handler =
  Os_handlers.forgot_password_handler Os_services.main_service

let%client forgot_password_handler =
  let forgot_password_rpc =
    ~%(Eliom_client.server_function [%derive.json : string]
       @@ forgot_password_handler ())
  in
  fun () -> forgot_password_rpc

(* Action links are links created to perform an action.
   They are used for example to send activation links by email,
   or links to reset a password.
   You can create your own action links and define their behaviour here.
*)
let%shared action_link_handler myid_o akey () =
  (* We try first the default actions (activation link, reset password) *)
  try%lwt Os_handlers.action_link_handler myid_o akey () with
  | Os_handlers.No_such_resource
  | Os_handlers.Invalid_action_key _ ->
    Os_msg.msg ~level:`Err ~onload:true
      "Invalid action key, please ask for a new one.";
    Eliom_registration.(appl_self_redirect Action.send) ()
  | e ->
    let%lwt (email, phantom_user) =
      match e with
      | Os_handlers.Account_already_activated_unconnected
          {Os_types.Action_link_key.userid = _; email; validity = _;
           action = _; data = _; autoconnect = _} ->
        Lwt.return (email, false)
      | Os_handlers.Custom_action_link
          ({Os_types.Action_link_key.userid = _; email; validity = _;
            action = _; data = _; autoconnect = _},
           phantom_user) ->
        Lwt.return (email, phantom_user)
      | _ ->
        Lwt.fail e
    in
    (* Define here your custom action links.
       If phantom_user is true, it means the link has been created for
       an email that does not correspond to an existing user.
       By default, we just display a sign up form or phantom users,
       a login form for others.
       You don't need to modify this if you are not using custom action links.

       Perhaps personalise the intended behaviour for when you meet
       [Account_already_activated_unconnected].
    *)
    if myid_o = None (* Not currently connected, and no autoconnect *)
    then
      if phantom_user
      then
        let page = [ div ~a:[ a_class ["login-signup-box"] ]
                       [ Os_view.sign_up_form ~email () ] ]
        in
        %%%MODULE_NAME%%%_base.App.send (%%%MODULE_NAME%%%_page.make_page page)
      else
        let page = [ div ~a:[ a_class ["login-signup-box"] ]
                       [ Os_view.connect_form ~email () ] ]
        in
        %%%MODULE_NAME%%%_base.App.send (%%%MODULE_NAME%%%_page.make_page page)
    else (*VVV In that case we must do something more complex.
            Check whether myid = userid and ask the user
            what he wants to do. *)
      Eliom_registration.
        (appl_self_redirect
           Redirection.send
           (Redirection Eliom_service.reload_action))

(* Set password *)
let%server set_password_handler =
  Os_session.connected_fun Os_handlers.set_password_handler

let%client set_password_handler () =
  Os_handlers.set_password_rpc

(* Preregister *)
let%server preregister_handler =
  Os_handlers.preregister_handler

let%client preregister_handler =
  let preregister_rpc =
    ~%(Eliom_client.server_function [%derive.json : string]
       @@ preregister_handler ())
  in
  fun () -> preregister_rpc

let%shared main_service_handler myid_o () () = Eliom_content.Html.F.(
  %%%MODULE_NAME%%%_container.page
    ~a:[ a_class ["os-page-main"] ]
    myid_o (
    [ p [em [pcdata "Ocsigen Start: Put app content here."]] ]
  )
)

let%shared about_handler myid_o () () = Eliom_content.Html.F.(
  %%%MODULE_NAME%%%_container.page
    ~a:[ a_class ["os-page-about"] ]
    myid_o
    [ div
        [ p [pcdata "This template provides a skeleton \
                     for an Ocsigen application."]
        ; br ()
        ; p [pcdata "Feel free to modify the generated code and use it \
                     or redistribute it as you want."]
        ]
    ]
)

let%shared settings_handler myid_o () () =
  let%lwt user = %%%MODULE_NAME%%%_container.get_user_data myid_o in
  let%lwt content = match user with
    | Some user -> %%%MODULE_NAME%%%_settings.settings_content user
    | None -> Lwt.return []
  in
  %%%MODULE_NAME%%%_container.page myid_o content
