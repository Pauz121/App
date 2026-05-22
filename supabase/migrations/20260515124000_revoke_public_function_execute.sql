revoke execute on function public.create_trainer_account(text, text, text, text, text) from public;
revoke execute on function public.generate_client_invite_code(uuid, uuid) from public;
revoke execute on function public.redeem_client_invite_code(text, text) from public;
revoke execute on function public.get_current_trainer_id() from public;
revoke execute on function public.get_current_client_id() from public;
revoke execute on function public.trainer_can_add_client(uuid) from public;
revoke execute on function public.is_current_trainer(uuid) from public;
revoke execute on function public.is_super_admin() from public;
revoke execute on function public.trainer_owns_client(uuid, uuid) from public;

grant execute on function public.create_trainer_account(text, text, text, text, text) to authenticated;
grant execute on function public.generate_client_invite_code(uuid, uuid) to authenticated;
grant execute on function public.redeem_client_invite_code(text, text) to authenticated;
grant execute on function public.get_current_trainer_id() to authenticated;
grant execute on function public.get_current_client_id() to authenticated;
grant execute on function public.trainer_can_add_client(uuid) to authenticated;
