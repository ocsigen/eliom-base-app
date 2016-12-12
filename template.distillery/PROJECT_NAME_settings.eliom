(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)


(* Create a button to update set the email as main email *)
let%shared update_main_email_button email =
  let open Eliom_content.Html in
  let button =
    D.button ~a:[D.a_class ["button"]] [D.pcdata [%i18n S.set_as_main_email ~capitalize:true]]
  in
  ignore [%client (Lwt.async (fun () ->
    Lwt_js_events.clicks
      (Eliom_content.Html.To_dom.of_element ~%button)
      (fun _ _ ->
        let%lwt () = Os_current_user.update_main_email ~%email in
        Eliom_client.change_page
          ~service:%%%MODULE_NAME%%%_services.settings_service () ()
      )
  ) : unit) ];
  button

(* Create a button to remove the email from the database *)
let%shared delete_email_button email =
  let open Eliom_content.Html in
  let button = D.button
      ~a:[D.a_class ["button" ; "os-remove-email-button"]]
      [%%%MODULE_NAME%%%_icons.D.trash ()]
  in
  ignore [%client (Lwt.async (fun () ->
    Lwt_js_events.clicks
      (Eliom_content.Html.To_dom.of_element ~%button)
      (fun _ _ ->
        let%lwt () = Os_current_user.remove_email_from_user ~%email in
        Eliom_client.change_page
          ~service:%%%MODULE_NAME%%%_services.settings_service () ()
      )
  ) : unit) ];
  button

(* Return a list of buttons to update or to remove the email depending on the
   email properties
*)
let%shared buttons_of_email is_main_email is_validated email =
  if is_main_email
  then []
  else if is_validated
  then [update_main_email_button email ; delete_email_button email]
  else [delete_email_button email]

(* Return a list of labels describing the email properties. *)
let%shared labels_of_email is_main_email is_validated =
  let open Eliom_content.Html.F in
  let valid_label =
    span ~a: [a_class ["os-settings-label" ; "os-validated-email"]] [
     pcdata @@
      if is_validated
      then [%i18n S.validated ~capitalize:true]
      else [%i18n S.waiting_confirmation ~capitalize:true]
  ] in
  if is_main_email
  then [ span ~a:[a_class ["os-settings-label" ; "os-main-email"]]
           [%i18n main_email ~capitalize:true]
       ; valid_label]
  else [ valid_label ]

(* Return a list element for the given email *)
let%shared li_of_email main_email (email, is_validated) =
  let open Eliom_content.Html.D in
  let is_main_email = (main_email = email) in
  let labels = labels_of_email is_main_email is_validated in
  let buttons = buttons_of_email is_main_email is_validated email in
  let email = span ~a:[a_class ["os-settings-email"]] [pcdata email] in
  Lwt.return @@ li (email :: labels @ buttons)

let%shared ul_of_emails (main_email, emails) =
  let open Eliom_content.Html.F in
  let li_of_email = li_of_email main_email in
  let%lwt li_list = Lwt_list.map_s li_of_email emails in
  Lwt.return @@ ul li_list

(* Return a list with information about emails *)
let%server get_emails () =
  let myid = Os_current_user.get_current_userid () in
  let%lwt main_email = Os_db.User.email_of_userid myid in
  let%lwt emails = Os_db.User.emails_of_userid myid in
  let%lwt emails = Lwt_list.map_s
      (fun email ->
         let%lwt v = Os_current_user.is_email_validated email in
         Lwt.return (email, v))
      emails
  in
  Lwt.return (main_email, emails)

(* Return a list with information about emails *)
let%client get_emails =
  ~%(Eliom_client.server_function [%derive.json : unit]
       (Os_session.connected_wrapper get_emails))

let%shared settings_content () =
  let%lwt emails = get_emails () in
  let%lwt emails = ul_of_emails emails in
  Lwt.return @@
  Eliom_content.Html.D.(
    [
      div ~a:[a_class ["os-settings"]] [
        p [%i18n change_password ~capitalize:true];
        Os_user_view.password_form ~service:Os_services.set_password_service ();
        br ();
        Os_user_view.upload_pic_link
          ~submit:([a_class ["button"]], [pcdata "Submit"])
          %%%MODULE_NAME%%%_services.upload_user_avatar_service;
        br ();
        Os_user_view.reset_tips_link ();
        br ();
        p [%i18n link_new_email];
        Os_user_view.generic_email_form ~service:Os_services.add_email_service ();
        p [%i18n currently_registered_emails];
        div ~a:[a_class ["os-emails"]] [emails]
      ]
    ]
  )
