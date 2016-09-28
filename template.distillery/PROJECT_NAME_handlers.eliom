(* This file was generated by Ocsigen-start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

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
  let%lwt () = Os_user.update_avatar avatar myid in
  match old_avatar with
  | None -> Lwt.return ()
  | Some old_avatar ->
    Lwt_unix.unlink (Filename.concat avatar_dir old_avatar )

(* Set personal data *)
let%server set_personal_data_handler' =
  Os_session.connected_fun Os_handlers.set_personal_data_handler'

let%client set_personal_data_handler' =
  let set_personal_data_rpc =
    ~%(Eliom_client.server_function
         [%derive.json : ((string * string) * (string * string))]
       @@ set_personal_data_handler' ())
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

(* Activation *)
let%server activation_handler =
  Os_handlers.activation_handler

let%client activation_handler =
  let activation_handler_rpc =
    ~%(Eliom_client.server_function [%derive.json : string]
       @@ fun akey -> activation_handler akey ())
  in
  fun akey () -> activation_handler_rpc akey

(* Set password *)
let%server set_password_handler' =
  Os_session.connected_fun Os_handlers.set_password_handler'

let%client set_password_handler' () =
  Os_handlers.set_password_rpc

(* Preregister *)
let%server preregister_handler' =
  Os_handlers.preregister_handler'

let%client preregister_handler' =
  let preregister_rpc =
    ~%(Eliom_client.server_function [%derive.json : string]
       @@ preregister_handler' ())
  in
  fun () -> preregister_rpc


let%shared main_service_handler userid_o () () = Eliom_content.Html.F.(
 %%%MODULE_NAME%%%_container.page userid_o (
   [
     p [em [pcdata "Ocsigen-start: Put app content here."]]
   ]
 )
)

let%shared about_handler userid_o () () = Eliom_content.Html.F.(
 %%%MODULE_NAME%%%_container.page userid_o [
   div [
     p [pcdata "This template provides a skeleton \
                for an Ocsigen application."];
     br ();
     p [pcdata "Feel free to modify the generated code and use it \
                or redistribute it as you want."]
   ]
 ]
)

let%shared settings_handler userid_o () () =
  let%lwt user = %%%MODULE_NAME%%%_container.get_user_data userid_o in
  let%lwt content = match user with
    | Some user ->
      %%%MODULE_NAME%%%_content.Settings.settings_content user
    | None -> Lwt.return []
  in
  %%%MODULE_NAME%%%_container.page userid_o content
